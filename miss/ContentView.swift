//
//  ContentView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/22.
//

import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner) // インスタンスを生成
        // 諸々の設定をしていく
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        return banner // 最終的にインスタンスを返す
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
      // 特にないのでメソッドだけ用意
    }
}

struct ContentView: View {
    @ObservedObject private var viewModel = TweetViewModel()
    @State var showAnotherView_post: Bool = false
    @State private var inputText: String = "あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ"
    @State private var selectedImage: UIImage?
    var tweet: Tweet
    @Environment(\.activeView) var activeView
    @State private var isImagePickerDisplayed = false
    @ObservedObject private var authManager = AuthManager.shared
    @State private var showNotificationView: Bool = false
    @ObservedObject private var notificationViewModel = NotificationViewModel() // ここでViewModelを監視

    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    if let user = authManager.user {
                        NavigationLink(destination: UserDetailView(userId: user.id)) {
                            if let userIconURL = URL(string: authManager.user?.icon ?? "") {
                                AsyncImage(url: userIconURL) { image in // 非同期で画像をロード
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView() // プレースホルダー
                                }
                                .frame(width: 40, height: 40) // サイズを設定
                                .clipShape(Circle()) // 円形にクリップ
                                .padding(.leading)
//                                .padding(.top,5)
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .padding(.leading)
//                                    .padding(.top,5)
                            }
                        }
                    }
                    Spacer()
                    Image("miss")
                        .resizable()
                        .scaledToFill()
                        .frame(width:180,height:20)
                        .padding(.top,5)
                    Spacer()
                    
                    Button(action: {
                        self.showNotificationView = true
                        self.notificationViewModel.checkNotifications()
                    }, label: {
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
                    })
                    .font(.system(size: 28))
                    .padding(.trailing)

                }
                .padding(.top)
                
                NavigationLink(destination: NotificationView(viewModel: NotificationViewModel(), tweetViewModel: viewModel), isActive: $showNotificationView) {
                    EmptyView()
                }
//                AdMobBannerView()
//                    .frame(height:40)
//                    .padding(.bottom,-10)
//                    .padding(.top)
                ScrollView {
                    RefreshControl(coordinateSpaceName: "RefreshControl", onRefresh: {
                        print("doRefresh()")
                    })
                    VStack {
                        ForEach(viewModel.tweetLikeViewModels.sorted(by: { $0.tweet.createdAt > $1.tweet.createdAt }), id: \.tweet.id) { tweetLikeViewModel in
                            NavigationLink(destination: DetailView(tweetLikeViewModel: tweetLikeViewModel, viewModel: viewModel, tweet: tweetLikeViewModel.tweet, tweetId: tweetLikeViewModel.tweet.id)) {
                                HStack{
                                    VStack{
                                        NavigationLink(destination: UserDetailView(userId: tweetLikeViewModel.tweet.userId)) {
                                            CachedImage(url: URL(string: tweetLikeViewModel.tweet.userIcon) ?? URL(string: "https://default.com")!)
                                                .frame(width:60,height:60)
                                                .cornerRadius(75)
                                                .padding(.bottom)
                                        }
                                        .padding(.top)
                                        Spacer()
                                    }
                                    VStack{
                                        VStack{
                                            HStack{
                                                VStack(alignment: .leading){
                                                    HStack{
                                                        Text(tweetLikeViewModel.tweet.userName)
                                                  .fontWeight(.bold)
                                                Text(timeAgoSinceDate(tweetLikeViewModel.tweet.createdAt))
                                                  .font(.footnote)
                                                  .foregroundColor(.gray)
                                                    }
                                                    HStack{
                                                        Text(tweetLikeViewModel.tweet.text)
                                                            .multilineTextAlignment(.leading)
                                                            .fixedSize(horizontal: false, vertical: true)
                                                            .frame(maxWidth:.infinity, alignment: .leading)
                                                    }
                                                }
                                                .frame(maxWidth:.infinity)
                                                Spacer()
                                            }
                                            .frame(maxWidth:.infinity)
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
                                        .frame(maxWidth:.infinity)
                                        HStack{
                                            LikeButtonView(viewModel: LikeButtonViewModel(isLiked: tweetLikeViewModel.tweet.isLiked, likesCount: tweetLikeViewModel.tweet.likes.count, toggleLike: tweetLikeViewModel.toggleLike))
                                            Spacer()
                                        }
                                        .padding(.bottom)
                                        .frame(maxWidth:.infinity)
                                    }
                                    .frame(maxWidth:.infinity)
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
            }
        }
        .onAppear() {
self.viewModel.fetchData() // 既存のデータ取得
self.notificationViewModel.fetchNotifications() // 通知の取得
}
            .overlay(
                ZStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack{
                            Spacer()
                            HStack {
                                Spacer()
                                    Button(action: {
                                        self.showAnotherView_post = true
                                    }, label: {
                                        Image(systemName: "plus")
                                            .foregroundColor(.white)
                                            .font(.system(size: 24)) // --- 4
                                    }).frame(width: 60, height: 60)
                                        .background(Color("green"))
                                        .cornerRadius(30.0)
                                        .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
                                        .fullScreenCover(isPresented: $showAnotherView_post, content: {
                                            NavigationView {
                                                VStack {
                                                    TextField("口頭で頼まれていたことを忘れてしまった…", text: $inputText,axis: .vertical)
                                                        .frame(maxWidth: .infinity,maxHeight:.infinity, alignment: .top)
                                                        .border(Color.clear, width: 0)
//                                                    HStack{
//                                                        Button(action: {
//                                                            self.isImagePickerDisplayed = true
//                                                        }, label: {
//                                                            Image(systemName: "photo")
//                                                        })
//                                                        .sheet(isPresented: $isImagePickerDisplayed, content: {
//                                                            ImagePicker(image: $selectedImage)
//                                                        })
//                                                        .foregroundColor(.black)
//                                                        .padding(.vertical)
//
//                                                        Spacer()
//                                                    }
                                                    if let image = selectedImage {
                                                        ZStack(alignment: .topTrailing) {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(maxWidth: .infinity)
                                                                .cornerRadius(10)

                                                            Button(action: {
                                                                selectedImage = nil
                                                            }) {
                                                                Image(systemName: "xmark.circle")
                                                                    .font(.system(size: 24))
                                                                    .foregroundColor(.white)
                                                                    .opacity(0.6)
                                                            }
                                                            .padding(4)
                                                        }
                                                    }
                                                    Spacer()
                                                }
                                                .padding()
                                                .toolbar {
                                                    ToolbarItem(placement: .navigationBarLeading) {
                                                        Button("キャンセル") {
                                                            self.showAnotherView_post = false
                                                            inputText = ""
                                                        }
                                                        .foregroundColor(.black)
                                                    }
                                                    ToolbarItem(placement: .navigationBarTrailing) {
                                                        Button("送信") {
                                                            viewModel.sendTweet(text: inputText, image: selectedImage)
                                                            inputText = ""
                                                            selectedImage = nil // Reset selected image
                                                            self.showAnotherView_post = false
                                                        }
                                                        .frame(width:80)
                                                        .padding(.vertical,5)
                                                        .padding(.trailing,5)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                        .background(Color("green"))
                                                        .cornerRadius(30.0)
                                                    }
                                                }
                                            }
                                        })
                            }.padding()
                        }
                    }
                }
            )
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
        
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let tweet = Tweet(id: "dummyID", text: "dummyUser", userId: "dummyText", userName: "dummyIconURL", userIcon: "dummyIconURL", imageUrl: "https://default.com", isLiked: false, createdAt: Date())
        ContentView(tweet: tweet)
    }
}

