import UIKit

public protocol TitleFont {
    var titleFont: UIFont { get set }

    func titleFont(_ value: UIFont) -> Self
}

extension TitleFont {
    public func titleFont(_ value: UIFont) -> Self {
        var copy = self
        copy.titleFont = value
        return copy
    }
}
