//
//  FollowedUser.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import SwiftData
import Foundation

@Model
final class FollowedUser {
    @Attribute(.unique) var userID: Int

    init() {
        self.userID = 0
    }
}
