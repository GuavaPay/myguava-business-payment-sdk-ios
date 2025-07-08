//
//  SegmentedControlStyle.swift
//  
//
//  Created by Mikhail Kirillov on 25/6/24.
//

import UIKit

public extension SegmentedControl {
    protocol Style: TintColor, BackgroundColor, CornerRadius {
        var selectedForegroundColor: UIColor { get }
        var foregroundColor: UIColor { get }

        var selectedFontStyle: UIFont { get }
        var fontStyle: UIFont { get }
    }

    struct StockStyle: SegmentedControl.Style {

        public var tintColor: UIColor = .segmented.tabBackgroundActive
        public var backgroundColor: UIColor = .segmented.tabBackgroundRest
        public var cornerRadius: CGFloat = .radius200

        public var selectedFontStyle: UIFont = .body2Semibold
        public var fontStyle: UIFont = .body2Regular

        public var selectedForegroundColor: UIColor = .segmented.tabForegroundActive
        public var foregroundColor: UIColor = .segmented.tabForegroundRest

        public init() {}
    }
}
