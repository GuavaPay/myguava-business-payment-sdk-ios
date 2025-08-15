//
//  PaymentOrderStatusEvent.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 02.07.2025.
//

import Foundation

struct PaymentOrderStatusEvent: Decodable {
    let event: OrderStatusEvent
    let order: Order
    let payment: Payment?
    let refunds: [Refund]?
    let paymentRequirements: PaymentRequirements?
}

enum OrderStatusEvent: String, Decodable {
    case orderStateLoaded = "ORDER_STATE_LOADED"
    case orderStateChanged = "ORDER_STATE_CHANGED"
    case paymentRequirementsUpdated = "PAYMENT_REQUIREMENTS_UPDATED"
    case unknown = ""
}
