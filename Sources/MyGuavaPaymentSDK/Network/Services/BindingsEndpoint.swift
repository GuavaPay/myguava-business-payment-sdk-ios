//
//  BindingsEndpoint.swift
//  MyGuavaPaymentSDK
//
//  Created by Nikolai Kriuchkov on 22.08.2025.
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
