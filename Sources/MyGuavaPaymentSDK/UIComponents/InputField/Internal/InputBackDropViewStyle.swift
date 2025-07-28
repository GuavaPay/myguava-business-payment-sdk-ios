//
//  InputBackDropViewStyle.swift
//  
//
//  Created by Mikhail Kirillov on 18/6/24.
//

import UIKit

extension InputBackDropView {

    protocol Style: BackgroundColor, CornerRadius, BorderWidth, BorderColor, Padding {
    }

    struct StockStyle: Style {
        var padding: UIEdgeInsets = .init(top: .spacing100,
                                                 left: .spacing400,
                                                 bottom: .spacing100,
                                                 right: .spacing200)

        var backgroundColor: UIColor = UICustomization.Input.backgroundColor
        var cornerRadius: CGFloat = UICustomization.Input.cornerRadius
        var borderWidth: CGFloat = UICustomization.Input.borderWidth
        var borderColor: UIColor = UICustomization.Input.borderColor
    }
}


