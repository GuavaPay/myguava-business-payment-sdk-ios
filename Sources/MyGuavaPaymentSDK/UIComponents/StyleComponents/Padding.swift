import UIKit

public protocol Padding {
    var padding: UIEdgeInsets { get set }

    func padding(_ value: UIEdgeInsets) -> Self
}

extension Padding {
    public func padding(_ value: UIEdgeInsets) -> Self {
        var copy = self
        copy.padding = value
        return copy
    }

    public func paddingLeft(_ value: CGFloat) -> Self {
        var copy = self
        copy.padding.left = value
        return copy
    }

    public func paddingRight(_ value: CGFloat) -> Self {
        var copy = self
        copy.padding.right = value
        return copy
    }

    public func paddingTop(_ value: CGFloat) -> Self {
        var copy = self
        copy.padding.top = value
        return copy
    }

    public func paddingBottom(_ value: CGFloat) -> Self {
        var copy = self
        copy.padding.bottom = value
        return copy
    }
}
