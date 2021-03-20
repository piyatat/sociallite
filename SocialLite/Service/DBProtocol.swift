//
//  DBProtocol.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation

protocol DBManagerDelegate {
    // New item is added into DB
    func onItemCreated(item: Post?, error: Error?)
    // Single item fetch
    func onItemFetchCompleted(item: Post?, error: Error?)
    // Multiple items fetch (start after specified post, nil for start from the beginning)
    func onItemsFetchCompleted(items: [Post], startAfter offsetItem: Post?, hasMore: Bool, error: Error?)
    // Item is removed from DB (only call on remove request from the current session)
    func onItemRemoved(removedItem: Post?, error: Error?)
    // Multiple user's items fetch (start after specified post, nil for start from the beginning)
    func onUserItemsFetchCompleted(userID: String, items: [Post], startAfter offsetItem: Post?, hasMore: Bool, error: Error?)
    
    // User Info fetch
    func onUserFetchCompleted(user: User?, error: Error?)
}

protocol DBManagerProtocol {
    
    var delegate: DBManagerDelegate? { get set }
    
    // This is the designated function for setting up the instance
    // should be called before any other functions
    func config()
    
    // MARK: - Post DB related functions
    // Create new post for this userID
    func createPost(_ text: String, userID: String)
    // Delete post
    func deletePost(_ item: Post)
    // Fetch posts after the specified post (if nil, fetch from the start) (for pagination)
    // should fetch for a certain amount of item (don't fetch all at once)
    func fetchPosts(startAfter offsetItem: Post?)
    // Fetch specific post (in case of there is an update for this post)
    func fetchPost(_ item: Post)
    // Fetch user's posts after the specified post (if nil, fetch from the start) (for pagination)
    // should fetch for a certain amount of item (don't fetch all at once)
    func fetchUserPosts(for userID: String, startAfter offsetItem: Post?)
    // Update specific post with new data
    func updatePost(_ item: Post, updatedText text: String)
    
    // MARK: - User DB related functions
    // Create new user for this user object (in case of auth system and db system may be from difference service)
    func createUser(_ user: User)
    // Fetch user info for this userID
    func fetchUser(fromUserID userID: String)
    // Update specific user with new data
    func updateUser(_ user: User, updatedDisplayName: String)
}
