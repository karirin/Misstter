//
//  SignUp.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/23.
//

import SwiftUI

struct SignUp: View {
    @ObservedObject private var viewModel = TweetViewModel()
    @ObservedObject private var authManager = AuthManager.shared
    @State var showAnotherView_post: Bool = false
    @State private var inputText: String = ""
    @State private var userName: String = ""
    @State private var userIcon: UIImage?
//    @State private var userIcon: String = ""
    @State private var isImagePickerDisplay = false

    var body: some View {
//        if authManager.user == nil {
            VStack {
                TextField("ユーザー名を入力してください", text: $userName)
                Button(action: {
                    self.isImagePickerDisplay = true
                }) {
                    Text("アイコンを選択")
                }
                .sheet(isPresented: $isImagePickerDisplay) {
                    ImagePicker(image: self.$userIcon)
                }
                if let image = userIcon {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
//                TextField("アイコンを入力してください", text: $userIcon)
                Button(action: {
                    authManager.createUser(name: userName, icon: userIcon)
                }) {
                    Text("ユーザーを作成")
                }
            }
//        } else {
//            ContentView()
//        }
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}