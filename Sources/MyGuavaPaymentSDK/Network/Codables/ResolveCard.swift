//
//  ResolveCard.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 01.07.2025.
//

struct ResolveCard: Codable {
    let cardScheme: CardScheme
    let product: CardProduct?
}

struct CardProduct: Codable {
    let id: String?
    let brand: String?
    let category: CardProductCategory?
}
