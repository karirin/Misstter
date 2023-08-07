//
//  missApp.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/22.
//

import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
//        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })

        application.registerForRemoteNotifications()

        Messaging.messaging().token { token, error in
            if let error {
//                print("Error fetching FCM registration token: \(error)")
            } else if let token {
//                print("FCM registration token: \(token)")
            }
        }

        return true
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
//                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
//                print("FCM registration token: \(token)")
            }
        }
    }

}

extension AppDelegate: MessagingDelegate {
    @objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Firebase token: \(String(describing: fcmToken))")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .list, .sound]])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo
        )
        completionHandler()
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
        if authManager.isLoading {
            LoadingView()  // ローディング画面
                .frame(width: 100, height: 100)  // ローディングビューのサイズを設定します。
                .position(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.4) // ローディングビューを画面の中央に配置します。
        } else if authManager.user == nil {
                SignUp()
            } else {
                let tweet = Tweet(id: "dummyID", text: "dummyUser", userId: "dummyText", userName: "dummyIconURL", userIcon: "dummyIconURL", imageUrl: "https://default.com", isLiked: false, createdAt: Date())
                ContentView(tweet: tweet)
            }
        }
    }
}

