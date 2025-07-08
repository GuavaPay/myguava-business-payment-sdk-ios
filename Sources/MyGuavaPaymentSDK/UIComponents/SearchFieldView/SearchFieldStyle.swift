//
//  SearchFieldStyle.swift
//  
//
//  Created by Ignat Chegodaykin on 19.06.2024.
//

import UIKit

extension SearchFieldView {

    public protocol Style: CornerRadius,
                           BackgroundColor,
                           ForegroundColor,
                           BorderColor,
                           TitleFont,
                           TintColor,
                           Height {
        var cursorColor: UIColor { get }
        var activeBorderColor: UIColor { get }

        func cursorColor(_ value: UIColor) -> Self
        func activeBorderColor(_ value: UIColor) -> Self
    }

    public struct StockStyle: Style {
        public var height: CGFloat = .spacing900
        public var tintColor: UIColor
        public var titleFont: UIFont = .headlineRegular
        public var cornerRadius: CGFloat = .radius200
        public var backgroundColor: UIColor
        public var foregroundColor: UIColor
        public var cursorColor: UIColor
        public var borderColor: UIColor
        public var activeBorderColor: UIColor

        public func cursorColor(_ value: UIColor) -> Self {
            var copy = self
            copy.cursorColor = value
            return copy
        }

        public func activeBorderColor(_ value: UIColor) -> Self {
            var copy = self
            copy.activeBorderColor = value
            return copy
        }

        public init(
            cursorColor: UIColor = .input.primaryForeground,
            tintColor: UIColor = .input.secondaryForeground,
            backgroundColor: UIColor = .input.backgroundRest,
            foregroundColor: UIColor = .background.inverse,
            borderColor: UIColor = .input.borderRest,
            activeBorderColor: UIColor = .input.borderFocused
        ) {
            self.cursorColor = cursorColor
            self.tintColor = tintColor
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.activeBorderColor = activeBorderColor
        }
    }
}

extension SearchFieldView.Style {

    public static func getStyle() -> SearchFieldView.Style {
        return SearchFieldView.StockStyle()
    }
}
