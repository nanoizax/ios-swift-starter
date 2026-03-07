// UserDetailView.swift
// IOSStarter — Users Presentation View
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import SwiftUI

struct UserDetailView: View {

    let user: UserItem

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                avatarSection
                infoSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .navigationTitle(user.fullName)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private var avatarSection: some View {
        VStack(spacing: 12) {
            avatarImage
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)

            Text(user.fullName)
                .font(.title2.bold())

            Text("#\(user.id)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let url = user.avatarURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    initialsPlaceholder
                }
            }
        } else {
            initialsPlaceholder
        }
    }

    private var initialsPlaceholder: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.15))
            .overlay {
                Text(user.initials)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.accentColor)
            }
    }

    private var infoSection: some View {
        VStack(spacing: 0) {
            infoRow(
                icon: "envelope.fill",
                label: "Email",
                value: user.email
            )
            Divider().padding(.leading, 56)

            infoRow(
                icon: "person.fill",
                label: "First Name",
                value: user.firstName
            )
            Divider().padding(.leading, 56)

            infoRow(
                icon: "person.fill",
                label: "Last Name",
                value: user.lastName
            )
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
                .padding(.leading, 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }

            Spacer()
        }
        .padding(.vertical, 14)
    }
}
