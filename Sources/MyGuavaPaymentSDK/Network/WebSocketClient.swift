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
            return "wss://cardium-cpg-preprod.guavapay.com/ws"
        }
    }
}

final class WebSocketClient: NSObject, URLSessionWebSocketDelegate {
    private var session: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?
    private var onEvent: ((String) -> Void)?
    private let environment: WSEnvironment
    private let token: String
    private let endpoint: String
    private let queryItems: [URLQueryItem]?
    private var reconnectTimer: Timer?
    private var pingTimer: Timer?
    
    private let pingInterval: TimeInterval = 10
    private let reconnectInterval: TimeInterval = 5
    
    init(
        environment: WSEnvironment,
        token: String,
        endpoint: String,
        queryItems: [URLQueryItem]? = nil
    ) {
        self.environment = environment
        self.token = token
        self.endpoint = endpoint
        self.queryItems = queryItems
    }
    
    func startListening(onEvent: @escaping (String) -> Void) {
        self.onEvent = onEvent
        
        var urlString = environment.baseURL + endpoint

        // !!!: Don't user URLComponent because it replaces wss to https
        if let queryItems = queryItems, !queryItems.isEmpty {
            let query = queryItems.map { "\($0.name)=\($0.value ?? "")" }
                .joined(separator: "&")
            urlString += "?" + query
        }

        guard let url = URL(string: urlString) else {
            print("[WebSocketClient] Invalid WS URL: \(urlString)")
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

private extension WebSocketClient {
    func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.onEvent?(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.onEvent?(text)
                    }
                default:
                    break
                }
                self.listen() // continue listening
            case .failure(let error):
                print("[WebSocketClient] Receive failed: \(error)")
                self.scheduleReconnect()
            }
        }
    }
    
    func startPing() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    func sendPing() {
        webSocketTask?.sendPing { [weak self] error in
            if let error {
                print("[WebSocketClient] Ping error: \(error)")
                self?.scheduleReconnect()
            } else {
                print("[WebSocketClient] Ping successful")
            }
        }
    }
    
    func scheduleReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectInterval, repeats: false) { [weak self] _ in
            print("[WebSocketClient] Trying to reconnect...")
            self?.startListening(onEvent: self?.onEvent ?? { _ in })
        }
    }
}

extension WebSocketClient: URLSessionDelegate {
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
