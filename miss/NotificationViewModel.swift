//
//  NotificationViewModel.swift
//  miss
//
//  Created by hashimo ryoya on 2023/08/01.
//

import Foundation
import Firebase
import SwiftUI

struct Notifications: Identifiable, Hashable {
    let id: String
    var senderInfo: [SenderInfo] // この行を追加
    let tweetContent: String
    let receiverId: String
    let tweetId: String
    let createdAt: Date
}

struct SenderInfo: Hashable { // この構造体を追加
    let senderId: String
    let senderName: String
    let senderIconURL: String
}

class NotificationViewModel: ObservableObject {
    @Published var notifications = [Notifications]()
    private var db = Database.database().reference()
    @Published var hasNewNotifications = false

    func fetchNotifications() {
        guard let userId = AuthManager.shared.user?.id else { print("test1"); return }
        db.child("notifications").queryOrdered(byChild: "receiverId").queryEqual(toValue: userId).observe(.value, with: { [weak self] (snapshot: DataSnapshot) in
            print("test")
            var notificationsDict: [String: Notifications] = [:]
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let senderId = dict["senderId"] as? String,
                   let receiverId = dict["receiverId"] as? String,
                   let tweetId = dict["tweetId"] as? String,
                   let createdAtTimestamp = dict["createdAt"] as? TimeInterval {
                    let createdAt = Date(timeIntervalSince1970: createdAtTimestamp / 1000)
                    self?.db.child("users").child(senderId).observeSingleEvent(of: .value, with: { usersnapshot in
                        if let userDict = usersnapshot.value as? [String: Any],
                           let senderName = userDict["name"] as? String,
                           let senderIconURL = userDict["icon"] as? String {
                            if var existingNotification = notificationsDict[tweetId] {
                                let senderInfo = SenderInfo(senderId: senderId, senderName: senderName, senderIconURL: senderIconURL)
                                existingNotification.senderInfo.append(senderInfo)
                                notificationsDict[tweetId] = existingNotification
                            } else {
                                self?.db.child("tweets").child(tweetId).observeSingleEvent(of: .value, with: { tweetSnapshot in
                                    if let tweetDict = tweetSnapshot.value as? [String: Any],
                                       let tweetContent = tweetDict["text"] as? String {
                                        let senderInfo = SenderInfo(senderId: senderId, senderName: senderName, senderIconURL: senderIconURL)
                                        let notification = Notifications(id: childSnapshot.key, senderInfo: [senderInfo], tweetContent: tweetContent, receiverId: receiverId, tweetId: tweetId, createdAt: createdAt)
                                        notificationsDict[tweetId] = notification
                                        DispatchQueue.main.async {
                                            self?.notifications = Array(notificationsDict.values)
                                            print("All notifications1: \(self?.notifications ?? [])")
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
            }
            DispatchQueue.main.async {
                if let notifications = self?.notifications {
                    self?.hasNewNotifications = !notifications.isEmpty
                } else {
                    self?.hasNewNotifications = false
                }
                self?.notifications = Array(notificationsDict.values)
            }
        })
    }
}
