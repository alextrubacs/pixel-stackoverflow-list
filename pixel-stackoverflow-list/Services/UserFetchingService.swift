//
//  UserFetchingService.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation
import UIKit

protocol UserFetchingProtocol: Sendable {
    func fetchUsers() async throws -> [User]
}

protocol UserDecodingProtocol: Sendable {
    func decodeUsersResponse(from data: Data) throws -> [User]
}

protocol ImageLoader {
    func downloadImageData(from url: URL) async throws -> Data
}

final class UserFetchingService {

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

        return try decodeUsersResponse(from: data)
    }
}

extension UserFetchingService: UserDecodingProtocol {
    nonisolated func decodeUsersResponse(from data: Data) throws -> [User] {
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

extension UserFetchingService: ImageLoader {
    func downloadImageData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw UserFetchingError.invalidResponse
        }

        return data
    }
}
