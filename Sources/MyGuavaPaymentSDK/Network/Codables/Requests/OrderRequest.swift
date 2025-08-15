//
//  OrderRequest.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 30.06.2025.
//

import Foundation

struct OrderRequest: Codable {
    var referenceNumber: String = UUID().uuidString
    var terminalId: String?
    var purpose: String? = "PURCHASE"
    var redirectUrl: String?
    var merchantUrl: String?
    var intermediateResultPageOptions: IntermediateResultPageOptions?
    var callbackUrl: String = ""
    var shippingAddress: String?
    var requestor: Requestor?
    var tags: [String: String]?
    var availablePaymentMethods: [String]?
    var availableCardSchemes: [String]?
    var availableCardProductCategories: [String]?
    var availablePaymentCurrencies: [String]?
    var availableCryptoNetworks: [CryptoNetwork]?
    var totalAmount: Amount
    var description: Description?
    var subtotals: [Subtotal]?
    var payer: Payer?
    var payee: Payee?
    var useIntermediateResultPage: Bool?
    var expirationOptions: ExpirationOptions?
    var recurrence: Recurrence?
    var shortPaymentPageUrlIsNeeded: Bool?
    var myguavaOpenbanking: MyGuavaOpenbanking?

    enum CodingKeys: String, CodingKey {
        case referenceNumber, terminalId, purpose, redirectUrl, merchantUrl
        case intermediateResultPageOptions, callbackUrl, shippingAddress, requestor, tags
        case availablePaymentMethods, availableCardSchemes, availableCardProductCategories
        case availablePaymentCurrencies, availableCryptoNetworks, totalAmount, description, subtotals
        case payer, payee, useIntermediateResultPage, expirationOptions, recurrence, shortPaymentPageUrlIsNeeded
        case myguavaOpenbanking = "-myguavaOpenbanking-"
    }
}

// MARK: - Description

struct Description: Codable {
    let textDescription: String
    let items: [DescriptionItem]
}

struct DescriptionItem: Codable {
    let barcodeNumber: String
    let vendorCode: String
    let productProvider: String
    let name: String
    let count: Int
    let unitPrice: Amount
    let totalCost: Amount
    let discountAmount: Amount
    let taxAmount: Amount
}

struct PayeeAccount: Codable {
    let type: String?
    let value: String?
}

// MARK: - ExpirationOptions

struct ExpirationOptions: Codable {
    let lifespanTimeoutSeconds: Int?
    let expirationDate: String?
}

// MARK: - MyGuavaOpenbanking

struct MyGuavaOpenbanking: Codable {
    let payee: OpenBankingPayee?
}

struct OpenBankingPayee: Codable {
    let name: String?
    let account: OpenBankingAccount?
    let address: OpenBankingAddress?
}

struct OpenBankingAccount: Codable {
    let sortCode: String?
    let number: String?
}

struct OpenBankingAddress: Codable {
    let country: String?
    let city: String?
    let street: String?
    let buildingNumber: String?
    let zipCode: String?
}

struct Subtotal: Codable {
    let name: String
    let direction: String
    let amount: Amount
}

