//
//  File.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 19.06.2025.
//

import UIKit

/// Default implementation for InputFieldTextProcessor
/// does no validation or formatting, triggers didChangeText callback for every character change
public class DefaultTextProcessor: InputFieldTextProcessor {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        didChangeText?(newString)
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didShouldReturn?()
        return true
    }
}
