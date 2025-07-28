import UIKit

protocol TitleFont {
    var titleFont: UIFont { get set }

    func titleFont(_ value: UIFont) -> Self
}

extension TitleFont {
    func titleFont(_ value: UIFont) -> Self {
        var copy = self
        copy.titleFont = value
        return copy
    }
}
