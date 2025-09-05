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

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserViewCell.self, forCellReuseIdentifier: CellIdentifier.userViewCell.rawValue)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
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

extension MainListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfUsers()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.userViewCell.rawValue, for: indexPath) as? UserViewCell else {
            return UITableViewCell()
        }

        if let user = viewModel.getUser(at: indexPath.row) {
            cell.configure(with: user)
        }
        return cell
    }
}
