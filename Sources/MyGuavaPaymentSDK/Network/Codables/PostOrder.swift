//
//  PostOrder.swift
//  Guavapay3DS2
//

import Foundation

struct PostOrder: Codable {
    struct TotalAmount: Codable {
        let baseUnits: Double
        let currency: String
        let localized: String
        let minorSubunits: Int
    }

    struct Payer: Codable {
        let contactEmail: String
    }

    struct Order: Codable {
        var id: String
        let referenceNumber: String
        let status: String
        let totalAmount: TotalAmount
        let redirectUrl: URL
        let paymentPageUrl: URL
        let expirationDate: Date
        let orderDescription: [String: String]?
        let sessionToken: String
        let payer: Payer
        let purpose: String
        let availablePaymentMethods: [String]
        let availableCardSchemes: [String]
        let serviceChannel: String
        let availableCardProductCategories: [String]
        let availablePaymentCurrencies: [String]
        let creationDate: Date

        enum CodingKeys: String, CodingKey {
            case id
            case referenceNumber
            case status
            case totalAmount
            case redirectUrl
            case paymentPageUrl
            case expirationDate
            case orderDescription = "description"
            case sessionToken
            case payer
            case purpose
            case availablePaymentMethods
            case availableCardSchemes
            case serviceChannel
            case availableCardProductCategories
            case availablePaymentCurrencies
            case creationDate
        }
    }
    let order: Order
}
