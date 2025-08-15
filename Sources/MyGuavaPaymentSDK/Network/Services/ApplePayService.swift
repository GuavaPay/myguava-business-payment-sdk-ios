//
//  File.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 24.06.2025.
//

import Foundation

struct ApplePayEndpoint: APIEndpoint {
    let path = "applepay/context"
    let method: HTTPMethod = .get
    let queryItems: [URLQueryItem]? = nil
    let body: [String: Any]? = nil
}

struct ApplePayService {
    private let api: APIClient

    init(api: APIClient = .shared) {
        self.api = api
    }

    func getContext(completion: @escaping (Result<APIResponse<ApplePayContext>, APIError>) -> Void) {
        api.performRequest(endpoint: ApplePayEndpoint(), completion: completion)
    }
}
