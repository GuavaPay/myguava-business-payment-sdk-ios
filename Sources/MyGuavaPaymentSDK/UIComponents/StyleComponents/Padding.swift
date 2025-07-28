import UIKit

protocol Padding {
    var padding: UIEdgeInsets { get set }

    func padding(_ value: UIEdgeInsets) -> Self
}

extension Padding {
    func padding(_ value: UIEdgeInsets) -> Self {
        var copy = self
        copy.padding = value
        return copy
    }

    func paddingLeft(_ value: CGFloat) -> Self {
        var copy = self
        copy.padding.left = value
        return copy
    }

    func paddingRight(_ value: CGFloat) -> Self {
        var copy = self
        copy.padding.right = value
        return copy
    }

    func paddingTop(_ value: CGFloat) -> Self {
        var copy = self
        copy.padding.top = value
        return copy
    }

    func paddingBottom(_ value: CGFloat) -> Self {
        var copy = self
        copy.padding.bottom = value
        return copy
    }
}
