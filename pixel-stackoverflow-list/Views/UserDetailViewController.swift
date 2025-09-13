//
//  UserDetailViewController.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 11/09/2025.
//

import Foundation
import UIKit

class UserDetailViewController: UIViewController {

    // MARK: - Dependencies
    private var viewModel: UserDetailViewModel?

    // MARK: - Subviews
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isHidden = false
        return containerView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()


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
        label.text = "Name of the user "
        return label
    }()

    private let reputationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "Reputation of the user "
        return label
    }()


    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "Location of the user "
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

    // MARK: - Initialization
    init(user: User) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        self.viewModel = UserDetailViewModel(
            user: user,
            followedUsersRepository: appDelegate.followedUsersRepository
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configure()
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(containerView)
        view.backgroundColor = .systemBackground

        containerView.addSubview(stackView)
        stackView.addArrangedSubview(avatarImageView)
        stackView.addArrangedSubview(displayNameLabel)
        stackView.addArrangedSubview(reputationLabel)
        stackView.addArrangedSubview(locationLabel)
        stackView.addArrangedSubview(followButton)
        viewModel?.delegate = self

        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Stack view
            stackView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            // Avatar image
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),

            // Display name label


            // Reputation label
//            reputationLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
//            reputationLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 4),
//            reputationLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),

            // Location label
//            locationLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
//            locationLabel.topAnchor.constraint(equalTo: reputationLabel.bottomAnchor, constant: 2),
//            locationLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),
//            locationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),

            // Follow button
            followButton.heightAnchor.constraint(equalToConstant: 32),
            followButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    func configure() {
        displayNameLabel.text = viewModel?.displayName
        reputationLabel.text = viewModel?.reputationText
        locationLabel.text = viewModel?.locationText
        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)

        Task {
            await updateFollowButton()
        }
    }

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

    @objc private func followButtonTapped() {
        Task {
            await viewModel?.followUser()
        }
    }
}

extension UserDetailViewController: UserDetailViewModelDelegate {
    func userCellViewModelDidUpdateFollowState(_ viewModel: UserDetailViewModel) {
        Task {
            await updateFollowButton()
        }
    }
}
