//
//  UserListViewModel.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation

class UserListViewModel {

    // MARK: - Properties
    private(set) var users: [User] = [] {
        didSet {
            onUsersUpdated?()
        }
    }

    private(set) var isLoading = false {
        didSet {
            onLoadingStateChanged?(isLoading)
        }
    }

    private(set) var error: Error?

    // MARK: - Dependencies
    private let userFetchingService: UserFetchingProtocol

    // MARK: - Callbacks
    var onUsersUpdated: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?

    // MARK: - Initialization
    init(userFetchingService: UserFetchingProtocol = UserFetchingService()) {
        self.userFetchingService = userFetchingService
    }

    // MARK: - Public Methods
    func getUsers() {
        Task { [weak self] in
            await self?.fetchUsers()
        }
    }

    func getUser(at index: Int) -> User? {
        guard index >= 0 && index < users.count else { return nil }
        return users[index]
    }

    func numberOfUsers() -> Int {
        return users.count
    }

    // MARK: - Private Methods
    @MainActor
    private func fetchUsers() async {
        isLoading = true
        error = nil

        do {
            users = try await userFetchingService.fetchUsers()
        } catch let fetchError {
            error = fetchError
            onError?(fetchError)
        }

        isLoading = false
    }
}
