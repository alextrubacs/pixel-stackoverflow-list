//
//  UserFetchingError.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation

enum UserFetchingError: Error, LocalizedError {
    case invalidURL(String)
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received from server"
        }
    }
}
