//
//  CardInfo.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 27.06.2025.
//

struct CardInfo {
    var number: String = ""
    var expiryMonth: String = ""
    var expiryYear: String = ""
    var cvv: Int = 0
    
    var newCardName: String?
    var cardholderName: String?
    
    var holderName: String? {
        guard let cardholderName else { return nil }
        return cardholderName.isEmpty ? nil : cardholderName
    }
}

struct BindingInfo {
    var bindingId: String?
    var cvv2: Int?
}
