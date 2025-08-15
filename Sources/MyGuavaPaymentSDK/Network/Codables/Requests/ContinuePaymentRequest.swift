//
//  ContinuePaymentRequest.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 04.08.2025.
//


struct ContinuePaymentRequest: Codable {
    let threedsSdkData: PackedAuthenticationData?
    let payPalOrderApproveEvent: PayPalOrderApproveEvent?
}

enum PayPalOrderApproveEvent: String, Codable {
    case approve = "APPROVE"
    case cancel = "CANCEL"
    case error = "ERROR"
}

struct PackedAuthenticationData: Codable {
    let packedAuthenticationData: String?
}
