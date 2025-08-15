//
//  PaymentPresenter.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 16.06.2025.
//

import Foundation
import UIKit

final class PaymentPresenter: PaymentViewOutput {

    private let interactor: PaymentInteractorInput
    private let router: PaymentRouterInput
    private weak var moduleOutput: PaymentDelegate?

    private weak var view: PaymentViewInput?
    private var paymentViewModel: PaymentViewModel?

    private var payment: PaymentDTO?

    private var selectedCountry: CountryResponse? {
        didSet {
            guard let selectedCountry else { return }
            view?.configureSelectCountry(selectedCountry)
        }
    }

    private var email: String? {
        didSet {
            view?.configureValidEmailField( email?.isValidEmail ?? false)
        }
    }

    private var cardNameForEdit: String?

    private var shouldUseSavedCard: Bool = true

    private var saveCards: [SavedCardsView.Section: [[SavedCardsCellKind]]] = [:] {
        didSet {
            view?.configureSaveCards(saveCards)
        }
    }

    // MARK: - Lifecycle

    init(
        interactor: PaymentInteractorInput,
        view: PaymentViewInput,
        router: PaymentRouterInput,
        moduleOutput: PaymentDelegate?
    ) {
        self.interactor = interactor
        self.view = view
        self.router = router
        self.moduleOutput = moduleOutput
    }

    func viewDidLoad() {
        view?.showLoading(true)
        interactor.getOrder(shouldRetry: true)
        interactor.listenOrderStatus()
    }

    func didTapApplePay() {
        interactor.payApple()
    }

    func didChangeCardNumber(digits: String) {
        guard digits.count >= 6 else {
            view?.configureConfirmButton(with: .disabled)
            return
        }

        interactor.resolveCardNumber(digits)
    }

    func didEndEditing(field: CardInformationView.Field) {
        view?.configureConfirmButton(with: .disabled)

        switch field {
        case let .cardNumber(number):
            paymentViewModel?.cardInfoViewModel.number = number
        case let .expirationDate(month, year):
            paymentViewModel?.cardInfoViewModel.expiryYear = year
            paymentViewModel?.cardInfoViewModel.expiryMonth = month
        case let .securityCode(code):
            paymentViewModel?.cardInfoViewModel.cvv = String(code ?? 0)
        case let .cardName(text):
            paymentViewModel?.cardInfoViewModel.cardName = text
        case let .cardHolderName(text):
            paymentViewModel?.cardInfoViewModel.cardholderName = text
        }
        validateCardPaymentInfo()
        view?.nextActiveInputIfAvailable()
    }

    func didTapSelectPhoneCodeButton() {
        router.openSelectCountry(selectedCountry: selectedCountry, output: self)
    }

    func didTapEditCardButton(indexPath: IndexPath) {
        let binding: Binding? = switch indexPath.section {
        case 0:
            paymentViewModel?.validSaveCards[safe: indexPath.row]
        case 1:
            paymentViewModel?.invalidSaveCards[safe: indexPath.row]
        default:
            nil
        }

        router.showEditCardNamePopup(currentName: binding?.name) { [weak self] in
            guard let bindingId = binding?.id, let cardName = self?.cardNameForEdit else { return }

            self?.interactor.renameCard(bindingId: bindingId, name: cardName) { [weak self] in
                self?.view?.showLoading(true)
                self?.interactor.getOrder(shouldRetry: true)
            }

        } cancelAction: { [weak self] in
            self?.cardNameForEdit = nil
        } editCardName: { [weak self] newName in
            self?.cardNameForEdit = newName
        }

    }

    func didTapDeleteCardButton(indexPath: IndexPath) {
        let binding: Binding? = switch indexPath.section {
        case 0:
            paymentViewModel?.validSaveCards[safe: indexPath.row]
        case 1:
            paymentViewModel?.invalidSaveCards[safe: indexPath.row]
        default:
            nil
        }

        let cardName = binding?.name
        let cardNumber = String(binding?.cardData?.maskedPan?.suffix(5) ?? "")
        let cardNameWithNumber = "\(cardName ?? "") \(cardNumber)"

        router.showDeleteCardPopup(cardName: cardNameWithNumber) { [weak self] in
            guard let bindingId = binding?.id else { return }

            self?.interactor.deleteCard(bindingId: bindingId) { [weak self] in
                self?.view?.showLoading(true)
                self?.interactor.getOrder(shouldRetry: true)
            }
        } cancelAction: {}
    }

    func didTapConfirmButton() {
        guard let viewModel = paymentViewModel?.cardInfoViewModel else { return }

        view?.configureConfirmButton(with: .loading)

        let contactViewModel = paymentViewModel?.contactInfoViewModel

        let cardInfo = CardInfo(
            number: viewModel.number,
            expiryMonth: viewModel.expiryMonth,
            expiryYear: viewModel.expiryYear,
            cvv: Int(viewModel.cvv) ?? 0,
            newCardName: viewModel.cardName,
            cardholderName: viewModel.cardholderName
        )

        let bindingInfo = BindingInfo(
            bindingId: paymentViewModel?.bindingInfoViewModel.bindingId,
            cvv2: paymentViewModel?.bindingInfoViewModel.cvv2
        )

        let hasContactInfo = contactViewModel?.hasContactInfo ?? false
        let contactInfo: ContactInfo? = hasContactInfo ? ContactInfo(
            countryCode: contactViewModel?.countryPhoneCode,
            nationalNumber: contactViewModel?.nationalNumber,
            contactEmail: contactViewModel?.contactEmail
        ) : nil

        let paymentMethod: PaymentMethodRequest = if shouldUseSavedCard {
            .paymentCardBinding(
                BindingMethod(
                    bindingId: bindingInfo.bindingId,
                    cvv2: bindingInfo.cvv2
                )
            )
        } else {
            .paymentCardMethod(
                PaymentCardMethod(
                    pan: cardInfo.number,
                    cvv2: cardInfo.cvv,
                    expiryDate: cardInfo.expiryDate,
                    cardholderName: cardInfo.cardholderName
                )
            )
        }

        interactor.executePayment(
            paymentMethod: paymentMethod,
            newCardName: cardInfo.newCardName,
            contactInfo: contactInfo,
            saveCard: paymentViewModel?.needSaveNewCard ?? false
        )
    }

    func didCloseViewByUser() {
        moduleOutput?.handlePaymentResult(.cancel)
    }

    func didTapScanCard() {
        router.showCardScanner(output: self)
    }

    func didTapSaveNewCard(_ needSaveNewCard: Bool) {
        paymentViewModel?.needSaveNewCard = needSaveNewCard
    }

    func didChangeNewCardName(_ name: String) {
        paymentViewModel?.cardInfoViewModel.cardName = name
    }

    func didSelectSavedCards(_ showSaveCards: Bool) {
        shouldUseSavedCard = showSaveCards
        if shouldUseSavedCard {
            validateBindingPaymentInfo()
        } else {
            validateCardPaymentInfo()
        }
    }

    func didChangeSavedCardCVV(_ indexPath: IndexPath, code: String) {
        view?.configureConfirmButton(with: .disabled)

        guard let binding = paymentViewModel?.validSaveCards[safe: indexPath.row],
              let bindingId = binding.id,
              let cvv = Int(code) else {
            return
        }

        paymentViewModel?.bindingInfoViewModel.bindingId = bindingId
        paymentViewModel?.bindingInfoViewModel.cvv2 = cvv

        validateBindingPaymentInfo()
    }

    func didTapContactInformationSaveButton(phoneNumber: String, email: String) {
        paymentViewModel?.contactInfoViewModel.nationalNumber = phoneNumber.isEmpty ? nil : phoneNumber
        paymentViewModel?.contactInfoViewModel.contactEmail = email.isEmpty ? nil : email

        paymentViewModel?.payer?.contactEmail = paymentViewModel?.contactInfoViewModel.contactEmail
        paymentViewModel?.payer?.contactPhone = ContactPhone(
            countryCode: paymentViewModel?.contactInfoViewModel.countryPhoneCode,
            nationalNumber: paymentViewModel?.contactInfoViewModel.nationalNumber
        )

        view?.setCurrentContactInformation(paymentViewModel?.payer)
    }
}

// MARK: - PaymentInteractorOutput

extension PaymentPresenter: PaymentInteractorOutput {

    func hideCardholderInput() {
        view?.hideCardholderInput()
    }

    func showLoading() {
        view?.showLoading(true)
    }

    func stopLoading() {
        view?.showLoading(false)
    }

    func setIsBindingAvailable(_ isBindingAvailable: Bool) {
        view?.setIsBindingAvailable(isBindingAvailable)
    }

    func didGetOrder(_ payment: PaymentDTO) {
        let viewModel = PaymentViewModel(payment: payment)

        view?.configureConfirmButton(text: viewModel.confirmText)
        view?.setCurrentContactInformation(viewModel.payer)
        view?.showAvailableCardSchemes(viewModel.availableCardSchemes.compactMap { $0.icon })

        prepareApplePayState(viewModel: viewModel)
        preparePaymentCardState(viewModel: viewModel)
        prepareSaveCardsState(viewModel: viewModel)

        view?.showLoading(false)
        paymentViewModel = viewModel

        interactor.getCountries()
    }

    func didNotGetOrder(_ error: Error) {
        view?.showLoading(false)
        SentryFacade.shared.capture(error: DataError.didNotGetOrder)

        router.showErrorConnectionPopup(
            title: "Timeout Exceeded",
            subtitle: "Check your internet connection and try again. If the issue persists, the server may be temporarily unavailable. Please try again later."
        ) { [weak self] in
            self?.view?.disableAllPayments()
            self?.moduleOutput?.handleOrderDidNotGet()
        }
    }

    func didNotExecutePayment(_ errorStatus: OrderStatusError) {
        finishPayment(withStatus: .error(errorStatus))
    }

    func didContinuePayment(_ status: PaymentStatus) {
        finishPayment(withStatus: status)
    }

    func didResolveCardNumber(_ model: ResolveCard?) {
        guard let model else {
            view?.showCardNumberState(.error(text: "Invalid card number"))
            return
        }

        guard paymentViewModel?.availableCardSchemes.contains(model.cardScheme) == true else {
            view?.showCardNumberState(.error(text: "This card not supported"))
            return
        }

        let paymentSystem = CreditCardType(from: model.cardScheme)
        view?.showCardNumberState(.normal(viewModel: .init(image: paymentSystem.icon)))

        guard let cvv = paymentViewModel?.cardInfoViewModel.cvv, !cvv.isEmpty else {
            view?.setSecurityCodeLength(model.cardScheme.cvvLength)
            return
        }

        guard model.cardScheme.cvvLength == paymentViewModel?.cardInfoViewModel.cvv.count ?? 0 else {
            view?.showSecurityCodeState(.error(text: "Invalid code"))
            return
        }

        let isCardInfoValid = paymentViewModel?.cardInfoViewModel.isValid ?? false
        let isContactInfoValid = paymentViewModel?.contactInfoViewModel.isValid ?? false

        view?.showSecurityCodeState(.normal)
        view?.configureConfirmButton(with: isCardInfoValid && isContactInfoValid ? .enabled : .disabled)
    }

    func didGetCountries(_ countries: [CountryResponse]) {
        let deviceIso2Code = NSLocale.current.regionCode
        let deviceCountry = countries.first(where: {
            $0.countryCode == deviceIso2Code
        })
        if let deviceCountry {
            didSelectCountry(deviceCountry)
        }
    }

    func didTapChangeInfo(editing: Bool) {
        paymentViewModel?.contactInfoViewModel.contactInfoInEditingMode = editing

        validatePaymentInfo()
    }
}

// MARK: - SelectCountryCodeModuleOutput

extension PaymentPresenter: SelectCountryCodeModuleOutput {
    func didSelectCountry(_ country: CountryResponse) {
        selectedCountry = country

        paymentViewModel?.contactInfoViewModel.countryPhoneCode = country.phoneCode
    }
}

// MARK: - CreditCardScannerDelegate

extension PaymentPresenter: CardScannerDelegate {
    func cardScannerViewControllerDidCancel(_ viewController: CardScannerViewController) {
        viewController.dismiss(animated: true)
    }

    func cardScannerViewController(
        _ viewController: CardScannerViewController,
        didErrorWith _: CardScannerError
    ) {
        viewController.dismiss(animated: true)
    }

    func cardScannerViewController(
        _ viewController: CardScannerViewController,
        didFinishWith card: CardScannerModel
    ) {
        viewController.dismiss(animated: true)
        view?.setCardNumber(card)
    }
}

// MARK: - Private

private extension PaymentPresenter {
    func prepareApplePayState(viewModel: PaymentViewModel) {
        guard !viewModel.isAvailableApplePay else { return }
        view?.hideApplePayment()
    }

    func preparePaymentCardState(viewModel: PaymentViewModel) {
        guard !viewModel.isCardPaymentAvailable else { return }
        view?.disablePaymentCard()
    }

    func prepareSaveCardsState(viewModel: PaymentViewModel) {
        var savedCards: [SavedCardsView.Section: [[SavedCardsCellKind]]] = [:]

        let validCards: [SavedCardsCellKind] = viewModel.validSaveCards.compactMap { .card($0) }
        let invalidCards: [SavedCardsCellKind] = viewModel.invalidSaveCards.compactMap { .card($0) }

        switch (validCards.isEmpty, invalidCards.isEmpty) {
        case (false, false):
            savedCards[.savedCards] = [validCards, invalidCards]
            view?.selectSegmentControl(index: 0)

        case (false, true):
            savedCards[.savedCards] = [validCards]
            view?.selectSegmentControl(index: 0)

        case (true, false):
            savedCards[.savedCards] = [invalidCards]
            view?.selectSegmentControl(index: 1)

        case (true, true):
            shouldUseSavedCard = false
            view?.disableSaveCards()
            return
        }

        view?.configureSaveCards(savedCards)
    }

    func validatePaymentInfo() {
        if shouldUseSavedCard {
            validateBindingPaymentInfo()
        } else {
            validateCardPaymentInfo()
        }
    }

    func validateCardPaymentInfo() {
        /// Start with local validation
        guard let cardNumber = paymentViewModel?.cardInfoViewModel.number, !cardNumber.isEmpty else {
            view?.configureConfirmButton(with: .disabled)
            return
        }

        guard cardNumber.count >= 13 else {
            view?.showCardNumberState(.error(text: "Card number too short"))
            view?.configureConfirmButton(with: .disabled)
            return
        }

        guard CCValidator.validate(cardNumber: cardNumber) else {
            view?.showCardNumberState(.error(text: "Incorrect card number"))
            view?.configureConfirmButton(with: .disabled)
            return
        }

        guard paymentViewModel?.contactInfoViewModel.isValid == true else {
            view?.configureConfirmButton(with: .disabled)
            return
        }

        interactor.resolveCardNumber(cardNumber)
    }

    func validateBindingPaymentInfo() {
        guard let bindingInfoViewModel = paymentViewModel?.bindingInfoViewModel else {
            view?.configureConfirmButton(with: .disabled)
            return
        }

        let bindingIdIsValid = !bindingInfoViewModel.bindingId.isEmpty
        let cvvIsValid = String(bindingInfoViewModel.cvv2).count >= 3
        let isContactInfoValid = paymentViewModel?.contactInfoViewModel.isValid ?? false

        view?.configureConfirmButton(with: bindingIdIsValid && cvvIsValid && isContactInfoValid ? .enabled : .disabled)
    }

    func finishPayment(withStatus status: PaymentStatus) {
        view?.configureConfirmButton(with: .enabled)
        view?.closeView()

        moduleOutput?.handlePaymentResult(status)
    }
}
