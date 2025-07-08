//
//  PaymentDTO.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 24.06.2025.
//

import Foundation

struct PaymentDTO {
    let order: Order?
    let availableCardSchemes: [CardScheme]
    let availableAppleCardSchemes: [CardScheme]
    let availablePaymentMethods: [OrderPaymentMethod]
    let availableCardCategories: [CardProductCategory]
    let savedCards: (valid: [Binding], invalid: [Binding])
}
