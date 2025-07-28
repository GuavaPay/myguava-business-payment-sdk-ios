//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import Foundation

protocol Size {
    var size: CGSize { get set }

    func size(_ value: CGSize) -> Self
}

extension Size {
    func size(_ value: CGSize) -> Self {
        var copy = self
        copy.size = value
        return copy
    }
}
