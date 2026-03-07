// UserDTO.swift
// IOSStarter — Users Data DTO
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

/// Decodes a single user object from the API response.
struct UserDTO: Decodable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let avatar: String?

    // MARK: - Domain Mapping

    func toDomain() -> UserItem {
        UserItem(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            avatarURL: avatar.flatMap { URL(string: $0) }
        )
    }
}

// MARK: - PaginatedUsersResponseDTO

/// Wraps the paginated users list response from the API.
struct PaginatedUsersResponseDTO: Decodable {
    let page: Int
    let perPage: Int
    let total: Int
    let totalPages: Int
    let data: [UserDTO]
}

// MARK: - SingleUserResponseDTO

/// Wraps a single user API response.
struct SingleUserResponseDTO: Decodable {
    let data: UserDTO
}
