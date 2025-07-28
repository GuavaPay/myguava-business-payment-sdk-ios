import UIKit

protocol BorderWidth {
    var borderWidth: CGFloat { get set }

    func borderWidth(_ value: CGFloat) -> Self
}

extension BorderWidth {
    func borderWidth(_ value: CGFloat) -> Self {
        var copy = self
        copy.borderWidth = value
        return copy
    }
}
