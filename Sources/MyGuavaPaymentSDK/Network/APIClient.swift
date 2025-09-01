//
//  APIClient.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 12.06.2025.
//

import Foundation

public enum GPEnvironment: String {
    case sandbox

    var baseURL: String {
        switch self {
        case .sandbox:
            return "https://sandbox-pgw.myguava.com"
        }
    }
}

public enum APIError: Error {
    enum Source {
        case httpRequest
        case webSocket
    }

    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case noData
    case connectionFailed
    case decodingError(Error)
    case unknown(Error)

    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .invalidResponse:
            "Invalid response"
        case let .httpError(code, _):
            "HTTP error \(code)"
        case .noData:
            "No data"
        case .connectionFailed:
            "Connection failed"
        case .decodingError(let error):
            "Decoding error: \(error)"
        case .unknown(let error):
            "Unknown error: \(error)"
        }
    }
}

struct APIResponse<T: Decodable> {
    let statusCode: Int
    let model: T?
}

final class APIClient {

    static let shared = APIClient()

    private var environment: GPEnvironment = .sandbox
    private var session: URLSession = URLSession(configuration: .default)

    private init() { }

    func configure(environment: GPEnvironment = .sandbox, token: String) {
        self.environment = environment

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        self.session = URLSession(configuration: configuration)
    }

    func performRequest<T: Decodable>(
        endpoint: APIEndpoint,
        responseModel: T.Type = T.self,
        acceptEmptyResponseCodes: Set<Int> = [204],
        allowedErrorCodes: Set<Int> = [],
        completion: @escaping (Result<APIResponse<T>, APIError>) -> Void
    ) {
        do {
            let request = try endpoint.makeURLRequest(baseURL: environment.baseURL)

            let task = session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error {
                        let error = APIError.unknown(error)
                        SentryFacade.shared.capture(apiError: error)
                        completion(.failure(error))
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        let error = APIError.invalidResponse
                        SentryFacade.shared.capture(apiError: error)
                        completion(.failure(error))
                        return
                    }

                    let statusCode = httpResponse.statusCode

                    switch statusCode {
                    case 200...299:
                        if acceptEmptyResponseCodes.contains(statusCode) || data?.isEmpty ?? true {
                            completion(.success(APIResponse(statusCode: statusCode, model: nil)))
                            return
                        }

                        guard let data = data else {
                            let error = APIError.noData
                            SentryFacade.shared.capture(apiError: error, headers: httpResponse.allHeaderFields)
                            completion(.failure(error))
                            return
                        }

                        do {
                            let decoded = try JSONDecoder().decode(T.self, from: data)
                            completion(.success(APIResponse(statusCode: statusCode, model: decoded)))
                        } catch {
                            let error = APIError.decodingError(error)
                            SentryFacade.shared.capture(apiError: error, headers: httpResponse.allHeaderFields)
                            completion(.failure(error))
                        }

                    default:
                        let error = APIError.httpError(statusCode: statusCode, data: data)
                        if !allowedErrorCodes.contains(statusCode) {
                            SentryFacade.shared.capture(apiError: error, headers: httpResponse.allHeaderFields)
                        }
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        } catch {
            if let error = error as? APIError {
                SentryFacade.shared.capture(apiError: error)
            }
            DispatchQueue.main.async {
                completion(.failure(.unknown(error)))
            }
        }
    }
}
