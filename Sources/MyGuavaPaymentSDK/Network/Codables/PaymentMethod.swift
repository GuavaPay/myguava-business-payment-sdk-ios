//
//  PaymentCardMethod.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 04.08.2025.
//


struct PaymentCardMethod: Encodable {
    let type = OrderPaymentMethod.paymentCard
    let pan: String?
    let cvv2: Int?
    let expiryDate: String?
    let cardholderName: String?
}

struct BindingMethod: Encodable {
    let type = OrderPaymentMethod.paymentCardBinding
    let bindingId: String?
    let cvv2: Int?
}
