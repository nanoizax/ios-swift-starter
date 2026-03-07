// CachedUser.swift
// IOSStarter — Users Data SwiftData Model
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import SwiftData
import Foundation

/// SwiftData persistent model for caching user list items locally.
///
/// Mirrors the `UserItem` domain entity. Never reference this model
/// outside the Data layer — always map to/from `UserItem`.
@Model
final class CachedUser {

    @Attribute(.unique) var id: Int
    var firstName: String
    var lastName: String
    var email: String
    var avatarURLString: String?
    var cachedAt: Date

    init(
        id: Int,
        firstName: String,
        lastName: String,
        email: String,
        avatarURLString: String? = nil,
        cachedAt: Date = .now
    ) {
        self.id               = id
        self.firstName        = firstName
        self.lastName         = lastName
        self.email            = email
        self.avatarURLString  = avatarURLString
        self.cachedAt         = cachedAt
    }

    // MARK: - Domain Mapping

    func toDomain() -> UserItem {
        UserItem(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            avatarURL: avatarURLString.flatMap { URL(string: $0) }
        )
    }

    static func from(domain: UserItem) -> CachedUser {
        CachedUser(
            id: domain.id,
            firstName: domain.firstName,
            lastName: domain.lastName,
            email: domain.email,
            avatarURLString: domain.avatarURL?.absoluteString
        )
    }
}
