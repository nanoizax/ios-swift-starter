// LoginUseCaseTests.swift
// IOSStarterTests
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import XCTest
@testable import IOSStarter

// MARK: - Mock AuthRepository

final class MockAuthRepository: AuthRepository {

    // Configurable outcomes
    var loginResult: Result<User, Error> = .success(
        User(id: 1, name: "Jane Doe", email: "jane@example.com")
    )
    var logoutResult: Result<Void, Error> = .success(())

    // Captured inputs
    private(set) var lastLoginEmail: String?
    private(set) var lastLoginPassword: String?
    private(set) var logoutCallCount = 0

    func login(email: String, password: String) async throws -> User {
        lastLoginEmail    = email
        lastLoginPassword = password
        return try loginResult.get()
    }

    func logout() async throws {
        logoutCallCount += 1
        try logoutResult.get()
    }
}

// MARK: - LoginUseCaseTests

final class LoginUseCaseTests: XCTestCase {

    private var sut: LoginUseCase!
    private var mockRepository: MockAuthRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockAuthRepository()
        sut = LoginUseCase(repository: mockRepository, minimumPasswordLength: 6)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Happy Path

    func test_execute_withValidCredentials_returnsUser() async throws {
        // Given
        let expectedUser = User(id: 42, name: "John Doe", email: "john@example.com")
        mockRepository.loginResult = .success(expectedUser)

        // When
        let user = try await sut.execute(email: "john@example.com", password: "secret123")

        // Then
        XCTAssertEqual(user, expectedUser)
        XCTAssertEqual(mockRepository.lastLoginEmail, "john@example.com")
        XCTAssertEqual(mockRepository.lastLoginPassword, "secret123")
    }

    func test_execute_trimsWhitespaceFromEmail() async throws {
        // Given
        mockRepository.loginResult = .success(
            User(id: 1, name: "Test", email: "test@example.com")
        )

        // When
        _ = try await sut.execute(email: "  test@example.com  ", password: "password123")

        // Then
        XCTAssertEqual(mockRepository.lastLoginEmail, "test@example.com")
    }

    // MARK: - Validation Failures

    func test_execute_withEmptyEmail_throwsEmptyEmailError() async {
        // When / Then
        await assertThrows(
            await sut.execute(email: "", password: "password123"),
            expectedError: LoginValidationError.emptyEmail
        )
    }

    func test_execute_withInvalidEmailFormat_throwsInvalidEmailError() async {
        // When / Then
        await assertThrows(
            await sut.execute(email: "not-an-email", password: "password123"),
            expectedError: LoginValidationError.invalidEmailFormat
        )
    }

    func test_execute_withEmptyPassword_throwsEmptyPasswordError() async {
        // When / Then
        await assertThrows(
            await sut.execute(email: "valid@example.com", password: ""),
            expectedError: LoginValidationError.emptyPassword
        )
    }

    func test_execute_withShortPassword_throwsPasswordTooShortError() async {
        // When / Then
        await assertThrows(
            await sut.execute(email: "valid@example.com", password: "abc"),
            expectedError: LoginValidationError.passwordTooShort(minimum: 6)
        )
    }

    // MARK: - Repository Failure

    func test_execute_whenRepositoryFails_propagatesError() async {
        // Given
        mockRepository.loginResult = .failure(NetworkError.unauthorized)

        // When / Then
        do {
            _ = try await sut.execute(email: "valid@example.com", password: "password123")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Helper

    private func assertThrows<T>(
        _ expression: @autoclosure () async throws -> T,
        expectedError: LoginValidationError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected \(expectedError) to be thrown", file: file, line: line)
        } catch let error as LoginValidationError {
            XCTAssertEqual(error, expectedError, file: file, line: line)
        } catch {
            XCTFail("Unexpected error type: \(error)", file: file, line: line)
        }
    }
}
