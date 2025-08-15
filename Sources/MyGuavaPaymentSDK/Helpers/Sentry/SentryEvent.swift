//
//  SentryEvent.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 11.08.2025.
//

enum SentryEvent: Error {
    case apiError(APIError)
    case unknown(Error)

    var localizedDescription: String {
        switch self {
        case .apiError(let error):
            "Unknown API error: \(error.localizedDescription)"
        case .unknown(let error):
            "Unknown event occurred: \(error.localizedDescription)"
        }
    }
}
