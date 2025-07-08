//
//  PaymentStatusReceiver.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 25.06.2025.
//

import Guavapay3DS2
import SwiftGuavapay3DS2

final class PaymentStatusReceiver: NSObject, GPTDSChallengeStatusReceiver {
    weak var delegate: PaymentStatusReceiverDelegate?

    func transaction(_ transaction: GPTDSTransaction, didCompleteChallengeWith completionEvent: GPTDSCompletionEvent) {
        print("PaymentStatusReceiver: transaction did complete challenge")
        delegate?.didCompleteChallenge(withSuccess: completionEvent.transactionStatus == "Y")
    }

    func transactionDidCancel(_ transaction: GPTDSTransaction) {
        print("PaymentStatusReceiver: transaction did cancel")
        delegate?.didCancelChallenge()
    }

    func transactionDidTimeOut(_ transaction: GPTDSTransaction) {
        print("PaymentStatusReceiver: transaction did time out")
        delegate?.didTimeoutChallenge()
    }

    func transaction(_ transaction: GPTDSTransaction, didErrorWith protocolErrorEvent: GPTDSProtocolErrorEvent) {
        print("PaymentStatusReceiver: transaction did error with protocol error: \(protocolErrorEvent)")
        delegate?.didReceiveProtocolError(protocolErrorEvent)
    }

    func transaction(_ transaction: GPTDSTransaction, didErrorWith runtimeErrorEvent: GPTDSRuntimeErrorEvent) {
        print("PaymentStatusReceiver: transaction did error with runtime error: \(runtimeErrorEvent)")
        delegate?.didReceiveRuntimeError(runtimeErrorEvent)
    }
}
