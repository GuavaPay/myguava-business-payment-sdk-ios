//
//  PhoneNumberTextProcessor.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 19.06.2025.
//

import UIKit
import PhoneNumberKit

/// TextProcessor that is delegate of InputField, needed to configure some logic of textfield for phone number
final class PhoneNumberTextProcessor: InputFieldTextProcessor {
    /// Callback when something was changed in textField and there was validation check for that new text. It returns result of phoneNumberKit validation
    var onPhoneValidationChange: ((Bool) -> Void)?

    /// iso2Code region of selected country
    var selectedRegion: String = "" {
        didSet {
            partialFormatter.defaultRegion = selectedRegion
        }
    }

    /// Phonecode of selected country
    var selectedRegionPhoneCode: String = ""

    private let partialFormatter = PartialFormatter()
    private let phoneNumberKit = PhoneNumberKit()

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let replacementStringOnlyWithNumbers = replaceStringOnlyWithNumbers(string)

        let currentFullTextFromTextField = (textField.text ?? "") as NSString

        let mergedTextFieldStringWithReplacementString = currentFullTextFromTextField.replacingCharacters(
            in: range,
            with: replacementStringOnlyWithNumbers
        )

        let mergedTextFieldStringWithReplacementStringWithoutSpaces =
        mergedTextFieldStringWithReplacementString
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let maxLength = phoneNumberKit.possiblePhoneNumberLengths(
            forCountry: partialFormatter.currentRegion,
            phoneNumberType: .mobile,
            lengthType: .national
        ).first ?? 15

        if mergedTextFieldStringWithReplacementStringWithoutSpaces.count > maxLength {
            return false
        }

        let formattedNumberWithCountryCode = partialFormatWithPhoneNumberKit(
            countryPhoneCode: selectedRegionPhoneCode,
            numberWithoutPrefix: mergedTextFieldStringWithReplacementString
        )

        let formattedNumberWithoutCountryCode = formatFullNumberToNumberWithoutPrefix(
            formattedNumberWithCountryCode
        )

        didChangeText?(replaceStringOnlyWithNumbers(formattedNumberWithoutCountryCode))

        let cursorPositionOfCurrentText = textField.offset(
            from: textField.beginningOfDocument,
            to: textField.selectedTextRange?.start ?? textField.beginningOfDocument
        )

        textField.text = formattedNumberWithoutCountryCode

        let cursorPositionOfNewText = textField.offset(
            from: textField.beginningOfDocument,
            to: textField.selectedTextRange?.start ?? textField.beginningOfDocument
        )

        let newCursorPosition = calculateNewCursorPosition(
            currentText: currentFullTextFromTextField as String,
            newText: formattedNumberWithoutCountryCode,
            cursorPositionOfCurrentText: cursorPositionOfCurrentText,
            cursorPositionOfNewText: cursorPositionOfNewText,
            range: range,
            replacementString: string
        )

        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorPosition) {
            DispatchQueue.main.async {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }

        validatePhoneNumber(formattedNumberWithoutCountryCode)

        return false
    }

    private func calculateNewCursorPosition(
        currentText: String,
        newText: String,
        cursorPositionOfCurrentText: Int,
        cursorPositionOfNewText: Int,
        range _: NSRange,
        replacementString: String
    ) -> Int {
        guard replacementString.isEmpty, newText.count > 1 else {
            return cursorPositionOfNewText
        }

        let newCursorPosition = max(0, cursorPositionOfNewText - 1)

        if newText[newCursorPosition] == " " {
            return max(0, newCursorPosition)
        }

        if newText.contains(" "), !currentText.contains(" ") {
            return cursorPositionOfNewText
        }

        return cursorPositionOfCurrentText - 1
    }

    /// Validates the provided phone number for correctness based on the selected region and phone code
    /// - Parameter number: the phone number to validate
    func validatePhoneNumber(_ number: String) {
        if !selectedRegionPhoneCode.hasPrefix("+") {
            selectedRegionPhoneCode = "+\(selectedRegionPhoneCode)"
        }

        let phoneIsValid = phoneNumberKit.isValidPhoneNumber(
            selectedRegionPhoneCode + number,
            withRegion: selectedRegion,
            ignoreType: false
        )

        onPhoneValidationChange?(phoneIsValid)
    }

    /// As we can't directly call shouldChangeCharacters, we also needed to update textField formatting and validation when user just select another country. This method helps to reformat string and update textField from PhoneNumberInputView
    /// - Parameter number: number that need to format
    /// - Returns: string with phonenumberkit formatting without country code
    func updateFormatPhoneNumber(_ number: String) -> String {
        let replacementStringOnlyWithNumbers = replaceStringOnlyWithNumbers(number)
        let formattedNumberWithCountryCode = partialFormatWithPhoneNumberKit(
            countryPhoneCode: selectedRegionPhoneCode,
            numberWithoutPrefix: replacementStringOnlyWithNumbers
        )

        let formattedNumberWithoutCountryCode = formatFullNumberToNumberWithoutPrefix(
            formattedNumberWithCountryCode
        )

        validatePhoneNumber(formattedNumberWithoutCountryCode)
        didChangeText?(formattedNumberWithoutCountryCode)

        return formattedNumberWithoutCountryCode
    }

    private func replaceStringOnlyWithNumbers(_ number: String) -> String {
        number.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression
        )
    }

    private func partialFormatWithPhoneNumberKit(countryPhoneCode: String, numberWithoutPrefix: String) -> String {
        partialFormatter.formatPartial(
            countryPhoneCode + numberWithoutPrefix.removingWhitespaceAndNewlines()
        )
    }

    private func formatFullNumberToNumberWithoutPrefix(_ fullPhoneNumber: String) -> String {
        fullPhoneNumber
            .replacingOccurrences(of: selectedRegionPhoneCode, with: "")
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "-", with: " ")
    }
}
