//
//  AuthManager.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/07/22.
//

import SwiftUI
import Firebase

struct User: Identifiable {
    let id: String
    let name: String
    let icon: String
}

class AuthManager: ObservableObject {
    @Published var user: User?
    private var db = Database.database().reference()
    static let shared = AuthManager()

    init() {
        fetchUser()
    }

    func fetchUser() {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        db.child("users").child(firebaseUser.uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let name = value["name"] as? String ?? ""
            let icon = value["icon"] as? String ?? ""
            self.user = User(id: firebaseUser.uid, name: name, icon: icon)
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
    
    func createUser(name: String, icon: String) {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        let user = ["name": name, "icon": icon]
        db.child("users").child(firebaseUser.uid).setValue(user) { error, _ in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                self.fetchUser()
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

