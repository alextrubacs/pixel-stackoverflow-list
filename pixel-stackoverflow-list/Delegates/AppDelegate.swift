//
//  AppDelegate.swift
//  pixel-stackoverflow-list
//
//  Created by Aleksandrs Trubacs on 04/09/2025.
//

import UIKit
import SwiftData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    lazy var modelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: FollowedUser.self)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    lazy var followedUsersRepository: FollowedUsersRepositoryProtocol = {
        FollowedUsersRepository(modelContainer: modelContainer)
    }()



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

