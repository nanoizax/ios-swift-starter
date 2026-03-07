// AppCoordinator.swift
// IOSStarter — App Coordinator
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation
import SwiftData

// MARK: - AuthState

enum AuthState: Equatable {
    case unauthenticated
    case authenticated(User)
}

// MARK: - AppCoordinator

/// Root coordinator that owns the authentication state for the entire app.
///
/// `IOSStarterApp` observes this object to decide which root view to display:
/// - Unauthenticated → `LoginView`
/// - Authenticated   → `UsersView`
///
/// All use cases and repositories are instantiated here (Poor Man's DI).
/// For larger apps, replace with a proper DI container (e.g., Factory, Swinject).
@MainActor
@Observable
final class AppCoordinator {

    // MARK: - State

    var authState: AuthState

    // MARK: - Dependencies (owned by the coordinator)

    let loginViewModel: LoginViewModel
    let usersViewModel: UsersViewModel

    // MARK: - Private

    private let tokenStorage: TokenStorageProtocol
    private let logoutUseCase: LogoutUseCaseProtocol

    // MARK: - Init

    init(modelContext: ModelContext) {
        tokenStorage = TokenStorage.shared

        // Auth dependencies
        let authRepository = AuthRepositoryImpl(
            apiClient: APIClient.shared,
            tokenStorage: tokenStorage
        )
        let loginUseCase  = LoginUseCase(repository: authRepository)
        let logoutUseCase = LogoutUseCase(repository: authRepository)
        self.logoutUseCase = logoutUseCase

        // Users dependencies
        let usersRepository = UsersRepositoryImpl(
            apiClient: APIClient.shared,
            modelContext: modelContext
        )
        let getUsersUseCase = GetUsersUseCase(repository: usersRepository)

        // ViewModels
        loginViewModel = LoginViewModel(
            loginUseCase: loginUseCase,
            logoutUseCase: logoutUseCase
        )
        usersViewModel = UsersViewModel(
            getUsersUseCase: getUsersUseCase,
            repository: usersRepository
        )

        // Restore session if a token already exists
        if tokenStorage.token != nil {
            // In a real app, validate the token with the server here.
            // For the starter, we treat a stored token as a valid session.
            authState = .authenticated(
                User(id: 0, name: "Cached Session", email: "", role: .user)
            )
        } else {
            authState = .unauthenticated
        }
    }

    // MARK: - Actions

    func userDidLogin(_ user: User) {
        authState = .authenticated(user)
    }

    func userDidLogout() async {
        await loginViewModel.logout()
        authState = .unauthenticated
    }
}
