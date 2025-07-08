//
//  UIView+Extension.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 16.06.2025.
//

import UIKit


extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }

    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
