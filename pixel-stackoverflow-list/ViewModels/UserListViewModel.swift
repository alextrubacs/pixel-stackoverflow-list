//
//  UserListViewModel.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation
import UIKit

class UserListViewModel {

    // MARK: - Properties
    private(set) var users: [User] = [] {
        didSet {
            onUsersUpdated?()
        }
    }

    private(set) var isLoading = false {
        didSet {
            onLoadingStateChanged?(isLoading)
        }
    }

    private(set) var error: Error?

    // MARK: - Dependencies
    private let userFetchingService: UserFetchingProtocol
    private let imageLoader: ImageLoader

    // MARK: - Cache
    private let imageCache = NSCache<NSString, UIImage>()

    // MARK: - Callbacks
    var onUsersUpdated: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?

    // MARK: - Initialization
    init(userFetchingService: UserFetchingProtocol = UserFetchingService(),
         imageLoader: ImageLoader = UserFetchingService()) {
        self.userFetchingService = userFetchingService
        self.imageLoader = imageLoader

        // Configure cache
        imageCache.countLimit = 100
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

}

// MARK: - Public Interface
extension UserListViewModel {
    func getUsers() {
        Task { [weak self] in
            await self?.fetchUsers()
        }
    }

    func getUser(at index: Int) -> User? {
        guard index >= 0 && index < users.count else { return nil }
        return users[index]
    }

    func numberOfUsers() -> Int {
        return users.count
    }
}

// MARK: - Image Handling
extension UserListViewModel {
    func cachedImage(for url: URL) -> UIImage? {
        let cacheKey = url.absoluteString as NSString
        return imageCache.object(forKey: cacheKey)
    }

    func downloadAndCacheImage(from url: URL) async throws -> UIImage {
        let cacheKey = url.absoluteString as NSString

        // Check cache first
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }

        // Download image data
        let imageData = try await imageLoader.downloadImageData(from: url)

        // Create image
        guard let image = UIImage(data: imageData) else {
            throw UserFetchingError.decodingError(NSError(domain: "ImageDecoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image data"]))
        }

        // Cache the image
        imageCache.setObject(image, forKey: cacheKey)

        return image
    }
}

// MARK: - Private Methods
private extension UserListViewModel {
    @MainActor
    func fetchUsers() async {
        isLoading = true
        error = nil

        do {
            users = try await userFetchingService.fetchUsers()
        } catch let fetchError {
            error = fetchError
            onError?(fetchError)
        }

        isLoading = false
    }
}
