//
//  GPUICustomization.swift
//  MyGuavaPaymentSDK
//

import UIKit
import Guavapay3DS2

/// Container for all UI customization components including common, button, label, input, and selection settings.
public struct GPUICustomization {
    /// Default customization instance with all components set to default values.
    public static let `default` = GPUICustomization(
        common: .default,
        button: .default,
        label: .default,
        input: .default,
        selectItem: .default
    )

    /// Common appearance customization settings.
    public var common: GPCommonCustomization
    /// Button appearance customization settings.
    public var button: GPButtonCustomization
    /// Label appearance customization settings.
    public var label: GPLabelCustomization
    /// Input field appearance customization settings.
    public var input: GPInputCustomization
    /// Selection item appearance customization settings.
    public var selectItem: GPSelectItemCustomization

    /// Initializer
    /// - Parameters:
    ///   - common: Common appearance customization settings.
    ///   - button: Button appearance customization settings.
    ///   - label: Label appearance customization settings.
    ///   - input: Input field appearance customization settings.
    ///   - selectItem: Selection item appearance customization settings.
    public init(
        common: GPCommonCustomization,
        button: GPButtonCustomization,
        label: GPLabelCustomization,
        input: GPInputCustomization,
        selectItem: GPSelectItemCustomization
    ) {
        self.common = common
        self.button = button
        self.label = label
        self.input = input
        self.selectItem = selectItem
    }
}

/// Customization for common UI elements, such as backgrounds and dividers.
public struct GPCommonCustomization {
    /// Default common customization with standard background and divider colors.
    public static let `default` = GPCommonCustomization()

    /// Primary background color.
    public var backgroundColor: UIColor
    /// Secondary background color.
    public var backgroundSecondaryColor: UIColor
    /// Divider line color.
    public var dividerColor: UIColor

    /// Initializer
    /// - Parameters:
    ///   - backgroundColor: Primary background color.
    ///   - backgroundSecondaryColor: Secondary background color.
    ///   - dividerColor: Divider line color.
    public init(
        backgroundColor: UIColor = .background.primary,
        backgroundSecondaryColor: UIColor = .background.primary,
        dividerColor: UIColor = .background.divider
    ) {
        self.backgroundColor = backgroundColor
        self.backgroundSecondaryColor = backgroundSecondaryColor
        self.dividerColor = dividerColor
    }
}

/// Customization for buttons
public struct GPButtonCustomization {
    /// Default button customization with standard colors and no border.
    public static let `default` = GPButtonCustomization()

    /// Button primary background color.
    public var backgroundPrimary: UIColor
    /// Button secondary background color.
    public var backgroundSecondary: UIColor
    /// Button corner radius.
    public var cornerRadius: CGFloat
    /// Button text color.
    public var textColor: UIColor
    /// Button border color.
    public var borderColor: UIColor
    /// Button border width.
    public var borderWidth: CGFloat

    /// Initializer
    /// - Parameters:
    ///   - backgroundPrimary: Primary background color.
    ///   - backgroundSecondary: Secondary background color.
    ///   - cornerRadius: Corner radius.
    ///   - textColor: Text color.
    ///   - borderColor: Border color.
    ///   - borderWidth: Border width.
    public init(
        backgroundPrimary: UIColor = .button.primaryBackgroundRest,
        backgroundSecondary: UIColor = .gray200,
        cornerRadius: CGFloat = .radius200,
        textColor: UIColor = .foreground.onAccent,
        borderColor: UIColor = .clear,
        borderWidth: CGFloat = 0.0
    ) {
        self.backgroundPrimary = backgroundPrimary
        self.backgroundSecondary = backgroundSecondary
        self.cornerRadius = cornerRadius
        self.textColor = textColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}

/// Customization for label text colors.
public struct GPLabelCustomization {
    /// Default label customization with standard primary and secondary colors.
    public static let `default` = GPLabelCustomization()

    /// Primary text color for labels.
    public var textPrimaryColor: UIColor
    /// Secondary text color for labels.
    public var textSecondaryColor: UIColor

    /// Initializer
    /// - Parameters:
    ///   - textPrimaryColor: Primary text color for labels.
    ///   - textSecondaryColor: Secondary text color for labels.
    public init(
        textPrimaryColor: UIColor = .input.primaryForeground,
        textSecondaryColor: UIColor = .input.secondaryForeground
    ) {
        self.textPrimaryColor = textPrimaryColor
        self.textSecondaryColor = textSecondaryColor
    }
}

/// Customization for input fields
public struct GPInputCustomization {
    /// Default input customization with standard styling for text fields.
    public static let `default` = GPInputCustomization()

    /// Input field background color.
    public var backgroundColor: UIColor
    /// Input field corner radius.
    public var cornerRadius: CGFloat
    /// Input text color.
    public var textColor: UIColor
    /// Placeholder text color.
    public var placeholderTextColor: UIColor
    /// Input field border color.
    public var borderColor: UIColor
    /// Input field border width.
    public var borderWidth: CGFloat

    /// Initializer
    /// - Parameters:
    ///   - backgroundColor: Background color.
    ///   - cornerRadius: Corner radius.
    ///   - textColor: Text color.
    ///   - placeholderTextColor: Placeholder text color.
    ///   - borderColor: Border color.
    ///   - borderWidth: Border width.
    public init(
        backgroundColor: UIColor = .gray200,
        cornerRadius: CGFloat = .radius200,
        textColor: UIColor = .input.primaryForeground,
        placeholderTextColor: UIColor = .foreground.secondary,
        borderColor: UIColor = .input.borderRest,
        borderWidth: CGFloat = 1.0
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.textColor = textColor
        self.placeholderTextColor = placeholderTextColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}

/// Customization for selection items (checkboxes and radio buttons)
public struct GPSelectItemCustomization {
    /// Default select item customization with standard accent color.
    public static let `default` = GPSelectItemCustomization()

    /// Accent color used for selected items.
    public var accentColor: UIColor

    /// Initializer
    /// - Parameter accentColor: accent color for selected item
    public init(
        accentColor: UIColor = .button.primaryBackgroundRest
    ) {
        self.accentColor = accentColor
    }
}

// MARK: - Conversion to GPTDSUICustomization

extension GPTDSUICustomization {

    /// Creates a GPTDSUICustomization by mapping values from a GPUICustomization instance.
    /// - Parameter customization: PSDK customization model
    convenience init(from customization: GPUICustomization) {
        let defaultSettings = GPTDSUICustomization.defaultSettings()
        self.init()

        // Copy default settings
        self.navigationBarCustomization = defaultSettings.navigationBarCustomization
        self.labelCustomization = defaultSettings.labelCustomization
        self.textFieldCustomization = defaultSettings.textFieldCustomization
        self.footerCustomization = defaultSettings.footerCustomization
        self.selectionCustomization = defaultSettings.selectionCustomization
        self.backgroundColor = defaultSettings.backgroundColor
        self.activityIndicatorViewStyle = defaultSettings.activityIndicatorViewStyle
        self.blurStyle = defaultSettings.blurStyle
        self.preferredStatusBarStyle = defaultSettings.preferredStatusBarStyle

        // Map common customization
        self.backgroundColor = customization.common.backgroundColor

        // Map navigation bar customization
        navigationBarCustomization.headerText = "Secure Checkout"
        navigationBarCustomization.buttonText = "Cancel"

        // Map label customization
        labelCustomization.headingTextColor = customization.label.textPrimaryColor

        // Map text field customization
        textFieldCustomization.borderWidth = customization.input.borderWidth
        textFieldCustomization.borderColor = customization.selectItem.accentColor
        textFieldCustomization.cornerRadius = customization.input.cornerRadius
        textFieldCustomization.placeholderTextColor = customization.input.placeholderTextColor

        // Map footer customization
        footerCustomization.backgroundColor = customization.common.backgroundColor
        footerCustomization.chevronColor = customization.label.textPrimaryColor
        footerCustomization.headingTextColor = customization.label.textPrimaryColor

        // Map button customization
        let buttonCustomization = defaultSettings.buttonCustomization(for: .submit)

        buttonCustomization.backgroundColor = customization.button.backgroundPrimary
        buttonCustomization.cornerRadius = customization.button.cornerRadius

        for buttonType in [GPTDSUICustomizationButtonType.submit, .continue, .next] {
            self.setButton(buttonCustomization, for: buttonType)
        }

        // Map selection item customization
        selectionCustomization.primarySelectedColor = customization.selectItem.accentColor
        selectionCustomization.secondarySelectedColor = customization.common.backgroundColor
        selectionCustomization.unselectedBackgroundColor = customization.common.backgroundColor
        selectionCustomization.unselectedBorderColor = customization.selectItem.accentColor
    }
}
