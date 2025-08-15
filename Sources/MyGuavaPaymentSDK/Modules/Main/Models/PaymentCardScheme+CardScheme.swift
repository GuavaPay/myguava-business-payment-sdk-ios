//
//  File.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 24.06.2025.
//

import Foundation

extension PaymentCardScheme {
    var cardScheme: CardScheme? {
        switch self {
        case .visa: .visa
        case .mastercard: .mastercard
        case .unionpay: .unionpay
        case .americanExpress: .americanExpress
        case .dinersClub: .dinersClub
        }
    }
}
