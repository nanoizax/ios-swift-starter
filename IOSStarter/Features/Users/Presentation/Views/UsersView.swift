// UsersView.swift
// IOSStarter — Users Presentation View
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import SwiftUI

struct UsersView: View {

    @State private var viewModel: UsersViewModel

    init(viewModel: UsersViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.users.isEmpty && viewModel.isLoading {
                    ProgressView("Loading users…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    userList
                }
            }
            .navigationTitle("Users")
            .toolbar { toolbarContent }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.dismissError() } }
                )
            ) {
                Button("Retry") { Task { await viewModel.refresh() } }
                Button("Dismiss", role: .cancel) { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task { await viewModel.onAppear() }
    }

    // MARK: - Subviews

    private var userList: some View {
        List {
            ForEach(viewModel.users) { user in
                NavigationLink(value: user) {
                    UserRowView(user: user)
                }
                .task {
                    await viewModel.loadNextPageIfNeeded(currentItem: user)
                }
            }

            if viewModel.isLoading && !viewModel.users.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable { await viewModel.refresh() }
        .navigationDestination(for: UserItem.self) { user in
            UserDetailView(user: user)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if viewModel.isLoading && !viewModel.isRefreshing {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
            }
        }
    }
}

// MARK: - UserRowView

private struct UserRowView: View {

    let user: UserItem

    var body: some View {
        HStack(spacing: 12) {
            avatarCircle
            VStack(alignment: .leading, spacing: 2) {
                Text(user.fullName)
                    .font(.headline)
                Text(user.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var avatarCircle: some View {
        Group {
            if let url = user.avatarURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        initialsView
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    private var initialsView: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.15))
            .overlay {
                Text(user.initials)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.accentColor)
            }
    }
}
