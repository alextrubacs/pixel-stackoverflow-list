//
//  MockUserFetchingService.swift
//  pixel-stackoverflow-listTests
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation
@testable import pixel_stackoverflow_list

/// Mock implementation of UserFetchingProtocol for testing
final class MockUserFetchingService: UserFetchingProtocol {
    var mockUsers: [User] = []
    var mockError: Error?
    var fetchUsersCalled = false

    init(mockUsers: [User] = MockDataProvider.shared.mockUsers) {
        self.mockUsers = mockUsers
    }

    func fetchUsers() async throws -> [User] {
        fetchUsersCalled = true

        if let error = mockError {
            throw error
        }

        return mockUsers
    }
}
