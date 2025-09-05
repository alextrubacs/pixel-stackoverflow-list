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
    func userCellViewModelDidTapFollow(_ viewModel: UserCellViewModel)
    func userCellViewModelDidUpdateFollowState(_ viewModel: UserCellViewModel)
}

class UserCellViewModel {
    // MARK: - Properties
    private let user: User
    private let imageLoader: ((URL) async throws -> UIImage)?
    private let followAction: (() -> Void)?
    private var currentImageURL: URL?
    private var _isFollowed: Bool

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
        _isFollowed
    }

    var followButtonTitle: String {
        isFollowed ? "Following" : "Follow"
    }

    var followButtonImage: String? {
        isFollowed ? "checkmark.circle.fill" : nil
    }

    // MARK: - Initialization
    init(user: User, imageLoader: ((URL) async throws -> UIImage)?, followAction: (() -> Void)? = nil) {
        self.user = user
        self.imageLoader = imageLoader
        self.followAction = followAction
        self._isFollowed = user.isFollowed
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

    func followUser() {
        _isFollowed.toggle()
        print("\(isFollowed ? "Followed" : "Unfollowed") user: \(user.displayName)")
        delegate?.userCellViewModelDidTapFollow(self)
        delegate?.userCellViewModelDidUpdateFollowState(self)
        followAction?()
    }
}
