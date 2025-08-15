//
//  OrderService.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 19.06.2025.
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

struct OrderService {
    private let api: APIClient

    init(api: APIClient = .shared) {
        self.api = api
    }

    func getOrder(byId orderId: String, completion: @escaping (Result<APIResponse<GetOrder>, APIError>) -> Void) {
        let endpoint = GetOrderEndpoint(orderId: orderId, queryItems: [
            .init(name: "merchant-included", value: "true"),
            .init(name: "transactions-included", value: "true")
        ])
        api.performRequest(endpoint: endpoint, completion: completion)
    }

    func executePayment(
        orderId: String,
        body: [String: Any],
        completion: @escaping (Result<APIResponse<ExecutePaymentRequirements>, APIError>) -> Void
    ) {
        api.performRequest(
            endpoint: ExecutePaymentEndpoint(orderId: orderId, body: body),
            responseModel: ExecutePaymentRequirements.self,
            acceptEmptyResponseCodes: [200],
            completion: completion
        )
    }

    func continuePayment(
        orderId: String,
        body: [String: Any],
        completion: @escaping (Result<APIResponse<ExecutePaymentRequirements>, APIError>) -> Void
    ) {
        api.performRequest(
            endpoint: ContinuePaymentEndpoint(orderId: orderId, body: body),
            responseModel: ExecutePaymentRequirements.self,
            acceptEmptyResponseCodes: [200, 204],
            completion: completion
        )
    }
}
