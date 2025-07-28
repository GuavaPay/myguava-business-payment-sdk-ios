//
//  InputFieldStyle.swift
//  
//
//  Created by Mikhail Kirillov on 18/6/24.
//

import UIKit

extension InputField {

    enum State: CaseIterable {
        case enabled
        case focused
        case error
        case disabled
        case blocked
        case success

        var inputState: PlaceholderInputField.State {
            switch self {
            case .blocked, .disabled: return .disabled
            case .success: return .success
            case .enabled: return .enabled
            case .focused: return .focused
            case .error: return .error
            }
        }
    }

    protocol AccessoryStyle: ForegroundColor, Padding, Size {}

    struct StockAccessoryStyle: AccessoryStyle {
        var size: CGSize = .init(width: .spacing600, height: .spacing600)

        var foregroundColor: UIColor = { .input.secondaryForeground }()
        var padding: UIEdgeInsets = .init(top: .spacing200,
                                               left: .spacing200,
                                               bottom: .spacing200,
                                               right: .spacing200)
    }

    protocol Style: ForegroundColor {
        var backDropStyle: InputBackDropView.Style { get set }
        var inputFieldStyle: PlaceholderInputField.Style { get set }
        var iconTintColor: UIColor { get set }

        var accessoryStyle: AccessoryStyle { get set }

        func accessoryPadding(_ value: UIEdgeInsets) -> Self
        func accessorySize(_ value: CGSize) -> Self
    }

    struct StockStyle: Style {

        var backDropStyle: InputBackDropView.Style = { InputBackDropView.StockStyle() }()
        var inputFieldStyle: PlaceholderInputField.Style = { PlaceholderInputField.StockStyle() }()
        var iconTintColor: UIColor = { .input.secondaryForeground }()
        var foregroundColor: UIColor = { .input.secondaryForeground }()

        var accessoryStyle: AccessoryStyle = StockAccessoryStyle()
        init() {}

        func accessoryPadding(_ value: UIEdgeInsets) -> Self {
            var copy = self
            copy.accessoryStyle.padding = value
            return copy
        }

        func accessorySize(_ value: CGSize) -> Self {
            var copy = self
            copy.accessoryStyle.size = value
            return copy
        }
    }

    protocol StyleFactoryProtocol {

        var stockStyle: InputField.Style { get }

        func styleForstate(_ state: InputField.State) -> InputField.Style
    }

    struct StockStyleFactory: StyleFactoryProtocol {

        private(set) var stockStyle: Style

        init(style: Style = StockStyle()) {
            self.stockStyle = style
        }

        func styleForstate(_ state: InputField.State) -> InputField.Style {
            var stock = self.stockStyle
            switch state {
            case .enabled:
                return stock
            case .focused:
                stock.backDropStyle.borderColor = .input.borderFocused
                stock.backDropStyle.borderWidth = 1
                return stock
            case .disabled:
                stock.backDropStyle.borderColor = .input.borderRest
                stock.iconTintColor = .foreground.onAccent
                stock.foregroundColor = .input.backgroundDisabled
                return stock
            case .error:
                stock.backDropStyle.padding.right = .spacing300
                stock.backDropStyle.borderColor = .input.borderDanger
                stock.backDropStyle.borderWidth = 1
                return stock.foregroundColor(.input.dangerForeground)
            case .blocked:
                stock.foregroundColor = .input.backgroundDisabled
                return stock
            case .success:
                stock.backDropStyle.padding.right = .spacing300
                return stock
            }
        }
    }
}
