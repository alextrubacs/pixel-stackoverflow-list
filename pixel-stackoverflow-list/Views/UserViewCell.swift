//
//  UserViewCell.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import UIKit

class UserViewCell: UICollectionViewCell {
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
    override init(frame: CGRect) {
            super.init(frame: frame)

        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)

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
}
