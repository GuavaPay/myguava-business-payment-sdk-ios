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
    private let environment: WSEnvironment
    private let token: String
    private let endpoint: String
    private let queryItems: [URLQueryItem]?

    init(
        environment: WSEnvironment = .sandbox,
        orderId: String,
        token: String,
        queryItems: [URLQueryItem]? = nil
    ) {
        self.environment = environment
        self.token = token
        self.endpoint = "/order/\(orderId)"
        self.queryItems = queryItems
        self.webSocketClient = WebSocketClient(
            environment: environment,
            token: token,
            endpoint: endpoint,
            queryItems: queryItems
        )
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


