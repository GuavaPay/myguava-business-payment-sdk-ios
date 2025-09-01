//
//  ApplePayEndpoint.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

import Foundation

struct ApplePayEndpoint: APIEndpoint {
    let path = "applepay/context"
    let method: HTTPMethod = .get
    let queryItems: [URLQueryItem]? = nil
    let body: [String: Any]? = nil
}
