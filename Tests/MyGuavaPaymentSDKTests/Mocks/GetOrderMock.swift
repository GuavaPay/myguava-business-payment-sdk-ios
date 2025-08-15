//
//  GetOrderMock.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 01.08.2025.
//

import Foundation
@testable import MyGuavaPaymentSDK

extension GetOrder {
    static func mock(
        order: Order? = .mock(),
        merchant: Merchant? = Merchant(name: "Test Merchant", country: nil),
        payment: Payment? = nil,
        refunds: [Refund]? = nil,
        paymentRequirements: PaymentRequirements? = nil
    ) -> GetOrder {
        return GetOrder(
            order: order,
            merchant: merchant,
            payment: payment,
            refunds: refunds,
            paymentRequirements: paymentRequirements
        )
    }
}
