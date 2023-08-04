//
//  NotificationView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/08/01.
//

import SwiftUI

struct NotificationRow: View {
    var notification: Notifications
    var tweetLikeViewModels: [TweetLikeViewModel]
    var tweetViewModel: TweetViewModel

    var body: some View {
        let tweetLikeViewModel = tweetLikeViewModels.first { $0.tweet.id == notification.tweetId }
        
        // 送信者の名前を結合
        let senderNames = notification.senderInfo.map { $0.senderName }
        let senderNamesText = senderNames.joined(separator: "さんと") + "さん"
        
        return Group {
            if let tweetLikeViewModel = tweetLikeViewModel {
                NavigationLink(destination: DetailView(tweetLikeViewModel: tweetLikeViewModel, viewModel: tweetViewModel, tweet: tweetLikeViewModel.tweet, tweetId: notification.tweetId)) {
                    VStack {
                        HStack {
                            // すべての送信者のアイコンを表示
                            ForEach(notification.senderInfo, id: \.senderId) { sender in
                                CachedImage(url: URL(string: sender.senderIconURL) ?? URL(string: "https://default.com")!)
                                    .frame(width:60,height:60)
                                    .cornerRadius(75)
                            }
                            Spacer()
                        }
                        Text("\(senderNamesText)があなたの投稿にドンマイしました")
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        Text(notification.tweetContent)
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                            .frame(maxWidth: .infinity,alignment: .leading)
                        Divider()
                    }
                    .padding(.leading)
                }
                    .foregroundColor(.black)
            } else {
                Text("test")
            }
        }
    }
}



struct NotificationView: View {
    @ObservedObject var viewModel: NotificationViewModel
    @ObservedObject var tweetViewModel: TweetViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            HStack{
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.backward")
                    }
                }
                .padding(.leading)
                Spacer()
                Text("通知")
                Spacer()
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.backward")
                    }
                }
                .opacity(0)
            }
            NavigationView {
                ScrollView {
                    VStack {
                        ForEach(viewModel.notifications) { notification in
                            NotificationRow(notification: notification, tweetLikeViewModels: tweetViewModel.tweetLikeViewModels, tweetViewModel: tweetViewModel)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.fetchNotifications()
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        // ここで適切な NotificationViewModel と TweetViewModel のインスタンスを作成または取得します。
        let viewModel = NotificationViewModel()
        let tweetViewModel = TweetViewModel()
        
        // 作成または取得したインスタンスを NotificationView に渡します。
        NotificationView(viewModel: viewModel, tweetViewModel: tweetViewModel)
    }
}

