//
//  WebSocketClientStub.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

import Foundation
@testable import MyGuavaPaymentSDK

final class WebSocketClientStub: NSObject, WebSocketClient {
        var isConnected: Bool = false

        private(set) var startListeningCalled = false
        private(set) var stopListeningCalled = false

        private var onEvent: ((String) -> Void)?
        private var onFailure: ((APIError) -> Void)?

        func startListening(onEvent: @escaping (String) -> Void, onFailure: ((APIError) -> Void)?) {
            startListeningCalled = true
            self.onEvent = onEvent
            self.onFailure = onFailure
        }

        func stopListening() { stopListeningCalled = true }

        // Test helpers
        func emit(event: String) { onEvent?(event) }
        func fail(with error: APIError) { onFailure?(error) }
    }
