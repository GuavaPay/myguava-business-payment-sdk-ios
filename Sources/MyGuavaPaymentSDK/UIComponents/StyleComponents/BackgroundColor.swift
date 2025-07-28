import UIKit

protocol BackgroundColor {
    var backgroundColor: UIColor { get set }

    func backgroundColor(_ value: UIColor) -> Self
}

extension BackgroundColor {
    func backgroundColor(_ value: UIColor) -> Self {
        var copy = self
        copy.backgroundColor = value
        return copy
    }
}
