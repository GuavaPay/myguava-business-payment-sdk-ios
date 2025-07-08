//
//  Set+.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 26.06.2025.
//

extension Set {
    static func intersectMany<S: Sequence>(_ sequences: [S]) -> Set<Element> where S.Element == Element {
        guard var result = sequences.first.map(Set.init) else {
            return []
        }
        for sequence in sequences.dropFirst() {
            result.formIntersection(sequence)
        }
        return result
    }

    static func intersectManyArray<S: Sequence>(_ sequences: [S]) -> [Element] where S.Element == Element {
        Array(intersectMany(sequences))
    }
}
