//
//  UITextField+.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 13.06.2025.
//

import UIKit

extension UITextField {
    func setLeftPadding(_ spacer: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: spacer, height: 0))
        leftViewMode = .always
    }
}

extension UITextField {
    /// Saves cursor position after our changes
    /// - Parameters:
    ///   - textField: TextField we work with
    ///   - formattedString: new string
    ///   - isBackspace: is backspace action
    func saveCursorPosition(
        formattedString: String,
        isBackspace: Bool
    ) {
        let oldSelectedRange = selectedTextRange
        var oldCursorPosition: Int?
        if let oldSelectedRange {
            oldCursorPosition = offset(from: beginningOfDocument, to: oldSelectedRange.start)
        }

        let oldLength = (text ?? "").count

        text = formattedString

        if let oldSelectedRange {
            let newLength = (text ?? "").count
            if isBackspace, newLength == oldLength {
                if let newPosition = position(from: oldSelectedRange.start, offset: -1) {
                    selectedTextRange = textRange(from: newPosition, to: newPosition)
                }
            } else {
                if isBackspace && oldCursorPosition == 1 {
                    let newPosition = beginningOfDocument
                    selectedTextRange =
                    textRange(from: newPosition, to: newPosition)
                } else {
                    if let newPosition = position(
                        from: oldSelectedRange.start,
                        offset: newLength - oldLength
                    ) {
                        selectedTextRange =
                        textRange(from: newPosition, to: newPosition)
                    }
                }
            }
        }
    }
}
