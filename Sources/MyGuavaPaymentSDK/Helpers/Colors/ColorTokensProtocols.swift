//
//  ColorTokensProtocols.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 16.06.2025.
//

import UIKit

public protocol BackgroundColorProtocol {
    static var primary: UIColor { get }
    static var secondary: UIColor { get }
    static var tertiary: UIColor { get }
    static var inverse: UIColor { get }
    static var brand: UIColor { get }
    static var brandAlt: UIColor { get }
    static var disabled: UIColor { get }
    static var disabled2: UIColor { get }
    static var info: UIColor { get }
    static var success: UIColor { get }
    static var danger: UIColor { get }
    static var warning: UIColor { get }
    static var divider: UIColor { get }
}

public protocol ForegroundColorProtocol {
    static var primary: UIColor { get }
    static var secondary: UIColor { get }
    static var onAccent: UIColor { get }
    static var onAccentSecondary: UIColor { get }
    static var disabled: UIColor { get }
    static var brand: UIColor { get }
    static var info: UIColor { get }
    static var success: UIColor { get }
    static var danger: UIColor { get }
    static var warning: UIColor { get }
}

public protocol BorderColorProtocol {
    static var primary: UIColor { get }
    static var secondary: UIColor { get }
    static var focus: UIColor { get }
}

public protocol ButtonColorProtocol {
    static var primaryBackgroundRest: UIColor { get }
    static var primaryBackgroundHover: UIColor { get }
    static var primaryBackgroundPressed: UIColor { get }
    static var primaryBackgroundDisabled: UIColor { get }

    static var primaryForegroundRest: UIColor { get }
    static var primaryForegroundDisabled: UIColor { get }

    static var secondaryBorder: UIColor { get }
    static var secondaryBackgroundHover: UIColor { get }
    static var secondaryBackgroundPressed: UIColor { get }
    static var secondaryBackgroundDisabled: UIColor { get }
    static var secondaryForegroundRest: UIColor { get }
    static var secondaryForegroundDisabled: UIColor { get }

    static var ghostBackgroundHover: UIColor { get }
    static var ghostBackgroundPressed: UIColor { get }
    static var ghostBackgroundDisabled: UIColor { get }
    static var ghostForegroundRest: UIColor { get }
    static var ghostForegroundDisabled: UIColor { get }

    static var dangerBackgroundRest: UIColor { get }
    static var dangerBackgroundHover: UIColor { get }
    static var dangerBackgroundPressed: UIColor { get }
    static var dangerBackgroundDisabled: UIColor { get }
    static var dangerForegroundRest: UIColor { get }
    static var dangerForegroundDisabled: UIColor { get }
}

public protocol ControlsColorProtocol {
    static var backgroundHover: UIColor { get }
    static var backgroundDisabled: UIColor { get }

    static var selectedBackgroundRest: UIColor { get }
    static var selectedBackgroundHover: UIColor { get }
    static var selectedForegroundRest: UIColor { get }

    static var borderRest: UIColor { get }
    static var borderDisable: UIColor { get }
}

public protocol SwitchColorProtocol {
    static var backgroundRest: UIColor { get }
    static var backgroundHover: UIColor { get }

    static var selectedBackgroundRest: UIColor { get }
    static var selectedBackgroundHover: UIColor { get }

    static var foregroundRest: UIColor { get }
}

public protocol InputColorProtocol {
    static var backgroundRest: UIColor { get }
    static var backgroundHover: UIColor { get }
    static var backgroundDisabled: UIColor { get }

    static var primaryForeground: UIColor { get }
    static var secondaryForeground: UIColor { get }
    static var dangerForeground: UIColor { get }
    static var disabledForeground: UIColor { get }

    static var borderRest: UIColor { get }
    static var borderFocused: UIColor { get }
    static var borderDanger: UIColor { get }
}

public protocol LinkColorProtocol {
    static var primaryRest: UIColor { get }
    static var primaryHover: UIColor { get }
    static var primaryDisabled: UIColor { get }

    static var secondaryRest: UIColor { get }
    static var secondaryHover: UIColor { get }
    static var secondaryDisabled: UIColor { get }
}

public protocol TabColorProtocol {
    static var backgroundRest: UIColor { get }
    static var backgroundHover: UIColor { get }

    static var foregroundRest: UIColor { get }
    static var foregroundDanger: UIColor { get }

    static var border: UIColor { get }
    static var borderSelected: UIColor { get }
}

public protocol InfoColorProtocol {
    static var backgroundRest: UIColor { get }
    static var backgroundSecondary: UIColor { get }

    static var foregroundRest: UIColor { get }
    static var foregroundSecondary: UIColor { get }
    static var foregroundHover: UIColor { get }
}

public protocol SegmentedColorProtocol {
    static var tabBackgroundRest: UIColor { get }
    static var tabBackgroundActive: UIColor { get }
    static var tabForegroundRest: UIColor { get }
    static var tabForegroundActive: UIColor { get }
}

public protocol OtherColorProtocol {
    static var overylay: UIColor { get }
    static var shimmerBase: UIColor { get }
    static var shimmerGlow: UIColor { get }
}
