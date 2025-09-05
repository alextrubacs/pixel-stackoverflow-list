//
//  UserFetchingService.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation

protocol UserFetchingProtocol {
    func fetchUsers() async throws -> [User]
}

final class UserFetchingService: UserFetchingProtocol {

    // MARK: - Properties
    private let session: URLSession
    private let baseURL = "https://api.stackexchange.com/2.2"

    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - UserFetchingProtocol
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "\(baseURL)/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow") else {
            throw UserFetchingError.invalidURL("\(baseURL)/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow")
        }

        do {
            let (data, response) = try await session.data(from: url)
            return try handleNetworkResponse(data: data, response: response)
        } catch let networkError as URLError {
            throw UserFetchingError.networkError(networkError)
        } catch let userFetchingError as UserFetchingError {
            throw userFetchingError
        } catch {
            throw UserFetchingError.networkError(error)
        }
    }

    // MARK: - Private Methods
    private func handleNetworkResponse(data: Data, response: URLResponse) throws -> [User] {

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
