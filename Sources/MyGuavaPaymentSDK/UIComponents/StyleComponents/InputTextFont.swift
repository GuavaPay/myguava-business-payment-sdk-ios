import UIKit

protocol InputTextFont {
    var inputTextFont: UIFont { get set }

    func inputTextFont(_ value: UIFont) -> Self
}

extension InputTextFont {
    func inputTextFont(_ value: UIFont) -> Self {
        var copy = self
        copy.inputTextFont = value
        return copy
    }
}
