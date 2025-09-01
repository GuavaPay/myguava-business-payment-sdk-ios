//
//  OrderStatusWorkerTests.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 05.08.2025.
//

import XCTest
@testable import MyGuavaPaymentSDK

final class OrderStatusWorkerTests: XCTestCase {
    private var pollingWorkerMock: OrderStatusPollingWorkerMock!
    private var socketWorkerMock: OrderStatusSocketWorkerMock!
    private var delegateSpy: OrderStatusWorkerDelegateSpy!

    private var sut: OrderStatusWorker!

    override func setUp() {
        super.setUp()
        pollingWorkerMock = OrderStatusPollingWorkerMock()
        socketWorkerMock = OrderStatusSocketWorkerMock()
        sut = OrderStatusWorker(pollingWorker: pollingWorkerMock, socketWorker: socketWorkerMock)
        delegateSpy = OrderStatusWorkerDelegateSpy()
        sut.delegate = delegateSpy
    }

    override func tearDown() {
        sut = nil
        pollingWorkerMock = nil
        socketWorkerMock = nil
        delegateSpy = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_fetchOrderStatus_startsSocketListening() {
        // when
        sut.fetchOrderStatus()

        // then
        XCTAssertEqual(socketWorkerMock.startListeningCallCount, 1)
        XCTAssertFalse(pollingWorkerMock.startPollingCalled, "Polling should not start until socket fails")
    }

    func test_fetchOrderStatusNow_whenSocketIsConnected_doesNotStartFastPolling() {
        // given
        socketWorkerMock.isConnected = true

        // when
        sut.fetchOrderStatusNow()

        // then
        XCTAssertFalse(pollingWorkerMock.startPollingCalled, "Should not start polling if socket is already connected")
    }

    func test_fetchOrderStatusNow_whenSocketIsNotConnected_startsFastPolling() {
        // given
        socketWorkerMock.isConnected = false

        // when
        sut.fetchOrderStatusNow()

        // then
        XCTAssertTrue(pollingWorkerMock.startPollingCalled, "Should start polling when socket is not connected")
        XCTAssertTrue(pollingWorkerMock.startPolling_needFast, "Polling must be fast when explicitly requested via fetchOrderStatusNow()")
    }

    func test_stopFetching_cancelsPolling_andStopsSocket() {
        // when
        sut.stopFetching()

        // then
        XCTAssertTrue(pollingWorkerMock.cancelCalled, "stopFetching() must cancel polling")
        XCTAssertEqual(socketWorkerMock.stopListeningCallCount, 1)
    }
}
