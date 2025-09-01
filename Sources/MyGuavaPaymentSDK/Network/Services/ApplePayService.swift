//
//  ApplePayService.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 24.06.2025.
//

import Foundation

protocol ApplePayService {
    func getContext(completion: @escaping (Result<APIResponse<ApplePayContext>, APIError>) -> Void)
}

struct ApplePayServiceImpl: ApplePayService {
    private let api: APIClient

    init(api: APIClient = .shared) {
        self.api = api
    }

    func getContext(completion: @escaping (Result<APIResponse<ApplePayContext>, APIError>) -> Void) {
        api.performRequest(endpoint: ApplePayEndpoint(), completion: completion)
    }
}
