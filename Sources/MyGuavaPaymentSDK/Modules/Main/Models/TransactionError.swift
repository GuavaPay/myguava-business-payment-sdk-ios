//
//  TDSTransactionError.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 04.07.2025.
//

import Guavapay3DS2

public enum TransactionError: Error {
    case timeout
    case cancelled
    case protocolError(GPTDSProtocolErrorEvent)
    case runtimeError(GPTDSRuntimeErrorEvent)
    case unknown(Error)
}
