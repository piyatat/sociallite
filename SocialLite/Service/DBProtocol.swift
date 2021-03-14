//
//  DBProtocol.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation

protocol DBManagerDelegate {
    // New item is added into DB
    func onItemCreated(item: Post?)
    // Single item fetch
    func onItemFetchCompleted(item: Post?)
    // Multiple items fetch (start after specified post, nil for start from the beginning)
    func onItemsFetchCompleted(items: [Post], startAfter offsetItem: Post?)
    // Item is removed from DB (only call on remove request from the current session)
    func onItemRemoved(removedItem: Post?)
    
    // User Info fetch
    func onUserFetchCompleted(user: User?)
}

protocol DBManagerProtocol {
    
    var delegate: DBManagerDelegate? { get set }
    
    func config()
    
    // Post DB related functions
    func createPost(_ text: String, user: User)
    func deletePost(_ item: Post)
    func fetchPosts(startAfter offsetItem: Post?)
    func fetchPost(_ item: Post)
    func fetchUserPosts(for userID: String, startAfter offsetItem: Post?)
    func updatePost(_ item: Post, updatedText text: String)
    
    // User DB related functions
    func createUser(_ user: User)
    func fetchUser(fromUserID userID: String)
    func updateUser(_ user: User, updatedDisplayName: String)
}
