//
//  OrderStatusWorkerDelegateSpy.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

@testable import MyGuavaPaymentSDK

final class OrderStatusWorkerDelegateSpy: OrderStatusWorkerDelegate {
    private(set) var receivedResults: [Result<PaymentOrderStatusEvent, OrderStatusError>] = []
    func didGetStatusUpdate(_ result: Result<PaymentOrderStatusEvent, OrderStatusError>) {
        receivedResults.append(result)
    }
}
