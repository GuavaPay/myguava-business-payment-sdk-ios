//
//  Array+.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 26.06.2025.
//

import Foundation

extension Array {
    func partitioned(by predicate: (Element) throws -> Bool) rethrows -> ([Element], [Element]) {
        var matching = [Element]()
        var nonMatching = [Element]()
        for element in self {
            if try predicate(element) {
                matching.append(element)
            } else {
                nonMatching.append(element)
            }
        }
        return (matching, nonMatching)
    }

    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
