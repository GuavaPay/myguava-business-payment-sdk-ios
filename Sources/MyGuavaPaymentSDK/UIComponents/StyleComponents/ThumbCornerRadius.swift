import UIKit

protocol ThumbCornerRadius {
    var thumbCornerRadius: CGFloat { get set }

    func thumbCornerRadius(_ value: CGFloat) -> Self
}

extension ThumbCornerRadius {
    func thumbCornerRadius(_ value: CGFloat) -> Self {
        var copy = self
        copy.thumbCornerRadius = value
        return copy
    }
}
