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

struct PreCreatePaymentEndpoint: APIEndpoint {
    let path: String
    let method: HTTPMethod = .put
    let queryItems: [URLQueryItem]? = nil
    let body: [String: Any]?

    init(orderId: String, body: [String: Any]) {
        self.path = "order/\(orderId)/payment"
        self.body = body
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

struct OrderService {
    private let api: APIClient
    
    init(api: APIClient = .shared) {
        self.api = api
    }
    
    func getOrder(byId orderId: String, completion: @escaping (Result<APIResponse<GetOrder>, Error>) -> Void) {
        let endpoint = GetOrderEndpoint(orderId: orderId, queryItems: [
            .init(name: "merchant-included", value: "true"),
            .init(name: "transactions-included", value: "true")
        ])
        api.performRequest(endpoint: endpoint, completion: completion)
    }

    func preCreatePayment(
        orderId: String,
        body: [String: Any],
        completion: @escaping (Result<APIResponse<PreCreatePayment>, Error>) -> Void
    ) {
        api.performRequest(
            endpoint: PreCreatePaymentEndpoint(orderId: orderId, body: body),
            responseModel: PreCreatePayment.self,
            acceptEmptyResponseCodes: [204],
            completion: completion
        )
    }

    func executePayment(
        orderId: String,
        body: [String: Any],
        completion: @escaping (Result<APIResponse<ExecutePaymentRequirements>, Error>) -> Void
    ) {
        api.performRequest(
            endpoint: ExecutePaymentEndpoint(orderId: orderId, body: body),
            responseModel: ExecutePaymentRequirements.self,
            acceptEmptyResponseCodes: [200],
            completion: completion
        )
    }
}
