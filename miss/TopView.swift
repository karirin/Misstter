//
//  TopView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/29.
//

import SwiftUI

struct TopView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var selectedTab = 0
    @ObservedObject private var notificationViewModel = NotificationViewModel()
    @ObservedObject private var viewModel = TweetViewModel()
    
    var body: some View {
      TabView(selection: $selectedTab) {
            let tweet = Tweet(id: "dummyID", text: "dummyUser", userId: "dummyText", userName: "dummyIconURL", userIcon: "dummyIconURL", imageUrl: "https://default.com", isLiked: false, createdAt: Date())
            ContentView(tweet: tweet)
                .tag(0)
                .tabItem {
                    Image(systemName: "house")
                    Text("ホーム")
                }
          
          NotificationView(viewModel: notificationViewModel, tweetViewModel: viewModel)
              .tag(1)
              .tabItem {
                  ZStack {
                      Image(systemName: notificationViewModel.hasNewNotifications && !notificationViewModel.isNotificationChecked ? "bell" : "bell")
                          .foregroundColor(.black)
                      if notificationViewModel.hasNewNotifications && !notificationViewModel.isNotificationChecked {
                          Image(systemName: "circle.fill")
                              .resizable()
                              .frame(width: 10, height: 10)
                              .foregroundColor(.red)
                              .offset(x: 10, y: -10)
                      }
                  }
                  Text("ホーム")
              }
        }
      .onAppear() {
          self.notificationViewModel.fetchNotifications() // 通知の取得
      }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
