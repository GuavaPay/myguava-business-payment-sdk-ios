//
//  InputBackDropViewStyle.swift
//  
//
//  Created by Mikhail Kirillov on 18/6/24.
//

import UIKit

extension InputBackDropView {

    public protocol Style: BackgroundColor, CornerRadius, BorderWidth, BorderColor, Padding {
    }

    public struct StockStyle: Style {
        public var padding: UIEdgeInsets = .init(top: .spacing100,
                                                 left: .spacing400,
                                                 bottom: .spacing100,
                                                 right: .spacing200)

        public var backgroundColor: UIColor = UICustomization.Input.backgroundColor
        public var cornerRadius: CGFloat = UICustomization.Input.cornerRadius
        public var borderWidth: CGFloat = UICustomization.Input.borderWidth
        public var borderColor: UIColor = UICustomization.Input.borderColor
    }
}


