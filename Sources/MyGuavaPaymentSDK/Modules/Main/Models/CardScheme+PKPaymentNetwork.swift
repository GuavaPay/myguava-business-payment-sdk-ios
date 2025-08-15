//
//  CardScheme+.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 24.06.2025.
//

import PassKit

extension CardScheme {
    var pkPaymentNetwork: PKPaymentNetwork? {
        switch self {
        case .visa: .visa
        case .mastercard: .masterCard
        case .unionpay: nil
        case .americanExpress: .amex
        case .dinersClub: .discover
        case .none: nil
        }
    }
}
