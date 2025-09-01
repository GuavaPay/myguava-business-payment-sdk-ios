//
//  BindingsService.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 26.06.2025.
//

import Foundation

protocol BindingsService {
    func getBindings(completion: @escaping (Result<APIResponse<Bindings>, APIError>) -> Void)

    func renameBinding(
        bindingId: String,
        name: String,
        completion: @escaping (Result<APIResponse<Binding>, APIError>) -> Void
    )

    func deleteBinding(
        bindingId: String,
        completion: @escaping (Result<APIResponse<String>, APIError>) -> Void
    )
}

struct BindingsServiceImpl: BindingsService {
    private let api: APIClient

    init(api: APIClient = .shared) {
        self.api = api
    }

    func getBindings(completion: @escaping (Result<APIResponse<Bindings>, APIError>) -> Void) {
        api.performRequest(endpoint: BindingsEndpoint(), completion: completion)
    }

    func renameBinding(
        bindingId: String,
        name: String,
        completion: @escaping (Result<APIResponse<Binding>, APIError>) -> Void
    ) {
        api.performRequest(
            endpoint: RenameBindingEndpoint(
                bindingId: bindingId,
                body: ["name": name]
            ),
            completion: completion
        )
    }

    func deleteBinding(bindingId: String, completion: @escaping (Result<APIResponse<String>, APIError>) -> Void) {
        api.performRequest(
            endpoint: DeleteBindingEndpoint(bindingId: bindingId),
            responseModel: String.self,
            acceptEmptyResponseCodes: [204],
            allowedErrorCodes: [404],
            completion: completion
        )
    }
}
