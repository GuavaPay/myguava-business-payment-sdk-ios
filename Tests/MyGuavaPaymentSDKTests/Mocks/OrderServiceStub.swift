//
//  OrderServiceStub.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

import Foundation
@testable import MyGuavaPaymentSDK

final class OrderServiceStub: OrderService {
    /// Controls what to do on each `getOrder` invocation
    enum Mode {
        // do not call completion (simulate hanging request)
        case noop
        // immediately fail every time
        case alwaysFail(APIError)
    }

    var mode: Mode = .noop

    private(set) var requestIds: [String] = []

    func executePayment(
        orderId: String,
        body: [String : Any],
        completion: @escaping (Result<APIResponse<ExecutePaymentRequirements>, APIError>) -> Void
    ) {
        requestIds.append(orderId)

        switch mode {
        case .noop:
            return
        case .alwaysFail(let error):
            completion(.failure(error))
        }
    }

    func continuePayment(
        orderId: String,
        body: [String : Any],
        completion: @escaping (Result<APIResponse<ExecutePaymentRequirements>, APIError>) -> Void
    ) {
        requestIds.append(orderId)

        switch mode {
        case .noop:
            return
        case .alwaysFail(let error):
            completion(.failure(error))
        }
    }

    func getOrder(
        byId id: String,
        completion: @escaping (Result<APIResponse<GetOrder>, APIError>) -> Void
    ) {
        requestIds.append(id)

        switch mode {
        case .noop:
            return
        case .alwaysFail(let error):
            completion(.failure(error))
        }
    }
}
