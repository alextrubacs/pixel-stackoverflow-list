//
//  UserViewCell.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import UIKit

class UserViewCell: UITableViewCell {
    static var reuseIdentifier: String { CellIdentifier.userViewCell.rawValue }

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

    private let userTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .tertiaryLabel
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
        contentView.addSubview(userTypeLabel)
        contentView.addSubview(locationLabel)

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
            displayNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Reputation label
            reputationLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            reputationLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 4),
            reputationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // User type label
            userTypeLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            userTypeLabel.topAnchor.constraint(equalTo: reputationLabel.bottomAnchor, constant: 2),
            userTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Location label
            locationLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            locationLabel.topAnchor.constraint(equalTo: userTypeLabel.bottomAnchor, constant: 2),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            locationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
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
        userTypeLabel.text = nil
        locationLabel.text = nil
    }

    // MARK: - Configuration
    func configure(with user: User) {
        displayNameLabel.text = user.displayName
        reputationLabel.text = "Reputation: \(user.reputation)"
        userTypeLabel.text = user.userType.capitalized
        locationLabel.text = user.location ?? "Location not available"

        // Load avatar image if available
        if user.profileImage != nil {
            // TODO: Load the profile image 
            avatarImageView.backgroundColor = .systemBlue
        } else {
            avatarImageView.backgroundColor = .secondarySystemFill
        }
    }
}
