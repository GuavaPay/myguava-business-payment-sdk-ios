//
//  PaymentSheetAssembly.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 16.06.2025.
//

import UIKit
import Guavapay3DS2

public typealias PaymentCardScheme = PaymentConfig.PaymentCardScheme
public typealias PaymentMethod = PaymentConfig.PaymentMethod
public typealias PaymentCardProductCategory = PaymentConfig.PaymentCardProductCategory

public struct ResultDataModel {
    public struct Amount {
        public let amount: Decimal?
        public let currency: String?
    }
    public struct Order {
        public let id: String
        public let status: OrderStatus
        public let referenceNumber: String?
        public let amount: Amount?
    }
    public struct Payment {
        public let id: String?
        public let date: String?
        public let rrn: String?
        public let authCode: String?
        public let resultMessage: String?
    }
    public let order: Order
    public let payment: Payment?
}

public enum OrderStatusError: Error {
    case timeout
    case runtimeError(GPTDSRuntimeErrorEvent)
    case protocolError(GPTDSProtocolErrorEvent)
    case unknown(Error?)
    case statusCode(String?)
    case deviceNotSupported
    case cancelled
    case cancelledByUser
}

public protocol PaymentDelegate {
    func handlePaymentResult(_ result: Result<ResultDataModel, OrderStatusError>)
    func handlePaymentCancel()
    func handleOrderDidNotGet()
}

public struct PaymentConfig {
    public enum PaymentCardScheme {
        case visa
        case mastercard
        case unionpay
        case americanExpress
        case dinersClub
    }
    public enum PaymentMethod {
        case applePay
        /* case paymentCardBinding */
        case paymentCard
    }
    public enum PaymentCardProductCategory {
        case debit
        case credit
        case prepaid
    }
    public let sessionToken: String
    public let orderId: String
    public let environment: GPEnvironment
    public let availableCardSchemes: [PaymentCardScheme]
    public let availablePaymentMethods: [PaymentMethod]
    public let availableCardProductCategories: [PaymentCardProductCategory]
    
    public init(
        sessionToken: String,
        orderId: String,
        environment: GPEnvironment = .sandbox,
        availableCardSchemes: [PaymentCardScheme] = [
            .visa, .mastercard, .unionpay, .americanExpress, .dinersClub
        ],
        availablePaymentMethods: [PaymentMethod] = [
            .paymentCard, /* .paymentCardBinding, */ .applePay
        ],
        availableCardProductCategories: [PaymentCardProductCategory] = [
            .credit, .debit, .prepaid
        ]
    ) {
        self.sessionToken = sessionToken
        self.orderId = orderId
        self.environment = environment
        self.availableCardSchemes = availableCardSchemes
        self.availablePaymentMethods = availablePaymentMethods
        self.availableCardProductCategories = availableCardProductCategories
    }
}

public final class PaymentAssembly {
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
        return viewController
    }
}
