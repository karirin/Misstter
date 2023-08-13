//
//  DetailView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/24.
//

import SwiftUI

struct DetailView: View {
    var tweetLikeViewModel: TweetLikeViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: TweetViewModel  // 追加
    var tweet: Tweet
    @State private var comments: [Comment] = []
    @State private var showingCommentView = false
    @Environment(\.activeView) var activeView
    @ObservedObject var authManager = AuthManager.shared
    var tweetId: String

    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    var body: some View {
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
            Text("詳細")
            Spacer()
            
            Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.backward")
                        }
                    }
                    .padding(.trailing)
                    .opacity(0)
        }
        .padding(.top)
        ScrollView {
            VStack {
                HStack{
                    CachedImage(url: URL(string: tweetLikeViewModel.tweet.userIcon) ?? URL(string: "https://default.com")!)
                        .frame(width:60,height:60)
                        .background(Color("green"))
                        .cornerRadius(75)
                    Text(tweetLikeViewModel.tweet.userName)
                    Spacer()
                }
                .padding(5)
                HStack{
                    Text(tweetLikeViewModel.tweet.text)
                    Spacer()
                }
                .padding(.leading)
                               if let imageUrl = URL(string: tweetLikeViewModel.tweet.imageUrl ?? "") {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .padding()
                }
                HStack{
                Text(dateFormatter.string(from: tweetLikeViewModel.tweet.createdAt))
                    Spacer()
                }
                .padding(.leading)
                .padding(.top)

                Divider()
                HStack{
                    Text("\(tweetLikeViewModel.likeButtonViewModel.likesCount)件のどんまい")
                        .padding(.leading)
                    Spacer()
                }
                Divider()
                HStack{
                    Button(action: {
                        showingCommentView = true
                    }) {
                        Image(systemName: "bubble.left")
                    }
                    .padding(.leading)
                    .padding(5)
                    
                    DetailLikeButtonView(viewModel: LikeButtonViewModel(isLiked: tweetLikeViewModel.tweet.isLiked, likesCount: tweetLikeViewModel.tweet.likes.count, toggleLike: tweetLikeViewModel.toggleLike))
                    Spacer()
                }
                Divider()
                    .frame(maxWidth:.infinity)
                ForEach(comments) { comment in
                    VStack(alignment: .leading) {

                        HStack {
                            VStack{
                                
                                CachedImage(url: URL(string: comment.userIcon) ?? URL(string: "https://default.com")!)
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(75)
                                    .padding(.trailing,5)
                                Spacer()
                            }
                            VStack(alignment: .leading) {
                                HStack{
                                    Text(comment.userName)
                                        .fontWeight(.bold)
                                    Text(timeAgoSinceDate(comment.createdAt)) // ここでコメントの作成時間を表示します
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                Text(comment.text)
                                HStack{
                                    if tweet.bestCommentId == nil {
                                        if authManager.user?.id == tweet.userId {
                                            Button(action: {
                                                viewModel.setBestComment(tweetId: tweet.id, commentId: comment.id, userId: comment.userId)
                                            }) {
                                                Image("ナイスフォロー")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width:50,height:50)
                                                    .padding(.bottom,-15)
                                                    .padding(.top,-10)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                            Spacer()
                                if tweet.bestCommentId == comment.id {
                                    Image("フォロー")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:80,height:80)
                                }
                        }
                        .padding(5)
                        Spacer()
                    }
                    Divider()
                }

//                Spacer()
            }
            .onAppear {
                viewModel.fetchComments(tweetId: tweet.id) { fetchedComments in
                    self.comments = fetchedComments
                }
            }
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $showingCommentView) {
                NavigationView {
                    CommentView(tweetLikeViewModel: tweetLikeViewModel)
                }
            }
        }
    }
    func timeAgoSinceDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: date, to: now)

        if let year = components.year, year >= 1 {
            return year == 1 ? "1年前" : "\(year)年"
        }

        if let month = components.month, month >= 1 {
            return month == 1 ? "1ヶ月前" : "\(month)ヶ月"
        }

        if let weekOfYear = components.weekOfYear, weekOfYear >= 1 {
            return weekOfYear == 1 ? "1週間前" : "\(weekOfYear)週間"
        }

        if let day = components.day, day >= 1 {
            return day == 1 ? "1日前" : "\(day)日"
        }

        if let hour = components.hour, hour >= 1 {
            return hour == 1 ? "1時間前" : "\(hour)時間"
        }

        if let minute = components.minute, minute >= 1 {
            return minute == 1 ? "1分前" : "\(minute)分"
        }

        return "たった今"
    }
}
//
//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
