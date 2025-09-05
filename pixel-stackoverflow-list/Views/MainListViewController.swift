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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        createDataSource()
        setupViewModel()
        loadUsers()
    }
}

private extension MainListViewController {
    func setup() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupViewModel() {
        viewModel.onUsersUpdated = { [weak self] in
            self?.loadUsersIntoDataSource()
        }

        viewModel.onError = { error in
            DispatchQueue.main.async {
                print("Error loading users: \(error.localizedDescription)")
                // TODO: Show error UI
            }
        }
    }

    func loadUsers() {
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

            cell.configure(with: user, imageLoader: imageLoader)

            return cell
        }
    }

    func loadUsersIntoDataSource() {
        let users = viewModel.allUsers

        var snapshot = NSDiffableDataSourceSnapshot<String, User>()
        snapshot.appendSections(["users"])
        snapshot.appendItems(users, toSection: "users")

        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UserListViewModel Extension
private extension UserListViewModel {
    var allUsers: [User] {
        users
    }
}
