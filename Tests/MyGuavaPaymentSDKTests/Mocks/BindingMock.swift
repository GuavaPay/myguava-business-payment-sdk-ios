//
//  BindingMock.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 01.08.2025.
//

import Foundation
@testable import MyGuavaPaymentSDK

extension Binding {
    static func mock(
        id: String? = nil,
        payerId: String? = nil,
        creationDate: String? = nil,
        lastUseDate: String? = nil,
        activity: Bool? = nil,
        cardData: CardData = .mock(),
        name: String? = nil,
        product: Product? = .mock(),
        isReadonly: Bool? = false
    ) -> Binding {
        Binding(
            id: id,
            payerId: payerId,
            creationDate: creationDate,
            lastUseDate: lastUseDate,
            activity: activity,
            cardData: cardData,
            name: name,
            product: product,
            isReadonly: isReadonly
        )
    }
}

extension Product {
    static func mock(
        id: String? = nil,
        brand: String? = nil,
        category: CardProductCategory = .debit
    ) -> Product {
        Product(id: id, brand: brand, category: category)
    }
}

extension CardData {
    static func mock(
        maskedPan: String? = nil,
        expiryDate: String? = nil,
        cardScheme: CardScheme = .visa
    ) -> CardData {
        CardData(maskedPan: maskedPan, expiryDate: expiryDate, cardScheme: cardScheme)
    }
}
