//
//  OrderStatusWorker.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 29.07.2025.
//

import Foundation

protocol OrderStatusWorkerDelegate: AnyObject {
    func didGetStatusUpdate(_ result: Result<PaymentOrderStatusEvent, OrderStatusError>)
}

final class OrderStatusWorker {
    weak var delegate: OrderStatusWorkerDelegate?

    private let pollingWorker: OrderStatusPoolingWorkerProtocol
    private let socketWorker: OrderStatusSocketWorkerProtocol
    private let socketReconnectInterval: TimeInterval = 30

    private var socketReconnectWorkItem: DispatchWorkItem?

    init(pollingWorker: OrderStatusPoolingWorkerProtocol, socketWorker: OrderStatusSocketWorkerProtocol) {
        self.pollingWorker = pollingWorker
        self.socketWorker = socketWorker
    }

    func fetchOrderStatus() {
        fetchWithSocket()
    }

    /// When socket is connected just continue.
    /// If it is not connected - restart polling with shorter delay interval
    func fetchOrderStatusNow() {
        guard !socketWorker.isConnected else { return }

        cancelPolling()
        fetchWithPolling(needFastPolling: true)
    }

    func stopFetching() {
        pollingWorker.cancel()
        socketWorker.stopListening()
    }

    private func fetchWithSocket() {
        socketWorker.startListening { [weak self] result in
            switch result {
            case .success(let event):
                self?.delegate?.didGetStatusUpdate(.success(event))
            case .failure:
                self?.scheduleSocketReconnect()
                self?.fetchWithPolling()
            }
        }
    }

    private func fetchWithPolling(needFastPolling: Bool = false) {
        pollingWorker.startPolling(needFastPolling: needFastPolling) { [weak self] result in
            switch result {
            case .success(let event):
                self?.delegate?.didGetStatusUpdate(.success(event))
            case .failure(let error):
                self?.cancelSocketReconnect()
                self?.delegate?.didGetStatusUpdate(.failure(error))
            }
        }
    }

    private func scheduleSocketReconnect() {
        let workItem = DispatchWorkItem { [weak self] in
            self?.cancelPolling()
            self?.fetchWithSocket()
        }
        socketReconnectWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + socketReconnectInterval, execute: workItem)
    }

    private func cancelSocketReconnect() {
        socketReconnectWorkItem?.cancel()
        socketReconnectWorkItem = nil
    }

    private func cancelPolling() {
        pollingWorker.cancel()
    }
}
