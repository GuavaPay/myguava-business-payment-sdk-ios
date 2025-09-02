//
//  SentryErrorEvent.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 11.08.2025.
//

import Guavapay3DS2

protocol SentryError: Error, CustomStringConvertible {
    var localizedDescription: String { get }
    var debugDescription: String { get }
    var description: String { get }
}

extension SentryError {
    var description: String {
        localizedDescription
    }

    var debugDescription: String {
        localizedDescription
    }
}

enum DataError: SentryError {
    case didNotGetOrder
    case fetchOrderStatusFailed
    case invalidChallengeRequirements
    case x5cCertificatesNotFound

    var localizedDescription: String {
        switch self {
        case .didNotGetOrder:
            "Failed to get order"
        case .fetchOrderStatusFailed:
            "WebSocket and polling failed to get order status"
        case .invalidChallengeRequirements:
            "Challenge data is invalid"
        case .x5cCertificatesNotFound:
            "List of x5c certificates is empty"
        }
    }
}

enum NetworkError: SentryError {
    case connectionFailed
    case clientCode(code: Int, message: String)
    case serverCode(code: Int, message: String)
    case unexpectedSuccessCode(Int)
    case invalidURL
    case invalidResponse
    case unknownError(code: Int, error: Error?)

    var localizedDescription: String {
        switch self {
        case .connectionFailed:
            "Connection failed"
        case let .clientCode(code, message):
            "\(message) -> \(code)"
        case let .serverCode(code, message):
            "\(message) -> \(code)"
        case .unexpectedSuccessCode(let code):
            "Unexpected success status code: \(code)"
        case .invalidURL:
            "Invalid request URL"
        case .invalidResponse:
            "Invalid response body"
        case .unknownError(let code, let error):
            "Unknown network error: \(code) \(error)"
        }
    }
}

enum WebSocketError: SentryError {
    case connectionFailed
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case unknownError(error: Error?)

    var localizedDescription: String {
        switch self {
        case .connectionFailed:
            "Connection failed"
        case .invalidURL:
            "Invalid request URL"
        case .invalidResponse:
            "Invalid response body"
        case .decodingError(let error):
            "Decoding error: \(error)"
        case .unknownError(let error):
            "Unknown WebSocket error: \(error)"
        }
    }
}

enum EncodingSentryError: SentryError {
    case packedSdkData
    case requestBody

    var localizedDescription: String {
        switch self {
        case .packedSdkData:
            "Encoding error: packedSdkData"
        case .requestBody:
            "Encoding error: HTTP request body"
        }
    }
}

enum DecodingSentryError: SentryError {
    case getOrderResponse
    case unknownError(Error)

    var localizedDescription: String {
        switch self {
        case .getOrderResponse:
            "Decoding error: GET order response"
        case .unknownError(let error):
            "Unknown decoding error: \(error)"
        }
    }
}

enum ApplePaySentryError: SentryError {
    case deviceNotSupported
    case unexpectedStatusCode(String?)

    var localizedDescription: String {
        switch self {
        case .deviceNotSupported:
            "Apple Pay error: Device Not Supported"
        case .unexpectedStatusCode(let message):
            "Apple Pay error: Unexpected status code - \(message ?? "")"
        }
    }
}

enum ThreeDSError: SentryError {
    case protocolError(GPTDSProtocolErrorEvent)
    case runtimeError(GPTDSRuntimeErrorEvent)

    var localizedDescription: String {
        switch self {
        case .protocolError(let error):
            "3DS Protocol error: \(error.localizedDescription)"
        case .runtimeError(let error):
            "3DS Runtime error: \(error.localizedDescription)"
        }
    }
}

extension GPTDSProtocolErrorEvent {
    open override var debugDescription: String {
        localizedDescription
    }

    var localizedDescription: String {
        let sdkId = "sdkTransID - \(sdkTransactionIdentifier)"
        let transId = "threeDSServerTransID - \(errorMessage.threeDSServerTransID ?? "null")"
        let message = "errorMessage - \(errorMessage.errorDescription)"
        return "3DS Protocol error: \(sdkId); \(transId); \(message)"
    }
}

extension GPTDSRuntimeErrorEvent {
    open override var debugDescription: String {
        localizedDescription
    }

    var localizedDescription: String {
        "3DS Runtime error: code - \(errorCode); message - \(errorMessage)"
    }
}
