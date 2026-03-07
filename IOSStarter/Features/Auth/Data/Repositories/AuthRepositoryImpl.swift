// AuthRepositoryImpl.swift
// IOSStarter — Auth Data Repository
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

/// Concrete implementation of `AuthRepository`.
///
/// Responsibilities:
/// - Build the network request via `APIClient`.
/// - Persist and clear the auth token via `TokenStorage`.
/// - Map DTOs to domain entities.
final class AuthRepositoryImpl: AuthRepository {

    private let apiClient: APIClientProtocol
    private let tokenStorage: TokenStorageProtocol

    init(
        apiClient: APIClientProtocol = APIClient.shared,
        tokenStorage: TokenStorageProtocol = TokenStorage.shared
    ) {
        self.apiClient    = apiClient
        self.tokenStorage = tokenStorage
    }

    // MARK: - AuthRepository

    func login(email: String, password: String) async throws -> User {
        let requestDTO  = LoginRequestDTO(email: email, password: password)
        let endpoint    = APIEndpoint.login(requestDTO)

        // 1. Obtain token
        let authResponse: AuthResponseDTO = try await apiClient.request(endpoint)
        tokenStorage.save(token: authResponse.token)

        // 2. Fetch user profile with the fresh token
        //    reqres.in uses numeric IDs — we request user #1 as a demo.
        //    In a real app, the login response would include the user's own ID.
        let userEndpoint = APIEndpoint.getUserById(id: 1)
        let userResponse: SingleUserResponseDTO = try await apiClient.request(userEndpoint)

        return userResponse.data.toDomain()
    }

    func logout() async throws {
        defer { tokenStorage.clear() }
        // Attempt server-side logout. Ignore server errors — local token is cleared regardless.
        _ = try? await apiClient.request(APIEndpoint.logout) as EmptyResponse
    }
}

// MARK: - Supporting Types

/// Wraps a single-user API response (reqres.in shape).
private struct SingleUserResponseDTO: Decodable {
    let data: UserResponseDTO
}

/// Used when a response body is expected but the content is irrelevant.
private struct EmptyResponse: Decodable {}
