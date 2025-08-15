//
//  ExecutePaymentRequirements.swift
//  Guavapay3DS2
//

import Foundation

// MARK: - ExecutePaymentRequirements
struct ExecutePaymentRequirements: Codable {
    let requirements: PaymentRequirements
}

struct ThreeDSMethod: Codable {
    let data: String?
    let url: String?
}

struct PayerAuthorization: Codable {
    let authorizationUrl: String?
    let qrCodeData: String?
    let expirationDate: Date?
}

struct CryptocurrencyTransfer: Codable {
    let walletAddress: String?
    let expirationDate: Date?
    let networkName: String?
    let detectedAmount: Amount?
}

struct PayPalOrderApprove: Codable {
    let actionUrl: String?
    let orderId: String?
}
