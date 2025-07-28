import UIKit

protocol ForegroundColor {
    var foregroundColor: UIColor { get set }

    func foregroundColor(_ value: UIColor) -> Self
}

extension ForegroundColor {
    func foregroundColor(_ value: UIColor) -> Self {
        var copy = self
        copy.foregroundColor = value
        return copy
    }
}
