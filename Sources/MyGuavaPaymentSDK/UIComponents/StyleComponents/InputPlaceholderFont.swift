import UIKit

protocol InputPlaceholderFont {
    var inputPlaceholderFont: UIFont { get set }

    func inputPlaceholderFont(_ value: UIFont) -> Self
}

extension InputPlaceholderFont {
    func inputPlaceholderFont(_ value: UIFont) -> Self {
        var copy = self
        copy.inputPlaceholderFont = value
        return copy
    }
}
