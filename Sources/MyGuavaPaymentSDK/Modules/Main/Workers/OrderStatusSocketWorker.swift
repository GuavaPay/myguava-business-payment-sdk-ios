//
//  OrderStatusSocketWorker.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 02.07.2025.
//

import Foundation

final class OrderStatusSocketWorker {
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
                guard
                    let data = rawEvent.data(using: .utf8),
                    let event = try? JSONDecoder().decode(PaymentOrderStatusEvent.self, from: data)
                else {
                    print("[OrderListener] Failed to decode PaymentOrderStatusEvent: \(rawEvent)")
                    return
                }
                onStatusUpdate(.success(event))
            },
            onFailure: { error in
                onStatusUpdate(.failure(error))
            }
        )
    }
    
    func stopListening() {
        webSocketClient.stopListening()
    }
}


