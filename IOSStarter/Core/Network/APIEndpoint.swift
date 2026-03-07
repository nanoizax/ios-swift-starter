// APIEndpoint.swift
// IOSStarter
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

// MARK: - APIEndpoint

/// Defines every API endpoint the app can call.
/// Each case carries the data required to build a `URLRequest`.
enum APIEndpoint {

    // Auth
    case login(LoginRequestDTO)
    case logout

    // Users
    case getUsers(page: Int, limit: Int)
    case getUserById(id: Int)

    // MARK: - Base URL

    private static let baseURL = "https://reqres.in/api"

    // MARK: - Request Building

    /// Builds a fully configured `URLRequest` for this endpoint.
    /// - Parameter token: Optional bearer token injected into the Authorization header.
    /// - Throws: `NetworkError.invalidURL` if the URL cannot be constructed.
    func urlRequest(token: String? = nil) throws -> URLRequest {
        guard let url = buildURL() else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = httpBody {
            request.httpBody = body
        }

        return request
    }

    // MARK: - Private Helpers

    private var method: HTTPMethod {
        switch self {
        case .login:         return .post
        case .logout:        return .post
        case .getUsers:      return .get
        case .getUserById:   return .get
        }
    }

    private var path: String {
        switch self {
        case .login:               return "/login"
        case .logout:              return "/logout"
        case .getUsers:            return "/users"
        case .getUserById(let id): return "/users/\(id)"
        }
    }

    private var queryItems: [URLQueryItem]? {
        switch self {
        case .getUsers(let page, let limit):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(limit)")
            ]
        default:
            return nil
        }
    }

    private var httpBody: Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        switch self {
        case .login(let dto):
            return try? encoder.encode(dto)
        default:
            return nil
        }
    }

    private func buildURL() -> URL? {
        var components = URLComponents(string: Self.baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
