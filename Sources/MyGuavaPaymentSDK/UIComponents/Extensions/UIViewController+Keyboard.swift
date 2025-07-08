//
//  UIViewController+Keyboard.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 27.06.2025.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround(customView: UIView? = nil) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        (customView ?? view).addGestureRecognizer(tap)
    }

    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
