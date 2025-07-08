//
//  SpinnerViewStyle.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 16.06.2025.
//

import UIKit

public extension SpinnerView {

    protocol Style {
        var borderStrokeColor: UIColor { get set }
        var borderFillColor: UIColor { get set }
    }

    enum Size: CGFloat, CaseIterable {
        case small = 24.0
    }

    struct StockStyle: Style {
        public var borderStrokeColor: UIColor
        public var borderFillColor: UIColor

        public func borderStrokeColor(_ value: UIColor) -> Self {
            var copy = self
            copy.borderStrokeColor = value
            return copy
        }

        public func borderFillColor(_ value: UIColor) -> Self {
            var copy = self
            copy.borderFillColor = value
            return copy
        }

        public init(
            borderStrokeColor: UIColor = .foreground.onAccent,
            borderFillColor: UIColor = .clear
        ) {
            self.borderStrokeColor = borderStrokeColor
            self.borderFillColor = borderFillColor
        }
    }
}

extension SpinnerView.Style {

    public static func getStyle() -> SpinnerView.Style {
        SpinnerView.StockStyle()
    }
}

