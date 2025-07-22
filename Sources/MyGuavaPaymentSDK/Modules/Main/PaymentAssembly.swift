//
//  PaymentSheetAssembly.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 16.06.2025.
//

import UIKit
import Guavapay3DS2

/// Represents a card scheme such as Visa, Mastercard, etc.
public typealias PaymentCardScheme = PaymentConfig.PaymentCardScheme
/// Represents a supported payment method (e.g., card, Apple Pay).
public typealias PaymentMethod = PaymentConfig.PaymentMethod
/// Represents the category of a payment card (credit, debit, prepaid).
public typealias PaymentCardProductCategory = PaymentConfig.PaymentCardProductCategory

/// Contains result data for a completed or failed payment operation.
public struct ResultDataModel {
    /// Describes the monetary value and currency of a transaction.
    public struct Amount {
        /// Transaction amount.
        public let amount: Decimal?
        /// Currency code (e.g., "USD", "EUR").
        public let currency: String?
    }
    /// Contains details about the payment order.
    public struct Order {
        /// The order ID.
        public let id: String
        /// Current status of the order.
        public let status: OrderStatus
        /// Optional reference number from the merchant or system.
        public let referenceNumber: String?
        /// The amount and currency of the order.
        public let amount: Amount?
    }
    /// Contains payment-specific information if payment was processed.
    public struct Payment {
        /// The payment ID.
        public let id: String?
        /// ISO date string of the payment time.
        public let date: String?
        /// Retrieval Reference Number (RRN) of the transaction.
        public let rrn: String?
        /// Authorization code returned by the issuer.
        public let authCode: String?
        /// Human-readable result message (optional).
        public let resultMessage: String?
    }
    /// The related order.
    public let order: Order
    /// The payment information (if available).
    public let payment: Payment?
}

/// Represents an error that occurred during the payment flow or order status retrieval.
public enum OrderStatusError: Error {
    /// Timeout occurred during payment or status polling.
    case timeout
    /// Runtime error from 3DS or payment services.
    case runtimeError(GPTDSRuntimeErrorEvent)
    /// Protocol-level error from the payment gateway.
    case protocolError(GPTDSProtocolErrorEvent)
    /// Unknown error, possibly external or unhandled.
    case unknown(Error?)
    /// Received unexpected or invalid HTTP status code.
    case statusCode(String?)
    /// Device is not supported for this payment method.
    case applePayNotSupported
}

public enum PaymentStatus {
    case success(ResultDataModel)
    case unsuccess(ResultDataModel)
    case error(OrderStatusError)
    case cancel
}

/// A protocol that allows your application to handle key payment lifecycle events.
public protocol PaymentDelegate: AnyObject {
    /// Called when the payment process finishes, either successfully or with an error.
    ///
    /// - Parameter result: A `Result` containing either a successful `ResultDataModel` or an `OrderStatusError`.
    @available(*, deprecated: 0.0.6, message: "Use handlePaymentResult(_ result: PaymentStatus) instead.")
    func handlePaymentResult(_ result: Result<ResultDataModel, OrderStatusError>)
    /// Called when the user cancels the payment flow before any processing has occurred.
    @available(*, deprecated: 0.0.6, message: "Use handlePaymentResult(_ result: PaymentStatus) instead. In PaymentStatus enum will pass 'cancel' case")
    func handlePaymentCancel()
    /// Called when the payment process finishes, either successfully or with an error.
    ///
    /// - Parameter result: A `PaymentStatus` value representing the final status of the payment. This can indicate success, failure, or other terminal states.
    func handlePaymentResult(_ result: PaymentStatus)
    /// Called when the payment module is initialized but the order data could not be retrieved from the backend (e.g. due to a network error or invalid session).
    func handleOrderDidNotGet()
}

/// A configuration object for customizing the payment flow.
public struct PaymentConfig {
    /// Supported card schemes for payment.
    public enum PaymentCardScheme {
        case visa
        case mastercard
        case unionpay
        case americanExpress
        case dinersClub
    }
    /// Supported payment methods.
    public enum PaymentMethod {
        case applePay
        case paymentCardBinding
        case paymentCard
    }
    /// Categories of cards supported for the transaction.
    public enum PaymentCardProductCategory {
        case debit
        case credit
        case prepaid
    }
    /// The token used to initiate a payment session.
    public let sessionToken: String
    /// The ID of the order to be paid.
    public let orderId: String
    /// The environment (sandbox or production).
    public let environment: GPEnvironment
    /// Payment sheet and 3DS UI customization model
    public let uiCustomization: GPUICustomization
    /// Array of allowed card schemes (e.g., Visa, Mastercard).
    public let availableCardSchemes: [PaymentCardScheme]
    /// Array of allowed payment methods (e.g., Apple Pay, card).
    public let availablePaymentMethods: [PaymentMethod]
    /// Array of allowed card product categories (e.g., debit, credit).
    public let availableCardProductCategories: [PaymentCardProductCategory]
    
    /// Creates a new instance of `PaymentConfig`.
    /// 
    /// - Parameters:
    ///   - sessionToken: The session token for authenticating the payment.
    ///   - orderId: The order ID being paid.
    ///   - environment: The environment to use (defaults to `.sandbox`).
    ///   - uiCustomization: UI customization model for payment sheet and 3DS
    ///   - availableCardSchemes: Card schemes that should be shown to the user.
    ///   - availablePaymentMethods: Payment methods available to the user.
    ///   - availableCardProductCategories: Supported card categories.
    public init(
        sessionToken: String,
        orderId: String,
        environment: GPEnvironment = .sandbox,
        uiCustomization: GPUICustomization = GPUICustomization.default,
        availableCardSchemes: [PaymentCardScheme] = [
            .visa, .mastercard, .unionpay, .americanExpress, .dinersClub
        ],
        availablePaymentMethods: [PaymentMethod] = [
            .paymentCard, .paymentCardBinding, .applePay
        ],
        availableCardProductCategories: [PaymentCardProductCategory] = [
            .credit, .debit, .prepaid
        ]
    ) {
        self.sessionToken = sessionToken
        self.orderId = orderId
        self.environment = environment
        self.uiCustomization = uiCustomization
        self.availableCardSchemes = availableCardSchemes
        self.availablePaymentMethods = availablePaymentMethods
        self.availableCardProductCategories = availableCardProductCategories
    }
}

/// The entry point for presenting the payment module.
public final class PaymentAssembly {
    /// Assembles and returns the payment UI view controller ready for presentation.
    ///
    /// - Parameters:
    ///   - config: The `PaymentConfig` containing session and environment data.
    ///   - delegate: The object that handles payment results, conforming to `PaymentDelegate`.
    /// - Returns: A ready-to-use `UIViewController` for the payment flow.
    public static func assemble(_ config: PaymentConfig, _ delegate: PaymentDelegate?) -> UIViewController {
        let orderService = OrderService()
        let applePayManager = ApplePayManager(orderService: orderService, orderId: config.orderId)
        let statusReceiver = PaymentStatusReceiver()

        let interactor = PaymentInteractor(
            config: config,
            applePayManager: applePayManager,
            orderService: OrderService(),
            threeDS2Service: GPTDSThreeDS2Service(),
            statusReceiver: statusReceiver,
            applePayService: ApplePayService(),
            bindingService: BindingsService(),
            resolveCardService: ResolveCardService(),
            orderStatusWorker: OrderStatusWorker(orderService: orderService)
        )
        let viewController = PaymentViewController()
        let router = PaymentRouter(view: viewController)
        let presenter = PaymentPresenter(
            interactor: interactor,
            view: viewController,
            router: router,
            moduleOutput: delegate
        )

        viewController.output = presenter
        interactor.output = presenter
        applePayManager.delegate = interactor
        statusReceiver.delegate = interactor
        interactor.mainVC = viewController

        UICustomizationProvider.shared.setUICustomization(config.uiCustomization)

        return viewController
    }
}
