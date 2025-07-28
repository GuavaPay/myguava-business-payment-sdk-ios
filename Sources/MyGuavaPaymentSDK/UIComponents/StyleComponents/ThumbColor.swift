import UIKit

protocol ThumbColor {
    var thumbColor: UIColor { get set }

    func thumbColor(_ value: UIColor) -> Self
}

extension ThumbColor {
    func thumbColor(_ value: UIColor) -> Self {
        var copy = self
        copy.thumbColor = value
        return copy
    }
}
