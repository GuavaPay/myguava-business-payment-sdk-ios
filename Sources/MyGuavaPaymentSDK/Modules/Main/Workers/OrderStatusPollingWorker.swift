//
//  OrderStatusPollingWorker.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 03.07.2025.
//

import Foundation

protocol OrderStatusPoolingWorkerProtocol {
    func startPolling(
        needFastPolling: Bool,
        completion: @escaping (Result<PaymentOrderStatusEvent, OrderStatusError>) -> Void
    )
    func cancel()
}

final class OrderStatusPollingWorker: OrderStatusPoolingWorkerProtocol {

    private let orderService: OrderService
    private let orderId: String

    private let pollInterval: TimeInterval = 10
    private let retryInterval: TimeInterval = 2
    private let retryCount = 5

    private var currentRetryCount = 0

    private var statusHandler: ((Result<PaymentOrderStatusEvent, OrderStatusError>) -> Void)?
    private var currentWorkItem: DispatchWorkItem?

    init(
        orderService: OrderService,
        orderId: String
    ) {
        self.orderService = orderService
        self.orderId = orderId
    }

    /// Start polling loop
    /// - Parameters:
    ///   - needFastPolling: Use short polling interval if required
    func startPolling(
        needFastPolling: Bool = false,
        completion: @escaping (Result<PaymentOrderStatusEvent, OrderStatusError>) -> Void
    ) {
        statusHandler = completion
        poll(delay: needFastPolling ? retryInterval : pollInterval)
    }

    func cancel() {
        currentWorkItem?.cancel()
        currentWorkItem = nil
    }
}

// MARK: - Private

private extension OrderStatusPollingWorker {
    func submitFailure() {
        cancel()
        statusHandler?(.failure(.unknown(APIError.connectionFailed)))
    }

    func scheduleNext(delay: TimeInterval) {
        cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.poll(delay: delay)
        }
        currentWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    func poll(delay: TimeInterval) {
        orderService.getOrder(byId: orderId) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                // If order status "CREATED" continue polling
                guard response.model?.order?.status != .created else {
                    scheduleNext(delay: delay)
                    return
                }

                guard let model = response.model,
                      let order = model.order else {
                    SentryFacade.shared.capture(error: DecodingSentryError.getOrderResponse)
                    statusHandler?(.failure(.unknown(APIError.invalidResponse)))
                    return
                }

                statusHandler?(.success(
                    PaymentOrderStatusEvent(
                        event: .unknown,
                        order: order,
                        payment: model.payment,
                        refunds: model.refunds,
                        paymentRequirements: model.paymentRequirements
                    )
                ))

            case .failure:
                currentRetryCount += 1
                if currentRetryCount < retryCount {
                    // In case of failure retry within `retryInterval` instead of `pollInterval`
                    scheduleNext(delay: retryInterval)
                } else {
                    // Return error if polling and websocket failed to connect
                    submitFailure()
                }
            }
        }
    }
}
