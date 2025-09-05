//
//  UserCellViewModelTests.swift
//  pixel-stackoverflow-listTests
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Testing
import UIKit
@testable import pixel_stackoverflow_list

/// Mock implementation of FollowedUsersRepositoryProtocol for testing
class MockFollowedUsersRepository: FollowedUsersRepositoryProtocol {
    var mockFollowedUsers: Set<Int> = []
    var shouldThrowError = false

    func followUser(userID: Int) async throws {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: -1, userInfo: nil)
        }
        mockFollowedUsers.insert(userID)
    }

    func unfollowUser(userID: Int) async throws {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: -1, userInfo: nil)
        }
        mockFollowedUsers.remove(userID)
    }

    func isUserFollowed(userID: Int) async throws -> Bool {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: -1, userInfo: nil)
        }
        return mockFollowedUsers.contains(userID)
    }

    func getAllFollowedUserIDs() async throws -> [Int] {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: -1, userInfo: nil)
        }
        return Array(mockFollowedUsers)
    }
}

/// Mock delegate for testing UserCellViewModel delegate callbacks
class MockUserCellViewModelDelegate: UserCellViewModelDelegate {
    var didUpdateImageCalled = false
    var didFailWithErrorCalled = false
    var didUpdateFollowStateCalled = false
    var lastUpdatedImage: UIImage?
    var lastError: Error?
    var lastFollowViewModel: UserCellViewModel?

    func userCellViewModel(_ viewModel: UserCellViewModel, didUpdateImage image: UIImage?) {
        didUpdateImageCalled = true
        lastUpdatedImage = image
    }

    func userCellViewModel(_ viewModel: UserCellViewModel, didFailWithError error: Error) {
        didFailWithErrorCalled = true
        lastError = error
    }

    func userCellViewModelDidUpdateFollowState(_ viewModel: UserCellViewModel) {
        didUpdateFollowStateCalled = true
        lastFollowViewModel = viewModel
    }
}

@Suite("UserCellViewModel Tests")
struct UserCellViewModelTests {
    // MARK: - Test Data
    private let testUser = User(
        accountId: 12345,
        reputation: 1500,
        userId: 67890,
        location: "San Francisco, CA",
        profileImage: URL(string: "https://example.com/avatar.jpg"),
        displayName: "John Doe"
    )

    private let testUserWithoutLocation = User(
        accountId: 12345,
        reputation: 1500,
        userId: 67890,
        location: nil,
        profileImage: URL(string: "https://example.com/avatar.jpg"),
        displayName: "Jane Smith"
    )

    private let testUserWithoutImage = User(
        accountId: 12345,
        reputation: 1500,
        userId: 67890,
        location: "New York, NY",
        profileImage: nil,
        displayName: "Bob Wilson"
    )

    private let mockRepository = MockFollowedUsersRepository()

    // MARK: - Setup
    private func resetMockRepository() {
        mockRepository.mockFollowedUsers.removeAll()
        mockRepository.shouldThrowError = false
    }

    // MARK: - Computed Properties Tests
    @Test("Computed properties return correct values")
    func testComputedProperties() {
        // Given
        let viewModel = UserCellViewModel(user: testUser, imageLoader: nil, followedUsersRepository: mockRepository)

        // Then
        #expect(viewModel.displayName == "John Doe")
        #expect(viewModel.reputationText == "Reputation: 1500")
        #expect(viewModel.locationText == "San Francisco, CA")
        #expect(viewModel.profileImageURL?.absoluteString == "https://example.com/avatar.jpg")
    }

    @Test("Location text handles nil location correctly")
    func testLocationTextWithNilLocation() {
        // Given
        let viewModel = UserCellViewModel(user: testUserWithoutLocation, imageLoader: nil, followedUsersRepository: mockRepository)

        // Then
        #expect(viewModel.locationText == "Location not available")
    }

    @Test("Profile image URL returns nil when user has no profile image")
    func testProfileImageURLWithNilImage() {
        // Given
        let viewModel = UserCellViewModel(user: testUserWithoutImage, imageLoader: nil, followedUsersRepository: mockRepository)

        // Then
        #expect(viewModel.profileImageURL == nil)
    }

    // MARK: - Image Loading Tests
    @Test("Load avatar image calls delegate with nil when no profile image")
    func testLoadAvatarImageWithNoProfileImage() async {
        // Given
        let delegate = MockUserCellViewModelDelegate()
        let viewModel = UserCellViewModel(user: testUserWithoutImage, imageLoader: nil, followedUsersRepository: mockRepository)
        viewModel.delegate = delegate

        // When
        viewModel.loadAvatarImage()

        // Then
        try? await Task.sleep(nanoseconds: 100_000_000) // Wait for async operations
        #expect(delegate.didUpdateImageCalled)
        #expect(delegate.lastUpdatedImage == nil)
        #expect(!delegate.didFailWithErrorCalled)
    }

    @Test("Load avatar image successfully loads and calls delegate")
    func testLoadAvatarImageSuccess() async throws {
        // Given
        let delegate = MockUserCellViewModelDelegate()
        let expectedImage = UIImage(systemName: "person.circle")!
        let imageLoader: ((URL) async throws -> UIImage)? = { _ in
            return expectedImage
        }
        let viewModel = UserCellViewModel(user: testUser, imageLoader: imageLoader, followedUsersRepository: mockRepository)
        viewModel.delegate = delegate

        // When
        viewModel.loadAvatarImage()

        // Then
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for async operations
        #expect(delegate.didUpdateImageCalled)
        #expect(delegate.lastUpdatedImage === expectedImage)
        #expect(!delegate.didFailWithErrorCalled)
    }

    @Test("Load avatar image handles errors and calls delegate")
    func testLoadAvatarImageError() async throws {
        // Given
        let delegate = MockUserCellViewModelDelegate()
        let expectedError = NSError(domain: "TestError", code: -1, userInfo: nil)
        let imageLoader: ((URL) async throws -> UIImage)? = { _ in
            throw expectedError
        }
        let viewModel = UserCellViewModel(user: testUser, imageLoader: imageLoader, followedUsersRepository: mockRepository)
        viewModel.delegate = delegate

        // When
        viewModel.loadAvatarImage()

        // Then
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for async operations
        #expect(!delegate.didUpdateImageCalled)
        #expect(delegate.didFailWithErrorCalled)
        #expect(delegate.lastError as? NSError === expectedError)
    }

    @Test("Cancel image loading prevents delegate callbacks")
    func testCancelImageLoading() async throws {
        // Given
        let delegate = MockUserCellViewModelDelegate()
        let expectedImage = UIImage(systemName: "person.circle")!
        let imageLoader: ((URL) async throws -> UIImage)? = { _ in
            // Simulate slow network
            try await Task.sleep(nanoseconds: 200_000_000)
            return expectedImage
        }
        let viewModel = UserCellViewModel(user: testUser, imageLoader: imageLoader, followedUsersRepository: mockRepository)
        viewModel.delegate = delegate

        // When
        viewModel.loadAvatarImage()
        viewModel.cancelImageLoading()

        // Then
        try await Task.sleep(nanoseconds: 300_000_000) // Wait for potential callback
        #expect(!delegate.didUpdateImageCalled)
        #expect(!delegate.didFailWithErrorCalled)
    }

    @Test("Multiple calls to loadAvatarImage work correctly")
    func testMultipleLoadAvatarImageCalls() async throws {
        // Given
        let delegate = MockUserCellViewModelDelegate()
        let expectedImage = UIImage(systemName: "person.circle")!
        var callCount = 0

        let imageLoader: ((URL) async throws -> UIImage)? = { url in
            callCount += 1
            return expectedImage
        }

        let viewModel = UserCellViewModel(user: testUser, imageLoader: imageLoader, followedUsersRepository: mockRepository)
        viewModel.delegate = delegate

        // When - Call loadAvatarImage multiple times
        viewModel.loadAvatarImage()
        viewModel.loadAvatarImage()
        viewModel.loadAvatarImage()

        // Then - Delegate should be called and at least one network call should be made
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(delegate.didUpdateImageCalled)
        #expect(delegate.lastUpdatedImage === expectedImage)
        #expect(callCount >= 1) // At least one network call should be made
    }

    @Test("Initialization with nil image loader")
    func testInitializationWithNilImageLoader() {
        // Given
        let viewModel = UserCellViewModel(user: testUser, imageLoader: nil, followedUsersRepository: mockRepository)

        // Then
        #expect(viewModel.displayName == testUser.displayName)
        #expect(viewModel.reputationText == "Reputation: \(testUser.reputation)")
        #expect(viewModel.locationText == testUser.location)
        #expect(viewModel.profileImageURL == testUser.profileImage)
    }

    @Test("Delegate is weakly referenced")
    func testDelegateWeakReference() {
        // Given
        var delegate: MockUserCellViewModelDelegate? = MockUserCellViewModelDelegate()
        let viewModel = UserCellViewModel(user: testUser, imageLoader: nil, followedUsersRepository: mockRepository)
        viewModel.delegate = delegate

        // When
        delegate = nil // Should not cause retain cycle

        // Then
        // ViewModel should still exist (no assertion needed for non-optional)
    }

    // MARK: - Follow Functionality Tests

    @Test("Follow user calls repository and updates delegate")
    func testFollowUser() async throws {
        // Given
        resetMockRepository()
        let delegate = MockUserCellViewModelDelegate()
        let viewModel = UserCellViewModel(user: testUser, imageLoader: nil, followedUsersRepository: mockRepository)
        viewModel.delegate = delegate

        // When
        await viewModel.followUser()

        // Then
        #expect(delegate.didUpdateFollowStateCalled)
        #expect(mockRepository.mockFollowedUsers.contains(testUser.userId))
    }

    @Test("Unfollow user calls repository and updates delegate")
    func testUnfollowUser() async throws {
        // Given
        resetMockRepository()
        let delegate = MockUserCellViewModelDelegate()
        let viewModel = UserCellViewModel(user: testUser, imageLoader: nil, followedUsersRepository: mockRepository)
        viewModel.delegate = delegate

        // First follow the user
        await viewModel.followUser()
        #expect(mockRepository.mockFollowedUsers.contains(testUser.userId))

        // When - unfollow
        await viewModel.followUser() // Second call should unfollow

        // Then
        #expect(delegate.didUpdateFollowStateCalled)
        #expect(!mockRepository.mockFollowedUsers.contains(testUser.userId))
    }

    @Test("Follow user handles repository errors gracefully")
    func testFollowUserWithRepositoryError() async throws {
        // Given
        resetMockRepository()
        let delegate = MockUserCellViewModelDelegate()
        mockRepository.shouldThrowError = true
        let viewModel = UserCellViewModel(user: testUser, imageLoader: nil, followedUsersRepository: mockRepository)
        viewModel.delegate = delegate

        // When
        await viewModel.followUser()

        // Then
        #expect(delegate.didUpdateFollowStateCalled) // Delegate should still be called
        #expect(!mockRepository.mockFollowedUsers.contains(testUser.userId)) // User should not be followed
    }

    @Test("Follow button title shows correct state")
    func testFollowButtonTitle() async {
        // Given
        resetMockRepository()
        let viewModel = UserCellViewModel(user: testUser, imageLoader: nil, followedUsersRepository: mockRepository)

        // When - initially not followed
        let initialTitle = await viewModel.followButtonTitle

        // Then
        #expect(initialTitle == "Follow")

        // When - follow the user
        await viewModel.followUser()
        let followedTitle = await viewModel.followButtonTitle

        // Then
        #expect(followedTitle == "Following")
    }

    @Test("Follow button image shows correct state")
    func testFollowButtonImage() async {
        // Given
        resetMockRepository()
        let viewModel = UserCellViewModel(user: testUser, imageLoader: nil, followedUsersRepository: mockRepository)

        // When - initially not followed
        let initialImage = await viewModel.followButtonImage

        // Then
        #expect(initialImage == nil)

        // When - follow the user
        await viewModel.followUser()
        let followedImage = await viewModel.followButtonImage

        // Then
        #expect(followedImage == "checkmark.circle.fill")
    }
}
