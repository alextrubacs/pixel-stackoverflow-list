//
//  FollowedUsersRepository.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import SwiftData
import Foundation

final class FollowedUsersRepository: FollowedUsersRepositoryProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    func followUser(userID: Int) async throws {
        let followedUser = FollowedUser()
        followedUser.userID = userID
        modelContext.insert(followedUser)
        try modelContext.save()
    }

    func unfollowUser(userID: Int) async throws {
        let descriptor = FetchDescriptor<FollowedUser>(
            predicate: #Predicate { $0.userID == userID }
        )
        
        if let followedUser = try modelContext.fetch(descriptor).first {
            modelContext.delete(followedUser)
            try modelContext.save()
        }
    }

    func isUserFollowed(userID: Int) async throws -> Bool {
        let descriptor = FetchDescriptor<FollowedUser>(
            predicate: #Predicate { $0.userID == userID }
        )
        
        let count = try modelContext.fetchCount(descriptor)
        return count > 0
    }
    
    /// Gets all followed user IDs
    func getAllFollowedUserIDs() async throws -> [Int] {
        let descriptor = FetchDescriptor<FollowedUser>()
        let followedUsers = try modelContext.fetch(descriptor)
        return followedUsers.map { $0.userID }
    }
}
