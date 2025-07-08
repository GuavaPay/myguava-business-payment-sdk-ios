//
//  UIApplication+Extension.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 19.06.2025.
//

import UIKit

public extension UIApplication {

    static func setRootViewController(_ viewController: UIViewController?) {
        UIApplication.shared.delegate?.window??.rootViewController = viewController
    }
}
