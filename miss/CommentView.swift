//
//  CommentView.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/24.
//

import SwiftUI

struct CommentView: View {
    @State private var commentText: String = "comment"
    @ObservedObject private var viewModel = TweetViewModel()
    var tweetLikeViewModel: TweetLikeViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            TextField("コメントを入力...", text: $commentText,axis: .vertical)
                //.padding()
                .frame(maxWidth: .infinity,maxHeight:100, alignment: .top)
                .border(Color.clear, width: 0)
            Spacer()
        }
        .navigationBarItems(leading: Button(action: {
            // 戻るボタンのアクションをここに書きます
            print("modoru1")
          presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "arrow.backward")
            }
            .foregroundColor(.black)
        })
        .navigationBarItems(trailing: Button(action: {
            viewModel.sendComment(tweetId: tweetLikeViewModel.tweet.id, text: commentText)
            commentText = ""
            print("modoru2")
          presentationMode.wrappedValue.dismiss()
        }) {
            Text("送信")
        })
        .padding()
        
    }
}
