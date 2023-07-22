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
        FirebaseApp.configure()
        return true
    }
}

@main
struct missApp: App {
    // 追加
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
