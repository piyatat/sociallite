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

// There is completion block version for each functions
// to make it easier for testing

// The delegate callback version will call completion block version
// and call delegate in the completion block

class FirebaseDBManager: DBManagerProtocol {
    // Since Firebase RealTime Database is NoSQL
    // It uses path to ref to object
    // For convenience, store ref to posts object list & users object list separately
    var itemDBRef: DatabaseReference?
    var userDBRef: DatabaseReference?
    
    public var delegate: DBManagerDelegate?
    
    deinit {
        self.itemDBRef?.removeAllObservers()
        self.itemDBRef = nil
        self.userDBRef = nil
    }
    
    // MARK: - Setup Function
    // This is the designated function for setting up the instance
    // should be called before any other functions
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
            // Parse items, there should be only 1 item
            let items = Post.Load(snapshot: snapshot)
            if let item = items.first {
                // Check whether this is newly created or not (should be create within N seconds from now)
                // Use 5 seconds as limit
                if Int(Date.timeIntervalSinceReferenceDate) - item.time < 5 {
                    // Newly created item
                    // Notify delegate
                    self.delegate?.onItemCreated(item: items.first, error: nil)
                }
            }
        }, withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
            // Notify delegate
            self.delegate?.onItemCreated(item: nil, error: error)
        })
    }
    
    
    // MARK: - Item DB Functions
    // Create new post for this userID
    // - delegate callback version
    func createPost(_ text: String, userID: String) {
        self.createPost(text, userID: userID) { (error, ref) in
            // No need to notify delegate, new item observer will do that
        }
    }
    // - completion block version
    func createPost(_ text: String, userID: String, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        let time = Int(Date.timeIntervalSinceReferenceDate)
        // Since we cannot query on 2+ fields with Firebase and no sort option
        // so we create key in this format "USERID_TIME" to make it easier to
        // sort item by user + time
        let pid = "\(userID)_\(time)"
        
        let postRef = self.itemDBRef?.child(pid)
        let post = Post(key: pid, text: text, time: time, uid: userID)
        postRef?.setValue(post.toAnyObject(), withCompletionBlock: block)
    }
    
    
    // Delete post
    // - delegate callback version
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
    // - completion block version
    func deletePost(_ item: Post, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        // Delete Post
        let ref = self.itemDBRef?.child(item.key)
        ref?.removeValue(completionBlock: block)
    }
    
    
    // Fetch posts after the specified post (if nil, fetch from the start) (for pagination)
    // should fetch for a certain amount of item (don't fetch all at once)
    // - delegate callback version
    func fetchPosts(startAfter offsetItem: Post?) {
        self.fetchPosts(startAfter: offsetItem) { (snapshot) in
            // Parse items
            let items = Post.Load(snapshot: snapshot)
            let hasMore = (items.count < FIREBASE_QUERY_LIMIT ? false : true)
            // Notify delegate
            self.delegate?.onItemsFetchCompleted(items: items, startAfter: offsetItem, hasMore: hasMore, error: nil)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
            // Notify delegate
            self.delegate?.onItemsFetchCompleted(items: [], startAfter: offsetItem, hasMore: false, error: error)
        }
    }
    // - completion block version
    func fetchPosts(startAfter offsetItem: Post?, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        // There is no sort option in Firebase Realtime DB (only sort in ascending order)
        // so sort by time and pick the last N items instead
        // PS. it is possible to have 2+ posts with the same time in high-traffic platform
        // in this case, we should build backend service to generate itemID instead of using time as key
        let ref = self.itemDBRef?.queryOrdered(byChild: "time").queryStarting(atValue: 0).queryEnding(atValue: (offsetItem?.time ?? Int(Date.timeIntervalSinceReferenceDate))-1).queryLimited(toLast: UInt(FIREBASE_QUERY_LIMIT))
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    
    // Fetch specific post (in case of there is an update for this post)
    // - delegate callback version
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
    // - completion block version
    func fetchPost(_ item: Post, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        let ref = self.itemDBRef?.child(item.key)
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    
    // Fetch user's posts after the specified post (if nil, fetch from the start) (for pagination)
    // should fetch for a certain amount of item (don't fetch all at once)
    // - delegate callback version
    func fetchUserPosts(for userID: String, startAfter offsetItem: Post?) {
        self.fetchUserPosts(for: userID, startAfter: offsetItem) { (snapshot) in
            // Parse items
            let items = Post.Load(snapshot: snapshot)
            let hasMore = (items.count < FIREBASE_QUERY_LIMIT ? false : true)
            // Notify delegate
            self.delegate?.onUserItemsFetchCompleted(userID: userID, items: items, startAfter: offsetItem, hasMore: hasMore, error: nil)
        } withCancel: { (error) in
            debugPrint("Error: \(error.localizedDescription)")
            // Notify delegate
            self.delegate?.onUserItemsFetchCompleted(userID: userID, items: [], startAfter: offsetItem, hasMore: false, error: error)
        }
    }
    // - completion block version
    func fetchUserPosts(for userID: String, startAfter offsetItem: Post?, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        // There is no sort option in Firebase Realtime DB (only sort in ascending order)
        // and we cannot query on 2+ fields with Firebase, so we have to query on key instead
        // which is in this format "USERID_TIME"
        let ref = self.itemDBRef?.queryOrderedByKey().queryStarting(atValue: "\(userID)_0").queryEnding(atValue: "\(userID)_\((offsetItem?.time ?? Int(Date.timeIntervalSinceReferenceDate))-1)").queryLimited(toLast: UInt(FIREBASE_QUERY_LIMIT))
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    
    // Update specific post with new data
    // - delegate callback version
    func updatePost(_ item: Post, updatedText text: String) {
        self.updatePost(item, updatedText: text) { (error, ref) in
            // Fetch this post again to update cache data
            self.fetchPost(item)
        }
    }
    // - completion block version
    func updatePost(_ item: Post, updatedText text: String, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        // Update post
        self.itemDBRef?.child(item.key).updateChildValues(["text": text], withCompletionBlock: block)
    }
    
    
    // MARK: - User DB Functions
    // Create new user for this user object (in case of auth system and db system may be from difference service)
    // - delegate callback version
    func createUser(_ user: User) {
        self.createUser(user) { (error, ref) in
            // Fetch this user again to update cache data
            self.fetchUser(fromUserID: user.uid)
        }
    }
    // - completion block version
    func createUser(_ user: User, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        let userRef = self.userDBRef?.child(user.uid)
        userRef?.setValue(user.toAnyObject(), withCompletionBlock: block)
    }
    
    
    // Fetch user info for this userID
    // - delegate callback version
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
    // - completion block version
    func fetchUser(fromUserID userID: String, withCompletion block: @escaping (DataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        let ref = self.userDBRef?.child(userID)
        ref?.observeSingleEvent(of: .value, with: block, withCancel: cancelBlock)
    }
    
    
    // Update specific user with new data
    // - delegate callback version
    func updateUser(_ user: User, updatedDisplayName: String) {
        self.updateUser(user, updatedDisplayName: updatedDisplayName) { (error, ref) in
            // Fetch this user again to update cache data
            self.fetchUser(fromUserID: user.uid)
        }
    }
    // - completion block version
    func updateUser(_ user: User, updatedDisplayName: String, withCompletion block: @escaping (Error?, DatabaseReference) -> Void) {
        // Update user
        self.userDBRef?.child(user.key).updateChildValues(["displayName": updatedDisplayName], withCompletionBlock: block)
    }
}
