//
//  WebSocketClient.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 02.07.2025.
//

import Foundation

public enum WSEnvironment: String {
    case sandbox

    var baseURL: String {
        switch self {
        case .sandbox:
            return "wss://sandbox-pgw.myguava.com/ws"
        }
    }
}

protocol WebSocketClient: URLSessionWebSocketDelegate {
    var isConnected: Bool { get }

    func startListening(
        onEvent: @escaping (String) -> Void,
        onFailure: ((APIError) -> Void)?
    )

    func stopListening()
}

final class WebSocketClientImpl: NSObject, WebSocketClient {

    var isConnected: Bool {
        pingTimer != nil
    }

    private var session: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?
    private let environment: WSEnvironment
    private let token: String
    private let endpoint: String
    private let queryItems: [URLQueryItem]?
    private var reconnectTimer: Timer?
    private var pingTimer: Timer?

    private let connectionRetryInterval: TimeInterval = 0.15
    private let connectionRetryCount = 3
    private var currentConnectionRetryCount = 0

    private let pingRetryInterval: TimeInterval = 2.0
    private let pingRetryCount = 3
    private var currentPingRetryCount = 0

    private var onEvent: ((String) -> Void)?
    private var onFailure: ((APIError) -> Void)?

    init(
        environment: WSEnvironment,
        token: String,
        orderId: String,
        queryItems: [URLQueryItem]? = [
            .init(name: "payment-requirements-included", value: "true"),
            .init(name: "transactions-included", value: "true")
        ]
    ) {
        self.environment = environment
        self.token = token
        self.endpoint = "/order/\(orderId)"
        self.queryItems = queryItems
    }

    func startListening(
        onEvent: @escaping (String) -> Void,
        onFailure: ((APIError) -> Void)? = nil) {

            self.onEvent = onEvent
            self.onFailure = onFailure

            var urlString = environment.baseURL + endpoint

            // !!!: Don't user URLComponent because it replaces wss to https
            if let queryItems = queryItems, !queryItems.isEmpty {
                let query = queryItems.map { "\($0.name)=\($0.value ?? "")" }
                    .joined(separator: "&")
                urlString += "?" + query
            }

            guard let url = URL(string: urlString) else {
                print("[WebSocketClient] Invalid WS URL: \(urlString)")

                let error = APIError.invalidURL
                SentryFacade.shared.capture(apiError: error, source: .webSocket)
                onFailure?(error)
                return
            }

            let config = URLSessionConfiguration.default
            config.httpAdditionalHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]

            session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
            webSocketTask = session?.webSocketTask(with: url)
            webSocketTask?.resume()

            listen()
            startPing()
        }

    func stopListening() {
        pingTimer?.invalidate()
        reconnectTimer?.invalidate()

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        session?.invalidateAndCancel()

        webSocketTask = nil
        session = nil
    }
}

// MARK: - Private

private extension WebSocketClientImpl {
    func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                currentConnectionRetryCount = 0

                switch message {
                case .string(let text):
                    onEvent?(text)
                case .data(let data):
                    guard let text = String(data: data, encoding: .utf8) else {
                        return
                    }
                    onEvent?(text)
                @unknown default:
                    assertionFailure("Unexpectected message type")
                }
                listen()

            case .failure(let error):

                // Track connection retry count and fallback to onFailure after threshold
                currentConnectionRetryCount += 1
                print("[WebSocketClient] Connection error: \(error)")
                print("[WebSocketClient] Connection retry (\(currentConnectionRetryCount)/\(connectionRetryCount))")

                if currentConnectionRetryCount >= connectionRetryCount {
                    print("[WebSocketClient] Connection retry failed")

                    let error = APIError.connectionFailed
                    fallback(with: error)
                } else {
                    scheduleReconnect()
                }
            }
        }
    }

    func startPing() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: pingRetryInterval, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }

    func stopPing() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    func sendPing() {
        webSocketTask?.sendPing { [weak self] error in
            guard let error else {
                print("[WebSocketClient] Ping successful")
                return
            }

            guard let self else { return }

            // Track ping retry count and fallback to onFailure after threshold
            currentPingRetryCount += 1
            print("[WebSocketClient] Ping error: \(error)")
            print("[WebSocketClient] Ping retry (\(currentPingRetryCount)/\(pingRetryCount))")

            if currentPingRetryCount >= pingRetryCount {
                print("[WebSocketClient] Ping retry failed")

                let error = APIError.connectionFailed
                SentryFacade.shared.capture(apiError: error, source: .webSocket)
                fallback(with: error)
            } else {
                scheduleReconnect()
            }
        }
    }

    func scheduleReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: connectionRetryInterval, repeats: false) { [weak self] _ in
            print("[WebSocketClient] Attempting reconnect #\(self?.currentConnectionRetryCount ?? 0)")
            self?.startListening(onEvent: self?.onEvent ?? { _ in }, onFailure: self?.onFailure)
        }
    }

    func fallback(with error: APIError) {
        currentConnectionRetryCount = 0
        currentPingRetryCount = 0
        stopPing()
        onFailure?(error)
    }
}

extension WebSocketClientImpl: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let trust = challenge.protectionSpace.serverTrust
        let credential = trust.map { URLCredential(trust: $0) }
        completionHandler(.useCredential, credential)
    }
}
