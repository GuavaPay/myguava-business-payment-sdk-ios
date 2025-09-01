//
//  OrderStatusWorkerTests.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

import XCTest
@testable import MyGuavaPaymentSDK

final class OrderStatusPollingWorkerTests: XCTestCase {
    private var serviceStub: OrderServiceStub!
    private var sut: OrderStatusPollingWorker!

    private let orderId = "ORDER-123"
    private let pollInterval: TimeInterval = 1
    private let retryInterval: TimeInterval = 0.2
    private let retryCount = 2

    override func setUp() {
        super.setUp()
        serviceStub = OrderServiceStub()
        sut = OrderStatusPollingWorker(
            orderService: serviceStub,
            orderId: orderId,
            pollInterval: pollInterval,
            retryInterval: retryInterval,
            retryCount: retryCount
        )
    }

    override func tearDown() {
        sut = nil
        serviceStub = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_startPolling_immediatelyCallsOrderServiceOnce() {
        // given
        serviceStub.mode = .noop

        // when
        let exp = expectation(description: "allow async path to run once")
        sut.startPolling(needFastPolling: false) { _ in }

        // give the worker a brief moment to hit the service once
        DispatchQueue.main.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: retryInterval * 2)

        // then
        XCTAssertEqual(serviceStub.requestIds.count, 1)
        XCTAssertEqual(serviceStub.requestIds.first, "ORDER-123")
    }

    func test_cancel_preventsEmittingTerminalFailureAfterFirstError() {
        // given: the service will fail fast on every call
        serviceStub.mode = .alwaysFail(.connectionFailed)

        // when
        let invertedExpectation = expectation(description: "no terminal failure should be delivered after cancel")
        invertedExpectation.isInverted = true

        sut.startPolling(needFastPolling: true) { result in
            // The worker emits terminal failure only after retry budget is exhausted.
            // We plan to cancel before that happens, so this block must not be called.
            if case .failure = result {
                invertedExpectation.fulfill()
            }
        }

        // Cancel shortly after the first failure has scheduled a retry.
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval / 2) { [weak sut] in
            sut?.cancel()
        }

        // then: wait long enough that we would otherwise see a terminal failure if not cancelled
        wait(for: [invertedExpectation], timeout: retryInterval * 2)
    }

    func test_exhaustedRetries_emitsFailure() {
        // given: fast path so retries use short interval; always fail
        serviceStub.mode = .alwaysFail(.connectionFailed)

        let expectation = expectation(description: "receive terminal failure after retries are exhausted")

        // when
        sut.startPolling(needFastPolling: true) { result in
            if case let .failure(error) = result {
                // Verify error is wrapped into OrderStatusError.unknown with underlying APIError
                switch error {
                case .unknown(let underlying as APIError):
                    switch underlying {
                    case .connectionFailed:
                        expectation.fulfill()
                    default:
                        XCTFail("Unexpected underlying error: \(underlying)")
                    }
                default:
                    XCTFail("Unexpected error: \(error)")
                }
            }
        }

        // then: retryCount is 2, retryInterval is 0.2s => ~0.4s until terminal fail
        // Add a small safety margin.
        wait(for: [expectation], timeout: retryInterval * Double(retryCount) * 2)
    }
}
