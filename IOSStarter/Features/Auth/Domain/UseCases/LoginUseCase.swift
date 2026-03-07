// LoginUseCase.swift
// IOSStarter — Auth Domain Use Case
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

// MARK: - LoginValidationError

enum LoginValidationError: Error, LocalizedError, Equatable {
    case emptyEmail
    case invalidEmailFormat
    case emptyPassword
    case passwordTooShort(minimum: Int)

    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Email address cannot be empty."
        case .invalidEmailFormat:
            return "Please enter a valid email address."
        case .emptyPassword:
            return "Password cannot be empty."
        case .passwordTooShort(let min):
            return "Password must be at least \(min) characters long."
        }
    }
}

// MARK: - LoginUseCaseProtocol

protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> User
}

// MARK: - LoginUseCase

/// Orchestrates the login flow: validate input → call repository → return User.
final class LoginUseCase: LoginUseCaseProtocol {

    private let repository: AuthRepository
    private let minimumPasswordLength: Int

    init(repository: AuthRepository, minimumPasswordLength: Int = 6) {
        self.repository = repository
        self.minimumPasswordLength = minimumPasswordLength
    }

    /// Validates credentials, then delegates to the repository.
    ///
    /// - Parameters:
    ///   - email: Raw email input from the user.
    ///   - password: Raw password input from the user.
    /// - Returns: Authenticated `User` entity.
    /// - Throws: `LoginValidationError` for invalid input, or repository errors.
    func execute(email: String, password: String) async throws -> User {
        // 1. Input validation
        try validate(email: email, password: password)

        // 2. Delegate to the repository (network + token storage)
        return try await repository.login(email: email, password: password)
    }

    // MARK: - Private

    private func validate(email: String, password: String) throws {
        let trimmedEmail    = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            throw LoginValidationError.emptyEmail
        }

        if !isValidEmail(trimmedEmail) {
            throw LoginValidationError.invalidEmailFormat
        }

        if trimmedPassword.isEmpty {
            throw LoginValidationError.emptyPassword
        }

        if trimmedPassword.count < minimumPasswordLength {
            throw LoginValidationError.passwordTooShort(minimum: minimumPasswordLength)
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        // RFC 5322 simplified check
        let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
