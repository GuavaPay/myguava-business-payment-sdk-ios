import UIKit

protocol BorderColor {
    var borderColor: UIColor { get set }

    func borderColor(_ value: UIColor) -> Self
}

extension BorderColor {
    func borderColor(_ value: UIColor) -> Self {
        var copy = self
        copy.borderColor = value
        return copy
    }
}
