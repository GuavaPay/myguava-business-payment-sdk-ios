//
//  CreditCardPrefix.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 17.06.2025.
//

final class CreditCardPrefix {
    let rangeStart: Int
    let rangeEnd: Int
    let prefixLength: Int

    init(rangeStart: Int, rangeEnd: Int, length: Int) {
        self.rangeStart = rangeStart
        self.rangeEnd = rangeEnd
        prefixLength = length
    }
}
