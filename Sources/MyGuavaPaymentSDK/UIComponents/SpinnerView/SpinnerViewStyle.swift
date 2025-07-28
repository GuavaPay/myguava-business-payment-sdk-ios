//
//  SpinnerViewStyle.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 16.06.2025.
//

import UIKit

extension SpinnerView {

    protocol Style {
        var borderStrokeColor: UIColor { get set }
        var borderFillColor: UIColor { get set }
    }

    enum Size: CGFloat, CaseIterable {
        case small = 24.0
    }

    struct StockStyle: Style {
        var borderStrokeColor: UIColor
        var borderFillColor: UIColor

        func borderStrokeColor(_ value: UIColor) -> Self {
            var copy = self
            copy.borderStrokeColor = value
            return copy
        }

        func borderFillColor(_ value: UIColor) -> Self {
            var copy = self
            copy.borderFillColor = value
            return copy
        }

        init(
            borderStrokeColor: UIColor = .foreground.onAccent,
            borderFillColor: UIColor = .clear
        ) {
            self.borderStrokeColor = borderStrokeColor
            self.borderFillColor = borderFillColor
        }
    }
}

extension SpinnerView.Style {

    static func getStyle() -> SpinnerView.Style {
        SpinnerView.StockStyle()
    }
}

