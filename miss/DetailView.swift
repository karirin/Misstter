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


    var body: some View {
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
                    Spacer()
                }
                Divider()
                    .frame(maxWidth:.infinity)
                ForEach(comments) { comment in
                    HStack {
                        CachedImage(url: URL(string: comment.userIcon) ?? URL(string: "https://default.com")!)
                            .frame(width: 60, height: 60)
                            .cornerRadius(75)
                        VStack(alignment: .leading) {
                            Text(comment.userName)
                                .fontWeight(.bold)
                            Text(comment.text)
                        }
                        Spacer()
                    }
                    .padding(5)
                    Divider()
                }
                Spacer()
            }
            .onAppear {
                viewModel.fetchComments(tweetId: tweet.id) { fetchedComments in
                    self.comments = fetchedComments
                }
                activeView.wrappedValue = "DetailView"
            }
            .onDisappear() {
                activeView.wrappedValue = ""
            }
            .navigationTitle("詳細")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                // 戻るボタンのアクションをここに書きます
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.backward")
                }
                .foregroundColor(.black)
            })
            .onAppear {
                viewModel.fetchComments(tweetId: tweet.id) { fetchedComments in
                    self.comments = fetchedComments
                }
            }
            .fullScreenCover(isPresented: $showingCommentView) {
                NavigationView {
                    CommentView(tweetLikeViewModel: tweetLikeViewModel)
                }
            }
        }
    }
}
//
//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
