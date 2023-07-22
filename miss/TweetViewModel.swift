//
//  TweetViewModel.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/22.
//

import Foundation
import Firebase

struct Tweet: Identifiable, Hashable {
    let id: String
    let text: String
    let userId: String
}

class TweetViewModel: ObservableObject {
    @Published var tweets = [Tweet]()

    private var db = Database.database().reference()

    func fetchData() {
        db.child("tweets").observe(.childAdded, with: { (snapshot) in
            let dict = snapshot.value as! [String: Any]
            let text = dict["text"] as! String
            let userId = dict["userId"] as! String
            let tweet = Tweet(id: snapshot.key, text: text, userId: userId)
            self.tweets.append(tweet)
        })
    }

    func sendTweet(text: String) {
        let key = db.child("tweets").childByAutoId().key ?? ""
        let userId = AuthManager.shared.user?.uid ?? ""
        let tweet = ["text": text, "userId": userId]
        db.child("tweets").child(key).setValue(tweet)
    }
}
