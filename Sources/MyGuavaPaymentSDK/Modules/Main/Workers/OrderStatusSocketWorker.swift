//
//  OrderStatusSocketWorker.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 02.07.2025.
//

import Foundation

protocol OrderStatusSocketWorkerProtocol {
    var isConnected: Bool { get }

    func startListening(onStatusUpdate: @escaping (Result<PaymentOrderStatusEvent, Error>) -> Void)
    func stopListening()
}

final class OrderStatusSocketWorker: OrderStatusSocketWorkerProtocol {

    var isConnected: Bool {
        webSocketClient.isConnected
    }

    private let webSocketClient: WebSocketClient

    init(
        webSocketClient: WebSocketClient
    ) {
        self.webSocketClient = webSocketClient
    }

    func startListening(
        onStatusUpdate: @escaping (Result<PaymentOrderStatusEvent, Error>) -> Void
    ) {
        webSocketClient.startListening(
            onEvent: { rawEvent in
                do {
                    guard let data = rawEvent.data(using: .utf8) else {
                        print("[OrderListener] Invalid response: \(rawEvent)")

                        SentryFacade.shared.capture(error: WebSocketError.invalidResponse)
                        onStatusUpdate(.failure(APIError.invalidResponse))
                        return
                    }

                    let event = try JSONDecoder().decode(PaymentOrderStatusEvent.self, from: data)
                    onStatusUpdate(.success(event))
                } catch {
                    print("[OrderListener] Failed to decode PaymentOrderStatusEvent: \(rawEvent)")

                    SentryFacade.shared.capture(error: WebSocketError.decodingError(error))
                    onStatusUpdate(.failure(APIError.decodingError(error)))
                }
            },
            onFailure: { error in
                SentryFacade.shared.capture(apiError: error, source: .webSocket)
                onStatusUpdate(.failure(error))
            }
        )
    }

    func stopListening() {
        webSocketClient.stopListening()
    }
}
