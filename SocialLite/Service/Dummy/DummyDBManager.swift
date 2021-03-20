//
//  DummyDBManager.swift
//  SocialLite_Dev
//
//  Created by Tei on 19/3/21.
//

import Foundation

let DUMMY_QUERY_LIMIT = 10

class DummyDBManager: DBManagerProtocol {
    
    private var users = [User(key: "DemoUser@toremove.com", uid: "DemoUser@toremove.com", displayName: "DemoUser@toremove.com", email: "DemoUser@toremove.com")]
    private var posts = [Post]()
    
    public var delegate: DBManagerDelegate?
    
    init() {
        for i in 0..<100 {
            posts.append(Post(key: "\(i)", text: "Post \(i)", time: Int(Date.timeIntervalSinceReferenceDate) - 500 * (1000 - i), uid: "DemoUser@toremove.com"))
        }
    }
    
    func config() {
        
    }
    
    // MARK: - Post DB related functions
    // Create new post for this userID
    func createPost(_ text: String, userID: String) {
        let time = Int(Date.timeIntervalSinceReferenceDate)
        // Since we cannot query on 2+ fields with Firebase and no sort option
        // so we create key in this format "USERID_TIME" to make it easier to
        // sort item by user + time
        let pid = "\(self.posts.count)"
        let post = Post(key: pid, text: text, time: time, uid: userID)
        self.posts = [post] + self.posts
        self.delegate?.onItemCreated(item: post, error: nil)
    }
    // Delete post
    func deletePost(_ item: Post) {
        let size = self.posts.count
        for i in 0..<size {
            if self.posts[i].key == item.key {
                self.posts.remove(at: i)
                self.delegate?.onItemRemoved(removedItem: item, error: nil)
                break
            }
        }
    }
    // Fetch posts after the specified post (if nil, fetch from the start) (for pagination)
    // should fetch for a certain amount of item (don't fetch all at once)
    func fetchPosts(startAfter offsetItem: Post?) {
        var posts = [Post]()
        var idx = 0
        if let post = offsetItem {
            while idx < self.posts.count && self.posts[idx].key != post.key {
                idx += 1
            }
            idx += 1
        }
        while idx < self.posts.count && posts.count < DUMMY_QUERY_LIMIT {
            posts.append(self.posts[idx])
            idx += 1
        }
        let hasMore = (posts.count < DUMMY_QUERY_LIMIT ? false : true)
        self.delegate?.onItemsFetchCompleted(items: posts, startAfter: offsetItem, hasMore: hasMore, error: nil)
    }
    // Fetch specific post (in case of there is an update for this post)
    func fetchPost(_ item: Post) {
        let size = self.posts.count
        for i in 0..<size {
            if self.posts[i].key == item.key {
                self.delegate?.onItemFetchCompleted(item: self.posts[i], error: nil)
                break
            }
        }
    }
    // Fetch user's posts after the specified post (if nil, fetch from the start) (for pagination)
    // should fetch for a certain amount of item (don't fetch all at once)
    func fetchUserPosts(for userID: String, startAfter offsetItem: Post?) {
        var posts = [Post]()
        var idx = 0
        if let post = offsetItem {
            while idx < self.posts.count && self.posts[idx].key != post.key {
                idx += 1
            }
            idx += 1
        }
        while idx < self.posts.count && posts.count < DUMMY_QUERY_LIMIT {
            if self.posts[idx].uid == userID {
                posts.append(self.posts[idx])
            }
            idx += 1
        }
        let hasMore = (posts.count < DUMMY_QUERY_LIMIT ? false : true)
        self.delegate?.onUserItemsFetchCompleted(userID: userID, items: posts, startAfter: offsetItem, hasMore: hasMore, error: nil)
    }
    // Update specific post with new data
    func updatePost(_ item: Post, updatedText text: String) {
        let size = self.posts.count
        for i in 0..<size {
            if self.posts[i].key == item.key {
                let post = Post(key: self.posts[i].key, text: text, time: self.posts[i].time, uid: self.posts[i].uid)
                self.posts[i] = post
                break
            }
        }
    }
    
    // MARK: - User DB related functions
    // Create new user for this user object (in case of auth system and db system may be from difference service)
    func createUser(_ user: User) {
        self.users.append(user)
        self.fetchUser(fromUserID: user.uid)
    }
    // Fetch user info for this userID
    func fetchUser(fromUserID userID: String) {
        let size = self.users.count
        for i in 0..<size {
            if self.users[i].key == userID {
                self.delegate?.onUserFetchCompleted(user: self.users[i], error: nil)
                break
            }
        }
    }
    // Update specific user with new data
    func updateUser(_ user: User, updatedDisplayName: String) {
        let size = self.users.count
        for i in 0..<size {
            if self.users[i].key == user.key {
                let user = User(key: user.key, uid: user.uid, displayName: updatedDisplayName, email: user.email)
                self.users[i] = user
                break
            }
        }
    }
}
