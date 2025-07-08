//
//  PlaceholderInputField.swift
//  
//
//  Created by Mikhail Kirillov on 14/6/24.
//

import UIKit

public extension PlaceholderInputField {

    enum State {
        case enabled
        case focused
        case error
        case disabled
        case success
    }

    protocol Style: TitleFont, InputPlaceholderFont, InputTextFont, TintColor {
        var titleColor: UIColor { get }
        var inputPlaceholderColor: UIColor  { get }
        var inputTextColor: UIColor  { get }

        func inputTextColor(_ value: UIColor) -> Self
        func inputPlaceholderColor(_ value: UIColor) -> Self
        func styleForState(_ state: State) -> Style
    }

    struct StockStyle: Style {
        public var tintColor: UIColor = .input.primaryForeground

        public var titleFont: UIFont = .caption1Regular

        /// Always use .lineBreakUsing(.byWordWrapping) when using custom font
        public var inputTextFont: UIFont = .body1Regular
        public var inputPlaceholderFont: UIFont = .body1Regular

        public var titleColor: UIColor = .input.secondaryForeground
        public var inputPlaceholderColor: UIColor = .input.secondaryForeground
        public var inputTextColor: UIColor = .input.primaryForeground

        public func titleColor(_ value: UIColor) -> Self {
            var copy = self
            copy.titleColor = value
            return copy
        }

        public func inputTextColor(_ value: UIColor) -> Self {
            var copy = self
            copy.inputTextColor = value
            return copy
        }

        public func inputPlaceholderColor(_ value: UIColor) -> Self {
            var copy = self
            copy.inputPlaceholderColor = value
            return copy
        }

        public func styleForState(_ state: State) -> Style {
            let stock = StockStyle()
            switch state {
            case .enabled, .focused, .success:
                return stock
            case .disabled:
                return stock.titleColor(.input.disabledForeground)
                    .inputTextColor(.input.disabledForeground)
                    .inputPlaceholderColor(.input.disabledForeground)
            case .error:
                return stock.titleColor(.input.dangerForeground)
                    .inputPlaceholderColor(.input.secondaryForeground)
            }
        }

        public init() {}
    }
}
