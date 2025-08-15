//
//  Event+Type.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 11.08.2025.
//

import Sentry

extension Event {
    static let sentryHttpClientError = "HTTPClientError"

    static let psdkName = "MyGuavaPaymentSDK"
    static let psdkDataError = psdkName + String(describing: DataError.self)
    static let psdkEncodingError = psdkName + String(describing: EncodingSentryError.self)
    static let psdkDecodingError = psdkName + String(describing: DecodingSentryError.self)

    static let httpClientErrorTypes: [String] = [
        sentryHttpClientError,
        psdkDataError,
        psdkEncodingError,
        psdkDecodingError
    ]

    var isHttpClientError: Bool {
        Self.httpClientErrorTypes.contains(exceptions?.first?.type ?? "")
    }

    var httpHeaders: [String: Any]? {
        let response = context?["response"] as? [String: Any]
        return response?["headers"] as? [String: Any]
    }
}
