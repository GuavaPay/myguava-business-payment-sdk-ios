import UIKit

protocol Height {
    var height: CGFloat { get set }

    func height(_ value: CGFloat) -> Self
}

extension Height {
    func height(_ value: CGFloat) -> Self {
        var copy = self
        copy.height = value
        return copy
    }
}
