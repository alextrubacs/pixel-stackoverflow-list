//
//  APIConfiguration.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation

/// Configuration for Stack Exchange API endpoints and parameters
enum APIConfiguration {
    // MARK: - Base Configuration
    static let baseURL = "https://api.stackexchange.com/2.2"

    // MARK: - Endpoints
    enum Endpoint {
        case users

        var path: String {
            switch self {
            case .users:
                return "/users"
            }
        }
    }

    // MARK: - Query Parameters
    enum Parameter {
        case page(Int)
        case pageSize(Int)
        case order(String)
        case sort(String)
        case site(String)

        var queryItem: URLQueryItem {
            switch self {
            case .page(let value):
                return URLQueryItem(name: "page", value: "\(value)")
            case .pageSize(let value):
                return URLQueryItem(name: "pagesize", value: "\(value)")
            case .order(let value):
                return URLQueryItem(name: "order", value: value)
            case .sort(let value):
                return URLQueryItem(name: "sort", value: value)
            case .site(let value):
                return URLQueryItem(name: "site", value: value)
            }
        }
    }

    // MARK: - Default Parameters
    static let defaultUsersParameters: [Parameter] = [
        .page(1),
        .pageSize(20),
        .order("desc"),
        .sort("reputation"),
        .site("stackoverflow")
    ]

    // MARK: - URL Construction
    static func buildURL(for endpoint: Endpoint, parameters: [Parameter] = []) -> URL? {
        let urlString = baseURL + endpoint.path

        guard var urlComponents = URLComponents(string: urlString) else {
            return nil
        }

        urlComponents.queryItems = parameters.map { $0.queryItem }

        return urlComponents.url
    }

    // MARK: - Convenience Methods
    static func usersURL() -> URL? {
        return buildURL(for: .users, parameters: defaultUsersParameters)
    }

    static func usersURL(with customParameters: [Parameter]) -> URL? {
        return buildURL(for: .users, parameters: customParameters)
    }
}
