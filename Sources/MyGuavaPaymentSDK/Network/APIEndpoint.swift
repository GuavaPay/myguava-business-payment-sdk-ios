//
//  APIEndpoint.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 12.06.2025.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var body: [String: Any]? { get }

    func makeURLRequest(baseURL: String) throws -> URLRequest
}

extension APIEndpoint {
    func makeURLRequest(baseURL: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(path)") else {
            throw APIError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems

        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue

        if let body = body {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        }

        return request
    }
}
