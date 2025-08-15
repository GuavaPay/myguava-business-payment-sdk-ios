//
//  Codable+Dictionary.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 07.07.2025.
//


import Foundation

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            return nil
        }

        var json = jsonObject as? [String: Any]

        // Remove top level fields with empty object
        for (key, value) in json ?? [:] where (value as? [String: Any])?.isEmpty == true {
            json?[key] = nil
        }

        return json
    }
}
