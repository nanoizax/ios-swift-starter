// LogoutUseCase.swift
// IOSStarter — Auth Domain Use Case
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

// MARK: - LogoutUseCaseProtocol

protocol LogoutUseCaseProtocol {
    func execute() async throws
}

// MARK: - LogoutUseCase

/// Invalidates the server session and clears local auth state.
final class LogoutUseCase: LogoutUseCaseProtocol {

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    /// Performs the logout operation.
    ///
    /// This calls the server endpoint and, regardless of the server response,
    /// the local token is cleared (handled in the repository implementation).
    func execute() async throws {
        try await repository.logout()
    }
}
