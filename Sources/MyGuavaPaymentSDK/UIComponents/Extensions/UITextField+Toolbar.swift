//
//  UITextField+Toolbar.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 27.06.2025.
//

import UIKit

extension UITextField {

    func addKeyboardArrowToToolbar(
        onDone: (target: Any, action: Selector),
        onUpArrow: (target: Any, action: Selector),
        onDownArrow: (target: Any, action: Selector)
    ) {
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(
                image: UIImage(systemName: "chevron.up"),
                style: .plain,
                target: onUpArrow.target,
                action: onUpArrow.action
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "chevron.down"),
                style: .plain,
                target: onDownArrow.target,
                action: onDownArrow.action
            ),
            UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: self,
                action: nil
            ),
            UIBarButtonItem(
                title: "Done",
                style: .done,
                target: onDone.target,
                action: onDone.action
            )
        ]
        toolbar.sizeToFit()

        inputAccessoryView = toolbar
    }

    func addKeyboardDoneToToolbar() {
        let onDone: (target: Any, action: Selector) = (self,  #selector(doneButtonTapped))
        let toolbar: UIToolbar = UIToolbar()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.barStyle = .default
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: onDone.target,
            action: onDone.action
        )
        doneButton.tintColor = .systemBlue
        doneButton.setTitleTextAttributes(
            [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
            ],
            for: .normal
        )
        toolbar.items = [
            flexibleSpace,
            doneButton
        ]
        toolbar.sizeToFit()
        inputAccessoryView = toolbar
    }

    @objc
    private func doneButtonTapped() {
        endEditing(true)
    }
}
