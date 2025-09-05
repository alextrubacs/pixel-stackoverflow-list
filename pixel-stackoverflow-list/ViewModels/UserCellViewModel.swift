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
}

class UserCellViewModel {
    // MARK: - Properties
    private let user: User
    private let imageLoader: ((URL) async throws -> UIImage)?
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

    // MARK: - Initialization
    init(user: User, imageLoader: ((URL) async throws -> UIImage)?) {
        self.user = user
        self.imageLoader = imageLoader
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
}
