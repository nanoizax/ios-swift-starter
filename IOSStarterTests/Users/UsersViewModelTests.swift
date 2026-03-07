// UsersViewModelTests.swift
// IOSStarterTests
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import XCTest
@testable import IOSStarter

// MARK: - Mock GetUsersUseCase

final class MockGetUsersUseCase: GetUsersUseCaseProtocol {
    var result: Result<[UserItem], Error> = .success([])
    private(set) var executeCallCount = 0
    private(set) var lastPage: Int?
    private(set) var lastLimit: Int?

    func execute(page: Int, limit: Int) async throws -> [UserItem] {
        executeCallCount += 1
        lastPage  = page
        lastLimit = limit
        return try result.get()
    }
}

// MARK: - Mock UsersRepository

final class MockUsersRepository: UsersRepository {
    var getUsersResult: Result<[UserItem], Error> = .success([])
    var cachedUsers: [UserItem] = []
    private(set) var cachedUsersFromCacheCallCount = 0
    private(set) var cacheUsersCallCount = 0
    private(set) var lastCachedUsers: [UserItem]?

    func getUsers(page: Int, limit: Int) async throws -> [UserItem] {
        return try getUsersResult.get()
    }

    func getUser(id: Int) async throws -> UserItem {
        throw NetworkError.notFound
    }

    func getCachedUsers() async throws -> [UserItem] {
        cachedUsersFromCacheCallCount += 1
        return cachedUsers
    }

    func cacheUsers(_ users: [UserItem]) async throws {
        cacheUsersCallCount += 1
        lastCachedUsers = users
    }
}

// MARK: - UsersViewModelTests

@MainActor
final class UsersViewModelTests: XCTestCase {

    private var sut: UsersViewModel!
    private var mockUseCase: MockGetUsersUseCase!
    private var mockRepository: MockUsersRepository!

    override func setUp() {
        super.setUp()
        mockUseCase    = MockGetUsersUseCase()
        mockRepository = MockUsersRepository()
        sut = UsersViewModel(
            getUsersUseCase: mockUseCase,
            repository: mockRepository
        )
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_onAppear_loadsUsersFromAPI() async {
        // Given
        let expectedUsers = makeUsers(count: 3)
        mockUseCase.result = .success(expectedUsers)

        // When
        await sut.onAppear()

        // Then
        XCTAssertEqual(sut.users.count, expectedUsers.count)
        XCTAssertEqual(sut.viewState, .loaded)
        XCTAssertFalse(sut.isLoading)
    }

    func test_onAppear_whenAPIFails_setsErrorState() async {
        // Given
        mockUseCase.result = .failure(NetworkError.noConnection)

        // When
        await sut.onAppear()

        // Then
        if case .error(let message) = sut.viewState {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected error state, got \(sut.viewState)")
        }
    }

    func test_refresh_resetsPaginationAndReloadsFirstPage() async {
        // Given — first load with 20 users (simulates a full page)
        let firstPageUsers = makeUsers(count: 20)
        mockUseCase.result = .success(firstPageUsers)
        await sut.onAppear()

        // Now simulate refresh with a smaller set
        let refreshedUsers = makeUsers(count: 5, startingAt: 100)
        mockUseCase.result = .success(refreshedUsers)

        // When
        await sut.refresh()

        // Then — list should contain only the refreshed results
        XCTAssertEqual(sut.users.count, refreshedUsers.count)
        XCTAssertEqual(mockUseCase.lastPage, 1)
        XCTAssertEqual(sut.viewState, .loaded)
    }

    func test_onAppear_showsCachedUsersBeforeAPIResponse() async {
        // Given — cache has data, API will also respond
        let cachedUsers = makeUsers(count: 2, startingAt: 200)
        mockRepository.cachedUsers = cachedUsers

        let apiUsers = makeUsers(count: 3)
        mockUseCase.result = .success(apiUsers)

        // When
        await sut.onAppear()

        // Then — the cache was read
        XCTAssertGreaterThan(mockRepository.cachedUsersFromCacheCallCount, 0)
        // Final state should have API results
        XCTAssertEqual(sut.viewState, .loaded)
    }

    func test_dismissError_resetsStateToIdle() async {
        // Given
        mockUseCase.result = .failure(NetworkError.serverError(500))
        await sut.onAppear()
        XCTAssertNotNil(sut.errorMessage)

        // When
        sut.dismissError()

        // Then
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.viewState, .idle)
    }

    // MARK: - Helpers

    private func makeUsers(count: Int, startingAt start: Int = 1) -> [UserItem] {
        (start..<(start + count)).map { i in
            UserItem(
                id: i,
                firstName: "User",
                lastName: "\(i)",
                email: "user\(i)@example.com",
                avatarURL: nil
            )
        }
    }
}
