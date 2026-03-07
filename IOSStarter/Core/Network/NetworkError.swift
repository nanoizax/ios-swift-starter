// NetworkError.swift
// IOSStarter
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import Foundation

/// Typed errors produced by the networking layer.
enum NetworkError: Error, LocalizedError, Equatable {

    /// The server returned 401 Unauthorized.
    case unauthorized

    /// The server returned 404 Not Found.
    case notFound

    /// The server returned an unexpected HTTP status code.
    case serverError(Int)

    /// The response could not be decoded into the expected type.
    case decodingError(String)

    /// No network connection is available.
    case noConnection

    /// The URL could not be constructed from the given endpoint.
    case invalidURL

    /// A raw error from URLSession that does not fit other categories.
    case transportError(String)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Authentication required. Please log in again."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let code):
            return "Server error with status code \(code)."
        case .decodingError(let detail):
            return "Failed to decode response: \(detail)"
        case .noConnection:
            return "No internet connection. Please check your network settings."
        case .invalidURL:
            return "An invalid URL was constructed. Please contact support."
        case .transportError(let detail):
            return "A network transport error occurred: \(detail)"
        }
    }

    // MARK: - Equatable

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized): return true
        case (.notFound, .notFound): return true
        case (.serverError(let a), .serverError(let b)): return a == b
        case (.decodingError(let a), .decodingError(let b)): return a == b
        case (.noConnection, .noConnection): return true
        case (.invalidURL, .invalidURL): return true
        case (.transportError(let a), .transportError(let b)): return a == b
        default: return false
        }
    }
}
