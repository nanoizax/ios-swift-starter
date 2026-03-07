// UsersViewModel.swift
// IOSStarter — Users Presentation ViewModel
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation
import Combine

// MARK: - UsersViewState

enum UsersViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)

    static func == (lhs: UsersViewState, rhs: UsersViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loaded, .loaded): return true
        case (.error(let a), .error(let b)): return a == b
        default: return false
        }
    }
}

// MARK: - UsersViewModel

/// Drives `UsersView` with paginated loading and local-first caching.
@MainActor
@Observable
final class UsersViewModel {

    // MARK: - State

    var users: [UserItem] = []
    var viewState: UsersViewState = .idle
    var isRefreshing: Bool = false
    var hasMorePages: Bool = true

    var isLoading: Bool { viewState == .loading }

    var errorMessage: String? {
        if case .error(let msg) = viewState { return msg }
        return nil
    }

    // MARK: - Pagination

    private let pageLimit = 20
    private var currentPage = 1

    // MARK: - Dependencies

    private let getUsersUseCase: GetUsersUseCaseProtocol
    private let repository: UsersRepository

    // MARK: - Init

    init(
        getUsersUseCase: GetUsersUseCaseProtocol,
        repository: UsersRepository
    ) {
        self.getUsersUseCase = getUsersUseCase
        self.repository      = repository
    }

    // MARK: - Public Actions

    /// Initial load: show cache first, then refresh from API.
    func onAppear() async {
        guard viewState == .idle else { return }
        await loadFromCache()
        await fetchPage(reset: true)
    }

    /// Called by `.refreshable` on the List.
    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        await fetchPage(reset: true)
    }

    /// Loads the next page when the user scrolls to the bottom.
    func loadNextPageIfNeeded(currentItem: UserItem) async {
        guard
            hasMorePages,
            !isLoading,
            let lastItem = users.last,
            lastItem.id == currentItem.id
        else { return }

        await fetchPage(reset: false)
    }

    func dismissError() {
        if case .error = viewState {
            viewState = .idle
        }
    }

    // MARK: - Private

    private func loadFromCache() async {
        do {
            let cached = try await repository.getCachedUsers()
            if !cached.isEmpty {
                users = cached
                viewState = .loaded
            }
        } catch {
            // Cache miss is non-critical — proceed to network fetch.
        }
    }

    private func fetchPage(reset: Bool) async {
        if reset {
            currentPage = 1
            hasMorePages = true
        }

        guard hasMorePages else { return }

        // Avoid overlapping requests unless this is a refresh
        if isLoading && !isRefreshing { return }
        viewState = .loading

        do {
            let fetched = try await getUsersUseCase.execute(
                page: currentPage,
                limit: pageLimit
            )

            if reset {
                users = fetched
            } else {
                // Append and deduplicate by ID
                let existingIDs = Set(users.map(\.id))
                let newItems = fetched.filter { !existingIDs.contains($0.id) }
                users.append(contentsOf: newItems)
            }

            hasMorePages = fetched.count == pageLimit
            if hasMorePages { currentPage += 1 }
            viewState = .loaded

        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
}
