//
//  FirebaseDBManager.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

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
    func config() {
        self.config(withItemPath: "Posts", userPath: "Users")
    }
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
            self.delegate?.onItemCreated(item: items.first)
        }, withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
        })
    }
    
    // MARK: - Item DB Functions
    func createPost(_ text: String, user: User) {
        self.createPost(text, user: user) { (error, ref) in
            // TODO: implement this
        }
    }
    func createPost(_ text: String, user: User, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        let uid = user.uid
        let time = Int(Date.timeIntervalSinceReferenceDate)
        let pid = "\(uid)_\(time)"
        
        let postRef = self.itemDBRef?.child(pid)
        let post = Post(key: pid, text: text, time: time, uid: uid)
        postRef?.setValue(post.toAnyObject(), withCompletionBlock: block)
    }
    
    func deletePost(_ item: Post) {
        // Delete Post
        self.deletePost(item) { (error, ref) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            // Notify delegate
            self.delegate?.onItemRemoved(removedItem: item)
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
            self.delegate?.onItemsFetchCompleted(items: items, startAfter: offsetItem)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
        }
    }
    func fetchPosts(startAfter offsetItem: Post?, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        let ref = self.itemDBRef?.queryOrdered(byChild: "time").queryStarting(atValue: 0).queryEnding(atValue: (offsetItem?.time ?? Int(Date.timeIntervalSinceReferenceDate))).queryLimited(toLast: UInt(FIREBASE_QUERY_LIMIT))
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    func fetchPost(_ item: Post) {
        self.fetchPost(item) { (snapshot) in
            // Parse items
            let items = Post.Load(snapshot: snapshot)
            // Notify delegate
            self.delegate?.onItemFetchCompleted(item: items.first)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
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
            self.delegate?.onUserItemsFetchCompleted(userID: userID, items: items, startAfter: offsetItem)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
        }
    }
    func fetchUserPosts(for userID: String, startAfter offsetItem: Post?, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        let ref = self.itemDBRef?.queryOrderedByKey().queryStarting(atValue: "\(userID)_0").queryEnding(atValue: "\(userID)_\(offsetItem?.time ?? Int(Date.timeIntervalSinceReferenceDate))").queryLimited(toLast: UInt(FIREBASE_QUERY_LIMIT))
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    func updatePost(_ item: Post, updatedText text: String) {
        self.updatePost(item, updatedText: text) { (error, ref) in
            // TODO: implement this
            // Notify delegate
        }
    }
    func updatePost(_ item: Post, updatedText text: String, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        // Update post
        self.itemDBRef?.child(item.key).updateChildValues(["text": text], withCompletionBlock: block)
    }
    
    // MARK: - User DB Functions
    func createUser(_ user: User) {
        self.createUser(user) { (error, ref) in
            // TODO: implement this
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
            self.delegate?.onUserFetchCompleted(user: users.first)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
        }
    }
    func fetchUser(fromUserID userID: String, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        let ref = self.userDBRef?.child(userID)
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    func updateUser(_ user: User, updatedDisplayName: String) {
        self.updateUser(user, updatedDisplayName: updatedDisplayName) { (error, ref) in
            // TODO: implement this
        }
    }
    func updateUser(_ user: User, updatedDisplayName: String, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        // Update user
        self.userDBRef?.child(user.key).updateChildValues(["displayName": updatedDisplayName], withCompletionBlock: block)
    }
}
