//
//  File.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 16.06.2025.
//

import Foundation
import PassKit
import Guavapay3DS2
import SwiftGuavapay3DS2

final class PaymentInteractor: PaymentInteractorInput {

    weak var output: PaymentInteractorOutput?

    private let config: PaymentConfig
    private let applePayManager: ApplePayManager

    private let threeDS2Service: GPTDSThreeDS2Service
    private let statusReceiver: PaymentStatusReceiver
    private let orderService: OrderService
    private let applePayService: ApplePayService
    private let bindingService: BindingsService
    private let resolveCardService: ResolveCardService


    private let paymentWorker: PaymentWorker
    private let orderListener: OrderStatusSocketWorker

    private let timeoutSeconds = TimeInterval(5 * 60)
    private let requestorAppUrl = "https://google.com"
    private let sdkAvailableCardSchemes: [CardScheme] = [
        .visa,
        .mastercard,
        .americanExpress
    ]

    private let sdkAvailableCardMethods: [OrderPaymentMethod] = [
        .applePay,
        .paymentCardBinding,
        .paymentCard
    ]

    private let sdkAvailableCardProductCategories: [CardProductCategory] = [
        .credit,
        .debit,
        .prepaid
    ]

    weak var mainVC: UIViewController? // Need reference for apple pay sdk

    private var payment: PaymentDTO?
    private var messageVersion: String?
    private var directoryServerID: String?
    private var transaction: GPTDSTransaction?

    init(
        config: PaymentConfig,
        applePayManager: ApplePayManager,
        orderService: OrderService,
        threeDS2Service: GPTDSThreeDS2Service,
        statusReceiver: PaymentStatusReceiver,
        applePayService: ApplePayService,
        bindingService: BindingsService,
        resolveCardService: ResolveCardService,
        orderStatusWorker: OrderStatusWorker
    ) {
        self.config = config
        self.applePayManager = applePayManager
        self.orderService = orderService
        self.threeDS2Service = threeDS2Service
        self.statusReceiver = statusReceiver
        self.applePayService = applePayService
        self.bindingService = bindingService
        self.resolveCardService = resolveCardService
        self.paymentWorker = PaymentWorker(
            sdkCardSchemes: sdkAvailableCardSchemes,
            sdkPaymentMethods: sdkAvailableCardMethods,
            sdkCardCategories: sdkAvailableCardProductCategories,
            config: config
        )
        self.orderListener = OrderStatusSocketWorker(
            orderId: config.orderId,
            token: config.sessionToken,
            queryItems: [
                .init(name: "payment-requirements-included", value: "true"),
                .init(name: "transactions-included", value: "true")
            ]
        )

        APIClient.shared.configure(
            environment: config.environment,
            token: config.sessionToken
        )
        setupTDSService()
    }

    func getOrder(shouldRetry: Bool = true) {
        if config.disableCardholderNameInput {
            output?.hideCardholderInput()
        }

        orderService.getOrder(byId: config.orderId) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                guard let model = response.model else { return }
                self.handleOrderSuccess(model)
            case .failure(let error):
                var shouldAttemptRetry = false

                if let apiError = error as? APIError {
                    switch apiError {
                    case .httpError, .invalidURL:
                        shouldAttemptRetry = true
                    case .invalidResponse, .noData, .decodingError:
                        shouldAttemptRetry = false
                    }
                } else {
                    shouldAttemptRetry = true
                }

                if shouldAttemptRetry, shouldRetry {
                    self.getOrder(shouldRetry: false)
                    return
                }
                self.output?.didNotGetOrder(error)
            }
        }
    }

    func pollOrderStatusUntilPaid(
        delay: TimeInterval,
        repeatCount: Int,
        completion: @escaping (Result<GetOrder, Error>) -> Void
    ) {
        guard repeatCount > 0 else {
            completion(.failure(APIError.noData))
            return
        }
        orderService.getOrder(byId: config.orderId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                guard let model = response.model,
                      let order = model.order else {
                    completion(.failure(APIError.noData))
                    return
                }
                if order.status == .paid {
                    completion(.success(model))
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.pollOrderStatusUntilPaid(delay: delay, repeatCount: repeatCount - 1, completion: completion)
                }
            case .failure:
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.pollOrderStatusUntilPaid(delay: delay, repeatCount: repeatCount - 1, completion: completion)
                }
            }
        }
    }

    func preCreatePayment(cardInfo: CardInfo?, bindingInfo: BindingInfo?, contactInfo: ContactInfo?, saveCard: Bool) {
        orderService.preCreatePayment(
            orderId: config.orderId,
            body: getBody(
                cardInfo: cardInfo,
                bindingInfo: bindingInfo,
                contactInfo: contactInfo,
                saveCard: false
            )
        ) { [weak self] result in
            switch result {
            case .success(let success):
                switch success.statusCode {
                case 202:
                    self?.messageVersion = success.model?.requirements.threedsSdkCreateTransaction.messageVersion
                    self?.directoryServerID = success.model?.requirements.threedsSdkCreateTransaction.directoryServerID

                case 204:
                    print("204")
                default:
                    print("default")
                }
                self?.executePayment(cardInfo: cardInfo, bindingInfo: bindingInfo, contactInfo: contactInfo, saveCard: saveCard)
            case .failure(let failure):
                self?.output?.didNotPreCreateOrder(failure)
            }
        }
    }

    func payApple() {
        applePayManager.pay()
    }

    func resolveCardNumber(_ cardNumber: String) {
        resolveCardService.resolveCard(for: cardNumber) { [weak self] result in
            guard case .success(let response) = result else {
                self?.output?.didResolveCardNumber(nil)
                return
            }

            self?.output?.didResolveCardNumber(response.model)
        }
    }

    func getCountries() {
        if let url = Bundle.module.url(forResource: "countries", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([CountryResponse].self, from: data)
                output?.didGetCountries(jsonData)
            } catch {
                print("error:\(error)")
            }
        }
    }

    func renameCard(bindingId: String, name: String, completion: @escaping () -> Void) {
        bindingService.renameBinding(bindingId: bindingId, name: name) { _ in
            completion()
        }
    }

    func deleteCard(bindingId: String, completion: @escaping () -> Void) {
        bindingService.deleteBinding(bindingId: bindingId) { _ in
            completion()
        }
    }
}

// MARK: - Private + PaymentInteractor

private extension PaymentInteractor {
    func handleOrderSuccess(_ response: GetOrder) {
        loadAdditionalOrderData(getOrder: response) { [weak self] appleCardSchemes, bindings in
            guard let self else { return }
            let paymentDTO = self.paymentWorker.buildPaymentDTO(
                from: response,
                bindings: bindings,
                applePaySchemes: appleCardSchemes
            )
            self.output?.didGetOrder(paymentDTO)
            self.payment = paymentDTO
        }
    }

    func loadAdditionalOrderData(
        getOrder: GetOrder,
        completion: @escaping ([CardScheme], [Binding]) -> Void
    ) {
        let group = DispatchGroup()

        var appleCardSchemes: [CardScheme] = []
        var bindings: [Binding] = []

        group.enter()
        fetchSaveCardsIfNeeded(getOrder: getOrder) {
            bindings = $0
            group.leave()
        }

        group.enter()
        fetchApplePayContextIfNeeded(getOrder: getOrder) {
            appleCardSchemes = $0
            group.leave()
        }

        group.notify(queue: .main) {
            completion(appleCardSchemes, bindings)
        }
    }

    func fetchSaveCardsIfNeeded(getOrder: GetOrder, completion: @escaping ([Binding]) -> Void) {
        guard let order = getOrder.order, order.payer?.id != nil else {
            completion([])
            return
        }

        let availableMethods = Set.intersectManyArray([
            order.availablePaymentMethods,
            sdkAvailableCardMethods,
            config.availablePaymentMethods.compactMap { $0.orderMethod }
        ])

        let isBindingAvailable = availableMethods.contains(.paymentCardBinding)
        output?.setIsBindingAvailable(isBindingAvailable)

        guard isBindingAvailable else {
            completion([])
            return
        }

        bindingService.getBindings { result in
            switch result {
            case .success(let response):
                guard let model = response.model else { return completion([]) }
                completion(model.data)
            case .failure:
                completion([])
            }
        }
    }

    func setupTDSService() {
        let configParameters = GPTDSConfigParameters()
        let customization = GPTDSUICustomization(from: config.uiCustomization)

        threeDS2Service.initialize(
            withConfig: configParameters,
            locale: .current,
            uiSettings: customization
        )
    }

    func extractX5C(from acsSignedContent: String) -> [String]? {
        let header = acsSignedContent.decodeJWTHeader()

        guard let x5c = header?["x5c"] as? [String] else {
            print("x5c array not found in header")
            return nil
        }
        return x5c
    }

    func executePayment(cardInfo: CardInfo?, bindingInfo: BindingInfo?, contactInfo: ContactInfo?, saveCard: Bool) {
        var packedSdkDataString: String?
        if let directoryServerID {
            let transaction = threeDS2Service.createTransaction(
                forDirectoryServer: directoryServerID,
                withProtocolVersion: messageVersion
            )
            self.transaction = transaction

            let packedSdkData = transaction.createAuthenticationRequestParameters()
            let packedSdkDict = GPTDSJSONEncoder.dictionary(forObject: packedSdkData)

            guard
                let packedSdkJsonData = try? JSONSerialization.data(withJSONObject: packedSdkDict, options: []),
                let dataString = packedSdkJsonData.base64URLEncodedString() else {
                assertionFailure("Failed to encode packedSdkData")
                return
            }
            packedSdkDataString = dataString
        }

        orderService.executePayment(
            orderId: config.orderId,
            body: getBody(
                cardInfo: cardInfo,
                bindingInfo: bindingInfo,
                contactInfo: contactInfo,
                saveCard: saveCard,
                packedSdkDataString: packedSdkDataString
            )
        ) { [weak self] result in
            switch result {
            case .success(let success):
                switch success.statusCode {
                case 200:
                    self?.startPollingOrderStatus()
                case 202:
                    guard let model = success.model else {
                        return
                    }
                    self?.doPaymentChallenge(requirements: model)
                default:
                    print("default")
                }
            case .failure(let error):
                self?.output?.didExecutePayment(.error(.unknown(error)))
            }
        }
    }

    func doPaymentChallenge(requirements: ExecutePaymentRequirements) {
        guard
            let mainVC,
            let packedSDK = requirements.requirements.threedsChallenge?.packedSdkChallengeParameters,
            let challengeParameters = GPTDSChallengeParameters(
                packedSDKString: packedSDK,
                requestorAppURL: requestorAppUrl
            ) else {
            assertionFailure("Challenge data is invalid")
            return
        }

        // - Setting Root Certs to transaction from JWT header
        // ! For test only !
        // Will be removed after certification and replaced with built-in ones
        guard let x5cArray = extractX5C(from: challengeParameters.acsSignedContent), !x5cArray.isEmpty else {
            assertionFailure("x5cArray is empty")
            return
        }

        let certificateString = x5cArray[0]
        let rootCertificateStrings = Array(x5cArray.dropFirst())

        transaction?.setCertificatesWithCustomCertificate(certificateString, rootCertificates: rootCertificateStrings)
        // - Setting Root Certs to transaction from header

        transaction?.doChallenge(
            with: mainVC,
            challengeParameters: challengeParameters,
            messageExtensions: nil,
            challengeStatusReceiver: statusReceiver,
            oobDelegate: nil,
            timeout: timeoutSeconds
        )
    }

    func getBody(
        cardInfo: CardInfo?,
        bindingInfo: BindingInfo?,
        contactInfo: ContactInfo?,
        saveCard: Bool,
        packedSdkDataString: String? = nil
    ) -> [String: Any] {
        var body = [String: Any]()

        if let cardInfo {
            let paymentMethod: [String: Any] = [
                "type": "PAYMENT_CARD",
                "pan": cardInfo.number,
                "cvv2": cardInfo.cvv,
                "expiryDate": "\(cardInfo.expiryYear)\(cardInfo.expiryMonth)",
                "cardholderName": cardInfo.holderName
            ]

            body["paymentMethod"] = paymentMethod

            if saveCard {
                body["bindingCreationIsNeeded"] = saveCard
                body["bindingName"] = cardInfo.newCardName
            }
        }

        if let bindingInfo {
            let paymentMethod: [String: Any] = [
                "type": "PAYMENT_CARD_BINDING",
                "bindingId": bindingInfo.bindingId,
                "cvv2": bindingInfo.cvv2
            ]

            body["paymentMethod"] = paymentMethod
        }

        let contactPhone = ContactPhone(
            countryCode: contactInfo?.countryCode.map { $0.replacingOccurrences(of: "+", with: "") },
            nationalNumber: contactInfo?.nationalNumber.map { $0.replacingOccurrences(of: " ", with: "") }
        )
        let payer = Payer(
            id: nil,
            availableInputModes: nil,
            firstName: nil,
            lastName: nil,
            dateOfBirth: nil,
            contactEmail: contactInfo?.contactEmail ?? payment?.order?.payer?.contactEmail,
            contactPhone: contactPhone ?? payment?.order?.payer?.contactPhone,
            maskedFirstName: nil,
            maskedLastName: nil,
            maskedDateOfBirth: nil,
            maskedContactEmail: nil,
            maskedContactPhone: nil,
            address: nil
        )

        let payerDict = payer.toDictionary()
        body["payer"] = payerDict?.isEmpty == true ? nil : payerDict

        body["deviceData"] = [
            "threedsSdkData": [
                "name": "iOS SDK",
                "version": "1.0.0",
                "packedAuthenticationData": packedSdkDataString
            ]
        ]

        return body
    }

    func startPollingOrderStatus() {
        orderListener.startListening { [weak self] result in
            guard let self else { return }

            guard case let .success(event) = result else {
                self.fallbackToStatusPolling()
                return
            }

            switch event.order.status {
            case .paid, .partiallyRefunded, .refunded, .recurrenceActive, .recurrenceClose:
                self.output?.stopLoading()
                self.orderListener.stopListening()
                self.output?.didExecutePayment(.success(.init(
                    order: .init(
                        id: event.order.id,
                        status: event.order.status,
                        referenceNumber: event.order.referenceNumber,
                        amount: ResultDataModel.Amount(from: event.order.totalAmount)
                    ),
                    payment: .init(
                        id: event.payment?.id,
                        date: event.payment?.date,
                        rrn: event.payment?.rrn,
                        authCode: event.payment?.authCode,
                        resultMessage: event.payment?.result?.message
                    )
                )))
            case .declined, .cancelled, .expired:
                self.output?.stopLoading()
                self.orderListener.stopListening()
                self.output?.didExecutePayment(.unsuccess(.init(
                    order: .init(
                        id: event.order.id,
                        status: event.order.status,
                        referenceNumber: event.order.referenceNumber,
                        amount: ResultDataModel.Amount(from: event.order.totalAmount)
                    ),
                    payment: .init(
                        id: event.payment?.id,
                        date: event.payment?.date,
                        rrn: event.payment?.rrn,
                        authCode: event.payment?.authCode,
                        resultMessage: event.payment?.result?.message
                    )
                )))
            case .created:
                break
            }
        }
    }

    // Fallback to polling getOrder endpoint on WebSocket connection error
    func fallbackToStatusPolling() {
        orderListener.stopListening()
        pollOrderStatusUntilPaid(delay: 2.0, repeatCount: 5) { [weak self] pollResult in
            guard let self = self else { return }
            switch pollResult {
            case .success(let response):
                if let order = response.order, let status = order.status {
                    self.output?.stopLoading()
                    self.output?.didExecutePayment(.success(.init(
                        order: .init(
                            id: order.id,
                            status: status,
                            referenceNumber: order.referenceNumber,
                            amount: ResultDataModel.Amount(from: order.totalAmount)
                        ),
                        payment: .init(
                            id: response.payment?.id,
                            date: response.payment?.date,
                            rrn: response.payment?.rrn,
                            authCode: response.payment?.authCode,
                            resultMessage: response.payment?.result?.message
                        )
                    )))
                }
            case .failure(let error):
                self.output?.stopLoading()
                self.output?.didExecutePayment(.error(.unknown(error)))
            }
        }
    }
}

// MARK: - Private + ApplePay (Should be move to ApplePay worker later)

private extension PaymentInteractor {
    private func fetchApplePayContextIfNeeded(
        getOrder: GetOrder,
        completion: @escaping ([CardScheme]) -> Void
    ) {
        guard let order = getOrder.order else {
            completion([])
            return
        }

        let availableMethods = Set.intersectManyArray([
            order.availablePaymentMethods,
            sdkAvailableCardMethods,
            config.availablePaymentMethods.compactMap { $0.orderMethod }
        ])

        guard availableMethods.contains(.applePay) else {
            completion([])
            return
        }

        applePayService.getContext { [weak self] result in
            guard let self, case .success(let response) = result,
                  let model = response.model,
                  let merchantId = model.context.appleId,
                  let countryCode = getOrder.merchant?.country?.alpha2Code,
                  let appleSupportedCardSchemes = model.context.supportedCardSchemes
            else {
                completion([])
                return
            }

            let supportedAppleCardSchemes = Set.intersectManyArray([
                order.availableCardSchemes,
                appleSupportedCardSchemes,
                sdkAvailableCardSchemes,
                config.availableCardSchemes.compactMap { $0.cardScheme }
            ])
            let merchantCapabilities = self.getMerchantCapabilities(order.availableCardProductCategories)
            let displayName = response.model?.context.displayName ?? ""
            let merchantName = getOrder.merchant?.name ?? ""
            
            let label = if !displayName.isEmpty {
                displayName
            } else if !merchantName.isEmpty {
                merchantName
            } else {
                ""
            }
            
            self.applePayManager.config = ApplePayConfig(
                merchantIdentifier: merchantId,
                countryCode: countryCode,
                currencyCode: order.totalAmount.currency,
                paymentSummaryItems: [
                    .init(
                        label: label,
                        amount: NSDecimalNumber(decimal: Decimal(order.totalAmount.baseUnits)),
                        type: .final
                    )
                ],
                supportedNetworks: supportedAppleCardSchemes.compactMap { $0.pkPaymentNetwork },
                merchantCapabilities: merchantCapabilities
            )
            completion(supportedAppleCardSchemes)
        }
    }


    func getMerchantCapabilities(
        _ availableCardProductCategories: [CardProductCategory]
    ) -> [PKMerchantCapability] {
        var merchantCapabilities: [PKMerchantCapability] = [.capability3DS]

        if availableCardProductCategories.contains(.credit) {
            merchantCapabilities.append(.credit)
        }
        if availableCardProductCategories.contains(.debit) || availableCardProductCategories.contains(.prepaid) {
            merchantCapabilities.append(.debit)
        }
        return merchantCapabilities
    }
}

// MARK: - PaymentStatusReceiverDelegate

extension PaymentInteractor: PaymentStatusReceiverDelegate {
    func didCompleteChallenge(withSuccess: Bool) {
        print("Payment completed with: \(withSuccess)")
        startPollingOrderStatus()
    }

    func didCancelChallenge() {
        output?.didExecutePayment(.cancel)
    }

    func didTimeoutChallenge() {
        output?.didExecutePayment(.error(.timeout))
    }

    func didReceiveProtocolError(_ error: GPTDSProtocolErrorEvent) {
        output?.didExecutePayment(.error(.protocolError(error)))
    }

    func didReceiveRuntimeError(_ error: GPTDSRuntimeErrorEvent) {
        output?.didExecutePayment(.error(.runtimeError(error)))
    }
}

// MARK: - ApplePayManagerDelegate

extension PaymentInteractor: ApplePayManagerDelegate {
    func didAuthorizePayment(result: Result<Void, ApplePayError>) {
        switch result {
        case .success:
            output?.showLoading()
            orderListener.startListening { [weak self] result in
                guard let self else { return }

                guard case let .success(event) = result else {
                    self.fallbackToStatusPolling()
                    return
                }

                switch event.order.status {
                case .paid, .partiallyRefunded, .refunded, .recurrenceActive, .recurrenceClose:
                    self.output?.stopLoading()
                    self.orderListener.stopListening()
                    self.output?.didExecutePayment(.success(.init(
                        order: .init(
                            id: event.order.id,
                            status: event.order.status,
                            referenceNumber: event.order.referenceNumber,
                            amount: ResultDataModel.Amount(from: event.order.totalAmount)
                        ),
                        payment: .init(
                            id: event.payment?.id,
                            date: event.payment?.date,
                            rrn: event.payment?.rrn,
                            authCode: event.payment?.authCode,
                            resultMessage: event.payment?.result?.message
                        )
                    )))
                case .declined, .cancelled, .expired:
                    self.output?.stopLoading()
                    self.orderListener.stopListening()
                    self.output?.didExecutePayment(.unsuccess(.init(
                        order: .init(
                            id: event.order.id,
                            status: event.order.status,
                            referenceNumber: event.order.referenceNumber,
                            amount: ResultDataModel.Amount(from: event.order.totalAmount)
                        ),
                        payment: .init(
                            id: event.payment?.id,
                            date: event.payment?.date,
                            rrn: event.payment?.rrn,
                            authCode: event.payment?.authCode,
                            resultMessage: event.payment?.result?.message
                        )
                    )))
                case .created:
                    break
                }
            }
        case .failure(let errorType):
            switch errorType {
            case .deviceNotSupported:
                self.output?.didExecutePayment(.error(.applePayNotSupported))
            case .statusCode(let error):
                self.output?.didExecutePayment(.error(.statusCode(error)))
            default:
                break
            }
        }
    }
}
