//
//  MockDataProvider.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation

/// Provides mock data for development and testing purposes
final class MockDataProvider {
    static let shared = MockDataProvider()

    /// Mock users data for development and testing
    lazy var mockUsers: [User] = [
        User(accountId: 1, reputation: 1500, userType: "registered", userId: 1, location: "San Francisco, CA", profileImage: nil, displayName: "John Doe"),
        User(accountId: 2, reputation: 2500, userType: "moderator", userId: 2, location: "New York, NY", profileImage: nil, displayName: "Jane Smith"),
        User(accountId: 3, reputation: 800, userType: "registered", userId: 3, location: "London, UK", profileImage: nil, displayName: "Bob Johnson"),
        User(accountId: 4, reputation: 3200, userType: "registered", userId: 4, location: nil, profileImage: nil, displayName: "Alice Wilson"),
        User(accountId: 5, reputation: 450, userType: "registered", userId: 5, location: "Berlin, Germany", profileImage: nil, displayName: "Charlie Brown"),
        User(accountId: 6, reputation: 1200, userType: "registered", userId: 6, location: "Tokyo, Japan", profileImage: nil, displayName: "David Lee"),
        User(accountId: 7, reputation: 780, userType: "registered", userId: 7, location: "Sydney, Australia", profileImage: nil, displayName: "Eva Garcia"),
        User(accountId: 8, reputation: 2100, userType: "registered", userId: 8, location: "Toronto, Canada", profileImage: nil, displayName: "Frank Miller"),
        User(accountId: 9, reputation: 950, userType: "registered", userId: 9, location: "Paris, France", profileImage: nil, displayName: "Grace Davis"),
        User(accountId: 10, reputation: 1800, userType: "registered", userId: 10, location: "Amsterdam, Netherlands", profileImage: nil, displayName: "Henry Wilson")
    ]

    /// Returns a specific number of mock users
    func getMockUsers(count: Int) -> [User] {
        Array(mockUsers.prefix(count))
    }

    /// Returns a single mock user by index
    func getMockUser(at index: Int) -> User? {
        guard index >= 0 && index < mockUsers.count else { return nil }
        return mockUsers[index]
    }

    /// Returns mock users filtered by user type
    func getMockUsers(byType userType: String) -> [User] {
        mockUsers.filter { $0.userType == userType }
    }

    /// Returns mock users with locations
    func getMockUsersWithLocation() -> [User] {
        mockUsers.filter { $0.location != nil }
    }

    private init() {}
}
