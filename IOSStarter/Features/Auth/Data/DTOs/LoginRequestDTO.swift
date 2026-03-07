// LoginRequestDTO.swift
// IOSStarter — Auth Data DTO
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

/// Encodes the login request body sent to the API.
struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}
