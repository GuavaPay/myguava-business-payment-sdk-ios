//
//  ThemedInputContainerView.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 25.07.2025.
//

import UIKit

class ThemedInputContainerView: UIView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.layer.borderColor = UICustomization.Input.borderColor.resolvedColor(with: traitCollection).cgColor
        }
    }
}
