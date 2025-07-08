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
    private let moduleOutput: PaymentDelegate?

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
            paymentViewModel?.cardInfoViewModel.cvv = String(code)
        }
        validateCardInfo()
    }

    func didTapSelectPhoneCodeButton() {
        router.openSelectCountry(selectedCountry: selectedCountry, output: self)
    }

    func didTapEditCardButton(indexPath: IndexPath) {
        router.showEditCardNamePopup { [weak self] in
            print(self?.cardNameForEdit ?? "")
        } cancelAction: {
            print("cancelEditAction")
        } editCardName: { [weak self] newName in
            self?.cardNameForEdit = newName
        }

    }

    func didTapDeleteCardButton(indexPath: IndexPath) {
        router.showPopup {
            print("deleteAction")
        } cancelAction: {
            print("cancelAction")
        }
    }

    func didTapConfirmButton() {
        guard let viewModel = paymentViewModel?.cardInfoViewModel else { return }

        view?.configureConfirmButton(with: .loading)

        let contactViewModel = paymentViewModel?.contactInfoViewModel

        let cardInfo = CardInfo(
            number: viewModel.number,
            expiryMonth: viewModel.expiryMonth,
            expiryYear: viewModel.expiryYear,
            cvv: Int(viewModel.cvv) ?? 0
        )

        let hasContactInfo = contactViewModel?.hasContactInfo ?? false
        let contactInfo: ContactInfo? = hasContactInfo ? ContactInfo(
            countryCode: contactViewModel?.countryPhoneCode,
            nationalNumber: contactViewModel?.nationalNumber,
            contactEmail: contactViewModel?.contactEmail
        ) : nil

        interactor.preCreatePayment(
            cardInfo: cardInfo,
            contactInfo: contactInfo
        )
    }

    func didCloseView() {
        moduleOutput?.handlePaymentCancel()
    }

    func didTapScanCard() {
        router.showCardScanner(output: self)
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

    func showLoading() {
        view?.showLoading(true)
    }
    
    func stopLoading() {
        view?.showLoading(false)
    }
    
    func didGetOrder(_ payment: PaymentDTO) {
        let viewModel = PaymentViewModel(payment: payment)

        view?.configureConfirmButton(text: viewModel.confirmText)
        view?.setCurrentContactInformation(viewModel.payer)
        view?.showAvailableCardSchemes(viewModel.availableCardSchemes.compactMap { $0.icon })

        prepareApplePayState(viewModel: viewModel)
        preparePaymentCardState(viewModel: viewModel)

        view?.showLoading(false)
        paymentViewModel = viewModel

        interactor.getCountries()
    }

    func didNotGetOrder(_ error: Error) {
        view?.showLoading(false)
        router.showErrorConnectionPopup(
            title: "Timeout Exceeded",
            subtitle: "Check your internet connection and try again. If the issue persists, the server may be temporarily unavailable. Please try again later."
        ) { [weak self] in
            self?.view?.disableAllPayments()
            self?.moduleOutput?.handleOrderDidNotGet()
        }
    }

    func didNotPreCreateOrder(_ error: any Error) {
        view?.configureConfirmButton(with: .enabled)
        print("Error: \(error)")
        // Show error
    }

    func didExecutePayment(_ result: Result<ResultDataModel, OrderStatusError>) {
        view?.configureConfirmButton(with: .enabled)
        print("Payment Completed")

        view?.closeView()
        switch result {
        case .success(let model):
            moduleOutput?.handlePaymentResult(.success(model))
        case .failure(let error):
            moduleOutput?.handlePaymentResult(.failure(.unknown(error)))
        }
    }

    func didNotExecutePayment(_ error: OrderStatusError) {
        view?.configureConfirmButton(with: .enabled)
        print("Error: \(error)")

        view?.closeView()
        switch error {
        case .timeout, .protocolError, .runtimeError, .unknown, .deviceNotSupported, .statusCode:
            moduleOutput?.handlePaymentResult(.failure(error))
        case .cancelled:
            moduleOutput?.handlePaymentCancel()
        case .cancelledByUser:
            break
        }
    }

    func didResolveCardNumber(_ model: ResolveCard?) {
        guard let model else {
            view?.showCardNumberState(.error(text: "Invalid card number"))
            return
        }

        guard interactor.availableCardSchemes.contains(model.cardScheme) else {
            view?.showCardNumberState(.error(text: "This card not supported"))
            return
        }

        let paymentSystem = CreditCardType(from: model.cardScheme)
        view?.showCardNumberState(.normal(viewModel: .init(image: paymentSystem.icon)))

        guard let cvv = paymentViewModel?.cardInfoViewModel.cvv, !cvv.isEmpty else { return }

        guard model.cardScheme.cvvLength == paymentViewModel?.cardInfoViewModel.cvv.count ?? 0 else {
            view?.showSecurityCodeState(.error(text: "Invalid code"))
            return
        }

        view?.showSecurityCodeState(.normal)

        view?.configureConfirmButton(with: paymentViewModel?.cardInfoViewModel.isValid ?? false ? .enabled : .disabled)
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

    func didResolveCardNumber(_ model: ResolveCard) {
        let paymentSystem = CreditCardType(from: model.cardScheme)
        view?.showCardNumberState(.normal(viewModel: .init(image: paymentSystem.icon)))
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

    func validateCardInfo() {
        /// Start with local validation
        guard let cardNumber = paymentViewModel?.cardInfoViewModel.number, !cardNumber.isEmpty else {
            
            return
        }

        guard cardNumber.count >= 13 else {
            view?.showCardNumberState(.error(text: "Card number too short"))
            view?.configureConfirmButton(with: .disabled)
            return
        }
        guard CCValidator.validate(creditCardNumber: cardNumber) else {
            view?.showCardNumberState(.error(text: "Incorrect card number"))
            view?.configureConfirmButton(with: .disabled)
            return
        }

        /// Then validate by resolved `CardScheme` (if there is any)
        interactor.resolveCardNumber(cardNumber)
    }
}
