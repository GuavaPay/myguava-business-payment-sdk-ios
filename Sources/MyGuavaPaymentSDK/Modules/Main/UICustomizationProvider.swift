//
//  UICustomizationProvider.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 18.07.2025.
//

import UIKit

final class UICustomizationProvider {

    static let shared = UICustomizationProvider()

    var uiCustomization = GPUICustomization.default

    func setUICustomization(_ uiCustomization: GPUICustomization) {
        self.uiCustomization = uiCustomization
    }
}

enum UICustomization {

    enum Common {
        static var backgroundColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.common.backgroundColor
        }

        static var backgroundSecondaryColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.common.backgroundSecondaryColor
        }

        static var dividerColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.common.dividerColor
        }
    }


    enum Label {
        static var textColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.label.textPrimaryColor
        }

        static var secondaryTextColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.label.textSecondaryColor
        }
    }

    enum Button {
        static var backgroundColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.button.backgroundPrimary
        }

        static var secondaryBackgroundColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.button.backgroundSecondary
        }

        static var textColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.button.textColor
        }

        static var secondaryTextColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.button.secondaryTextColor
        }

        static var cornerRadius: CGFloat {
            UICustomizationProvider.shared.uiCustomization.button.cornerRadius
        }

        static var borderColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.button.borderColor
        }

        static var borderWidth: CGFloat {
            UICustomizationProvider.shared.uiCustomization.button.borderWidth
        }
    }

    enum Input {
        static var backgroundColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.input.backgroundColor
        }

        static var cornerRadius: CGFloat {
            UICustomizationProvider.shared.uiCustomization.input.cornerRadius
        }

        static var borderColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.input.borderColor
        }

        static var borderWidth: CGFloat {
            UICustomizationProvider.shared.uiCustomization.input.borderWidth
        }

        static var textColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.input.textColor
        }

        static var placeholderTextColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.input.placeholderTextColor
        }
    }

    enum SelectItem {
        static var accentColor: UIColor {
            UICustomizationProvider.shared.uiCustomization.selectItem.accentColor
        }
    }

}
