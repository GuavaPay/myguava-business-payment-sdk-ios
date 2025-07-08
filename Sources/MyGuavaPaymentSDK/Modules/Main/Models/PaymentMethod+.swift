//
//  PaymentMethod+.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 26.06.2025.
//

import Foundation

extension PaymentMethod {
    var orderMethod: OrderPaymentMethod? {
        switch self {
        case .applePay: .applePay
        case .paymentCard: .paymentCard
        /* case .paymentCardBinding: .paymentCardBinding */
        }
    }
}
