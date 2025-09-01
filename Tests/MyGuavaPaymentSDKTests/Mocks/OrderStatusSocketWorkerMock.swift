//
//  OrderStatusSocketWorkerMock.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

@testable import MyGuavaPaymentSDK

final class OrderStatusSocketWorkerMock: OrderStatusSocketWorkerProtocol {
    var isConnected: Bool = false

    var startListeningCallCount = 0
    var stopListeningCallCount = 0
    var startListeningCompletion: ((Result<PaymentOrderStatusEvent, Error>) -> Void)?

    func startListening(onStatusUpdate: @escaping (Result<PaymentOrderStatusEvent, Error>) -> Void) {
        startListeningCallCount += 1
        startListeningCompletion = onStatusUpdate
    }

    func stopListening() {
        stopListeningCallCount += 1
    }
}
