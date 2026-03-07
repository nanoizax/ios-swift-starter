// AuthRepository.swift
// IOSStarter — Auth Domain Repository Protocol
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

/// Contract that any Auth repository implementation must fulfill.
/// The Domain layer depends on this protocol, never on concrete implementations.
protocol AuthRepository {

    /// Authenticates a user with the given credentials.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password (plain text — TLS is assumed).
    /// - Returns: The authenticated `User` domain entity.
    /// - Throws: `NetworkError` or domain-specific errors.
    func login(email: String, password: String) async throws -> User

    /// Invalidates the current session on the server and clears the local token.
    ///
    /// - Throws: `NetworkError` or domain-specific errors.
    func logout() async throws
}
