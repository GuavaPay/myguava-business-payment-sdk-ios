import UIKit

protocol TintColor {
    var tintColor: UIColor { get set }

    func tintColor(_ value: UIColor) -> Self
}

extension TintColor {
    func tintColor(_ value: UIColor) -> Self {
        var copy = self
        copy.tintColor = value
        return copy
    }
}
