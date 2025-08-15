//
//  PaymentWorkerTests.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 01.08.2025.
//

import XCTest
@testable import MyGuavaPaymentSDK

final class PaymentWorkerTests: XCTestCase {

    // MARK: - func buildPaymentDTO(...) -> PaymentDTO

    func test_buildPaymentDTO_filtersCorrectly_andMarksInvalidBindingsValidBindings_andCountsBindings() {
        // Arrange
        let order = Order.mock(
            availablePaymentMethods: [.paymentCard, .paymentCardBinding, .applePay],
            availableCardSchemes: [.visa, .mastercard, .americanExpress, .dinersClub, .unionpay],
            availableCardProductCategories: [.debit, .credit, .prepaid]
        )

        let getOrder = GetOrder.mock(order: order)

        let config = PaymentConfig(
            sessionToken: "",
            orderId: "",
            availableCardSchemes: [.visa, .mastercard],
            availablePaymentMethods: [.paymentCard, .paymentCardBinding],
            availableCardProductCategories: [.debit, .credit]
        )

        let sut = PaymentWorker(
            sdkCardSchemes: [.visa, .mastercard],
            sdkPaymentMethods: [.paymentCard, .paymentCardBinding, .applePay],
            sdkCardCategories: [.debit],
            config: config
        )

        let validBinding = Binding.mock(
            cardData: .mock(cardScheme: .visa),
            product: .mock(category: .debit),
            isReadonly: false
        )

        let invalidBindingMissingScheme = Binding.mock(
            cardData: .mock(cardScheme: .unionpay), // not in config or order
            product: .mock(category: .debit),
            isReadonly: false
        )

        let invalidBindingMissingCategory = Binding.mock(
            cardData: .mock(cardScheme: .visa),
            product: .mock(category: .prepaid), // not in config or order
            isReadonly: false
        )

        let bindings = [validBinding, invalidBindingMissingScheme, invalidBindingMissingCategory]

        // Act
        let dto = sut.buildPaymentDTO(from: getOrder, bindings: bindings, applePaySchemes: [.visa])

        // Assert - Available schemes, methods, categories, applePaySchemes
        XCTAssertEqual(Set(dto.availableCardSchemes), Set([.mastercard, .visa]))
        XCTAssertEqual(Set(dto.availablePaymentMethods), Set([.paymentCard, .paymentCardBinding]))
        XCTAssertEqual(Set(dto.availableCardCategories), Set([.debit]))
        XCTAssertEqual(Set(dto.availableAppleCardSchemes), Set([.visa]))

        // Saved cards counts
        XCTAssertEqual(dto.savedCards.valid.count, 1)
        XCTAssertEqual(dto.savedCards.invalid.count, 2)

        // Valid binding content
        XCTAssertEqual(dto.savedCards.valid.first?.cardData?.cardScheme, .visa)
        XCTAssertEqual(dto.savedCards.valid.first?.product?.category, .debit)

        // Invalid binding 1: unionpay + debit
        XCTAssertEqual(dto.savedCards.invalid.first?.cardData?.cardScheme, .unionpay)
        XCTAssertEqual(dto.savedCards.invalid.first?.product?.category, .debit)

        // Invalid binding 2: visa + prepaid
        XCTAssertEqual(dto.savedCards.invalid.last?.cardData?.cardScheme, .visa)
        XCTAssertEqual(dto.savedCards.invalid.last?.product?.category, .prepaid)

        // Valid card is enabled
        XCTAssertTrue(dto.savedCards.valid.allSatisfy { $0.isEnabled == true })

        // Invalids are disabled
        XCTAssertTrue(dto.savedCards.invalid.allSatisfy { $0.isEnabled == false })
    }
}
