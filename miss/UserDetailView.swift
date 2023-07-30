//
//  UserDetailView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/30.
//

import Foundation
import Firebase
import SwiftUI

struct UserDetailView: View {
    var userId: String // ユーザーID
    @State var user: User? // ユーザー情報
    var db = Database.database().reference() // Firebaseのデータベースへの参照
    @ObservedObject private var viewModel = TweetViewModel()
    
    var body: some View {
        // ユーザー情報の表示
        VStack{
            HStack{
                VStack (alignment: .leading){
                    if let user = user {
                        if let userIconURL = URL(string: user.icon ?? "") {
                            AsyncImage(url: userIconURL) { image in // 非同期で画像をロード
                                image.resizable()
                            } placeholder: {
                                ProgressView() // プレースホルダー
                            }
                            .frame(width: 80, height: 80) // サイズを設定
                            .clipShape(Circle()) // 円形にクリップ
                        }
                        Text(" \(user.name)")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                        Text(" \(user.bio)")
                        // 他の詳細情報も表示
                    } else {
                        Text("ユーザー情報をロード中...")
                    }
                }
                .padding()
                Spacer()
            }
            Divider()
                ScrollView {
                    RefreshControl(coordinateSpaceName: "RefreshControl", onRefresh: {
                        print("doRefresh()")
                    })
                    VStack {
                        ForEach(viewModel.tweetLikeViewModels, id: \.tweet.id) { tweetLikeViewModel in
                            NavigationLink(destination: DetailView(tweetLikeViewModel: tweetLikeViewModel, viewModel: viewModel, tweet: tweetLikeViewModel.tweet)) {
                                HStack{
                                    VStack{
                                        CachedImage(url: URL(string: tweetLikeViewModel.tweet.userIcon) ?? URL(string: "https://default.com")!)
                                            .frame(width:60,height:60)
                                            .cornerRadius(75)
                                            .padding(.bottom)
                                        Spacer()
                                    }
                                    VStack{
                                        VStack (alignment: .leading){
                                            HStack{
                                                VStack(alignment: .leading){
                                                    HStack{
                                                        Text(tweetLikeViewModel.tweet.userName)
                                                            .fontWeight(.bold)
                                                        Text(timeAgoSinceDate(tweetLikeViewModel.tweet.createdAt))
                                                            .font(.footnote)
                                                            .foregroundColor(.gray)
                                                    }
                                                    Text(tweetLikeViewModel.tweet.text)
                                                }
                                                Spacer()
                                            }
                                            if let imageUrl = URL(string: tweetLikeViewModel.tweet.imageUrl ?? "") {
                                                AsyncImage(url: imageUrl) { image in
                                                    image.resizable()
                                                        .scaledToFill()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(maxWidth: .infinity)
                                                .cornerRadius(10)
                                            }
                                        }
                                        .padding(.top,5)
                                        HStack{
                                            LikeButtonView(viewModel: LikeButtonViewModel(isLiked: tweetLikeViewModel.tweet.isLiked, likesCount: tweetLikeViewModel.tweet.likes.count, toggleLike: tweetLikeViewModel.toggleLike))
                                            Spacer()
                                        }
                                        .padding(.bottom)
                                    }
                                    Spacer()
                                }
                            }
                            .frame(maxWidth:.infinity)
                            .padding(5)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .padding(.horizontal, -16)
                                    .foregroundColor(Color("gray")),
                                alignment: .bottom
                            )
                        }
                        .foregroundColor(.black)
                        .refreshable {
                            await Task.sleep(1000000000)
                        }
                    }
            }
                .onAppear() {
                    self.viewModel.fetchDataByUserId(userId: self.userId)
                }
            Spacer()
        }
        .onAppear(perform: fetchUserData) // 画面表示時にユーザー情報を取得
    }
    
    // 指定されたuserIDに対応するユーザー情報を取得
    private func fetchUserData() {
        db.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            //            print(snapshot)
            guard let value = snapshot.value as? [String: Any] else { return }
            let name = value["name"] as? String ?? ""
            //            print(name)
            let icon = value["icon"] as? String ?? ""
            let bio = value["bio"] as? String ?? ""
            self.user = User(id: userId, name: name, icon: icon, bio: bio)
            print(self.user)
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
struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailView(userId: "p7HIhWldBHdbPYacmqLISnHBShF2") // userIdパラメータを渡す
    }
}
