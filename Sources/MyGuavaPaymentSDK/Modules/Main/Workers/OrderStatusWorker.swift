//
//  OrderStatusWorker.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 03.07.2025.
//

import Foundation

final class OrderStatusWorker {
    
    private let orderService: OrderService
    private var currentWorkItem: DispatchWorkItem?
    
    init(orderService: OrderService) {
        self.orderService = orderService
    }
    
    func startPolling(
        orderId: String,
        delay: TimeInterval,
        repeatCount: Int,
        completion: @escaping (Result<GetOrder, OrderStatusError>) -> Void
    ) {
        poll(
            orderId: orderId,
            delay: delay,
            repeatCount: repeatCount,
            completion: completion
        )
    }
    
    func cancel() {
        currentWorkItem?.cancel()
        currentWorkItem = nil
    }
}

// MARK: - Private

private extension OrderStatusWorker {
    
    func poll(
        orderId: String,
        delay: TimeInterval,
        repeatCount: Int,
        completion: @escaping (Result<GetOrder, OrderStatusError>) -> Void
    ) {
        guard repeatCount > 0 else {
            completion(.failure(OrderStatusError.timeout))
            return
        }
        
        orderService.getOrder(byId: orderId) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                guard let model = response.model,
                        let order = model.order else {
                    completion(.failure(.unknown(nil)))
                    return
                }
                
                switch order.status {
                case .paid, .declined, .cancelled, .expired:
                    completion(.success(model))
                case .created:
                    self.scheduleNext(
                        orderId: orderId,
                        delay: delay,
                        repeatCount: repeatCount - 1,
                        completion: completion
                    )
                default:
                    completion(.failure(.unknown(nil)))
                }
                
            case .failure:
                self.scheduleNext(
                    orderId: orderId,
                    delay: delay,
                    repeatCount: repeatCount - 1,
                    completion: completion
                )
            }
        }
    }
    
    func scheduleNext(
        orderId: String,
        delay: TimeInterval,
        repeatCount: Int,
        completion: @escaping (Result<GetOrder, OrderStatusError>) -> Void
    ) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.poll(
                orderId: orderId,
                delay: delay,
                repeatCount: repeatCount,
                completion: completion
            )
        }
        currentWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
