// AuthResponseDTO.swift
// IOSStarter — Auth Data DTO
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

// MARK: - AuthResponseDTO

/// Decodes the login API response.
/// Maps to the `reqres.in` `/api/login` shape.
struct AuthResponseDTO: Decodable {
    let token: String
}

// MARK: - UserResponseDTO

/// Decodes a single user as returned by the API.
/// Used to build the `User` domain entity after login.
struct UserResponseDTO: Decodable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let avatar: String?

    // MARK: - Domain Mapping

    func toDomain() -> User {
        User(
            id: id,
            name: "\(firstName) \(lastName)",
            email: email,
            role: .user,
            isActive: true,
            createdAt: .now
        )
    }
}

// MARK: - UserListResponseDTO

/// Wraps a paginated list of users from the API.
struct UserListResponseDTO: Decodable {
    let page: Int
    let perPage: Int
    let total: Int
    let totalPages: Int
    let data: [UserResponseDTO]
}
