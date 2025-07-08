//
//  Button+Extension.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 25.06.2025.
//

import UIKit

class ExtendedTapAreaButton: UIButton {
    var tapInset: UIEdgeInsets = .all(UIEdgeInsets.ExtendedTapAreaConstants.extraInset)

    convenience init(tapInset: UIEdgeInsets = .all(UIEdgeInsets.ExtendedTapAreaConstants.extraInset)) {
        self.init(type: .system)
        self.tapInset = tapInset
    }

    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        bounds.inset(by: UIEdgeInsets(
            top: -tapInset.top,
            left: -tapInset.left,
            bottom: -tapInset.bottom,
            right: -tapInset.right
        )).contains(point)
    }
}
