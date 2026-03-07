// User.swift
// IOSStarter — Auth Domain Entity
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

// MARK: - User Role

enum UserRole: String, Codable, CaseIterable, Equatable {
    case admin
    case user
    case moderator

    var displayName: String {
        switch self {
        case .admin:     return "Admin"
        case .user:      return "User"
        case .moderator: return "Moderator"
        }
    }
}

// MARK: - User Entity

/// Pure domain model representing an authenticated user.
/// This struct is framework-independent and belongs to the Domain layer only.
struct User: Identifiable, Equatable, Hashable {

    let id: Int
    let name: String
    let email: String
    let role: UserRole
    let isActive: Bool
    let createdAt: Date

    // MARK: - Init

    init(
        id: Int,
        name: String,
        email: String,
        role: UserRole = .user,
        isActive: Bool = true,
        createdAt: Date = .now
    ) {
        self.id        = id
        self.name      = name
        self.email     = email
        self.role      = role
        self.isActive  = isActive
        self.createdAt = createdAt
    }

    // MARK: - Helpers

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.compactMap { $0.first }.prefix(2)
        return String(letters).uppercased()
    }

    var isAdmin: Bool { role == .admin }
}
