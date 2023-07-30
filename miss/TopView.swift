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
    var body: some View {
        TabView(selection: $selectedTab) {
            let tweet = Tweet(id: "dummyID", text: "dummyUser", userId: "dummyText", userName: "dummyIconURL", userIcon: "dummyIconURL", imageUrl: "https://default.com", isLiked: false, createdAt: Date())
            ContentView(tweet: tweet)
                .tag(0)
                .tabItem {
                    Image(systemName: "house")
                    Text("ホーム")
                }
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
