//
//  ButtonStyle.swift
//
//
//  Created by Mikhail Kirillov on 3/6/24.
//

import UIKit

extension Button {

    protocol StyleFactory {
        func paddingForSize(size: Size, type: ButtonType) -> UIEdgeInsets
        func makeStyle(state: State,
                       scheme: Scheme,
                       size: Size,
                       type: ButtonType) -> Style
    }

    
    /// Button height, width is per content or outside constraints
    enum Size: Equatable {
        /// 48
        case large
        /// 40
        case medium
        /// 24
        case small
        /// custom height
        case custom(CGFloat)

        var height: CGFloat {
            switch self {

            case .large:
                return 48
            case .medium:
                return 40
            case .small:
                return 24
            case let .custom(height):
                return height
            }
        }

        static let allCases: [Button.Size] = [.small, .medium, .large, .custom(80)]
    }

    enum State: CaseIterable {
        case enabled
        case hovered
        case pressed
        case focused
        case disabled
        case loading
    }

    enum Scheme: CaseIterable {
        case primary
        case secondary
        case danger
        case ghost
    }

    protocol Style: CornerRadius, BackgroundColor, ForegroundColor, TitleFont, Padding, StackSpacing, Height {
        var spinnerSize: SpinnerView.Size { get }
        var focusedColor: UIColor { get set }

        func focusedColor(_ value: UIColor) -> Self
    }

    struct StockStyle: Style {
        /// Button height defaults to .small
        var height: CGFloat = 24
        var padding: UIEdgeInsets = .zero
        var spacing: CGFloat = .spacing200
        var backgroundColor: UIColor = UICustomization.Button.backgroundColor
        var foregroundColor: UIColor = UICustomization.Button.textColor
        var titleFont: UIFont = .body1Semibold
        var cornerRadius: CGFloat = UICustomization.Button.cornerRadius
        var spinnerSize: SpinnerView.Size = .small
        var focusedColor: UIColor = .border.focus

        func spinnerSize(_ value: SpinnerView.Size) -> Self {
            var copy = self
            copy.spinnerSize = value
            return copy
        }

        func focusedColor(_ value: UIColor) -> Self {
            var copy = self
            copy.focusedColor = value
            return copy
        }
    }

    struct StockStyleFactory: StyleFactory {

        func paddingForSize(size: Size, type: ButtonType) -> UIEdgeInsets {
            switch type {
            case .image:
                switch size {
                case .custom, .large: return .init(top: .spacing200, left: .spacing200, bottom: .spacing200, right: .spacing200)
                case .medium: return .init(top: .spacing200, left: .spacing200, bottom: .spacing200, right: .spacing200)
                case .small: return .init(top: .spacing100, left: .spacing200, bottom: .spacing100, right: .spacing200)
                }
            case .dual, .dualTrailing, .text:
                switch size {
                case .custom, .large: return .init(top: .spacing400, left: .spacing800, bottom: .spacing400, right: .spacing800)
                case .medium: return .init(top: .spacing300, left: .spacing600, bottom: .spacing300, right: .spacing600)
                case .small: return .init(top: .spacing200, left: .spacing400, bottom: .spacing200, right: .spacing400)
                }
            }
        }

        func spacingForSize(size: Size, type: ButtonType) -> CGFloat {
            switch size {
            case .large, .medium, .custom:
                return .spacing200
            case .small:
                return .spacing100
            }
        }

        func spinnerSizeForSize(size: Size, type: ButtonType) -> SpinnerView.Size {
            switch size {
            case .large, .medium, .custom:
                return .small
            case .small:
                return .small
            }
        }

        func makeStyle(state: State,
                              scheme: Scheme,
                              size: Size,
                              type: ButtonType) -> Style {
            let padding = paddingForSize(size: size, type: type)
            let spacing = spacingForSize(size: size, type: type)
            let spinnerSize = spinnerSizeForSize(size: size, type: type)
            let stock = StockStyle().padding(padding).spacing(spacing).spinnerSize(spinnerSize).height(size.height)

            switch (state, scheme) 
            {
            case (.enabled, .primary), (.loading, .danger), (.loading, .primary): return stock
            case (.disabled, .primary):
                return stock
                    .backgroundColor(.button.primaryBackgroundDisabled)
                    .foregroundColor(.button.primaryForegroundDisabled)
            case (.disabled, .secondary):
                return stock
                    .backgroundColor(.button.primaryBackgroundDisabled)
                    .foregroundColor(.button.primaryForegroundDisabled)
            case (.disabled, .danger):
                return stock
                    .backgroundColor(.button.primaryBackgroundDisabled)
                    .foregroundColor(.button.primaryForegroundDisabled)
            case (.disabled, .ghost):
                return stock
                    .backgroundColor(.button.primaryBackgroundDisabled)
                    .foregroundColor(.button.primaryForegroundDisabled)
            case (.enabled, .secondary):
                return stock
                    .backgroundColor(.clear)
                    .foregroundColor(.foreground.onAccent)
            case (.enabled, .danger):
                return stock
                    .backgroundColor(.button.dangerBackgroundRest)
                    .foregroundColor(.button.primaryForegroundRest)
            case (.enabled, .ghost):
                return stock
                    .backgroundColor(.clear)
                    .foregroundColor(.foreground.onAccent)
            case (.pressed, .primary):
                return stock
                    .backgroundColor(.button.primaryBackgroundPressed)
            case (.pressed, .secondary):
                return stock
                    .backgroundColor(.button.secondaryBackgroundPressed)
                    .foregroundColor(.foreground.onAccent)
            case (.pressed, .danger):
                return stock
                    .backgroundColor(.button.dangerBackgroundPressed)
                    .foregroundColor(.background.primary)
            case (.pressed, .ghost):
                return stock
                    .backgroundColor(.button.secondaryBackgroundPressed)
                    .foregroundColor(.foreground.onAccent)
            case (.loading, .secondary):
                return stock
                    .backgroundColor(.clear)
                    .foregroundColor(.foreground.onAccent)
            case (.loading, .ghost):
                return stock
                    .backgroundColor(.clear)
                    .foregroundColor(.foreground.onAccent)
            case (.hovered, .primary):
                return stock
                    .backgroundColor(.button.primaryBackgroundHover)
                    .foregroundColor(.foreground.onAccent)
            case (.hovered, .secondary):
                return stock
                    .backgroundColor(.button.secondaryBackgroundHover)
                    .foregroundColor(.foreground.onAccent)
            case (.hovered, .danger):
                return stock
                    .backgroundColor(.button.dangerBackgroundHover)
                    .foregroundColor(.background.primary)
            case (.hovered, .ghost):
                return stock
                    .backgroundColor(.button.secondaryBackgroundHover)
                    .foregroundColor(.foreground.onAccent)
            case (.focused, .primary):
                return stock
            case (.focused, .secondary):
                return stock
                    .backgroundColor(.clear)
                    .foregroundColor(.foreground.onAccent)
            case (.focused, .danger):
                return stock
                    .backgroundColor(.button.dangerBackgroundRest)
                    .foregroundColor(.button.primaryBackgroundRest)
            case (.focused, .ghost):
                return stock
                    .backgroundColor(.clear)
                    .foregroundColor(.foreground.onAccent)
            }
        }
    }
}




