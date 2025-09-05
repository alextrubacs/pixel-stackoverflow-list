//
//  User.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 05/09/2025.
//

import Foundation

struct UsersResponse: Codable {
    public let items: [User]
}

struct User: Codable {
    let accountId: Int?
    let reputation: Int
    let userId: Int
    let location: String?
    let profileImage: URL?
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case reputation
        case userId = "user_id"
        case location
        case profileImage = "profile_image"
        case displayName = "display_name"
    }
}
