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
    func setCurrentContactInformation(_ data: Payer?)
    func configureSaveCards(_ saveCards: [SavedCardsView.Section: [[SavedCardsCellKind]]])
    func selectSegmentControl(index: Int) 
    func hideApplePayment()
    func disablePaymentCard()
    func disableAllPayments()
    func disableSaveCards()
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
    func didCloseView()
    func didTapScanCard()
    func didTapContactInformationSaveButton(phoneNumber: String, email: String)
}

protocol PaymentInteractorInput {
    var availableCardSchemes: [CardScheme] { get }

    func getOrder(shouldRetry: Bool)
    func preCreatePayment(cardInfo: CardInfo, contactInfo: ContactInfo?)
    func payApple()
    func resolveCardNumber(_ cardNumber: String)
    func getCountries()
}

protocol PaymentInteractorOutput: AnyObject {
    func didGetOrder(_ order: PaymentDTO)
    func didNotGetOrder(_ error: Error)
    func didNotPreCreateOrder(_ error: Error)
    func didExecutePayment(_ status: PaymentStatus)
    func didGetCountries(_ countries: [CountryResponse])
    func didResolveCardNumber(_ model: ResolveCard?)
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
    func showPopup(
        deleteAction: (() -> Void)?,
        cancelAction: (() -> Void)?
    )
    func showEditCardNamePopup(
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
}
