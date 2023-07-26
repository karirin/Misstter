//
//  missApp.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/22.
//

import SwiftUI
import FirebaseCore // 追加

// 追加
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
        return true
    }
}

@main
struct missApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject var authManager: AuthManager
    let tweet = Tweet(id: "dummyID", text: "dummyUser", userId: "dummyText", userName: "dummyIconURL", userIcon: "dummyIconURL", imageUrl: "https://default.com", isLiked: false, createdAt: Date())

    init() {
        FirebaseApp.configure()
        authManager = AuthManager.shared
    }

    var body: some Scene {
        WindowGroup {
            if authManager.user == nil {
                SignUp()
            } else {
                ContentView(tweet: tweet)
            }
        }
    }
}

