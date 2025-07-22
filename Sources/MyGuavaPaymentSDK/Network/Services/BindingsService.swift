//
//  BindingsService.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 26.06.2025.
//

import Foundation

struct BindingsEndpoint: APIEndpoint {
    let path = "bindings"
    let method: HTTPMethod = .get
    var queryItems: [URLQueryItem]? = nil
    var body: [String: Any]? = nil
}

struct BindingsService {
    private let api: APIClient
    
    init(api: APIClient = .shared) {
        self.api = api
    }
    
    func getBindings(completion: @escaping (Result<APIResponse<Bindings>, Error>) -> Void) {
        api.performRequest(endpoint: BindingsEndpoint(), completion: completion)
    }
}
