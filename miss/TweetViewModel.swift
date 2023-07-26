        //
        //  TweetViewModel.swift
        //  miss
        //
        //  Created by hashimo ryoya on 2023/07/22.
        //

        import Foundation
        import Firebase
        import SwiftUI

struct Tweet: Identifiable, Hashable {
    let id: String
    let text: String
    let userId: String
    let userName: String
    let userIcon: String
    let imageUrl: String?
    var isLiked: Bool = false
    var likes: [String: Bool] = [:]
    let createdAt: Date // 追加
}

struct Comment: Identifiable, Hashable {
    let id: String
    let text: String
    let userId: String
    let userName: String
    let userIcon: String
}

        class TweetViewModel: ObservableObject {
            @Published var tweets = [Tweet]()
            @Published var allTweets = [Tweet]()
            @Published var tweetLikeViewModels = [TweetLikeViewModel]()

            private var db = Database.database().reference()

            func fetchData() {
                db.child("tweets").observe(.value, with: { [weak self] (snapshot) in
                    guard let self = self else { return }
                    
                    var newTweetLikeViewModels: [TweetLikeViewModel] = []
                    
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let dict = childSnapshot.value as? [String: Any],
                           let text = dict["text"] as? String,
                           let userId = dict["userId"] as? String,
                           let imageUrl = dict["imageUrl"] as? String,
                           let createdAtTimestamp = dict["createdAt"] as? TimeInterval {
                            let likes = dict["likes"] as? [String: Bool] ?? [:] // Handle case where likes does not exist
                            let isLiked = likes[AuthManager.shared.user?.id ?? ""] ?? false
                            let createdAt = Date(timeIntervalSince1970: createdAtTimestamp / 1000) // Convert to Date
                            
                            self.fetchUser(userId: userId) { user in
                                guard let user = user else { return }
                                let tweet = Tweet(id: childSnapshot.key, text: text, userId: userId, userName: user.name, userIcon: user.icon, imageUrl: imageUrl, isLiked: isLiked, likes: likes, createdAt: createdAt)
                                let tweetLikeViewModel = TweetLikeViewModel(tweet: tweet, parentViewModel: self)
                                newTweetLikeViewModels.append(tweetLikeViewModel)
                                
                                DispatchQueue.main.async {
                                    self.tweetLikeViewModels = newTweetLikeViewModels
                                }
                            }
                        }
                    }
                })
            }
            
            func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
                db.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
                    guard let value = snapshot.value as? [String: Any] else {
                        completion(nil)
                        return
                    }
                    let name = value["name"] as? String ?? ""
                    let icon = value["icon"] as? String ?? ""
                    let user = User(id: userId, name: name, icon: icon)
                    completion(user)
                }
            }

            func sendTweet(text: String, image: UIImage?) {
                guard let user = AuthManager.shared.user else { return }

                if let image = image {
                    uploadImage(image) { imageUrl in
                        let key = self.db.child("tweets").childByAutoId().key ?? ""
                        let tweet = ["text": text, "userId": user.id, "imageUrl": imageUrl ?? "", "likes": [:], "createdAt": ServerValue.timestamp()] as [String : Any]
                        self.db.child("tweets").child(key).setValue(tweet)
                    }
                } else {
                    let key = self.db.child("tweets").childByAutoId().key ?? ""
                    let tweet = ["text": text, "userId": user.id, "imageUrl": "", "likes": [:], "createdAt": ServerValue.timestamp()] as [String : Any]
                    self.db.child("tweets").child(key).setValue(tweet)
                }
            }


            
            func toggleLike(tweet: Tweet) {
                guard let user = AuthManager.shared.user else { return }
                
                if let index = tweetLikeViewModels.firstIndex(where: { $0.tweet.id == tweet.id }) {
                    // ユーザーがまだ「いいね」を送っていない場合
                    if tweetLikeViewModels[index].tweet.likes[user.id] == nil {
                        tweetLikeViewModels[index].tweet.likes[user.id] = true
                        tweetLikeViewModels[index].tweet.isLiked = true
                    } else {
                        // ユーザーがすでに「いいね」を送っている場合
                        tweetLikeViewModels[index].tweet.likes[user.id] = nil
                        tweetLikeViewModels[index].tweet.isLiked = false
                    }
                    db.child("tweets").child(tweetLikeViewModels[index].tweet.id).child("likes").setValue(tweetLikeViewModels[index].tweet.likes)
                }
            }
            
            func sendComment(tweetId: String, text: String) {
                print("aaaa")
                guard let user = AuthManager.shared.user else { return }
                print("bbbb")
                let key = db.child("tweets").child(tweetId).child("comments").childByAutoId().key ?? ""
                print("key：\(key)")
                let comment = ["text": text, "userId": user.id]
                db.child("tweets").child(tweetId).child("comments").child(key).setValue(comment)
            }
            
            func fetchComments(tweetId: String, completion: @escaping ([Comment]) -> Void) {
                db.child("tweets").child(tweetId).child("comments").observe(.value, with: { snapshot in
                    var comments: [Comment] = []
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let dict = childSnapshot.value as? [String: Any],
                           let text = dict["text"] as? String,
                           let userId = dict["userId"] as? String {
                            self.fetchUser(userId: userId) { user in
                                guard let user = user else { return }
                                let comment = Comment(id: childSnapshot.key, text: text, userId: userId, userName: user.name, userIcon: user.icon)
                                comments.append(comment)
                                DispatchQueue.main.async {
                                    completion(comments)
                                }
                            }
                        }
                    }
                })
            }
            func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
                guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                    completion(nil)
                    return
                }
                
                let storageRef = Storage.storage().reference()
                let imageName = UUID().uuidString
                let imageRef = storageRef.child("images/\(imageName).jpg")
                
                imageRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        print("Failed to upload image: \(error)")
                        completion(nil)
                    } else {
                        imageRef.downloadURL { url, error in
                            if let error = error {
                                print("Failed to get download URL: \(error)")
                                completion(nil)
                            } else {
                                completion(url?.absoluteString)
                            }
                        }
                    }
                }
            }
        }

    class TweetLikeViewModel: ObservableObject {
        @Published var tweet: Tweet
        let parentViewModel: TweetViewModel
        @ObservedObject var likeButtonViewModel: LikeButtonViewModel

        init(tweet: Tweet, parentViewModel: TweetViewModel) {
            self.tweet = tweet
            self.parentViewModel = parentViewModel
            self.likeButtonViewModel = LikeButtonViewModel(isLiked: tweet.isLiked, likesCount: tweet.likes.count, toggleLike: {})
            self.likeButtonViewModel.toggleLike = { [weak self] in self?.toggleLike() }
        }

        func toggleLike() {
            tweet.isLiked.toggle()
            likeButtonViewModel.isLiked = tweet.isLiked
            likeButtonViewModel.likesCount = tweet.likes.count
            parentViewModel.toggleLike(tweet: tweet)
        }
    }



