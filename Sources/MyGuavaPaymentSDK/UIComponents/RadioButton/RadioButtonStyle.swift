//
//  RadioButtonStyle.swift
//
//
//  Created by Игнат Чегодайкин on 06.06.2024.
//

import UIKit

protocol RadioButtonStyleProtocol {
    var backgroundCheckedColor: UIColor { get }
    var borderCheckedColor: UIColor { get }
    var backgroundUncheckedColor: UIColor { get }
    var borderUnCheckedColor: UIColor { get }
    var backgroundDisabledColor: UIColor { get }
    var borderDisabledColor: UIColor { get }
    var commonSize: CGSize { get }
    var checkSize: CGSize { get }
    var commonCornerRadius: CGFloat { get }
    var checkCornerRadius: CGFloat { get }
}

struct RadioButtonStyle: RadioButtonStyleProtocol {
    var backgroundCheckedColor: UIColor { UICustomization.SelectItem.accentColor }
    var borderCheckedColor: UIColor { UICustomization.SelectItem.accentColor }
    var backgroundUncheckedColor: UIColor { .clear }
    var borderUnCheckedColor: UIColor { .controls.borderRest }
    var backgroundDisabledColor: UIColor { .controls.backgroundDisabled }
    var borderDisabledColor: UIColor { .controls.borderDisable }
    var commonSize: CGSize { CGSize(width: 20, height: 20)}
    var checkSize: CGSize { CGSize(width: 12, height: 12)}
    var commonCornerRadius: CGFloat { commonSize.height / 2 }
    var checkCornerRadius: CGFloat { checkSize.height / 2 }
}
