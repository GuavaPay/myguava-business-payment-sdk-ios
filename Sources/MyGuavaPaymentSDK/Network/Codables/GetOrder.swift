//
//  GetOrder.swift
//  Guavapay3DS2
//
//  Created by Nikolai Kriuchkov on 16.04.2025.
//

import UIKit

enum Direction: String, Codable {
    case debit = "DEBIT"
    case credit = "CREDIT"
}

enum OrderPurpose: String, Codable {
    case purchase = "PURCHASE"
    case transfer = "TRANSFER"
    case subscription = "SUBSCRIPTION"
}

enum OrderPaymentMethod: String, Codable {
    case paymentCard = "PAYMENT_CARD"
    case paymentCardBinding = "PAYMENT_CARD_BINDING"
    case applePay = "APPLE_PAY"
    case googlePay = "GOOGLE_PAY"
    case bankAccount = "BANK_ACCOUNT"
    case clickToPay = "CLICK_TO_PAY"
    case cryptocurrency = "CRYPTOCURRENCY"
    case payPalWallet = "PAYPAL_WALLET"
    case myGuavaAccount = "MYGUAVA_ACCOUNT"
}

enum CardScheme: String, Codable, Equatable, CaseIterable {
    case visa = "VISA"
    case mastercard = "MASTERCARD"
    case unionpay = "UNIONPAY"
    case americanExpress = "AMERICAN_EXPRESS"
    case dinersClub = "DINERS_CLUB"
    case none

    /// Decodes an instance of `CardScheme` from the given decoder.
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if decoding fails.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(String.self)
        self = CardScheme(rawValue: rawValue ?? "") ?? .none
    }

    var icon: UIImage? {
        switch self {
        case .visa:
            return Icons.CardScheme.visa
        case .mastercard:
            return Icons.CardScheme.masterCard
        case .unionpay:
            return Icons.CardScheme.unionPay
        case .americanExpress:
            return Icons.CardScheme.americanExpress
        case .dinersClub:
            return Icons.CardScheme.dinersClub
        case .none:
            return nil
        }
    }

    var cvvLength: Int {
        switch self {
        case .visa, .mastercard, .unionpay, .dinersClub, .none:
            return 3
        case .americanExpress:
            return 4
        }
    }
}

enum CardProductCategory: String, Codable {
    case credit = "CREDIT"
    case prepaid = "PREPAID"
    case debit = "DEBIT"
}

enum ServiceChannel: String, Codable {
    case eCommerce = "E-COMM"
    case pos = "POS"
}

enum CryptoNetwork: String, Codable {
    case tron = "TRON"
    case ethereum = "ETHEREUM"
    case polygon = "POLYGON"
    case arbitrum = "ARBITRUM"
    case solana = "SOLANA"
    case binanceSmartChain = "BINANCE_SMART_CHAIN"
    case bitcoin = "BITCOIN"
    case litecoin = "LITECOIN"
}

enum InputMode: String, Codable {
    case copyFromPayee = "COPY_FROM_PAYEE"
    case manual = "MANUAL"
}

enum RecurrenceExecution: String, Codable {
    case manual = "MANUAL"
    case automatic = "AUTOMATIC"
}

enum InitialOperation: String, Codable {
    case payment = "PAYMENT"
    case prepareForFuturePayments = "PREPARE_FOR_FUTURE_PAYMENTS"
}

struct GetOrder: Codable {
    let order: Order?
    let merchant: Merchant?
    let payment: Payment?
    let refunds: [Refund]?
    let paymentRequirements: PaymentRequirements?
}

struct Order: Codable {
    let referenceNumber: String?
    let terminalId: String?
    let purpose: OrderPurpose
    let redirectUrl: URL
    let merchantUrl: URL?
    let intermediateResultPageOptions: IntermediateResultPageOptions?
    let callbackUrl: URL?
    let shippingAddress: String?
    let requestor: Requestor?
    let tags: [String: String]?
    let availablePaymentMethods: [OrderPaymentMethod]
    let availableCardSchemes: [CardScheme]
    let availableCardProductCategories: [CardProductCategory]
    let availablePaymentCurrencies: [String]?
    let availableCryptoNetworks: [CryptoNetworkCurrencyPair]?
    let id: String
    let status: OrderStatus?
    let serviceChannel: ServiceChannel
    let totalAmount: Amount
    let subtotals: [OrderSubtotal]?
    let refundedAmount: Amount?
    let recurrence: Recurrence?
    let paymentPageUrl: URL?
    let shortPaymentPageUrl: URL?
    let expirationDate: String
    let sessionToken: String
    let description: OrderDescription?
    let payer: Payer?
    let payee: Payee?
}

struct Merchant: Codable {
    struct Country: Codable {
        let alpha2Code: String
    }
    let name: String?
    let country: Country?
}

struct Payment: Codable {
    let id: String?
    let date: String?
    let exchangeRate: Double?
    let amount: Amount
    let referenceNumber: String?
    let result: PaymentResult?
    let rrn: String?
    let authCode: String?
    let paymentMethod: PaymentMethodDTO?
    let reversal: Reversal?
}

struct Refund: Codable {
    let id: String?
    let date: String?
    let originalId: String?
    let result: PaymentResult?
    let rrn: String?
    let authCode: String?
    let reason: String?
    let amount: Amount
    let items: [OrderItem]?
}

struct PaymentRequirements: Codable {
    let threedsMethod: ThreedsMethod?
    let threedsChallenge: ThreedsChallenge?
    let threedsSdkCreateTransaction: ThreeDSSdkCreateTransaction?
    let payerAuthorization: PayerAuthorization?
    let cryptocurrencyTransfer: CryptocurrencyTransfer?
    let payPalOrderApprove: PayPalOrderApprove?
    let finishPageRedirect: FinishPageRedirect?
}

struct ThreeDSSdkCreateTransaction: Codable {
    let messageVersion: String
    let directoryServerID: String
}

struct IntermediateResultPageOptions: Codable {
    let successMerchantUrl: String?
    let unsuccessMerchantUrl: String?
    let autoRedirectDelaySeconds: Int?
}

struct Requestor: Codable {
    let application: Application?
    let customData: CustomData?
}

struct Application: Codable {
    let name: String?
    let version: String?
}

struct CustomData: Codable {
    let shared: [String: String]?
    let secret: [String: String]?
}

struct OrderSubtotal: Codable {
    let name: String?
    let direction: Direction?
    let amount: Amount?
}

struct Recurrence: Codable {
    let execution: RecurrenceExecution?
    let initialOperation: InitialOperation?
    let description: String?
    let schedule: String?
    let startDate: String?
    let endDate: String?
    let amount: Amount
    let maxAmount: Amount
}

struct CryptoNetworkCurrencyPair: Codable {
    let currency: String?
    let network: CryptoNetwork?
}

struct Amount: Codable {
    let baseUnits: Double
    let currency: String
    let minorSubunits: Int
    let localized: String
}

struct OrderDescription: Codable {
    let textDescription: String?
    let items: [OrderItem]?
}

struct OrderItem: Codable {
    let barcodeNumber: String?
    let vendorCode: String?
    let productProvider: String?
    let name: String?
    let count: Int?
    let unitPrice: Amount
    let totalCost: Amount
    let discountAmount: Amount
    let taxAmount: Amount
}

struct Payer: Codable {
    let id: String?
    let availableInputModes: [InputMode]?
    let firstName: String?
    let lastName: String?
    let dateOfBirth: String?
    var contactEmail: String?
    var contactPhone: ContactPhone?
    let maskedFirstName: String?
    let maskedLastName: String?
    let maskedDateOfBirth: String?
    let maskedContactEmail: String?
    let maskedContactPhone: MaskedContactPhone?
    let address: Address?
}

struct ContactPhone: Codable {
    let countryCode: String?
    let nationalNumber: String?

    init?(countryCode: String?, nationalNumber: String?) {
        guard let countryCode, let nationalNumber else { return nil }

        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
    }
}

struct MaskedContactPhone: Codable {
    let countryCode: String?
    let nationalNumber: String?
    let formatted: String?

    init?(countryCode: String?, nationalNumber: String?, formatted: String?) {
        guard let countryCode, let nationalNumber, let formatted else { return nil }

        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
        self.formatted = formatted
    }
}

struct Address: Codable {
    let country: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let addressLine1: String?
    let addressLine2: String?
    let maskedZipCode: String?
    let maskedAddressLine1: String?
    let maskedAddressLine2: String?
}

struct Payee: Codable {
    let id: String?
    let firstName: String?
    let lastName: String?
    let dateOfBirth: String?
    let maskedFirstName: String?
    let maskedLastName: String?
    let maskedDateOfBirth: String?
    let account: Account?
    let address: Address?
}

struct Account: Codable {
    let type: String?
    let value: String?
}

struct PaymentResult: Codable {
    let code: String?
    let message: String?
}

struct PaymentMethodDTO: Codable {
    let type: String?
    let maskedPan: String?
    let cardScheme: String?
    let cardholderName: String?
}

struct Reversal: Codable {
    let result: PaymentResult?
    let reason: String?
}

struct ThreedsMethod: Codable {
    let data: String?
    let url: String?
}

struct ThreedsChallenge: Codable {
    let data: String?
    let url: String?
    let packedSdkChallengeParameters: String?
}

struct FinishPageRedirect: Codable {
    let url: String?
    let message: String?
}
