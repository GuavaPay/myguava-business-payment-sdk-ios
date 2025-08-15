//
//  OrderMock.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 01.08.2025.
//

import Foundation
@testable import MyGuavaPaymentSDK

extension Order {
    static func mock(
        referenceNumber: String? = nil,
        terminalId: String? = nil,
        purpose: OrderPurpose = .purchase,
        redirectUrl: URL = URL(string: "https://www.google.com/")!,
        merchantUrl: URL? = nil,
        intermediateResultPageOptions: IntermediateResultPageOptions? = nil,
        callbackUrl: URL? = nil,
        shippingAddress: String? = nil,
        requestor: Requestor? = nil,
        tags: [String: String]? = nil,
        availablePaymentMethods: [OrderPaymentMethod] = [
            .paymentCard, .paymentCardBinding, .applePay
        ],
        availableCardSchemes: [CardScheme] = [
            .visa, .mastercard, .unionpay, .americanExpress, .dinersClub
        ],
        availableCardProductCategories: [CardProductCategory] = [
            .credit, .debit, .prepaid
        ],
        availablePaymentCurrencies: [String]? = nil,
        availableCryptoNetworks: [CryptoNetworkCurrencyPair]? = nil,
        id: String = "",
        status: OrderStatus? = nil,
        serviceChannel: ServiceChannel = .eCommerce,
        totalAmount: Amount = .init(baseUnits: 100, currency: "USD", minorSubunits: 0, localized: ""),
        subtotals: [OrderSubtotal]? = nil,
        refundedAmount: Amount? = nil,
        recurrence: Recurrence? = nil,
        paymentPageUrl: URL? = nil,
        shortPaymentPageUrl: URL? = nil,
        expirationDate: String = "",
        sessionToken: String = "",
        description: OrderDescription? = nil,
        payer: Payer? = nil,
        payee: Payee? = nil
    ) -> Order {
        Order(
            referenceNumber: referenceNumber,
            terminalId: terminalId,
            purpose: purpose,
            redirectUrl: redirectUrl,
            merchantUrl: merchantUrl,
            intermediateResultPageOptions: intermediateResultPageOptions,
            callbackUrl: callbackUrl,
            shippingAddress: shippingAddress,
            requestor: requestor,
            tags: tags,
            availablePaymentMethods: availablePaymentMethods,
            availableCardSchemes: availableCardSchemes,
            availableCardProductCategories: availableCardProductCategories,
            availablePaymentCurrencies: availablePaymentCurrencies,
            availableCryptoNetworks: availableCryptoNetworks,
            id: id,
            status: status,
            serviceChannel: serviceChannel,
            totalAmount: totalAmount,
            subtotals: subtotals,
            refundedAmount: refundedAmount,
            recurrence: recurrence,
            paymentPageUrl: paymentPageUrl,
            shortPaymentPageUrl: shortPaymentPageUrl,
            expirationDate: expirationDate,
            sessionToken: sessionToken,
            description: description,
            payer: payer,
            payee: payee
        )
    }
}
