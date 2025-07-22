//
//  PaymentWorker.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 27.06.2025.
//

import Foundation

final class PaymentWorker {
    private let sdkCardSchemes: [CardScheme]
    private let sdkPaymentMethods: [OrderPaymentMethod]
    private let sdkCardCategories: [CardProductCategory]
    private let config: PaymentConfig

    init(
        sdkCardSchemes: [CardScheme],
        sdkPaymentMethods: [OrderPaymentMethod],
        sdkCardCategories: [CardProductCategory],
        config: PaymentConfig
    ) {
        self.sdkCardSchemes = sdkCardSchemes
        self.sdkPaymentMethods = sdkPaymentMethods
        self.sdkCardCategories = sdkCardCategories
        self.config = config
    }

    func buildPaymentDTO(
        from order: GetOrder,
        bindings: [Binding],
        applePaySchemes: [CardScheme]
    ) -> PaymentDTO {
        let availableCardSchemes = Set.intersectManyArray([
            order.order?.availableCardSchemes ?? [],
            sdkCardSchemes,
            config.availableCardSchemes.compactMap { $0.cardScheme }
        ])
        
        let availablePaymentMethods = Set.intersectManyArray([
            order.order?.availablePaymentMethods ?? [],
            sdkPaymentMethods,
            config.availablePaymentMethods.compactMap { $0.orderMethod }
        ])
        
        let availableCardCategories = Set.intersectManyArray([
            order.order?.availableCardProductCategories ?? [],
            sdkCardCategories,
            config.availableCardProductCategories.compactMap { $0.cardCategory }
        ])
        
        let updatedBindings = bindings.compactMap { binding in
            var binding = binding
            let isValid: Bool
            
            if let scheme = binding.cardData?.cardScheme,
               let category = binding.product?.category {
                isValid = availableCardSchemes.contains(scheme) && availableCardCategories.contains(category)
            } else {
                isValid = false
            }
            if !isValid {
                binding.isReadonly = true
            }
            return binding
        }

        let savedCards = updatedBindings.partitioned { $0.isEnabled }

        return PaymentDTO(
            order: order.order,
            availableCardSchemes: availableCardSchemes,
            availableAppleCardSchemes: applePaySchemes,
            availablePaymentMethods: availablePaymentMethods,
            availableCardCategories: availableCardCategories,
            savedCards: savedCards
        )
    }
}
