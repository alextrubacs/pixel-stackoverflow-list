//
//  UserDetailViewModel.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 11/09/2025.
//

import Foundation
import UIKit

protocol UserDetailViewModelDelegate: AnyObject {
    func userCellViewModelDidUpdateFollowState(_ viewModel: UserDetailViewModel)
}

class UserDetailViewModel {
    // MARK: - Properties
    private let user: User
    private let followedUsersRepository: FollowedUsersRepositoryProtocol

    weak var delegate: UserDetailViewModelDelegate?

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
    init(user: User, followedUsersRepository: FollowedUsersRepositoryProtocol) {
        self.user = user
        self.followedUsersRepository = followedUsersRepository
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
    }
}
