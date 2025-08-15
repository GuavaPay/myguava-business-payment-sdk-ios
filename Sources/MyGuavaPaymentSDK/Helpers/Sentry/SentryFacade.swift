//
//  SentryFacade.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 08.08.2025.
//

import Sentry

final class SentryFacade {
    static let shared = SentryFacade()

    private var needAssertOnErrors = false

    func startSession(environment: GPEnvironment, assertOnErrors: Bool) {
        needAssertOnErrors = assertOnErrors

        SentrySDK.start { [weak self] options in
            guard let self else { return }

            options.dsn = Constants.dsnAddress
            options.debug = false

            options.environment = getEnvironment(from: environment)

            options.sendDefaultPii = false

            // Disable default reporting of "HTTPClientError"
            // since we use .capture(apiError:) inside APIClient
            options.failedRequestStatusCodes = []
        }

        SentrySDK.configureScope { scope in
            scope.setTag(value: SDK.version, key: "myguava_psdk_version")
        }
    }

    func capture(error: SentryError) {
        SentrySDK.capture(error: error)

        guard needAssertOnErrors else { return }
        assertionFailure(error.localizedDescription)
    }

    func capture(
        apiError: APIError,
        source: APIError.Source = .httpRequest,
        headers: [AnyHashable: Any]? = nil
    ) {
        let sentryError: SentryError = switch source {
        case .httpRequest:
            switch apiError {
            case let .httpError(statusCode, data):
                switch statusCode {
                case 400...499:
                    NetworkError.clientCode(statusCode)
                case 500...599:
                    NetworkError.serverCode(statusCode)
                default:
                    NetworkError.unknownError(code: statusCode, error: nil)
                }

            case .invalidURL:
                NetworkError.invalidURL
            case .invalidResponse, .noData:
                NetworkError.invalidResponse
            case .connectionFailed:
                NetworkError.connectionFailed
            case .decodingError(let error):
                DecodingSentryError.unknownError(error)
            case .unknown(let error):
                NetworkError.unknownError(code: -1, error: error)
            }

        case .webSocket:
            switch apiError {
            case .invalidURL:
                WebSocketError.invalidURL
            case .invalidResponse, .noData, .httpError:
                WebSocketError.invalidResponse
            case .connectionFailed:
                WebSocketError.connectionFailed
            case .decodingError(let error):
                DecodingSentryError.unknownError(error)
            case .unknown(let error):
                WebSocketError.unknownError(error: error)
            }
        }

        SentrySDK.capture(error: sentryError) { [weak self] scope in
            scope.setTag(
                value: self?.getRequestId(headers: headers) ?? "null",
                key: Constants.requestIdHeaderKey
            )
        }

        guard needAssertOnErrors else { return }
        assertionFailure(sentryError.localizedDescription)
    }

    func capture(warning: SentryEvent) {
        var warningEvent = Event(level: .warning)
        warningEvent.message = SentryMessage(formatted: "Unknown API error")
        warningEvent.error = APIError.unknown(warning)

        SentrySDK.capture(event: warningEvent)
    }

    func capture(message: String) {
        SentrySDK.capture(message: message)
    }

    private func getEnvironment(from environment: GPEnvironment) -> String {
        environment.rawValue
    }

    private func getRequestId(headers: [AnyHashable: Any]?) -> String? {
        let typeCastedHeaders = headers as? [String: Any]
        return typeCastedHeaders?[Constants.requestIdHeaderKey] as? String
    }
}

extension SentryFacade {
    enum Constants {
        static let dsnAddress = "https://1288b07e644cb33c9df799d59dfd1c50@o4507129772310528.ingest.de.sentry.io/4509802652434512"
        static let requestIdHeaderKey = "request-id"
    }
}
