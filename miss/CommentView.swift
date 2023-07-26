//
//  CommentView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/24.
//

import SwiftUI

struct CommentView: View {
    @State private var commentText: String = ""
    @ObservedObject private var viewModel = TweetViewModel()
    var tweetLikeViewModel: TweetLikeViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            TextField("コメントを入力...", text: $commentText)
                //.padding()
                .frame(maxWidth: .infinity)
                .border(Color.clear, width: 0)
            Spacer()
        }
        .navigationBarItems(leading: Button(action: {
            // 戻るボタンのアクションをここに書きます
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "arrow.backward")
            }
            .foregroundColor(.black)
        })
        .navigationBarItems(trailing: Button(action: {
            viewModel.sendComment(tweetId: tweetLikeViewModel.tweet.id, text: commentText)
            commentText = ""
            self.presentationMode.wrappedValue.dismiss() // この行を追加
        }) {
            Text("送信")
        })
        .padding()
        
    }
}
