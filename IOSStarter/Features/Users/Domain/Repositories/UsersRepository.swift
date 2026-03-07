// UsersRepository.swift
// IOSStarter — Users Domain Repository Protocol
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

/// Contract for fetching and caching users.
protocol UsersRepository {

    /// Fetches a paginated list of users.
    ///
    /// - Parameters:
    ///   - page: 1-based page number.
    ///   - limit: Number of users per page.
    /// - Returns: Array of `UserItem` domain entities.
    func getUsers(page: Int, limit: Int) async throws -> [UserItem]

    /// Fetches a single user by their identifier.
    func getUser(id: Int) async throws -> UserItem

    /// Returns locally cached users without hitting the network.
    func getCachedUsers() async throws -> [UserItem]

    /// Persists a list of users to the local cache.
    func cacheUsers(_ users: [UserItem]) async throws
}
