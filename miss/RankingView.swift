//
//  RankingView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/29.
//

import SwiftUI

struct RankingView: View {
    @ObservedObject var viewModel: TweetViewModel
    @State var users: [User] = []

    var body: some View {
//        if users.isEmpty {
//            // ここに空の場合の表示内容を追加できます。例えば:
//            Text("No users available")
//                .foregroundColor(.gray)
//        } else {
            List(users) { user in
                HStack {
                    if let url = URL(string: user.icon) {
                        AsyncImage(url: url)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text("Best comments: \(user.bestCommentsCount)")
                            .font(.subheadline)
                    }
                }
            }
            .onAppear {
                viewModel.fetchTopUsers { fetchedUsers in
                    users = fetchedUsers
                }
            }
//        }
    }
}


struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TweetViewModel()
        RankingView(viewModel: viewModel)
    }
}

