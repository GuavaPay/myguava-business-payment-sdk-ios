//
//  Bindings.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 24.06.2025.
//

import UIKit

struct Bindings: Codable {
    let data: [Binding]
}

struct Binding: Codable, Equatable {
    let id: String?
    let payerId: String?
    let creationDate: String?
    let lastUseDate: String?
    let activity: Bool?
    let cardData: CardData?
    let name: String?
    let product: Product?

    var isEnabled: Bool {
        !(isReadonly ?? false)
    }

    var isReadonly: Bool? = false
}

struct CardData: Codable, Equatable {
    let maskedPan: String?
    let expiryDate: String?
    let cardScheme: CardScheme
}

struct Product: Codable, Equatable {
    let id: String?
    let brand: String?
    let category: CardProductCategory?
}
