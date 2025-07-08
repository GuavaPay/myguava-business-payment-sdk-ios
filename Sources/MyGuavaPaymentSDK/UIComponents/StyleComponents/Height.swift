import UIKit

public protocol Height {
    var height: CGFloat { get set }

    func height(_ value: CGFloat) -> Self
}

extension Height {
    public func height(_ value: CGFloat) -> Self {
        var copy = self
        copy.height = value
        return copy
    }
}
