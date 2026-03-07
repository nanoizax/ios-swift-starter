// PersistenceController.swift
// IOSStarter
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import SwiftData
import Foundation

/// Manages the SwiftData `ModelContainer` for the entire application.
///
/// Usage:
/// ```swift
/// @main
/// struct IOSStarterApp: App {
///     var body: some Scene {
///         WindowGroup { ContentView() }
///             .modelContainer(PersistenceController.shared.container)
///     }
/// }
/// ```
@MainActor
final class PersistenceController {

    // MARK: - Shared Instance

    static let shared = PersistenceController()

    /// In-memory container used during unit tests.
    static let preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    // MARK: - Properties

    let container: ModelContainer

    // MARK: - Init

    init(inMemory: Bool = false) {
        let schema = Schema([
            CachedUser.self
            // Register additional @Model classes here as the project grows.
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Convenience

    var mainContext: ModelContext {
        container.mainContext
    }
}
