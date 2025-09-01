//
//  ResolveCardEndpoint.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
//

import Foundation

struct ResolveCardEndpoint: APIEndpoint {
    let path = "card-range/resolve"
    let method: HTTPMethod = .post
    let queryItems: [URLQueryItem]? = nil
    let body: [String: Any]?
}
