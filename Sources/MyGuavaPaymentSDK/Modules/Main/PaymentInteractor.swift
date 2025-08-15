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
    private let orderStatusWorker: OrderStatusWorker

    private let timeoutSeconds: TimeInterval = 5 * 60
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
        self.orderStatusWorker = orderStatusWorker

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
                    case .httpError, .invalidURL, .connectionFailed, .unknown:
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

    func listenOrderStatus() {
        orderStatusWorker.fetchOrderStatus()
    }

    func executePayment(
        paymentMethod: PaymentMethodRequest,
        newCardName: String?,
        contactInfo: ContactInfo?,
        saveCard: Bool
    ) {
        let bodyModel = getExecuteBody(
            paymentMethod: paymentMethod,
            newCardName: newCardName,
            contactInfo: contactInfo,
            saveCard: saveCard
        )

        guard let body = bodyModel.toDictionary() else {
            SentryFacade.shared.capture(error: EncodingSentryError.requestBody)
            return
        }

        orderService.executePayment(
            orderId: config.orderId,
            body: body
        ) { [weak self] result in
            switch result {
            case .success(let success):
                switch success.statusCode {
                case 200:
                    self?.orderStatusWorker.fetchOrderStatusNow()
                case 202:
                    self?.messageVersion = success.model?.requirements.threedsSdkCreateTransaction?.messageVersion
                    self?.directoryServerID = success.model?.requirements.threedsSdkCreateTransaction?.directoryServerID
                    self?.continuePayment(paymentMethod: paymentMethod, contactInfo: contactInfo)
                default:
                    SentryFacade.shared.capture(error: NetworkError.unexpectedSuccessCode(success.statusCode))
                }
            case .failure(let failure):
                self?.output?.didNotExecutePayment(.unknown(failure))
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
                applePaySchemes: appleCardSchemes,
                disableCardholderNameField: config.disableCardholderNameInput
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

        return header?["x5c"] as? [String]
    }

    func continuePayment(
        paymentMethod: PaymentMethodRequest,
        contactInfo: ContactInfo?
    ) {
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
                SentryFacade.shared.capture(error: EncodingSentryError.packedSdkData)
                return
            }
            packedSdkDataString = dataString
        }

        let bodyModel = ContinuePaymentRequest(
            threedsSdkData: PackedAuthenticationData(packedAuthenticationData: packedSdkDataString),
            payPalOrderApproveEvent: nil
        )

        guard let body = bodyModel.toDictionary() else {
            SentryFacade.shared.capture(error: EncodingSentryError.requestBody)
            return
        }

        orderService.continuePayment(
            orderId: config.orderId,
            body: body
        ) { [weak self] result in
            switch result {
            case .success(let success):
                switch success.statusCode {
                case 200:
                    self?.orderStatusWorker.fetchOrderStatusNow()
                case 202:
                    guard let model = success.model else {
                        return
                    }
                    self?.doPaymentChallenge(requirements: model)
                case 204:
                    break
                default:
                    SentryFacade.shared.capture(error: NetworkError.unexpectedSuccessCode(success.statusCode))
                }
            case .failure(let error):
                self?.output?.didContinuePayment(.error(.unknown(error)))
            }
        }
    }

    func doPaymentChallenge(requirements: ExecutePaymentRequirements) {
        guard let mainVC else {
            return
        }

        guard let packedSDK = requirements.requirements.threedsChallenge?.packedSdkChallengeParameters,
              let challengeParameters = GPTDSChallengeParameters(
                packedSDKString: packedSDK,
                requestorAppURL: requestorAppUrl
              ) else {
            SentryFacade.shared.capture(error: DataError.invalidChallengeRequirements)
            return
        }

        // - Setting Root Certs to transaction from JWT header
        // ! For test only !
        // Will be removed after certification and replaced with built-in ones
        guard let x5cArray = extractX5C(from: challengeParameters.acsSignedContent), !x5cArray.isEmpty else {
            SentryFacade.shared.capture(error: DataError.x5cCertificatesNotFound)
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

    func getExecuteBody(
        paymentMethod: PaymentMethodRequest,
        newCardName: String?,
        contactInfo: ContactInfo?,
        saveCard: Bool,
        packedSdkDataString: String? = nil
    ) -> ExecutePaymentRequest {
        let contactPhone = ContactPhone(
            countryCode: contactInfo?.countryCode.map { $0.replacingOccurrences(of: "+", with: "") },
            nationalNumber: contactInfo?.nationalNumber.map { $0.replacingOccurrences(of: " ", with: "") }
        )

        return ExecutePaymentRequest(
            paymentMethod: paymentMethod,
            deviceData: DeviceDataRequest(
                browserData: nil,
                ip: nil,
                threedsSdkData: ThreedsSdkData(packedAuthenticationData: packedSdkDataString)
            ),
            bindingCreationIsNeeded: saveCard,
            bindingName: newCardName,
            exchange: nil,
            payer: PayerRequest(
                inputMode: nil,
                firstName: nil,
                lastName: nil,
                contactEmail: contactInfo?.contactEmail ?? payment?.order?.payer?.contactEmail,
                contactPhone: contactPhone ?? payment?.order?.payer?.contactPhone,
                address: nil
            ),
            challengeWindowSize: nil,
            priorityRedirectUrl: nil
        )
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
    }

    func didCancelChallenge() {
        output?.didContinuePayment(.cancel)
    }

    func didTimeoutChallenge() {
        output?.didContinuePayment(.error(.timeout))
    }

    func didReceiveProtocolError(_ error: GPTDSProtocolErrorEvent) {
        SentryFacade.shared.capture(error: ThreeDSError.protocolError(error))
        output?.didContinuePayment(.error(.protocolError(error)))
    }

    func didReceiveRuntimeError(_ error: GPTDSRuntimeErrorEvent) {
        SentryFacade.shared.capture(error: ThreeDSError.runtimeError(error))
        output?.didContinuePayment(.error(.runtimeError(error)))
    }
}

// MARK: - OrderStatusWorkerDelegate

extension PaymentInteractor: OrderStatusWorkerDelegate {
    func didGetStatusUpdate(_ result: Result<PaymentOrderStatusEvent, OrderStatusError>) {
        output?.stopLoading()

        switch result {
        case .success(let event):
            guard let status = event.order.status else {
                SentryFacade.shared.capture(error: DecodingSentryError.getOrderResponse)
                output?.didContinuePayment(.error(.unknown(APIError.invalidResponse)))
                return
            }

            let resultModel = ResultDataModel(
                order: .init(
                    id: event.order.id,
                    status: status,
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
            )

            switch status {
            case .paid, .partiallyRefunded, .refunded, .recurrenceActive, .recurrenceClose:
                orderStatusWorker.stopFetching()
                output?.didContinuePayment(.success(resultModel))

            case .declined, .cancelled, .expired:
                orderStatusWorker.stopFetching()
                output?.didContinuePayment(.unsuccess(resultModel))

            case .created:
                break
            }

        case .failure(let error):
            orderStatusWorker.stopFetching()

            SentryFacade.shared.capture(error: DataError.fetchOrderStatusFailed)
            output?.didContinuePayment(.error(.unknown(error)))
        }
    }
}

// MARK: - ApplePayManagerDelegate

extension PaymentInteractor: ApplePayManagerDelegate {
    func didAuthorizePayment(result: Result<Void, ApplePayError>) {
        switch result {
        case .success:
            output?.showLoading()
            listenOrderStatus()
        case .failure(let errorType):
            switch errorType {
            case .deviceNotSupported:
                SentryFacade.shared.capture(error: ApplePaySentryError.deviceNotSupported)
                self.output?.didContinuePayment(.error(.applePayNotSupported))
            case .statusCode(let error):
                SentryFacade.shared.capture(error: ApplePaySentryError.unexpectedStatusCode(error))
                self.output?.didContinuePayment(.error(.statusCode(error)))
            default:
                break
            }
        }
    }
}
