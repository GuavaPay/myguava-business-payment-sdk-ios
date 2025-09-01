//
//  OrderEndpoint.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

import Foundation

struct GetOrderEndpoint: APIEndpoint {
    let path: String
    let method: HTTPMethod = .get
    var queryItems: [URLQueryItem]? = nil
    let body: [String: Any]? = nil

    init(orderId: String, queryItems: [URLQueryItem]) {
        self.path = "order/\(orderId)"
        self.queryItems = queryItems
    }
}

struct ExecutePaymentEndpoint: APIEndpoint {
    let path: String
    let method: HTTPMethod = .post
    let queryItems: [URLQueryItem]? = nil
    let body: [String: Any]?

    init(orderId: String, body: [String: Any]) {
        self.path = "order/\(orderId)/payment/execute"
        self.body = body
    }
}

struct ContinuePaymentEndpoint: APIEndpoint {
    let path: String
    let method: HTTPMethod = .post
    let queryItems: [URLQueryItem]? = nil
    let body: [String: Any]?

    init(orderId: String, body: [String: Any]) {
        self.path = "order/\(orderId)/payment/continue"
        self.body = body
    }
}
