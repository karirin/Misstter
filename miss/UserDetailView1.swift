////
////  UserDetailView.swift
////  miss
////
////  Created by hashimo ryoya on 2023/07/30.
////
//
//import Foundation
//import Firebase
//import SwiftUI
//
//struct UserDetailView: View {
//    var userId: String // ユーザーID
//    @State private var user: User? // ユーザー情報
//    private var db = Database.database().reference() // Firebaseのデータベースへの参照
//
//    var body: some View {
//        // ユーザー情報の表示
//        Group {
//            if let user = user {
//                Text("ユーザー名: \(user.name)")
//                // 他の詳細情報も表示
//            } else {
//                Text("ユーザー情報をロード中...")
//            }
//        }
//        .onAppear(perform: fetchUserData) // 画面表示時にユーザー情報を取得
//    }
//
//    // 指定されたuserIDに対応するユーザー情報を取得
//    private func fetchUserData() {
//        db.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [String: Any] else { return }
//            let name = value["name"] as? String ?? ""
//            let icon = value["icon"] as? String ?? ""
//            let bio = value["bio"] as? String ?? ""
//            self.user = User(id: userId, name: name, icon: icon, bio: bio)
//        }
//    }
//}
//
//struct UserDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailView(userId: "12345") // userIdパラメータを渡す
//    }
//}
