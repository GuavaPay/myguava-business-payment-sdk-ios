//
//  PaymentProtocols.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 16.06.2025.
//

import Foundation
import class UIKit.UIViewController
import Guavapay3DS2

protocol PaymentViewInput: AnyObject {
    func showLoading(_ isLoading: Bool)
    func closeView()
    func configureConfirmButton(with state: Button.State)
    func configureConfirmButton(text: String)
    func showCardNumberState(_ state: CardNumberState)
    func showSecurityCodeState(_ state: CardSecurityCodeState)
    func showAvailableCardSchemes(_ icons: [UIImage])
    func configureSelectCountry(_ country: CountryResponse)
    func configureValidEmailField(_ isValid: Bool)
    func setCardNumber(_ model: CardScannerModel)
    func setSecurityCodeLength(_ length: Int)
    func setCurrentContactInformation(_ data: Payer?)
    func configureSaveCards(_ saveCards: [SavedCardsView.Section: [[SavedCardsCellKind]]])
    func selectSegmentControl(index: Int)
    func hideApplePayment()
    func disablePaymentCard()
    func disableAllPayments()
    func disableSaveCards()
    func hideSaveCards(_ isHidden: Bool)
    func hideCardholderInput()
    func setIsBindingAvailable(_ isBindingAvailable: Bool)
    func nextActiveInputIfAvailable()
}

protocol PaymentViewOutput {
    func viewDidLoad()
    func didTapApplePay()
    func didChangeCardNumber(digits: String)
    func didEndEditing(field: CardInformationView.Field)
    func didTapSelectPhoneCodeButton()
    func didTapDeleteCardButton(indexPath: IndexPath)
    func didTapEditCardButton(indexPath: IndexPath)
    func didTapConfirmButton()
    func didCloseViewByUser()
    func didTapScanCard()
    func didTapSaveNewCard(_ needSaveNewCard: Bool)
    func didChangeNewCardName(_ name: String)
    func didSelectSavedCards(_ showSaveCards: Bool)
    func didChangeSavedCardCVV(_ indexPath: IndexPath, code: String)
    func didTapContactInformationSaveButton(phoneNumber: String, email: String)
    func didTapChangeInfo(editing: Bool)
    func userDidTapClose(confirmAction: @escaping () -> Void)
}

protocol PaymentInteractorInput {
    func getOrder(shouldRetry: Bool)
    func listenOrderStatus()
    func executePayment(
        paymentMethod: PaymentMethodRequest,
        newCardName: String?,
        contactInfo: ContactInfo?,
        saveCard: Bool
    )
    func payApple()
    func resolveCardNumber(_ cardNumber: String)
    func getCountries()
    func renameCard(bindingId: String, name: String, completion: @escaping () -> Void)
    func deleteCard(bindingId: String, completion: @escaping () -> Void)
}

protocol PaymentInteractorOutput: AnyObject {
    func didGetOrder(_ order: PaymentDTO)
    func didNotGetOrder(_ error: Error)
    func didNotExecutePayment(_ errorStatus: OrderStatusError)
    func didContinuePayment(_ status: PaymentStatus)
    func didGetCountries(_ countries: [CountryResponse])
    func didResolveCardNumber(_ model: ResolveCard?)
    func setIsBindingAvailable(_ isBindingAvailable: Bool)
    func hideCardholderInput()
    func showLoading()
    func stopLoading()
}

protocol PaymentStatusReceiverDelegate: AnyObject {
    func didCompleteChallenge(withSuccess: Bool)
    func didCancelChallenge()
    func didTimeoutChallenge()
    func didReceiveProtocolError(_ error: GPTDSProtocolErrorEvent)
    func didReceiveRuntimeError(_ error: GPTDSRuntimeErrorEvent)
}

protocol PaymentRouterInput: Router {
    func openSelectCountry(
        selectedCountry: CountryResponse?,
        output: SelectCountryCodeModuleOutput?
    )
    func showDeleteCardPopup(
        cardName: String,
        deleteAction: (() -> Void)?,
        cancelAction: (() -> Void)?
    )
    func showEditCardNamePopup(
        currentName: String?,
        saveAction: (() -> Void)?,
        cancelAction: (() -> Void)?,
        editCardName: ((String) -> Void)?
    )
    func openQRCodeScanner(
        title: String,
        output: QRCodeScannerModuleOutput?
    )
    func showCardScanner(output: CardScannerDelegate)
    func showErrorConnectionPopup(
        title: String,
        subtitle: String,
        cancelAction: @escaping () -> Void
    )
    func showClosePaymentPopup(
        confirmAction: @escaping () -> Void
    )
}
