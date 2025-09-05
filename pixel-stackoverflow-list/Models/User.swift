//
//  User.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation

struct User: Codable, Hashable {
    let accountId: Int?
    let reputation: Int
    let userId: Int
    let location: String?
    let profileImage: URL?
    let displayName: String
}
