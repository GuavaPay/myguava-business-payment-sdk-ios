//
//  OrderStatusPollingWorkerMock.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

@testable import MyGuavaPaymentSDK

final class OrderStatusPollingWorkerMock: OrderStatusPoolingWorkerProtocol {
    var startPollingCalled = false
    var startPolling_needFast = false
    var cancelCalled = false
    var startPollingCompletion: ((Result<PaymentOrderStatusEvent, OrderStatusError>) -> Void)?

    func startPolling(needFastPolling: Bool, completion: @escaping (Result<PaymentOrderStatusEvent, OrderStatusError>) -> Void) {
        startPollingCalled = true
        startPolling_needFast = needFastPolling
        startPollingCompletion = completion
    }

    func cancel() {
        cancelCalled = true
    }
}
