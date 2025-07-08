//
//  UIEdgeInsets+Extension.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 25.06.2025.
//

import UIKit

extension UIEdgeInsets {
    static func custom(
        top: CGFloat = .zero,
        left: CGFloat = .zero,
        right: CGFloat = .zero,
        bottom: CGFloat = .zero
    ) -> UIEdgeInsets {
        .init(top: top, left: left, bottom: bottom, right: right)
    }

    static func custom(x: CGFloat = .zero, y: CGFloat = .zero) -> UIEdgeInsets {
        .init(top: y, left: x, bottom: y, right: x)
    }

    static func custom(x: CGFloat = .zero, top: CGFloat = .zero, bottom: CGFloat = .zero) -> UIEdgeInsets {
        .init(top: top, left: x, bottom: bottom, right: x)
    }

    static func custom(y: CGFloat = .zero, right: CGFloat = .zero, left: CGFloat = .zero) -> UIEdgeInsets {
        .init(top: y, left: left, bottom: y, right: right)
    }

    static func custom(edges: CGFloat) -> UIEdgeInsets {
        .init(top: edges, left: edges, bottom: edges, right: edges)
    }

    static func only(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    static func all(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    enum ExtendedTapAreaConstants {
        static let extraInset: CGFloat = 16
    }
}
