//
//  PaymentCardProductCategory+.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 26.06.2025.
//

import Foundation

extension PaymentCardProductCategory {
    var cardCategory: CardProductCategory? {
        switch self {
        case .credit: .credit
        case .debit: .debit
        case .prepaid: .prepaid
        }
    }
}
