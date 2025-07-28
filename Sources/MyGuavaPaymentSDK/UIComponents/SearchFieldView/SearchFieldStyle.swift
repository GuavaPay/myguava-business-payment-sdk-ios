//
//  SearchFieldStyle.swift
//  
//
//  Created by Ignat Chegodaykin on 19.06.2024.
//

import UIKit

extension SearchFieldView {

    protocol Style: CornerRadius,
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

    struct StockStyle: Style {
        var height: CGFloat = .spacing900
        var tintColor: UIColor
        var titleFont: UIFont = .headlineRegular
        var cornerRadius: CGFloat = .radius200
        var backgroundColor: UIColor
        var foregroundColor: UIColor
        var cursorColor: UIColor
        var borderColor: UIColor
        var activeBorderColor: UIColor

        func cursorColor(_ value: UIColor) -> Self {
            var copy = self
            copy.cursorColor = value
            return copy
        }

        func activeBorderColor(_ value: UIColor) -> Self {
            var copy = self
            copy.activeBorderColor = value
            return copy
        }

        init(
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

    static func getStyle() -> SearchFieldView.Style {
        return SearchFieldView.StockStyle()
    }
}
