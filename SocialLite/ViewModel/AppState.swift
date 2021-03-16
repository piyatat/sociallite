//
//  AppState.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation

class AppState: ObservableObject, AuthManagerDelegate, DBManagerDelegate {
    
    // Cache posts
    @Published var items = [Post]()
    // Cache posts by userID
    @Published var userItems = [String: [Post]]()
    // Cache User object [userID: User]
    @Published var userDict = [String: User]()
    
    // Current Sign in user
    @Published var currentUserID: String?
    
    @Published var hasNewPost = false
    @Published var hasMorePost = false
    
    public var authManager: AuthManagerProtocol?
    public var dbManager: DBManagerProtocol?
    
    // MARK: - Config
    func config(auth: AuthManagerProtocol, db: DBManagerProtocol) {
        self.authManager = auth
        self.dbManager = db
        
        self.authManager?.delegate = self
        self.dbManager?.delegate = self
    }
    
    // MARK: - Helper Function
    func getUser(_ userID: String) -> User? {
        if let user = self.userDict[userID] {
            // Already cached, return cache
            return user
        } else {
            // No cache, fetch from service, return nil for now
            self.dbManager?.fetchUser(fromUserID: userID)
            return nil
        }
    }
    
    // MARK: - AuthManagerDelegate
    func onAuthStatusUpdated() {
        self.currentUserID = self.authManager?.userID
        if let userID = self.currentUserID {
            // Cache current user info
            let _ = self.getUser(userID)
        }
    }
    
    // MARK: - DBManagerDelegate
    // New item is added into DB
    func onItemCreated(item: Post?) {
        self.hasNewPost = true
    }
    // Single item fetch
    func onItemFetchCompleted(item: Post?) {
        // Replace current item with the updated one
        if let item = item {
            let size = self.items.count
            for i in 0..<size {
                if self.items[i].key == item.key {
                    self.items[i] = item
                    break
                }
            }
        }
    }
    // Multiple items fetch (start after specified post, nil for start from the beginning)
    func onItemsFetchCompleted(items: [Post], startAfter offsetItem: Post?) {
        if let _ = offsetItem {
            // Fetch more items, append items to the list
            self.items += items
        } else {
            // Fetch from start, replace list with items
            self.items = items
        }
    }
    // Item is removed from DB (only call on remove request from the current session)
    func onItemRemoved(removedItem: Post?) {
        // Remove item from the list (if exist)
        if let item = removedItem {
            let size = self.items.count
            for i in 0..<size {
                if self.items[i].key == item.key {
                    self.items.remove(at: i)
                    break
                }
            }
        }
    }
    // Multiple user's items fetch (start after specified post, nil for start from the beginning)
    func onUserItemsFetchCompleted(userID: String, items: [Post], startAfter offsetItem: Post?) {
        if let _ = offsetItem {
            // Fetch more items, append items to the list
            if let currentItems = self.userItems[userID] {
                // Found the list (cache)
                self.userItems[userID] = currentItems + items
            } else {
                // No cache
                self.userItems[userID] = items
            }
        } else {
            // Fetch from start, replace list with items
            self.userItems[userID] = items
        }
    }
    
    // User Info fetch
    func onUserFetchCompleted(user: User?) {
        if let user = user {
            self.userDict[user.uid] = user
        }
    }
}
