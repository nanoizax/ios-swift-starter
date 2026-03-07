# IOSStarter — iOS Clean Architecture Starter

A production-ready iOS starter template built with Swift 5.9, SwiftUI, Clean Architecture, MVVM, Combine, and SwiftData.

**Author:** Leandro Perez <contacto@sonholab.com>

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI |
| State Management | `@Observable`, `@MainActor` |
| Reactive | Combine |
| Networking | URLSession + async/await |
| Persistence | SwiftData |
| Architecture | Clean Architecture + MVVM |
| Minimum Target | iOS 17 |
| Swift | 5.9 |
| Build System | Swift Package Manager |

---

## Architecture Overview

```
Features/
└── FeatureName/
    ├── Data/
    │   ├── DTOs/          — Network response models (Codable)
    │   ├── Models/        — SwiftData @Model classes
    │   └── Repositories/  — Repository implementations
    ├── Domain/
    │   ├── Entities/      — Pure Swift domain models
    │   ├── Repositories/  — Repository protocols (interfaces)
    │   └── UseCases/      — Business logic
    └── Presentation/
        ├── ViewModels/    — @Observable @MainActor view models
        └── Views/         — SwiftUI views
```

### Dependency Rule

Outer layers depend on inner layers. Inner layers know nothing about outer layers.

```
Presentation → Domain ← Data
                ↑
            (Entities, Repository Protocols, UseCases)
```

---

## Features Included

### Auth
- Login with email/password validation
- Logout use case
- Token persistence via UserDefaults (swap for Keychain in production)
- `AppCoordinator` drives authenticated/unauthenticated state

### Users
- Paginated user list with pull-to-refresh
- Local-first strategy: SwiftData cache → API → update cache
- User detail view

---

## Getting Started

### Requirements

- Xcode 15+
- iOS 17+ simulator or device
- Swift 5.9+

### Open in Xcode

```bash
open Package.swift
```

Xcode will resolve the package and you can run the `IOSStarter` scheme on any iOS 17 simulator.

### Run Tests

```bash
swift test
```

---

## Project Structure

```
ios-swift-starter/
├── IOSStarter/
│   ├── App/                     # App entry point and coordinator
│   ├── Core/
│   │   ├── Network/             # APIClient, APIEndpoint, NetworkError
│   │   ├── Persistence/         # SwiftData PersistenceController
│   │   └── Extensions/          # SwiftUI helpers
│   ├── Features/
│   │   ├── Auth/                # Login/Logout flow
│   │   └── Users/               # User list and detail
│   └── Resources/               # Assets
├── IOSStarterTests/
│   ├── Auth/                    # LoginUseCase tests
│   └── Users/                   # UsersViewModel tests
└── Package.swift
```

---

## Adapting to Your Project

1. Replace `reqres.in` base URL in `APIEndpoint.swift` with your API.
2. Swap `UserDefaults` token storage in `APIClient.swift` with Keychain.
3. Add new features following the `Auth` or `Users` pattern.
4. Register new `@Model` classes in `PersistenceController.swift`.

---

## License

MIT © 2024 Leandro Perez — [SonhoLab](https://sonholab.com)
