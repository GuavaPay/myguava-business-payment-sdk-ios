//
//  ExecutePaymentRequirements.swift
//  Guavapay3DS2
//

import Foundation

// MARK: - ExecutePaymentRequirements
struct ExecutePaymentRequirements: Codable {
    let requirements: Requirements
}

// MARK: - Requirements
struct Requirements: Codable {
    let threedsMethod: ThreeDSMethod?
    let threedsChallenge: ThreeDSChallenge?
    let payerAuthorization: PayerAuthorization?
    let cryptocurrencyTransfer: CryptocurrencyTransfer?
    let payPalOrderApprove: PayPalOrderApprove?
}

struct ThreeDSMethod: Codable {
    let data: String?
    let url: String?
}

struct ThreeDSChallenge: Codable {
    let data: String?
    let url: String?
    let packedSdkChallengeParameters: String?
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
    let detectedAmount: DetectedAmount?
}

struct DetectedAmount: Codable {
    let baseUnits: Double
    let currency: String
    let minorSubunits: Int
    let localized: String
}

struct PayPalOrderApprove: Codable {
    let actionUrl: String?
    let orderId: String?
}

struct Completed: Codable {
    let redirectUrl: URL
}
