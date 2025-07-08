import UIKit

public protocol ButtonBackgroundColor {
    var buttonBackgroundColor: UIColor { get set }

    func buttonBackgroundColor(_ value: UIColor) -> Self
}

extension ButtonBackgroundColor {
    public func buttonBackgroundColor(_ value: UIColor) -> Self {
        var copy = self
        copy.buttonBackgroundColor = value
        return copy
    }
}
