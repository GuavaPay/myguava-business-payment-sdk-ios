//
//  String+.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 17.06.2025.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }

    func removingCharactersInSet(_ set: CharacterSet) -> String {
        let stringParts = components(separatedBy: set)
        let notEmptyStringParts = stringParts.filter { text in
            text.isEmpty == false
        }
        return notEmptyStringParts.joined(separator: "")
    }

    func removingWhitespaceAndNewlines() -> String {
        removingCharactersInSet(CharacterSet.whitespacesAndNewlines)
    }
}

extension String {
    func index(at offset: Int) -> String.Index {
        index(startIndex, offsetBy: offset)
    }
}

extension String {
    subscript(value: Int) -> Character {
        self[index(at: value)]
    }
}

extension String {
    subscript(value: NSRange) -> Substring {
        self[value.lowerBound ..< value.upperBound]
    }
}

extension String {
    subscript(value: CountableClosedRange<Int>) -> Substring {
        self[index(at: value.lowerBound) ... index(at: value.upperBound)]
    }

    subscript(value: CountableRange<Int>) -> Substring {
        self[index(at: value.lowerBound) ..< index(at: value.upperBound)]
    }

    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        self[..<index(at: value.upperBound)]
    }

    subscript(value: PartialRangeThrough<Int>) -> Substring {
        self[...index(at: value.upperBound)]
    }

    subscript(value: PartialRangeFrom<Int>) -> Substring {
        self[index(at: value.lowerBound)...]
    }
}
