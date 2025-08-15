//
//  CardInfoViewModel.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 01.07.2025.
//

import Foundation

final class CardInfoViewModel {
    let disableCardholderNameField: Bool

    var number: String = ""
    var expiryMonth: String = ""
    var expiryYear: String = ""
    var cvv: String = ""
    var cardName: String?
    var cardholderName: String?

    var isValid: Bool {
        isValidCardNumber(number) &&
        !expiryMonth.isEmpty && expiryMonth.count > 1 &&
        !expiryYear.isEmpty && expiryYear.count > 1 &&
        isValidCVV(cvv) &&
        isValidCardHolderName
    }

    init(disableCardholderNameField: Bool) {
        self.disableCardholderNameField = disableCardholderNameField
    }

    private var isValidCardHolderName: Bool {
        guard disableCardholderNameField == false else {
            return true
        }
        guard let cardholderName = cardholderName,
              !cardholderName.isEmpty else {
            return false
        }
        return true
    }

    private func isValidCardNumber(_ cardNumber: String) -> Bool {
        !number.isEmpty && CCValidator.validate(cardNumber: cardNumber)
    }

    private func isValidCVV(_ cvv: String) -> Bool {
        let digitsOnly = CharacterSet.decimalDigits
        let validCharacters = CharacterSet(charactersIn: cvv)
        return digitsOnly.isSuperset(of: validCharacters) && (cvv.count == 3 || cvv.count == 4)
    }
}

final class BindingInfoViewModel {
    var bindingId: String = ""
    var cvv2: Int = 0
}
