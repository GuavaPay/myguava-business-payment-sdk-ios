//
//  PhoneNumberInputView.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 19.06.2025.
//

import UIKit

final class PhoneNumberInputView: UIView {
    /// Callback when user select phoneCountryView to show list of available countries
    var onSelect: (() -> Void)?
    /// Callback when validation of text input was triggered
    var onPhoneValidationChange: ((Bool) -> Void)?

    /// The phone number that the user entered into the input field
    var phoneNumber = ""

    /// Used to format input text, defaults to PhoneNumberTextProcessor
    let phoneTextProcessor: PhoneNumberTextProcessor
    /// Input field for entering a phone number
    let inputField = InputField(state: .enabled, placeholderText: "Phone number")

    /// Initializer
    /// - Parameter phoneTextProcessor: textProcessor of phone number for formating and validatin text from textfield
    init(phoneTextProcessor: PhoneNumberTextProcessor = PhoneNumberTextProcessor()) {
        self.phoneTextProcessor = phoneTextProcessor
        super.init(frame: .zero)
        inputField.setTextProcessor(phoneTextProcessor)
        configure()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configure phone input via country
    /// - Parameter country: selected country entity

    func configure(with country: CountryResponse) {
        phoneTextProcessor.selectedRegion = country.countryCode

        setCountryCodeText(country.phoneCode)

        updatePhoneNumberTextFieldFormat()

        phoneTextProcessor.validatePhoneNumber(phoneNumber)
    }

    /// Set country code to label
    /// - Parameter countryCode: country code text, if text not have "+" it will add automatically
    /// - Parameter countryRegion: countryRegion, iso2code: "AZ"
    func setCountryCodeText(_ countryCode: String, countryRegion: String? = nil) {
        var countryCode = countryCode

        if !countryCode.hasPrefix("+") {
            countryCode = "+\(countryCode)"
        }

        if let countryRegion {
            phoneTextProcessor.selectedRegion = countryRegion
        }

        phoneTextProcessor.selectedRegionPhoneCode = countryCode
    }


    /// Set default number to textfield when user open the screen
    /// - Parameter number: number without prefix
    /// - Parameter animated: set text to input field with animation or not, by default false
    func setNumberToTextField(_ number: String, animated: Bool = false) {
        phoneNumber = number
        let newFormattedPhoneNumber = phoneTextProcessor.updateFormatPhoneNumber(number)
        inputField.setText(newFormattedPhoneNumber, animated: animated)
    }

    /// Change state of input view
    /// - Parameter state: state of field, countryView will change state only on '.disabled' case
    func changeState(_ state: InputField.State) {
        if phoneTextProcessor.selectedRegionPhoneCode.isEmpty {
            inputField.state = .error
            inputField.bottomLeftText = "Please select country code"
        } else {
            inputField.state = state

            switch state {
            case .error:
                inputField.bottomLeftText = "Invalid phone number"
            case .disabled:
                break
            default:
                inputField.bottomLeftText = nil
            }
        }
    }

    /// Makes the input field the first responder to display the keyboard.
    func presentKeyboardForInputField() {
        _ = inputField.becomeFirstResponder()
    }

    /// Needed when user select country, we need reformat phone number input because country could be changed and formatting also should be changed too
    private func updatePhoneNumberTextFieldFormat() {
        guard !phoneNumber.isEmpty else {
            return
        }

        let newFormattedPhoneNumber = phoneTextProcessor.updateFormatPhoneNumber(phoneNumber)
        setNumberToTextField(newFormattedPhoneNumber)
    }

    private func configure() {
        configureUI()
        configureActions()
        addSubviews()
        configureLayout()
    }

    private func configureUI() {
        inputField.keyboardType = .numberPad
    }

    private func configureActions() {
        phoneTextProcessor.onPhoneValidationChange = { [weak self] isValid in
            self?.onPhoneValidationChange?(isValid)
        }

        phoneTextProcessor.didChangeText = { [weak self] text in
            self?.phoneNumber = text
        }
    }

    private func addSubviews() {
        addSubview(inputField)
    }

    private func configureLayout() {
        inputField.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(48)
        }
    }
}

// MARK: - UITextField's forwarded focus methods

extension PhoneNumberInputView {
    override var canBecomeFirstResponder: Bool {
        inputField.input.canBecomeFirstResponder
    }

    override var isFirstResponder: Bool {
        inputField.input.isFirstResponder
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        inputField.input.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        inputField.input.resignFirstResponder()
    }
}
