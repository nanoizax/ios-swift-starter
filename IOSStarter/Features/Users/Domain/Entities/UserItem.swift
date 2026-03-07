// UserItem.swift
// IOSStarter — Users Domain Entity
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

/// Domain entity representing a user in the users list.
/// Distinct from `User` (the authenticated session entity) to keep
/// concerns separated — a list item may carry different fields.
struct UserItem: Identifiable, Equatable, Hashable {

    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let avatarURL: URL?

    // MARK: - Computed

    var fullName: String { "\(firstName) \(lastName)" }

    var initials: String {
        let f = firstName.first.map(String.init) ?? ""
        let l = lastName.first.map(String.init) ?? ""
        return (f + l).uppercased()
    }
}
