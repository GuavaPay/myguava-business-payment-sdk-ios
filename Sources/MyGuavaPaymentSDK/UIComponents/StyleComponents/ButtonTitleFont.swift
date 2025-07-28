import UIKit

protocol ButtonTitleFont {
    var buttonTitleFont: UIFont { get set }

    func buttonTitleFont(_ value: UIFont) -> Self
}

extension ButtonTitleFont {
    func buttonTitleFont(_ value: UIFont) -> Self {
        var copy = self
        copy.buttonTitleFont = value
        return copy
    }
}
