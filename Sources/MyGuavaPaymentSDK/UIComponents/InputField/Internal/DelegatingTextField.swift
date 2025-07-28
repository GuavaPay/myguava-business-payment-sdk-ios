//
//  DelegatingTextField.swift
//
//
//  Created by Nikolay Kryuchkov on 27.11.2024.
//

import UIKit

/// Delegate of custom text field that can handle tap of backspace key
protocol DeletionTextFieldDelegate: AnyObject {
    /// When backspace key was tapped (even when text is already empty)
    /// - Parameter textField: source text field
    func didPressDelete(on textField: UITextField)
}

/// Delegate of custom text field to notify on text paste
protocol PastingTextFieldDelegate: AnyObject {
    /// When user paste text in text field
    /// - Parameters:
    ///   - text: pasted text
    ///   - textField: source text field
    func didPaste(_ text: String, on textField: UITextField)
}

/// Text field that notify its delegate on some event that are not covered by UITextFieldDelegate
final class DelegatingTextField: UITextField {
    /// Delegate that will be notified on tap of backspace key
    weak var deleteDelegate: DeletionTextFieldDelegate?

    /// Delegate that will be notified on paste event
    weak var pastingDelegate: PastingTextFieldDelegate?

    init() {
        super.init(frame: .zero)
        addKeyboardDoneToToolbar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func deleteBackward() {
        super.deleteBackward()
        deleteDelegate?.didPressDelete(on: self)
    }

    override func paste(_ sender: Any?) {
        super.paste(sender)
        if let pastedString = UIPasteboard.general.string {
            pastingDelegate?.didPaste(pastedString, on: self)
        }
    }
}
