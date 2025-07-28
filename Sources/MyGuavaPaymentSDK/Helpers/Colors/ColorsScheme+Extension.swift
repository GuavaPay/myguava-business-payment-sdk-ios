//
//   ColorsScheme+Extension.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 16.06.2025.
//

import UIKit

extension UIColor {
    public static var background: BackgroundColorProtocol.Type { BackgroundColorScheme.self }
    public static var foreground: ForegroundColorProtocol.Type { ForegroundColorScheme.self }
    public static var border: BorderColorProtocol.Type { BorderColorScheme.self }
    public static var button: ButtonColorProtocol.Type { ButtonColorScheme.self }
    public static var controls: ControlsColorProtocol.Type { ControlsColorScheme.self }
    public static var `switch`: SwitchColorProtocol.Type { SwitchColorScheme.self }
    public static var input: InputColorProtocol.Type { InputColorScheme.self }
    public static var link: LinkColorProtocol.Type { LinkColorScheme.self }
    public static var tab: TabColorProtocol.Type { TabColorScheme.self }
    public static var info: InfoColorProtocol.Type { InfoColorScheme.self }
    public static var segmented: SegmentedColorProtocol.Type { SegmentedColorScheme.self }
    public static var other: OtherColorProtocol.Type { OtherColorScheme.self }
}

// MARK: - BackgroundColorScheme

public struct BackgroundColorScheme: BackgroundColorProtocol {
    public static var primary: UIColor { UIColor(light: .gray100, dark: .gray100) }
    public static var primaryStatic: UIColor { UIColor(light: .gray100Static, dark: .gray100Static) }
    public static var secondary: UIColor { UIColor(light: .gray200, dark: .gray200) }
    public static var tertiary: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var inverse: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var brand: UIColor { UIColor(light: .brand600, dark: .brand600) }
    public static var brandAlt: UIColor { UIColor(light: .brand2_100, dark: .brand2_100) }
    public static var disabled: UIColor { UIColor(light: .gray400, dark: .gray400) }
    public static var disabled2: UIColor { UIColor(light: .additional100, dark: .additional100) }
    public static var info: UIColor { UIColor(light: .blue100, dark: .blue100) }
    public static var success: UIColor { UIColor(light: .green200, dark: .green200) }
    public static var danger: UIColor { UIColor(light: .red100, dark: .red100) }
    public static var warning: UIColor { UIColor(light: .yellow100, dark: .yellow100) }
    public static var divider: UIColor { UIColor(light: .gray300, dark: .gray300) }
}

// MARK: - ForegroundColorScheme

public struct ForegroundColorScheme: ForegroundColorProtocol {
    public static var primary: UIColor { UIColor(light: .gray100, dark: .gray100) }
    public static var secondary: UIColor { UIColor(light: .gray500, dark: .gray500) }
    public static var onAccent: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var onAccentSecondary: UIColor { UIColor(light: .gray700, dark: .gray700) }
    public static var disabled: UIColor { UIColor(light: .gray600, dark: .gray600) }
    public static var brand: UIColor { UIColor(light: .brand600, dark: .brand600) }
    public static var info: UIColor { UIColor(light: .blue600, dark: .blue600) }
    public static var success: UIColor { UIColor(light: .green800, dark: .green800) }
    public static var danger: UIColor { UIColor(light: .red600, dark: .red600) }
    public static var warning: UIColor { UIColor(light: .yellow700, dark: .yellow700) }
}

// MARK: - BorderColorScheme

public struct BorderColorScheme: BorderColorProtocol {
    public static var primary: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var secondary: UIColor { UIColor(light: .gray400, dark: .gray400) }
    public static var focus: UIColor { UIColor(light: .blue600, dark: .blue600) }
}

// MARK: - ButtonColorScheme

public struct ButtonColorScheme: ButtonColorProtocol {
    public static var primaryBackgroundRest: UIColor { UIColor(light: .brand600, dark: .brand600) }
    public static var primaryBackgroundHover: UIColor { UIColor(light: .brand700, dark: .brand700) }
    public static var primaryBackgroundPressed: UIColor { UIColor(light: .brand800, dark: .brand800) }
    public static var primaryBackgroundDisabled: UIColor { UIColor(light: .gray400, dark: .gray400) }
    public static var primaryForegroundRest: UIColor { UIColor(light: .gray1000Static, dark: .gray1000Static) }
    public static var primaryForegroundDisabled: UIColor { UIColor(light: .gray600, dark: .gray600) }
    public static var secondaryBorder: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var secondaryBackgroundHover: UIColor { UIColor(light: .gray200, dark: .gray200) }
    public static var secondaryBackgroundPressed: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var secondaryBackgroundDisabled: UIColor { UIColor(light: .gray400, dark: .gray400) }
    public static var secondaryForegroundRest: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var secondaryForegroundDisabled: UIColor { UIColor(light: .gray600, dark: .gray600) }
    public static var ghostBackgroundHover: UIColor { UIColor(light: .gray200, dark: .gray200) }
    public static var ghostBackgroundPressed: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var ghostBackgroundDisabled: UIColor { UIColor(light: .gray400, dark: .gray400) }
    public static var ghostForegroundRest: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var ghostForegroundDisabled: UIColor { UIColor(light: .gray600, dark: .gray600) }
    public static var dangerBackgroundRest: UIColor { UIColor(light: .red600, dark: .red600) }
    public static var dangerBackgroundHover: UIColor { UIColor(light: .red700, dark: .red700) }
    public static var dangerBackgroundPressed: UIColor { UIColor(light: .red800, dark: .red800) }
    public static var dangerBackgroundDisabled: UIColor { UIColor(light: .gray400, dark: .gray400) }
    public static var dangerForegroundRest: UIColor { UIColor(light: .gray100, dark: .gray100) }
    public static var dangerForegroundDisabled: UIColor { UIColor(light: .gray600, dark: .gray600) }
}

// MARK: - ControlsColorScheme

public struct ControlsColorScheme: ControlsColorProtocol {
    public static var backgroundHover: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var backgroundDisabled: UIColor { UIColor(light: .gray400, dark: .gray400) }
    public static var selectedBackgroundRest: UIColor { UIColor(light: .brand700, dark: .brand700) }
    public static var selectedBackgroundHover: UIColor { UIColor(light: .brand800, dark: .brand800) }
    public static var selectedForegroundRest: UIColor { UIColor(light: .gray100, dark: .gray100) }
    public static var borderRest: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var borderDisable: UIColor { UIColor(light: .gray700, dark: .gray700) }
}

// MARK: - SwitchColorScheme

public struct SwitchColorScheme: SwitchColorProtocol {
    public static var backgroundRest: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var backgroundHover: UIColor { UIColor(light: .gray400, dark: .gray400) }
    public static var selectedBackgroundRest: UIColor { UIColor(light: .green600, dark: .green600) }
    public static var selectedBackgroundHover: UIColor { UIColor(light: .green700, dark: .green700) }
    public static var foregroundRest: UIColor { UIColor(light: .gray100, dark: .gray100) }
}

// MARK: - InputColorScheme

public struct InputColorScheme: InputColorProtocol {
    public static var backgroundRest: UIColor { UIColor(light: .gray200, dark: .gray200) }
    public static var backgroundHover: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var backgroundDisabled: UIColor { UIColor(light: .gray400, dark: .gray400) }
    public static var primaryForeground: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var secondaryForeground: UIColor { UIColor(light: .gray700, dark: .gray700) }
    public static var dangerForeground: UIColor { UIColor(light: .red600, dark: .red600) }
    public static var disabledForeground: UIColor { UIColor(light: .gray600, dark: .gray600) }
    public static var borderRest: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var borderFocused: UIColor { UIColor(light: .brand700, dark: .brand700) }
    public static var borderDanger: UIColor { UIColor(light: .red600, dark: .red600) }
}

// MARK: - LinkColorScheme

public struct LinkColorScheme: LinkColorProtocol {
    public static var primaryRest: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var primaryHover: UIColor { UIColor(light: .gray800, dark: .gray800) }
    public static var primaryDisabled: UIColor { UIColor(light: .gray500, dark: .gray500) }
    public static var secondaryRest: UIColor { UIColor(light: .blue600, dark: .blue600) }
    public static var secondaryHover: UIColor { UIColor(light: .blue800, dark: .blue800) }
    public static var secondaryDisabled: UIColor { UIColor(light: .gray500, dark: .gray500) }
}

// MARK: - TabColorScheme

public struct TabColorScheme: TabColorProtocol {
    public static var backgroundRest: UIColor { UIColor(light: .gray100, dark: .gray100) }
    public static var backgroundHover: UIColor { UIColor(light: .gray200, dark: .gray200) }
    public static var foregroundRest: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var foregroundDanger: UIColor { UIColor(light: .red600, dark: .red600) }
    public static var border: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var borderSelected: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
}

// MARK: - InfoColorScheme

public struct InfoColorScheme: InfoColorProtocol {
    public static var backgroundRest: UIColor { UIColor(light: .gray900, dark: .gray900) }
    public static var backgroundSecondary: UIColor { UIColor(light: .gray200, dark: .gray200) }
    public static var foregroundRest: UIColor { UIColor(light: .gray100, dark: .gray100) }
    public static var foregroundSecondary: UIColor { UIColor(light: .gray1000, dark: .gray1000) }
    public static var foregroundHover: UIColor { UIColor(light: .gray300, dark: .gray300) }
}

// MARK: - SegmentedColorScheme

public struct SegmentedColorScheme: SegmentedColorProtocol {
    public static var tabBackgroundRest: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var tabBackgroundActive: UIColor { UIColor(light: .gray100, dark: .gray100) }
    public static var tabForegroundRest: UIColor { UIColor(light: .gray700, dark: .gray700) }
    public static var tabForegroundActive: UIColor { UIColor(light: .gray1000, dark: .gray1000) }

    public static var tabBase: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var tabActive: UIColor { UIColor(light: .gray100, dark: .gray100) }
    public static var tabDivider: UIColor { UIColor(light: .gray500, dark: .gray500) }
}


// MARK: - OtherColorScheme

public struct OtherColorScheme: OtherColorProtocol {
    public static var overylay: UIColor { UIColor(light: .alphaBlack100, dark: .alphaBlack100) }
    public static var shimmerBase: UIColor { UIColor(light: .gray300, dark: .gray300) }
    public static var shimmerGlow: UIColor { UIColor(light: .gray200, dark: .gray200) }
}
