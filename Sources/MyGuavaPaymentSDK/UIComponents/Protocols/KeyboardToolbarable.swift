//
//  KeyboardToolbarable.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 05.08.2025.
//

import UIKit

protocol KeyboardToolbarable: FirstResponderForwardable where ResponderType == UITextField {
    /// Is conforming view hidden
    var isHidden: Bool { get set }

    /// Add keyboard toolbar with `Up`, `Down` and `Done` buttons
    func addKeyboardArrowToToolbar(
        onUpArrow: (target: Any, action: Selector),
        onDownArrow: (target: Any, action: Selector)
    )
}

extension KeyboardToolbarable {
    func addKeyboardArrowToToolbar(
        onUpArrow: (target: Any, action: Selector),
        onDownArrow: (target: Any, action: Selector)
    ) {
        firstResponderInput.addKeyboardArrowToToolbar(onUpArrow: onUpArrow, onDownArrow: onDownArrow)
    }
}
