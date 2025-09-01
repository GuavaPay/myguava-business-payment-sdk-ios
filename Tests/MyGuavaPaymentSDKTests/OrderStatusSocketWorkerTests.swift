//
//  OrderStatusWorkerTests.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

import XCTest
@testable import MyGuavaPaymentSDK

final class OrderStatusSocketWorkerTests: XCTestCase {
    private var socketClientStub: WebSocketClientStub!
    private var sut: OrderStatusSocketWorker!

    override func setUp() {
        super.setUp()
        socketClientStub = WebSocketClientStub()
        sut = OrderStatusSocketWorker(
            webSocketClient: socketClientStub
        )
    }

    override func tearDown() {
        sut = nil
        socketClientStub = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_isConnected_reflectsClient() {
        socketClientStub.isConnected = false
        XCTAssertFalse(sut.isConnected)
        socketClientStub.isConnected = true
        XCTAssertTrue(sut.isConnected)
    }

    func test_startListening_bindsClientCallbacks() {
        let exp = expectation(description: "onFailure propagated")
        sut.startListening { result in
            if case let .failure(error as APIError) = result {
                switch error {
                case .connectionFailed:
                    exp.fulfill()
                default:
                    XCTFail("Expected decodingError, got: \(error)")
                }
            }
        }

        XCTAssertTrue(socketClientStub.startListeningCalled)
        socketClientStub.fail(with: .connectionFailed)
        wait(for: [exp], timeout: 1.0)
    }

    func test_startListening_decodingError_propagatesAsAPIErrorDecoding() {
        let exp = expectation(description: "decoding error propagated")
        sut.startListening { result in
            if case let .failure(error as APIError) = result {
                switch error {
                case .decodingError:
                    exp.fulfill()
                default:
                    XCTFail("Expected decodingError, got: \(error)")
                }
            }
        }
        // Send JSON that will not decode into PaymentOrderStatusEvent
        socketClientStub.emit(event: "{}")
        wait(for: [exp], timeout: 1.0)
    }

    func test_stopListening_delegatesToClient() {
        sut.stopListening()
        XCTAssertTrue(socketClientStub.stopListeningCalled)
    }
}
