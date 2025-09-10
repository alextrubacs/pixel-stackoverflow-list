//
//  MainListViewController.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 04/09/2025.
//

import UIKit

final class MainListViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = UserListViewModel()

    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserViewCell.self, forCellReuseIdentifier: CellIdentifier.userViewCell.rawValue)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()

    private var dataSource: UITableViewDiffableDataSource<String, User>?
    private var currentError: Error?

    private lazy var emptyStateView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isHidden = true

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16

        // Loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .secondaryLabel

        // Icon for no users / error
        let imageView = UIImageView(image: UIImage(systemName: "person.2.slash"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit

        // Retry button for error state
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        // Initially show loading state
        stackView.addArrangedSubview(loadingIndicator)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(retryButton)

        // Hide imageView, loadingIndicator, and retryButton initially
        imageView.isHidden = true
        loadingIndicator.isHidden = true
        retryButton.isHidden = true

        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -32),
            imageView.widthAnchor.constraint(equalToConstant: 64),
            imageView.heightAnchor.constraint(equalToConstant: 64),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 64),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 64)
        ])

        // Store references for state updates
        containerView.tag = 999 // Use tag to identify views
        if let stackView = containerView.subviews.first as? UIStackView {
            stackView.tag = 1000
            loadingIndicator.tag = 1001
            imageView.tag = 1002
            titleLabel.tag = 1003
            subtitleLabel.tag = 1004
            retryButton.tag = 1005
        }

        return containerView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        createDataSource()
        setupViewModel()
        configureRefreshControl()
        loadUsers()
    }
}

private extension MainListViewController {
    func setup() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupViewModel() {
        viewModel.onUsersUpdated = { [weak self] in
            self?.loadUsersIntoDataSource()
        }

        viewModel.onLoadingStateChanged = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateEmptyState()
            }
        }

        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                print("Error loading users: \(error.localizedDescription)")
                self?.currentError = error
                self?.updateEmptyState()
            }
        }
    }

    private func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onPullRefresh), for: .valueChanged)
    }

    private func loadUsers() {
        viewModel.getUsers()
    }
}

// MARK: - Data Source
private extension MainListViewController {
    func createDataSource() {
        dataSource = UITableViewDiffableDataSource<String, User>(
            tableView: tableView
        ) { [weak self] (tableView: UITableView, indexPath: IndexPath, user: User) in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CellIdentifier.userViewCell.rawValue,
                for: indexPath
            ) as? UserViewCell else {
                return UITableViewCell()
            }

            let imageLoader: ((URL) async throws -> UIImage)? = { [weak self] url in
                return try await self?.viewModel.downloadAndCacheImage(from: url) ?? UIImage()
            }

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return UITableViewCell()
            }

            cell.configure(with: user, imageLoader: imageLoader, followedUsersRepository: appDelegate.followedUsersRepository)

            return cell
        }
    }

    func loadUsersIntoDataSource() {
        let users = viewModel.allUsers

        var snapshot = NSDiffableDataSourceSnapshot<String, User>()
        snapshot.appendSections(["users"])
        snapshot.appendItems(users, toSection: "users")

        dataSource?.apply(snapshot, animatingDifferences: false)

        // Clear any previous error when users are successfully loaded
        currentError = nil

        // Update empty state visibility
        updateEmptyState()
    }

    func updateEmptyState() {
        guard let _ = emptyStateView.viewWithTag(1000) as? UIStackView,
              let loadingIndicator = emptyStateView.viewWithTag(1001) as? UIActivityIndicatorView,
              let imageView = emptyStateView.viewWithTag(1002) as? UIImageView,
              let titleLabel = emptyStateView.viewWithTag(1003) as? UILabel,
              let subtitleLabel = emptyStateView.viewWithTag(1004) as? UILabel,
              let retryButton = emptyStateView.viewWithTag(1005) as? UIButton else {
            return
        }

        let isLoading = viewModel.isLoading
        let hasUsers = !viewModel.isEmpty
        let hasError = currentError != nil

        if isLoading {
            // Show loading state
            emptyStateView.isHidden = false
            tableView.isHidden = true

            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
            imageView.isHidden = true
            retryButton.isHidden = true

            titleLabel.text = "Loading Users"
            subtitleLabel.text = "Please wait while we fetch the latest data."

        } else if hasError {
            // Show error state
            emptyStateView.isHidden = false
            tableView.isHidden = true

            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            imageView.isHidden = false
            retryButton.isHidden = false

            // Change icon to error icon
            imageView.image = UIImage(systemName: "exclamationmark.triangle")
            imageView.tintColor = .systemOrange

            titleLabel.text = "Connection Error"
            if let error = currentError {
                subtitleLabel.text = error.localizedDescription
            } else {
                subtitleLabel.text = "Unable to load users. Please check your connection and try again."
            }

        } else if hasUsers {
            // Hide empty state when we have users
            emptyStateView.isHidden = true
            tableView.isHidden = false

            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            imageView.isHidden = true

        } else {
            // Show no users state
            emptyStateView.isHidden = false
            tableView.isHidden = true

            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            imageView.isHidden = false
            retryButton.isHidden = true

            // Reset to default icon
            imageView.image = UIImage(systemName: "person.2.slash")
            imageView.tintColor = .secondaryLabel

            titleLabel.text = "No Users Found"
            subtitleLabel.text = "There are no users to display at the moment."
        }
    }

    @objc private func retryButtonTapped() {
        // Clear the current error and retry loading users
        currentError = nil
        loadUsers()
    }

    @objc func onPullRefresh() {
        self.tableView.refreshControl?.endRefreshing()
        loadUsers()
    }
}

// MARK: - UserListViewModel Extension
private extension UserListViewModel {
    var allUsers: [User] {
        users
    }
}
