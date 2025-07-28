//
//  PaymentOrderStatusEvent.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 02.07.2025.
//

import Foundation

struct PaymentOrderStatusEvent: Decodable {
    let event: String
    let order: Order
    let payment: Payment?
    let refunds: [Refund]?
    let paymentRequirements: PaymentRequirements?
    
    struct Order: Decodable {
        let id: String
        let referenceNumber: String
        let status: OrderStatus
        let paymentPageUrl: String?
        let shortPaymentPageUrl: String?
        let totalAmount: Amount
    }
    
    struct Payment: Decodable {
        let id: String
        let date: String?
        let amount: MoneyAmount
        let exchangeRate: Double?
        let referenceNumber: String?
        let result: PaymentResult?
        let rrn: String?
        let authCode: String?
        let paymentMethod: PaymentMethod?
        let reversal: PaymentReversal?
        
        struct PaymentResult: Decodable {
            let message: String?
        }
        
        struct PaymentMethod: Decodable {
            let type: String
            let maskedPan: String?
            let cardScheme: String?
            let cardholderName: String?
        }
        
        struct PaymentReversal: Decodable {
            let result: PaymentResult?
            let reason: String?
        }
    }
    
    struct Refund: Decodable {
        let id: String
        let date: String
        let originalId: String?
        let result: RefundResult?
        let rrn: String?
        let authCode: String?
        let reason: String?
        let amount: MoneyAmount
        let items: [RefundItem]?
        
        struct RefundResult: Decodable {
            let message: String?
        }
        
        struct RefundItem: Decodable {
            let barcodeNumber: String?
            let vendorCode: String?
            let productProvider: String?
            let name: String?
            let count: Int?
            let unitPrice: MoneyAmount?
            let totalCost: MoneyAmount?
            let discountAmount: MoneyAmount?
            let taxAmount: MoneyAmount?
        }
    }
    
    struct PaymentRequirements: Decodable {
        let threedsMethod: ThreeDSMethod?
        let threedsChallenge: ThreeDSChallenge?
        let payerAuthorization: PayerAuthorization?
        let cryptocurrencyTransfer: CryptocurrencyTransfer?
        let payPalOrderApprove: PayPalOrderApprove?
        let finishPageRedirect: FinishPageRedirect?
        
        struct ThreeDSMethod: Decodable {
            let data: String?
            let url: String?
        }
        
        struct ThreeDSChallenge: Decodable {
            let data: String?
            let url: String?
            let packedSdkChallengeParameters: String?
        }
        
        struct PayerAuthorization: Decodable {
            let authorizationUrl: String?
            let qrCodeData: String?
        }
        
        struct CryptocurrencyTransfer: Decodable {
            let walletAddress: String?
            let expirationDate: String?
            let networkName: String?
            let detectedAmount: MoneyAmount?
        }
        
        struct PayPalOrderApprove: Decodable {
            let actionUrl: String?
            let orderId: String?
        }
        
        struct FinishPageRedirect: Decodable {
            let url: String?
            let message: String?
        }
    }
}

struct MoneyAmount: Decodable {
    let baseUnits: Double
    let minorSubunits: Int
    let localized: String
    let currency: String
}

