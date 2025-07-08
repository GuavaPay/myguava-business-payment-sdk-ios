import UIKit

public protocol StackSpacing {
    var spacing: CGFloat { get set }

    func spacing(_ value: CGFloat) -> Self
}

extension StackSpacing {
    public func spacing(_ value: CGFloat) -> Self {
        var copy = self
        copy.spacing = value
        return copy
    }
}
