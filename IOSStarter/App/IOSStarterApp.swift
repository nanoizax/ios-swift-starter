// IOSStarterApp.swift
// IOSStarter
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import SwiftUI
import SwiftData

@main
struct IOSStarterApp: App {

    @State private var coordinator: AppCoordinator

    init() {
        let persistence = PersistenceController.shared
        _coordinator = State(
            wrappedValue: AppCoordinator(modelContext: persistence.mainContext)
        )
    }

    var body: some Scene {
        WindowGroup {
            rootView
                .modelContainer(PersistenceController.shared.container)
        }
    }

    // MARK: - Root View

    @ViewBuilder
    private var rootView: some View {
        switch coordinator.authState {
        case .unauthenticated:
            LoginView(viewModel: coordinator.loginViewModel) { user in
                coordinator.userDidLogin(user)
            }
        case .authenticated:
            UsersView(viewModel: coordinator.usersViewModel)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Sign Out", role: .destructive) {
                            Task { await coordinator.userDidLogout() }
                        }
                        .foregroundStyle(.red)
                    }
                }
        }
    }
}
