import UIKit

public protocol BorderWidth {
    var borderWidth: CGFloat { get set }

    func borderWidth(_ value: CGFloat) -> Self
}

extension BorderWidth {
    public func borderWidth(_ value: CGFloat) -> Self {
        var copy = self
        copy.borderWidth = value
        return copy
    }
}