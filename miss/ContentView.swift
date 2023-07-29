//
//  ContentView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = TweetViewModel()
    @State var showAnotherView_post: Bool = false
    @State private var inputText: String = ""
    @State private var selectedImage: UIImage?
    var tweet: Tweet
    @Environment(\.activeView) var activeView
    @State private var isImagePickerDisplayed = false
    
    struct RefreshControl: View {
        
        @State private var isRefreshing = false
        var coordinateSpaceName: String
        var onRefresh: () -> Void
        
        var body: some View {
            GeometryReader { geometry in
                if geometry.frame(in: .named(coordinateSpaceName)).midY > 50 {
                    Spacer()
                        .onAppear() {
                            isRefreshing = true
                        }
                } else if geometry.frame(in: .named(coordinateSpaceName)).maxY < 10 {
                    Spacer()
                        .onAppear() {
                            if isRefreshing {
                                isRefreshing = false
                                onRefresh()
                            }
                        }
                }
                HStack {
                    Spacer()
                    if isRefreshing {
                        ProgressView()
                    } else {
                        Text("⬇︎")
                            .font(.system(size: 28))
                    }
                    Spacer()
                }
            }.padding(.top, -50)
        }
    }

    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    Text("")
                    Spacer()
                    Text("     ")
                        .fontWeight(.bold)
                    Spacer()
                    Text("")
                }
                .padding()
                .background(Color("green"))
                .foregroundColor(.white)
                .frame(height:50)
                .font(.system(size: 20))
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
            }
            .onAppear() {
                self.viewModel.fetchData()
            }
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
                                                    TextField("口頭で頼まれていたことを忘れてしまった…", text: $inputText)
                                                        .frame(maxWidth: .infinity)
                                                        .border(Color.clear, width: 0)
                                                    HStack{
                                                        Button(action: {
                                                            self.isImagePickerDisplayed = true
                                                        }, label: {
                                                            Image(systemName: "photo")
                                                        })
                                                        .sheet(isPresented: $isImagePickerDisplayed, content: {
                                                            ImagePicker(image: $selectedImage)
                                                        })
                                                        .foregroundColor(.black)
                                                        .padding(.vertical)
                                                        
                                                        Spacer()
                                                    }
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
                                                        .padding(.vertical,5)
                                                        .padding(.horizontal,25)
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

