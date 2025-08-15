//
//  ApplePayService.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 23.06.2025.
//

import PassKit

typealias ApplePayConfig = ApplePayManager.ApplePayConfig

// MARK: - ApplePayError

public enum ApplePayError: Error {
    case statusCode(String?)
    case deviceNotSupported
    case cancelledByUser
}

protocol ApplePayManagerDelegate: AnyObject {
    func didAuthorizePayment(result: Result<Void, ApplePayError>)
}

final class ApplePayManager: NSObject {

    private let orderService: OrderService
    private let orderId: String

    weak var delegate: ApplePayManagerDelegate?
    var config: ApplePayConfig?

    // сюда сохраняем результат
    private var paymentResult: Result<Void, ApplePayError>?

    init(orderService: OrderService, orderId: String) {
        self.orderService = orderService
        self.orderId = orderId
    }

    func pay() {
        guard
            let supportedNetworks = config?.supportedNetworks,
            canMakePayments(supportedNetworks),
            let config
        else {
            delegate?.didAuthorizePayment(result: .failure(.deviceNotSupported))
            return
        }

        let request = PKPaymentRequest()
        request.merchantIdentifier = config.merchantIdentifier
        request.countryCode = config.countryCode
        request.currencyCode = config.currencyCode
        request.supportedNetworks = config.supportedNetworks
        request.merchantCapabilities = PKMerchantCapability(config.merchantCapabilities)
        request.paymentSummaryItems = config.paymentSummaryItems

        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        controller.present(completion: nil)
    }
}

// MARK: - Private

private extension ApplePayManager {
    func canMakePayments(_ supportedNetworks: [PKPaymentNetwork]) -> Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
    }

    func makeApplePayBody(from payment: PKPayment) -> [String: Any]? {
        guard
            let tokenObject = try? JSONSerialization.jsonObject(with: payment.token.paymentData, options: []) as? [String: Any]
        else {
            return nil
        }

        let paymentMethodInfo: [String: Any] = [
            "displayName": payment.token.paymentMethod.displayName ?? "",
            "network": payment.token.paymentMethod.network?.rawValue ?? "",
            "type": {
                switch payment.token.paymentMethod.type {
                case .credit: return "credit"
                case .debit: return "debit"
                case .prepaid: return "prepaid"
                case .store: return "store"
                default: return ""
                }
            }()
        ]

        let paymentDict: [String: Any] = [
            "paymentData": tokenObject,
            "paymentMethod": paymentMethodInfo,
            "transactionIdentifier": payment.token.transactionIdentifier
        ]

        let result: [String: Any] = [
            "paymentMethod": [
                "type": "APPLE_PAY",
                "payment": [
                    "token": paymentDict
                ]
            ],
            "deviceData": [
                "threedsSdkData": [
                    "name": "iOS SDK",
                    "version": "1.0.0"
                ]
            ]
        ]

        return result
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayManager: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        orderService.executePayment(
            orderId: orderId,
            body: makeApplePayBody(from: payment) ?? [:]
        ) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.statusCode == 200 {
                        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                        self.paymentResult = .success(())
                    } else {
                        completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                        self.paymentResult = .failure(.statusCode("Status code is not 200"))
                    }
                case .failure(let error):
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    self.paymentResult = .failure(.statusCode(error.localizedDescription))
                }
            }
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                if let result = self.paymentResult {
                    self.delegate?.didAuthorizePayment(result: result)
                } else {
                    self.delegate?.didAuthorizePayment(result: .failure(.cancelledByUser))
                }
            }
        }
    }
}

// MARK: - ApplePayConfiguration

extension ApplePayManager {
    struct ApplePayConfig {
        let merchantIdentifier: String
        let countryCode: String
        let currencyCode: String
        let paymentSummaryItems: [PKPaymentSummaryItem]
        let supportedNetworks: [PKPaymentNetwork]
        let merchantCapabilities: [PKMerchantCapability]

        init(
            merchantIdentifier: String,
            countryCode: String,
            currencyCode: String,
            paymentSummaryItems: [PKPaymentSummaryItem],
            supportedNetworks: [PKPaymentNetwork],
            merchantCapabilities: [PKMerchantCapability]
        ) {
            self.merchantIdentifier = merchantIdentifier
            self.countryCode = countryCode
            self.currencyCode = currencyCode
            self.paymentSummaryItems = paymentSummaryItems
            self.supportedNetworks = supportedNetworks
            self.merchantCapabilities = merchantCapabilities
        }
    }
}
