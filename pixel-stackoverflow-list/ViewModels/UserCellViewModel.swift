//
//  UserCellViewModel.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import UIKit

protocol UserCellViewModelDelegate: AnyObject {
    func userCellViewModel(_ viewModel: UserCellViewModel, didUpdateImage image: UIImage?)
    func userCellViewModel(_ viewModel: UserCellViewModel, didFailWithError error: Error)
    func userCellViewModelDidUpdateFollowState(_ viewModel: UserCellViewModel)
}

class UserCellViewModel {
    // MARK: - Properties
    private let user: User
    private let imageLoader: ((URL) async throws -> UIImage)?
    private let followAction: (() -> Void)?
    private let followedUsersRepository: FollowedUsersRepositoryProtocol
    private var currentImageURL: URL?

    weak var delegate: UserCellViewModelDelegate?

    // MARK: - Computed Properties
    var displayName: String {
        user.displayName
    }

    var reputationText: String {
        "Reputation: \(user.reputation)"
    }

    var locationText: String {
        user.location ?? "Location not available"
    }

    var profileImageURL: URL? {
        user.profileImage
    }

    var isFollowed: Bool {
        get async {
            do {
                return try await followedUsersRepository.isUserFollowed(userID: user.userId)
            } catch {
                print("Error checking if user is followed: \(error)")
                return false
            }
        }
    }

    var followButtonTitle: String {
        get async {
            await isFollowed ? "Following" : "Follow"
        }
    }

    var followButtonImage: String? {
        get async {
            await isFollowed ? "checkmark.circle.fill" : nil
        }
    }

    // MARK: - Initialization
    init(user: User, imageLoader: ((URL) async throws -> UIImage)?, followAction: (() -> Void)? = nil, followedUsersRepository: FollowedUsersRepositoryProtocol) {
        self.user = user
        self.imageLoader = imageLoader
        self.followAction = followAction
        self.followedUsersRepository = followedUsersRepository
    }

    // MARK: - Public Methods
    func loadAvatarImage() {
        guard let imageURL = user.profileImage else {
            delegate?.userCellViewModel(self, didUpdateImage: nil)
            currentImageURL = nil
            return
        }

        currentImageURL = imageURL

        Task { [weak self] in
            guard let self = self else { return }

            do {
                guard self.currentImageURL == imageURL else { return }

                let image = try await self.imageLoader?(imageURL)

                await MainActor.run {
                    guard self.currentImageURL == imageURL else { return }
                    self.delegate?.userCellViewModel(self, didUpdateImage: image)
                }
            } catch {
                await MainActor.run {
                    guard self.currentImageURL == imageURL else { return }
                    self.delegate?.userCellViewModel(self, didFailWithError: error)
                }
            }
        }
    }

    func cancelImageLoading() {
        currentImageURL = nil
    }

    func followUser() async {
        do {
            let currentlyFollowed = try await followedUsersRepository.isUserFollowed(userID: user.userId)

            if currentlyFollowed {
                try await followedUsersRepository.unfollowUser(userID: user.userId)
                print("Unfollowed user: \(user.displayName)")
            } else {
                try await followedUsersRepository.followUser(userID: user.userId)
                print("Followed user: \(user.displayName)")
            }
        } catch {
            print("Error following/unfollowing user: \(error)")
        }

        // Always notify delegate to update UI state, even on error
        delegate?.userCellViewModelDidUpdateFollowState(self)
        followAction?()
    }
}
