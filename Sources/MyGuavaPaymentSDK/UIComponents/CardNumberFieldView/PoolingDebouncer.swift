//
//  PoolingDebouncer.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 17.06.2025.
//

import Foundation

final class PollingDebouncer {
    private let interval: TimeInterval
    private var timer: Timer?
    private var isPolling = false

    init(interval: TimeInterval = 0.3) {
        self.interval = interval
    }
    
    deinit {
        stop()
    }

    func start(_ block: @escaping () -> Void) {
        stop()

        isPolling = true
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            block()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isPolling = false
    }
}
