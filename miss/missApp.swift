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
        _ = AuthManager.shared // ここでAuthManagerのsharedインスタンスを初期化します
        return true
    }
}

@main
struct missApp: App {
    // 追加
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    //@ObservedObject var authManager = AuthManager.shared // 追加

    var body: some Scene {
        WindowGroup {
//            if authManager.user == nil {
//                SignUp()
//            } else {
                ContentView()
//            }
        }
    }
}
