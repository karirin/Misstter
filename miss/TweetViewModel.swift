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
    //let userId: String
    var isLiked: Bool = false
    var likes: Int = 0
}

class TweetViewModel: ObservableObject {
    @Published var tweets = [Tweet]()
    @Published var allTweets = [Tweet]()

    private var db = Database.database().reference()

    func fetchData() {
        db.child("tweets").observe(.childAdded, with: { (snapshot) in
            let dict = snapshot.value as! [String: Any]
            let text = dict["text"] as! String
            //let userId = dict["userId"] as! String
            let likes = dict["likes"] as? Int ?? 0
            let isLiked = likes > 0
            let tweet = Tweet(id: snapshot.key, text: text, isLiked: isLiked, likes: likes)
            self.tweets.append(tweet)
        })
    }

    func sendTweet(text: String) {
        let key = db.child("tweets").childByAutoId().key ?? ""
        let userId = AuthManager.shared.user?.id ?? ""
        let tweet = ["text": text, "userId": userId]
        db.child("tweets").child(key).setValue(tweet)
    }
    
    func toggleLike(tweet: Tweet) {
        if let index = tweets.firstIndex(where: { $0.id == tweet.id }) {
            tweets[index].isLiked.toggle()
            tweets[index].likes += tweets[index].isLiked ? 1 : -1
            let likes = ["likes": tweets[index].likes]
            db.child("tweets").child(tweet.id).updateChildValues(likes)
        }
    }

}
