//
//  ApplePayEndpoint.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 01.07.2025.
//

import Foundation

struct ResolveCardEndpoint: APIEndpoint {
    let path = "card-range/resolve"
    let method: HTTPMethod = .post
    let queryItems: [URLQueryItem]? = nil
    let body: [String: Any]?
}

struct ResolveCardService {
    private let api: APIClient

    init(api: APIClient = .shared) {
        self.api = api
    }

    func resolveCard(
        for cardNumber: String,
        completion: @escaping (Result<APIResponse<ResolveCard>, APIError>) -> Void
    ) {
        let body: [String: Any] = ["rangeIncludes": cardNumber]
        api.performRequest(endpoint: ResolveCardEndpoint(body: body), completion: completion)
    }
}
