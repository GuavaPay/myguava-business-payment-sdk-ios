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
    private var capturedErrors: Set<String> = []

    private var paymentDetailsContext = [String: Any]()

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
            scope.setTag(value: SDK.version, key: Tags.psdkVersionKey)
        }
    }

    func addTag(_ key: String, value: String?) {
        SentrySDK.configureScope { scope in
            scope.setTag(value: value ?? "null", key: key)
        }
    }

    func addContext(_ key: String, value: Any) {
        paymentDetailsContext[key] = value

        SentrySDK.configureScope { [weak self] scope in
            guard let self else { return }

            scope.setContext(value: paymentDetailsContext, key: Context.rootKey)
        }
    }

    func capture(error: SentryError) {
        captureIfNeeded(error: error, headers: nil)
    }

    func capture(
        apiError: APIError,
        source: APIError.Source = .httpRequest,
        headers: [AnyHashable: Any]? = nil
    ) {
        let sentryError = getSentryError(from: apiError, source: source)
        captureIfNeeded(error: sentryError, headers: headers)
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

    // MARK: - Private Methods

    private func getEnvironment(from environment: GPEnvironment) -> String {
        environment.rawValue
    }

    private func getRequestId(headers: [AnyHashable: Any]?) -> String? {
        let typeCastedHeaders = headers as? [String: Any]
        return typeCastedHeaders?[Constants.requestIdHeaderKey] as? String
    }

    private func captureIfNeeded(error: SentryError, headers: [AnyHashable: Any]?) {
        guard shouldCapture(error) else {
            return
        }

        capturedErrors.insert(error.localizedDescription)
        SentrySDK.capture(error: error) { [weak self] scope in
            scope.setTag(
                value: self?.getRequestId(headers: headers) ?? "null",
                key: Tags.requestIdKey
            )
        }

        guard needAssertOnErrors else { return }
        assertionFailure(error.localizedDescription)
    }

    private func shouldCapture(_ error: SentryError) -> Bool {
        guard Constants.singleReportErrors.contains(error.localizedDescription) else {
            return true
        }

        return !capturedErrors.contains(error.localizedDescription)
    }

    private func getSentryError(from apiError: APIError, source: APIError.Source) -> SentryError {
        switch source {
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
    }
}

extension SentryFacade {
    enum Tags {
        static let requestIdKey = "request_id"
        static let psdkVersionKey = "myguava_psdk_version"
    }

    enum Context {
        static let rootKey = "Payment Details"
        static let paymentMethodKey = "Payment Method"
        static let merchantNameKey = "Merchant Name"
        static let deviceDataKey = "Device Data"
        static let orderIdKey = "Order ID"
    }

    private enum Constants {
        static let dsnAddress = "https://1288b07e644cb33c9df799d59dfd1c50@o4507129772310528.ingest.de.sentry.io/4509802652434512"
        static let requestIdHeaderKey = "request-id"

        static let singleReportErrors: Set<String> = [
            WebSocketError.connectionFailed.localizedDescription
        ]
    }
}
