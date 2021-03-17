//
//  FirebaseDBManager.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

// The max number of items for each fetch request
let FIREBASE_QUERY_LIMIT = 10

class FirebaseDBManager: DBManagerProtocol {
    
    var itemDBRef: DatabaseReference?
    var userDBRef: DatabaseReference?
    
    public var delegate: DBManagerDelegate?
    
    deinit {
        self.itemDBRef?.removeAllObservers()
        self.itemDBRef = nil
        self.userDBRef = nil
    }
    
    // MARK: - Setup Function
    // Config DB with default path
    func config() {
        self.config(withItemPath: "Posts", userPath: "Users")
    }
    // Config DB with specific path
    func config(withItemPath itemPath: String, userPath: String) {
        // Create DB ref to the specified path
        self.itemDBRef = Database.database().reference(withPath: itemPath)
        self.userDBRef = Database.database().reference(withPath: userPath)
        // Keep it sync with Firebase
        self.itemDBRef?.keepSynced(true)
        self.userDBRef?.keepSynced(true)
        
        // Listen to new item
        let ref = self.itemDBRef?.queryOrdered(byChild: "time").queryLimited(toLast: UInt(1))
        ref?.observe(.childAdded, with: { (snapshot) in
            // Parse items
            let items = Post.Load(snapshot: snapshot)
            // Notify delegate
            self.delegate?.onItemCreated(item: items.first, error: nil)
        }, withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
            // Notify delegate
            self.delegate?.onItemCreated(item: nil, error: error)
        })
    }
    
    // MARK: - Item DB Functions
    func createPost(_ text: String, userID: String) {
        self.createPost(text, userID: userID) { (error, ref) in
            // No need to notify delegate, new item observer will do that
        }
    }
    func createPost(_ text: String, userID: String, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        let time = Int(Date.timeIntervalSinceReferenceDate)
        let pid = "\(userID)_\(time)"
        
        let postRef = self.itemDBRef?.child(pid)
        let post = Post(key: pid, text: text, time: time, uid: userID)
        postRef?.setValue(post.toAnyObject(), withCompletionBlock: block)
    }
    
    func deletePost(_ item: Post) {
        // Delete Post
        self.deletePost(item) { (error, ref) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            // Notify delegate
            self.delegate?.onItemRemoved(removedItem: item, error: error)
        }
    }
    func deletePost(_ item: Post, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        // Delete Post
        let ref = self.itemDBRef?.child(item.key)
        ref?.removeValue(completionBlock: block)
    }
    
    func fetchPosts(startAfter offsetItem: Post?) {
        self.fetchPosts(startAfter: offsetItem) { (snapshot) in
            // Parse items
            let items = Post.Load(snapshot: snapshot)
            // Notify delegate
            self.delegate?.onItemsFetchCompleted(items: items, startAfter: offsetItem, error: nil)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
            // Notify delegate
            self.delegate?.onItemsFetchCompleted(items: [], startAfter: offsetItem, error: error)
        }
    }
    func fetchPosts(startAfter offsetItem: Post?, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        let ref = self.itemDBRef?.queryOrdered(byChild: "time").queryStarting(atValue: 0).queryEnding(atValue: (offsetItem?.time ?? Int(Date.timeIntervalSinceReferenceDate))-1).queryLimited(toLast: UInt(FIREBASE_QUERY_LIMIT))
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    func fetchPost(_ item: Post) {
        self.fetchPost(item) { (snapshot) in
            // Parse items
            let items = Post.Load(snapshot: snapshot)
            // Notify delegate
            self.delegate?.onItemFetchCompleted(item: items.first, error: nil)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
            // Notify delegate
            self.delegate?.onItemFetchCompleted(item: nil, error: error)
        }
    }
    func fetchPost(_ item: Post, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        let ref = self.itemDBRef?.child(item.key)
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    func fetchUserPosts(for userID: String, startAfter offsetItem: Post?) {
        self.fetchUserPosts(for: userID, startAfter: offsetItem) { (snapshot) in
            // Parse items
            let items = Post.Load(snapshot: snapshot)
            // Notify delegate
            self.delegate?.onUserItemsFetchCompleted(userID: userID, items: items, startAfter: offsetItem, error: nil)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
            // Notify delegate
            self.delegate?.onUserItemsFetchCompleted(userID: userID, items: [], startAfter: offsetItem, error: error)
        }
    }
    func fetchUserPosts(for userID: String, startAfter offsetItem: Post?, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        let ref = self.itemDBRef?.queryOrderedByKey().queryStarting(atValue: "\(userID)_0").queryEnding(atValue: "\(userID)_\((offsetItem?.time ?? Int(Date.timeIntervalSinceReferenceDate))-1)").queryLimited(toLast: UInt(FIREBASE_QUERY_LIMIT))
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    func updatePost(_ item: Post, updatedText text: String) {
        self.updatePost(item, updatedText: text) { (error, ref) in
            // Fetch this post again to update cache data
            self.fetchPost(item)
        }
    }
    func updatePost(_ item: Post, updatedText text: String, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        // Update post
        self.itemDBRef?.child(item.key).updateChildValues(["text": text], withCompletionBlock: block)
    }
    
    // MARK: - User DB Functions
    func createUser(_ user: User) {
        self.createUser(user) { (error, ref) in
            // Fetch this user again to update cache data
            self.fetchUser(fromUserID: user.uid)
        }
    }
    func createUser(_ user: User, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        let userRef = self.userDBRef?.child(user.uid)
        userRef?.setValue(user.toAnyObject(), withCompletionBlock: block)
    }
    
    func fetchUser(fromUserID userID: String) {
        self.fetchUser(fromUserID: userID) { (snapshot) in
            // Parse items
            let users = User.Load(snapshot: snapshot)
            // Notify delegate
            self.delegate?.onUserFetchCompleted(user: users.first, error: nil)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
            // Notify delegate
            self.delegate?.onUserFetchCompleted(user: nil, error: error)
        }
    }
    func fetchUser(fromUserID userID: String, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        let ref = self.userDBRef?.child(userID)
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    func updateUser(_ user: User, updatedDisplayName: String) {
        self.updateUser(user, updatedDisplayName: updatedDisplayName) { (error, ref) in
            // Fetch this user again to update cache data
            self.fetchUser(fromUserID: user.uid)
        }
    }
    func updateUser(_ user: User, updatedDisplayName: String, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        // Update user
        self.userDBRef?.child(user.key).updateChildValues(["displayName": updatedDisplayName], withCompletionBlock: block)
    }
}
