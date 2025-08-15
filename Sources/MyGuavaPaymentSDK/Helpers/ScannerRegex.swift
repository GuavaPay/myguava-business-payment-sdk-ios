//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import Foundation

struct ScannerRegex: ExpressibleByStringLiteral {
    private let pattern: String

    private var nsRegularExpression: NSRegularExpression? {
        try? NSRegularExpression(pattern: pattern)
    }

    typealias StringLiteralType = String

    init(stringLiteral value: StringLiteralType) {
        pattern = value
    }

    init(_ string: String) {
        pattern = string
    }

    func matches(in string: String) -> [String] {
        let ranges = nsRegularExpression?
            .matches(in: string, options: [], range: searchRange(for: string))
            .compactMap { Range($0.range, in: string) }
        ?? []

        return ranges
            .map { string[$0] }
            .map(String.init)
    }

    func hasMatch(in string: String) -> Bool {
        firstMatch(in: string) != nil
    }

    func firstMatch(in string: String) -> String? {
        guard
            let match = nsRegularExpression?.firstMatch(
                in: string,
                options: [],
                range: searchRange(for: string)
            ),
            let matchRange = Range(match.range, in: string) else {
            return nil
        }

        return String(string[matchRange])
    }

    func replacingOccurrences(in string: String, with replacement: String = "") -> String? {
        let range = searchRange(for: string)
        return nsRegularExpression?.stringByReplacingMatches(
            in: string,
            options: [],
            range: range,
            withTemplate: replacement
        )
    }

    func captures(in string: String) -> [String] {
        guard
            let checkingResult = nsRegularExpression?
                .firstMatch(in: string, options: [], range: searchRange(for: string)) else {
            return []
        }

        return (0 ..< checkingResult.numberOfRanges)
            .map { checkingResult.range(at: $0) }
            .compactMap { Range($0, in: string) }
            .map { string[$0] }
            .map(String.init)
    }

    private func searchRange(for string: String) -> NSRange {
        NSRange(location: 0, length: string.utf16.count)
    }
}

// MARK: Operator related

infix operator =~
infix operator !~

extension ScannerRegex {
    static func =~ (string: String, regex: ScannerRegex) -> Bool {
        regex.hasMatch(in: string)
    }

    static func =~ (regex: ScannerRegex, string: String) -> Bool {
        regex.hasMatch(in: string)
    }

    static func !~ (string: String, regex: ScannerRegex) -> Bool {
        !regex.hasMatch(in: string)
    }

    static func !~ (regex: ScannerRegex, string: String) -> Bool {
        !regex.hasMatch(in: string)
    }
}
