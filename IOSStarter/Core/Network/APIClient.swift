// APIClient.swift
// IOSStarter
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

// MARK: - APIClientProtocol

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

// MARK: - APIClient

/// Centralised HTTP client backed by `URLSession`.
///
/// Token injection is handled automatically — the client reads the token from
/// `TokenStorage` before every request. Swap `TokenStorage` for a Keychain
/// implementation in production.
final class APIClient: APIClientProtocol {

    // MARK: - Dependencies

    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenStorage: TokenStorageProtocol

    // MARK: - Shared Instance

    static let shared = APIClient()

    // MARK: - Init

    init(
        session: URLSession = .shared,
        tokenStorage: TokenStorageProtocol = TokenStorage.shared
    ) {
        self.session = session
        self.tokenStorage = tokenStorage

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    // MARK: - Public

    /// Performs an authenticated (or public) network request and decodes the response.
    ///
    /// - Parameter endpoint: The `APIEndpoint` case describing the request.
    /// - Returns: A decoded value of type `T`.
    /// - Throws: A `NetworkError` describing what went wrong.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let token = tokenStorage.token
        let urlRequest: URLRequest

        do {
            urlRequest = try endpoint.urlRequest(token: token)
        } catch {
            throw NetworkError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet ||
               urlError.code == .networkConnectionLost {
                throw NetworkError.noConnection
            }
            throw NetworkError.transportError(urlError.localizedDescription)
        } catch {
            throw NetworkError.transportError(error.localizedDescription)
        }

        try validate(response: response, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError {
            throw NetworkError.decodingError(decodingError.localizedDescription)
        }
    }

    // MARK: - Private

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - TokenStorage

protocol TokenStorageProtocol {
    var token: String? { get }
    func save(token: String)
    func clear()
}

/// Simple UserDefaults-backed token storage.
/// Replace with a Keychain wrapper for production apps.
final class TokenStorage: TokenStorageProtocol {

    static let shared = TokenStorage()

    private let key = "auth_token"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var token: String? {
        defaults.string(forKey: key)
    }

    func save(token: String) {
        defaults.set(token, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
