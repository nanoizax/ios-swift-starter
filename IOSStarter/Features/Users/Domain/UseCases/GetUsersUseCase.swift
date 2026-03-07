// GetUsersUseCase.swift
// IOSStarter — Users Domain Use Case
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

// MARK: - GetUsersUseCaseProtocol

protocol GetUsersUseCaseProtocol {
    func execute(page: Int, limit: Int) async throws -> [UserItem]
}

// MARK: - GetUsersUseCase

/// Fetches users using a local-first strategy:
/// 1. Return cached users immediately (fast).
/// 2. Fetch from API in the background.
/// 3. Update the cache with fresh data.
final class GetUsersUseCase: GetUsersUseCaseProtocol {

    private let repository: UsersRepository

    init(repository: UsersRepository) {
        self.repository = repository
    }

    /// Returns remote users, updating the cache after a successful fetch.
    ///
    /// For a strictly local-first flow with optimistic UI, call `getCachedUsers()`
    /// directly on the repository first, then call this use case to refresh.
    func execute(page: Int, limit: Int) async throws -> [UserItem] {
        let users = try await repository.getUsers(page: page, limit: limit)
        try await repository.cacheUsers(users)
        return users
    }
}
