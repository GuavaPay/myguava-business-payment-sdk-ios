import UIKit

public protocol GradientColor {
    var gradientColors: [UIColor] { get set }

    func gradientColors(_ values: [UIColor]) -> Self
}

extension GradientColor {
    public func gradientColors(_ values: [UIColor]) -> Self {
        var copy = self
        copy.gradientColors = values
        return copy
    }
}
