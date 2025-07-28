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

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case noData
    case decodingError(Error)
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
        completion: @escaping (Result<APIResponse<T>, Error>) -> Void
    ) {
        do {
            let request = try endpoint.makeURLRequest(baseURL: environment.baseURL)
            
            let task = session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.failure(APIError.invalidResponse))
                        return
                    }
                    
                    let statusCode = httpResponse.statusCode
                    if (200...299).contains(statusCode) {
                        if acceptEmptyResponseCodes.contains(statusCode) || data?.isEmpty ?? true {
                            completion(.success(APIResponse(statusCode: statusCode, model: nil)))
                            return
                        }
                        
                        guard let data = data else {
                            completion(.failure(APIError.noData))
                            return
                        }
                        
                        do {
                            let decoded = try JSONDecoder().decode(T.self, from: data)
                            completion(.success(APIResponse(statusCode: statusCode, model: decoded)))
                        } catch {
                            completion(.failure(APIError.decodingError(error)))
                        }
                        
                    } else {
                        completion(.failure(APIError.httpError(statusCode: statusCode, data: data)))
                    }
                }
            }
            task.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}
