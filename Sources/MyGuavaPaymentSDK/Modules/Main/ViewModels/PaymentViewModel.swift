//
//  File.swift
//  payment-ios-sdk
//
//  Created by Said Kagirov on 30.06.2025.
//

import Foundation

final class PaymentViewModel {
    
    private var payment: PaymentDTO
    
    var contactInfoViewModel: ContactInfoViewModel = .init()
    var cardInfoViewModel: CardInfoViewModel = .init()
    
    var isCardPaymentAvailable: Bool {
        payment.availablePaymentMethods.contains { $0 == .paymentCard } &&
        payment.availableCardSchemes.isNotEmpty &&
        payment.availableCardSchemes.contains(where: { $0 != .none })
    }

    var saveCardsIsEmpty: Bool {
        (payment.savedCards.valid.count + payment.savedCards.invalid.count) == 0
    }
    
    var validSaveCards: [Binding] {
        payment.savedCards.valid
    }
    
    var invalidSaveCards: [Binding] {
        payment.savedCards.invalid
    }
    
    var isAvailableApplePay: Bool {
        payment.availablePaymentMethods.contains { $0 == .applePay } &&
        payment.availableAppleCardSchemes.isNotEmpty
    }

    var availableCardSchemes: [CardScheme] {
        payment.availableCardSchemes
    }

    var confirmText: String {
        guard let totalAmount else {
            return "Pay"
        }
        return "Pay \(totalAmount.baseUnits.formattedStringWithCurrency(totalAmount.currency))"
    }
    
    var payer: Payer?
    let totalAmount: Amount?
    
    init(payment: PaymentDTO) {
        self.payment = payment
        self.payer = payment.order?.payer
        self.totalAmount = payment.order?.totalAmount
    }
}

