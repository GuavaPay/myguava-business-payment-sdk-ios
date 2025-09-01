//
//  OrderService.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 19.06.2025.
//

import Foundation

protocol OrderService {
    func getOrder(byId orderId: String, completion: @escaping (Result<APIResponse<GetOrder>, APIError>) -> Void)

    func executePayment(
        orderId: String,
        body: [String: Any],
        completion: @escaping (Result<APIResponse<ExecutePaymentRequirements>, APIError>) -> Void
    )

    func continuePayment(
        orderId: String,
        body: [String: Any],
        completion: @escaping (Result<APIResponse<ExecutePaymentRequirements>, APIError>) -> Void
    )
}

struct OrderServiceImpl: OrderService {
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
