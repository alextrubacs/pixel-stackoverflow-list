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

    // MARK: - Callbacks
    var onUsersUpdated: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?

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
            let url = URL(string: "https://api.stackexchange.com/2.2/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow")!
            let (data, _) = try await URLSession.shared.data(from: url)

            // First, let's see what we're getting
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString.prefix(500))...")
            }

            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

            let response = try jsonDecoder.decode(UsersResponse.self, from: data)
            users = response.items

        } catch let fetchError {
            print("Decoding error: \(fetchError)")
            if let decodingError = fetchError as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Missing key: \(key.stringValue), context: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch: \(type), context: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type), context: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            error = fetchError
            onError?(fetchError)
        }

        isLoading = false
    }
}
