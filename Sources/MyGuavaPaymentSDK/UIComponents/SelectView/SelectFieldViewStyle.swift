//
//  SelectFieldView.swift
//  GuavaDesign
//
//  Created by Ignat Chegodaykin on 15.10.2024.
//

import UIKit

extension SelectFieldView {
    public enum State: CaseIterable {
        case enabled
        case pressed
        case error
        case loading
        case disabled
        case blocked
        case blockedLoading

        func borderColor() -> UIColor {
            switch self {
            case .enabled, .pressed, .loading:
                return UICustomization.Input.borderColor
            case .error:
                return .input.borderDanger
            case .disabled, .blocked, .blockedLoading:
                return UICustomization.Input.borderColor
            }
        }

        func backgroundColor() -> UIColor {
            switch self {
            case .pressed:
                return .input.backgroundHover
            default:
                return UICustomization.Input.backgroundColor
            }
        }

        func textColor() -> UIColor {
            switch self {
            case .enabled, .pressed, .error, .loading:
                return UICustomization.Input.textColor
            case .disabled, .blocked, .blockedLoading:
                return .input.disabledForeground
            }
        }

        func placeholderTextColor() -> UIColor {
            switch self {
            case .enabled, .pressed, .loading:
                return UICustomization.Input.placeholderTextColor
            case .error:
                return .input.secondaryForeground
            case .disabled, .blocked, .blockedLoading:
                return UICustomization.Input.placeholderTextColor
            }
        }

        func bottomTextColor() -> UIColor {
            switch self {
            case .enabled, .pressed, .loading:
                return .input.primaryForeground
            case .error:
                return .input.dangerForeground
            case .disabled, .blocked, .blockedLoading:
                return .input.primaryForeground
            }
        }

        func borderWidth() -> CGFloat {
            switch self {
            case .error:
                return 2
            default:
                return 1
            }
        }
    }

    public protocol Style: BorderColor,
                           BorderWidth,
                           BackgroundColor,
                           CornerRadius,
                           Height,
                           TintColor {
        var inputTextFont: UIFont { get set }
        var titleTextFont: UIFont { get set }
        var placeholderTextFont: UIFont { get set }
        var bottomTextFont: UIFont { get set }
        var textColor: UIColor { get set }
        var placeholderTextColor: UIColor  { get set }
        var titleTextColor: UIColor  { get set }
        var bottomTextColor: UIColor  { get set }

        func textColor(_ value: UIColor) -> Self
        func placeholderTextColor(_ value: UIColor) -> Self
        func titleTextColor(_ value: UIColor) -> Self
        func bottomTextColor(_ value: UIColor) -> Self
        func inputTextFont(_ value: UIFont) -> Self
        func titleTextFont(_ value: UIFont) -> Self
        func placeholderTextFont(_ value: UIFont) -> Self
        func bottomTextFont(_ value: UIFont) -> Self
    }

    public struct StockStyle: Style {
        public var inputTextFont: UIFont
        public var titleTextFont: UIFont
        public var placeholderTextFont: UIFont
        public var bottomTextFont: UIFont
        public var tintColor: UIColor
        public var borderColor: UIColor
        public var borderWidth: CGFloat
        public var backgroundColor: UIColor
        public var cornerRadius: CGFloat
        public var height: CGFloat
        public var textColor: UIColor
        public var placeholderTextColor: UIColor
        public var titleTextColor: UIColor
        public var bottomTextColor: UIColor

        public func textColor(_ value: UIColor) -> Self {
            var copy = self
            copy.textColor = value
            return copy
        }

        public func placeholderTextColor(_ value: UIColor) -> Self {
            var copy = self
            copy.placeholderTextColor = value
            return copy
        }

        public func titleTextColor(_ value: UIColor) -> Self {
            var copy = self
            copy.titleTextColor = value
            return copy
        }

        public func bottomTextColor(_ value: UIColor) -> Self {
            var copy = self
            copy.bottomTextColor = value
            return copy
        }

        public func inputTextFont(_ value: UIFont) -> Self {
            var copy = self
            copy.inputTextFont = value
            return copy
        }

        public func titleTextFont(_ value: UIFont) -> Self {
            var copy = self
            copy.titleTextFont = value
            return copy
        }

        public func placeholderTextFont(_ value: UIFont) -> Self {
            var copy = self
            copy.placeholderTextFont = value
            return copy
        }

        public func bottomTextFont(_ value: UIFont) -> Self {
            var copy = self
            copy.bottomTextFont = value
            return copy
        }

        public init(
            inputTextFont: UIFont = .body1Regular,
            titleTextFont: UIFont = .body1Regular,
            placeholderTextFont: UIFont = .body1Regular,
            bottomTextFont: UIFont = .caption1Regular,
            tintColor: UIColor = .foreground.primary,
            borderColor: UIColor,
            borderWidth: CGFloat,
            backgroundColor: UIColor,
            cornerRadius: CGFloat,
            height: CGFloat = 48,
            textColor: UIColor,
            placeholderTextColor: UIColor,
            titleTextColor: UIColor = .input.primaryForeground,
            bottomTextColor: UIColor = .input.primaryForeground
        ) {
            self.inputTextFont = inputTextFont
            self.titleTextFont = titleTextFont
            self.placeholderTextFont = placeholderTextFont
            self.bottomTextFont = bottomTextFont
            self.tintColor = tintColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.height = height
            self.textColor = textColor
            self.placeholderTextColor = placeholderTextColor
            self.titleTextColor = titleTextColor
            self.bottomTextColor = bottomTextColor
        }
    }
}

extension SelectFieldView.Style {
    public static func getStyle(_ state: SelectFieldView.State) -> SelectFieldView.Style {
        let stock = SelectFieldView.StockStyle(
            borderColor: UICustomization.Input.borderColor,
            borderWidth: UICustomization.Input.borderWidth,
            backgroundColor: UICustomization.Input.backgroundColor,
            cornerRadius: UICustomization.Input.cornerRadius,
            textColor: UICustomization.Input.textColor,
            placeholderTextColor: UICustomization.Input.placeholderTextColor
        )
        return stock
            .borderColor(state.borderColor())
            .borderWidth(state.borderWidth())
            .backgroundColor(state.backgroundColor())
            .textColor(state.textColor())
            .placeholderTextColor(state.placeholderTextColor())
            .titleTextColor(.input.primaryForeground)
            .bottomTextColor(state.bottomTextColor())
    }
}
