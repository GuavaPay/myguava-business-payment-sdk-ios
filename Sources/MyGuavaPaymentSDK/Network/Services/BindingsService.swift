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

struct RenameBindingEndpoint: APIEndpoint {
    let path: String
    let method: HTTPMethod = .patch
    var queryItems: [URLQueryItem]? = nil
    var body: [String: Any]? = nil

    init(bindingId: String, body: [String : Any]? = nil) {
        self.path = "binding/\(bindingId)"
        self.body = body
    }
}

struct DeleteBindingEndpoint: APIEndpoint {
    let path: String
    let method: HTTPMethod = .delete
    var queryItems: [URLQueryItem]? = nil
    var body: [String: Any]? = nil

    init(bindingId: String) {
        self.path = "binding/\(bindingId)"
    }
}

struct BindingsService {
    private let api: APIClient
    
    init(api: APIClient = .shared) {
        self.api = api
    }
    
    func getBindings(completion: @escaping (Result<APIResponse<Bindings>, Error>) -> Void) {
        api.performRequest(endpoint: BindingsEndpoint(), completion: completion)
    }

    func renameBinding(bindingId: String, name: String, completion: @escaping (Result<APIResponse<Binding>, Error>) -> Void) {
        api.performRequest(
            endpoint: RenameBindingEndpoint(
                bindingId: bindingId,
                body: ["name": name]
            ),
            completion: completion
        )
    }

    func deleteBinding(bindingId: String, completion: @escaping (Result<APIResponse<String>, Error>) -> Void) {
        api.performRequest(
            endpoint: DeleteBindingEndpoint(bindingId: bindingId),
            responseModel: String.self,
            acceptEmptyResponseCodes: [204],
            completion: completion
        )
    }
}
