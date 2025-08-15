//
//  SegmentedControlStyle.swift
//
//
//  Created by Mikhail Kirillov on 25/6/24.
//

import UIKit

extension SegmentedControl {
    protocol Style: TintColor, BackgroundColor, CornerRadius {
        var selectedForegroundColor: UIColor { get }
        var foregroundColor: UIColor { get }

        var selectedFontStyle: UIFont { get }
        var fontStyle: UIFont { get }
    }

    struct StockStyle: SegmentedControl.Style {

        var tintColor: UIColor = .segmented.tabBackgroundActive
        var backgroundColor: UIColor = .segmented.tabBackgroundRest
        var cornerRadius: CGFloat = .radius200

        var selectedFontStyle: UIFont = .body2Semibold
        var fontStyle: UIFont = .body2Regular

        var selectedForegroundColor: UIColor = .segmented.tabForegroundActive
        var foregroundColor: UIColor = .segmented.tabForegroundRest

        init() {}
    }
}
