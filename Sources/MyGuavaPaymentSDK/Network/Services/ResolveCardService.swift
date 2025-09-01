//
//  ResolveCardService.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 01.07.2025.
//

import Foundation

protocol ResolveCardService {
    func resolveCard(
        for cardNumber: String,
        completion: @escaping (Result<APIResponse<ResolveCard>, APIError>) -> Void
    )
}

struct ResolveCardServiceImpl: ResolveCardService {
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
