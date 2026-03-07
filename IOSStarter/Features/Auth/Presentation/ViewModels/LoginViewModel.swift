// LoginViewModel.swift
// IOSStarter — Auth Presentation ViewModel
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation
import Combine

// MARK: - LoginViewState

enum LoginViewState: Equatable {
    case idle
    case loading
    case success(User)
    case error(String)
}

// MARK: - LoginViewModel

/// Drives the `LoginView`.
///
/// Annotated with `@MainActor` so that all state mutations happen on the main thread,
/// making it safe to bind directly to SwiftUI views.
@MainActor
@Observable
final class LoginViewModel {

    // MARK: - Public State (bindable)

    var email: String = ""
    var password: String = ""
    var viewState: LoginViewState = .idle
    var currentUser: User?

    // MARK: - Derived State

    var isLoading: Bool { viewState == .loading }

    var errorMessage: String? {
        if case .error(let msg) = viewState { return msg }
        return nil
    }

    var isLoginEnabled: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        !isLoading
    }

    // MARK: - Private

    private let loginUseCase: LoginUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol

    // MARK: - Init

    init(
        loginUseCase: LoginUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol
    ) {
        self.loginUseCase  = loginUseCase
        self.logoutUseCase = logoutUseCase
    }

    // MARK: - Actions

    func login() async {
        guard isLoginEnabled else { return }

        viewState = .loading

        do {
            let user = try await loginUseCase.execute(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            currentUser = user
            viewState   = .success(user)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func logout() async {
        do {
            try await logoutUseCase.execute()
        } catch {
            // Logout errors are non-critical — we clear local state regardless.
        }
        currentUser = nil
        email       = ""
        password    = ""
        viewState   = .idle
    }

    func dismissError() {
        if case .error = viewState {
            viewState = .idle
        }
    }
}
