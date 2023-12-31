//
//  AuthManager.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/07/22.
//

import SwiftUI
import Firebase
import FirebaseStorage


struct User: Identifiable {
    let id: String
    let name: String
    let icon: String
    let bio: String // 追加
}


class AuthManager: ObservableObject {
    @Published var user: User?
    private var db = Database.database().reference()
    static let shared = AuthManager()
    @Published var isLoading = true  // 追加

    init() {
        anonymousSignIn()
        fetchUser()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
        }
    }

    func fetchUser() {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        db.child("users").child(firebaseUser.uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let name = value["name"] as? String ?? ""
            let icon = value["icon"] as? String ?? ""
            let bio = value["bio"] as? String ?? "" // 追加
            self.user = User(id: firebaseUser.uid, name: name, icon: icon, bio: bio) // 変更
        }
    }


    func anonymousSignIn() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let result = result {
                print("Signed in anonymously with user ID: \(result.user.uid)")
                self.fetchUser()
            }
        }
    }
    
    func createUser(name: String, icon: UIImage?, bio: String) { // bioを追加
            guard let firebaseUser = Auth.auth().currentUser else { print("user")
                return }
            guard let image = icon, let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            
            let storageRef = Storage.storage().reference().child("\(firebaseUser.uid).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(imageData, metadata: metadata) { _, error in
                if let error = error {
                    print("Errorあ: \(error.localizedDescription)")
                } else {
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else if let url = url {
                            let user = ["name": name, "icon": url.absoluteString, "bio": bio] // bioを追加
                            self.db.child("users").child(firebaseUser.uid).setValue(user) { error, _ in
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                } else {
                                    self.fetchUser()
                                }
                            }
                        }
                    }
                }
            }
        }
}

struct AuthManager1: View {
    @ObservedObject var authManager = AuthManager.shared

    var body: some View {
        VStack {
            if authManager.user == nil {
                Text("Not logged in")
            } else {
                Text("Logged in with user ID: \(authManager.user!.id)")
            }
            Button(action: {
                if self.authManager.user == nil {
                    self.authManager.anonymousSignIn()
                }
            }) {
                Text("Log in anonymously")
            }
        }
    }
}

struct AuthManager_Previews: PreviewProvider {
    static var previews: some View {
        AuthManager1()
    }
}

