//
//  ApplePayContext.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 24.06.2025.
//

import Foundation

struct ApplePayContext: Codable {
    struct Context: Codable {
        let appleId: String?
        let displayName: String?
        let supportedCardSchemes: [CardScheme]?
        let isReady: Bool?
    }
    let context: Context
}
