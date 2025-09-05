//
//  UserListViewModelTests.swift
//  pixel-stackoverflow-listTests
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Testing
import Foundation
import UIKit
@testable import pixel_stackoverflow_list

// MARK: - Test Suite
@Suite("UserListViewModel Tests")
struct UserListViewModelTests {

    // MARK: - Setup
    private func makeSUT(
        userFetchingService: UserFetchingProtocol? = nil,
        imageLoader: ImageLoader? = nil
    ) -> UserListViewModel {
        let defaultUserFetching = userFetchingService ?? MockUserFetchingService()
        let defaultImageLoader = imageLoader ?? MockImageLoader()

        return UserListViewModel(
            userFetchingService: defaultUserFetching,
            imageLoader: defaultImageLoader
        )
    }

    // MARK: - Initialization Tests
    @Test("Initialization sets up dependencies correctly")
    func testInitialization() {
        let mockUserFetching = MockUserFetchingService()
        let mockImageLoader = MockImageLoader()

        let sut = makeSUT(
            userFetchingService: mockUserFetching,
            imageLoader: mockImageLoader
        )

        #expect(sut.numberOfUsers() == 0)
        #expect(sut.getUser(at: 0) == nil)
    }

    // MARK: - User Fetching Tests
    @Test("getUsers triggers user fetching and updates loading state")
    func testGetUsersTriggersFetching() async {
        let mockUserFetching = MockUserFetchingService(mockUsers: MockDataProvider.shared.getMockUsers(count: 1))

        let sut = makeSUT(userFetchingService: mockUserFetching)

        var loadingStates: [Bool] = []
        sut.onLoadingStateChanged = { isLoading in
            loadingStates.append(isLoading)
        }

        var usersUpdated = false
        sut.onUsersUpdated = {
            usersUpdated = true
        }

        sut.getUsers()

        // Wait for async operation to complete
        try? await Task.sleep(for: .milliseconds(100))

        #expect(mockUserFetching.fetchUsersCalled)
        #expect(loadingStates.count >= 2) // Should have true then false
        #expect(loadingStates.first == true) // Should start loading
        #expect(usersUpdated)
        #expect(sut.numberOfUsers() == 1)
        #expect(sut.getUser(at: 0)?.displayName == "John Doe")
    }

    @Test("getUsers handles errors correctly")
    func testGetUsersHandlesErrors() async {
        let mockUserFetching = MockUserFetchingService()
        let expectedError = NSError(domain: "TestError", code: 123, userInfo: nil)
        mockUserFetching.mockError = expectedError

        let sut = makeSUT(userFetchingService: mockUserFetching)

        var receivedError: Error?
        sut.onError = { error in
            receivedError = error
        }

        sut.getUsers()

        try? await Task.sleep(for: .milliseconds(100))

        #expect(mockUserFetching.fetchUsersCalled)
        #expect(receivedError != nil)
        #expect(sut.numberOfUsers() == 0)
    }

    // MARK: - User Access Tests
    @Test("getUser returns correct user at valid index")
    func testGetUserAtValidIndex() async {
        let mockUserFetching = MockUserFetchingService(mockUsers: MockDataProvider.shared.getMockUsers(count: 1))

        let sut = makeSUT(userFetchingService: mockUserFetching)

        sut.getUsers()
        try? await Task.sleep(for: .milliseconds(100))

        let retrievedUser = sut.getUser(at: 0)
        #expect(retrievedUser?.displayName == "John Doe")
        #expect(retrievedUser?.reputation == 1500)
    }

    @Test("getUser returns nil for invalid index")
    func testGetUserAtInvalidIndex() async {
        let mockUserFetching = MockUserFetchingService(mockUsers: MockDataProvider.shared.getMockUsers(count: 1))

        let sut = makeSUT(userFetchingService: mockUserFetching)

        sut.getUsers()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.getUser(at: -1) == nil)
        #expect(sut.getUser(at: 1) == nil) // Index out of bounds
        #expect(sut.getUser(at: 999) == nil)
    }

    @Test("numberOfUsers returns correct count")
    func testNumberOfUsers() async {
        let mockUserFetching = MockUserFetchingService(mockUsers: MockDataProvider.shared.getMockUsers(count: 2))

        let sut = makeSUT(userFetchingService: mockUserFetching)

        #expect(sut.numberOfUsers() == 0) // Initially empty

        sut.getUsers()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.numberOfUsers() == 2)
    }

    // MARK: - Image Caching Tests
    @Test("cachedImage returns nil for non-cached URL")
    func testCachedImageReturnsNilForNonCached() {
        let sut = makeSUT()
        let testURL = URL(string: "https://example.com/image.jpg")!

        let cachedImage = sut.cachedImage(for: testURL)
        #expect(cachedImage == nil)
    }

    @Test("downloadAndCacheImage downloads and caches image successfully")
    func testDownloadAndCacheImageSuccess() async throws {
        // Create a simple 1x1 pixel PNG image data
        let imageData = createTestImageData()
        let mockImageLoader = MockImageLoader(mockImageData: imageData)

        let sut = makeSUT(imageLoader: mockImageLoader)
        let testURL = URL(string: "https://example.com/image.jpg")!

        _ = try await sut.downloadAndCacheImage(from: testURL)

        #expect(mockImageLoader.downloadImageDataCalled)
        #expect(mockImageLoader.lastDownloadedURL == testURL)

        // Verify caching
        let cachedImage = sut.cachedImage(for: testURL)
        #expect(cachedImage != nil)
    }

    @Test("downloadAndCacheImage returns cached image on subsequent calls")
    func testDownloadAndCacheImageReturnsCached() async throws {
        let imageData = createTestImageData()
        let mockImageLoader = MockImageLoader(mockImageData: imageData)

        let sut = makeSUT(imageLoader: mockImageLoader)
        let testURL = URL(string: "https://example.com/image.jpg")!

        // First call - should download
        let image1 = try await sut.downloadAndCacheImage(from: testURL)
        #expect(mockImageLoader.downloadImageDataCalled)

        // Reset the call flag
        mockImageLoader.downloadImageDataCalled = false

        // Second call - should use cache
        let image2 = try await sut.downloadAndCacheImage(from: testURL)

        #expect(image1 == image2)
        #expect(!mockImageLoader.downloadImageDataCalled) // Should not download again
    }

    @Test("downloadAndCacheImage throws error for invalid image data")
    func testDownloadAndCacheImageInvalidData() async {
        let mockImageLoader = MockImageLoader(mockImageData: Data()) // Empty data = invalid image

        let sut = makeSUT(imageLoader: mockImageLoader)
        let testURL = URL(string: "https://example.com/image.jpg")!

        do {
            _ = try await sut.downloadAndCacheImage(from: testURL)
            Issue.record("Expected error for invalid image data")
        } catch {
            // Expected error
            #expect(error is UserFetchingError)
        }
    }

    @Test("downloadAndCacheImage handles network errors")
    func testDownloadAndCacheImageNetworkError() async {
        let expectedError = NSError(domain: "NetworkError", code: 500, userInfo: nil)
        let mockImageLoader = MockImageLoader(mockImageData: nil, mockError: expectedError)

        let sut = makeSUT(imageLoader: mockImageLoader)
        let testURL = URL(string: "https://example.com/image.jpg")!

        do {
            _ = try await sut.downloadAndCacheImage(from: testURL)
            Issue.record("Expected network error")
        } catch {
            #expect(error as NSError == expectedError)
        }
    }

    // MARK: - Helper Methods
    private func createTestImageData() -> Data {
        // Create a simple 1x1 pixel image for testing
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)

        UIColor.red.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image?.pngData() ?? Data()
    }
}
