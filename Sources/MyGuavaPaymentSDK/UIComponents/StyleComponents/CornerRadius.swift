import UIKit

public protocol CornerRadius {
    var cornerRadius: CGFloat { get set }

    func cornerRadius(_ value: CGFloat) -> Self
}

extension CornerRadius {
    public func cornerRadius(_ value: CGFloat) -> Self {
        var copy = self
        copy.cornerRadius = value
        return copy
    }
}