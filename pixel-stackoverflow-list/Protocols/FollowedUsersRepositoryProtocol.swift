//
//  FollowedUsersRepositoryProtocol.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation

protocol FollowedUsersRepositoryProtocol {
    func followUser(userID: Int) async throws
    func unfollowUser(userID: Int) async throws
    func isUserFollowed(userID: Int) async throws -> Bool
    func getAllFollowedUserIDs() async throws -> [Int]
}
