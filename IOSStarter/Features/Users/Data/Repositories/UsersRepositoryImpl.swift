// UsersRepositoryImpl.swift
// IOSStarter — Users Data Repository
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation
import SwiftData

/// Concrete repository that combines remote API calls with local SwiftData cache.
final class UsersRepositoryImpl: UsersRepository {

    private let apiClient: APIClientProtocol
    private let modelContext: ModelContext

    init(
        apiClient: APIClientProtocol = APIClient.shared,
        modelContext: ModelContext
    ) {
        self.apiClient    = apiClient
        self.modelContext = modelContext
    }

    // MARK: - UsersRepository

    func getUsers(page: Int, limit: Int) async throws -> [UserItem] {
        let endpoint = APIEndpoint.getUsers(page: page, limit: limit)
        let response: PaginatedUsersResponseDTO = try await apiClient.request(endpoint)
        return response.data.map { $0.toDomain() }
    }

    func getUser(id: Int) async throws -> UserItem {
        let endpoint = APIEndpoint.getUserById(id: id)
        let response: SingleUserResponseDTO = try await apiClient.request(endpoint)
        return response.data.toDomain()
    }

    @MainActor
    func getCachedUsers() async throws -> [UserItem] {
        let descriptor = FetchDescriptor<CachedUser>(
            sortBy: [SortDescriptor(\.id)]
        )
        let cached = try modelContext.fetch(descriptor)
        return cached.map { $0.toDomain() }
    }

    @MainActor
    func cacheUsers(_ users: [UserItem]) async throws {
        // Fetch existing cached users to update or insert
        let existingDescriptor = FetchDescriptor<CachedUser>()
        let existing = try modelContext.fetch(existingDescriptor)
        let existingMap = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for user in users {
            if let cached = existingMap[user.id] {
                // Update existing record
                cached.firstName       = user.firstName
                cached.lastName        = user.lastName
                cached.email           = user.email
                cached.avatarURLString = user.avatarURL?.absoluteString
                cached.cachedAt        = .now
            } else {
                // Insert new record
                let newCached = CachedUser.from(domain: user)
                modelContext.insert(newCached)
            }
        }

        try modelContext.save()
    }
}
