//
//  UserFetchingService.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation

protocol UserFetchingProtocol: Sendable {
    func fetchUsers() async throws -> [User]
}

protocol UserDecodingProtocol: Sendable {
    func decodeUsersResponse(from data: Data) async throws -> [User]
}

actor UserFetchingService {

    // MARK: - Properties
    private let session: URLSession

    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension UserFetchingService: UserFetchingProtocol {
    func fetchUsers() async throws -> [User] {
        guard let url = APIConfiguration.usersURL() else {
            throw UserFetchingError.invalidURL("Failed to construct users API URL")
        }

        do {
            let (data, response) = try await session.data(from: url)
            return try await handleNetworkResponse(data: data, response: response)
        } catch let networkError as URLError {
            throw UserFetchingError.networkError(networkError)
        } catch let userFetchingError as UserFetchingError {
            throw userFetchingError
        } catch {
            throw UserFetchingError.networkError(error)
        }
    }

    // MARK: - Private Methods
    private func handleNetworkResponse(data: Data, response: URLResponse) async throws -> [User] {

        if let jsonString = String(data: data, encoding: .utf8) {
            print("API Response: \(jsonString.prefix(500))...")
        }

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw UserFetchingError.invalidResponse
        }

        guard !data.isEmpty else {
            throw UserFetchingError.noData
        }

        return try await decodeUsersResponse(from: data)
    }
}

extension UserFetchingService: UserDecodingProtocol {
    func decodeUsersResponse(from data: Data) async throws -> [User] {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let response = try jsonDecoder.decode(UsersResponse.self, from: data)
            return response.items
        } catch {
            throw UserFetchingError.decodingError(error)
        }
    }
}
