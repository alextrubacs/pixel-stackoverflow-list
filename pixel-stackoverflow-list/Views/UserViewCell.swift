//
//  UserViewCell.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import UIKit

class UserViewCell: UITableViewCell, UserCellViewModelDelegate {
    static var reuseIdentifier: String { CellIdentifier.userViewCell.rawValue }

    // MARK: - Dependencies
    private var viewModel: UserCellViewModel?

    // MARK: - Subviews
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemFill
        return imageView
    }()

    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let reputationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()


    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isSymbolAnimationEnabled = true

        var config = UIButton.Configuration.tinted()
        config.title = "Follow"
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .preferredFont(forTextStyle: .caption1)
            return outgoing
        }

        button.configuration = config
        button.layer.cornerRadius = 8

        return button
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(displayNameLabel)
        contentView.addSubview(reputationLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(followButton)

        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Avatar image
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),

            // Display name label
            displayNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            displayNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            displayNameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),

            // Reputation label
            reputationLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            reputationLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 4),
            reputationLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),

            // Location label
            locationLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            locationLabel.topAnchor.constraint(equalTo: reputationLabel.bottomAnchor, constant: 2),
            locationLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),
            locationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Follow button
            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followButton.heightAnchor.constraint(equalToConstant: 32),
            followButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = 12
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        displayNameLabel.text = nil
        reputationLabel.text = nil
        locationLabel.text = nil
        viewModel?.cancelImageLoading()
        viewModel?.delegate = nil
        viewModel = nil
    }

    // MARK: - Actions
    @objc private func followButtonTapped() {
        Task {
            await viewModel?.followUser()
        }
    }

    // MARK: - Private Methods
    private func updateFollowButton() async {
        guard let viewModel = viewModel else { return }

        let isFollowed = await viewModel.isFollowed
        let title = await viewModel.followButtonTitle
        let imageName = await viewModel.followButtonImage

        var config: UIButton.Configuration

        if isFollowed {
            config = UIButton.Configuration.filled()
            config.title = title
            if let imageName = imageName {
                let symbolConfig = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .caption1))
                config.image = UIImage(systemName: imageName, withConfiguration: symbolConfig)
            }
        } else {
            config = UIButton.Configuration.tinted()
            config.title = title
            config.image = nil
        }

        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .preferredFont(forTextStyle: .caption1)
            return outgoing
        }

        followButton.configuration = config
        followButton.layer.cornerRadius = 8
    }

    // MARK: - Configuration
    func configure(with user: User, imageLoader: ((URL) async throws -> UIImage)?, followedUsersRepository: FollowedUsersRepositoryProtocol) {
        viewModel = UserCellViewModel(user: user, imageLoader: imageLoader, followedUsersRepository: followedUsersRepository)
        viewModel?.delegate = self

        displayNameLabel.text = viewModel?.displayName
        reputationLabel.text = viewModel?.reputationText
        locationLabel.text = viewModel?.locationText

        Task {
            await updateFollowButton()
        }

        if viewModel?.profileImageURL != nil {
            avatarImageView.image = nil
            avatarImageView.backgroundColor = .systemBlue
            viewModel?.loadAvatarImage()
        } else {
            avatarImageView.image = nil
            avatarImageView.backgroundColor = .secondarySystemFill
        }
    }

    // MARK: - UserCellViewModelDelegate
    func userCellViewModel(_ viewModel: UserCellViewModel, didUpdateImage image: UIImage?) {
        if let image = image {
            avatarImageView.image = image
            avatarImageView.backgroundColor = .clear
        } else {
            avatarImageView.image = nil
            avatarImageView.backgroundColor = .secondarySystemFill
        }
    }

    func userCellViewModel(_ viewModel: UserCellViewModel, didFailWithError error: Error) {
        avatarImageView.image = nil
        avatarImageView.backgroundColor = .secondarySystemFill
    }

    func userCellViewModelDidUpdateFollowState(_ viewModel: UserCellViewModel) {
        Task {
            await updateFollowButton()
        }
    }
}
