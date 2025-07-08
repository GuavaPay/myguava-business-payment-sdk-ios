//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import UIKit

extension Array where Element: UIView {

    public func setTintColor(_ color: UIColor) {
        self.forEach { $0.tintColor = color }
    }

    public func hide() {
        self.forEach { $0.isHidden = true }
    }

    public func unHide() {
        self.forEach { $0.isHidden = false }
    }

    public func isHidden() -> Bool {
        return allSatisfy { $0.isHidden }
    }
}

extension Array {
    /// Subscript for safe access to element by index
    subscript(safe index: Index) -> Element? {
        (index < count && index >= 0) ? self[index] : nil
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        count == other.count && sorted() == other.sorted()
    }
}
