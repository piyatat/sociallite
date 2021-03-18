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
    @Published var hasMoreUserPost = false
    
    // Error object for each event, should clean it up once consumed/read
    @Published var signInError: Error?
    @Published var signOutError: Error?
    @Published var signUpError: Error?
    
    @Published var itemCreatedError: Error?
    @Published var itemFetchError: Error?
    @Published var itemsFetchError: Error?
    @Published var itemRemovedError: Error?
    @Published var userItemsFetchError: Error?
    @Published var userFetchError: Error?
    
    public var authManager: AuthManagerProtocol?
    public var dbManager: DBManagerProtocol?
    
    // Flag to check whether there is fetch require at least one
    private var isFirstFetchDone = false
    
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
            
            // Fetch items
            self.dbManager?.fetchPosts(startAfter: nil)
        }
    }
    func onSignInCompleted(email: String, error: Error?) {
        if error == nil {
            // No error
        }
        self.signInError = error
    }
    func onSignOutCompleted(email: String?, error: Error?) {
        self.currentUserID = nil
        self.signOutError = error
    }
    func onSignUpCompleted(userID: String?, email: String, displayName: String, error: Error?) {
        if error == nil {
            // No error
            // Create this user in DB
            if let uid = userID {
                self.dbManager?.createUser(User(key: uid, uid: uid, displayName: displayName, email: email))
            }
        }
        self.signUpError = error
    }
    
    
    // MARK: - DBManagerDelegate
    // New item is added into DB
    func onItemCreated(item: Post?, error: Error?) {
        if self.isFirstFetchDone {
            // Only update state when the first fetch is finished
            if let item = item, item.uid == self.currentUserID {
                // If this is post created by current user, insert into top of cached items
                self.items = [item] + self.items
                // Also update cached items of current user
                if let uid = self.currentUserID, let items = self.userItems[uid] {
                    self.userItems[uid] = [item] + items
                }
                // No need to update state in this case
                self.hasNewPost = false
            } else {
                // Not create by current user, update state
                self.hasNewPost = true
            }
        } else {
            self.hasNewPost = false
        }
        self.itemCreatedError = error
    }
    // Single item fetch
    func onItemFetchCompleted(item: Post?, error: Error?) {
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
        self.itemFetchError = error
    }
    // Multiple items fetch (start after specified post, nil for start from the beginning)
    func onItemsFetchCompleted(items: [Post], startAfter offsetItem: Post?, error: Error?) {
        // Update first fetch flag
        self.isFirstFetchDone = true
        if items.count > 0 {
            // if there is item in the list, it is possible to have more
            self.hasMorePost = true
        } else {
            self.hasMorePost = false
        }
        if let _ = offsetItem {
            // Fetch more items, append items to the list
            self.items += items
        } else {
            // Fetch from start, replace list with items
            self.items = items
        }
        self.itemsFetchError = error
    }
    // Item is removed from DB (only call on remove request from the current session)
    func onItemRemoved(removedItem: Post?, error: Error?) {
        // Remove item from the list (if exist)
        if let item = removedItem {
            let size = self.items.count
            for i in 0..<size {
                if self.items[i].key == item.key {
                    self.items.remove(at: i)
                    break
                }
            }
            // Remove item from user's list as well (if they are cached)
            if let userItems = self.userItems[item.uid] {
                var items = userItems
                let size = items.count
                for i in 0..<size {
                    if items[i].key == item.key {
                        items.remove(at: i)
                        // Update cache
                        self.userItems[item.uid] = items
                        break
                    }
                }
            }
        }
        self.itemRemovedError = error
    }
    // Multiple user's items fetch (start after specified post, nil for start from the beginning)
    func onUserItemsFetchCompleted(userID: String, items: [Post], startAfter offsetItem: Post?, error: Error?) {
        if items.count > 0 {
            // if there is item in the list, it is possible to have more
            self.hasMoreUserPost = true
        } else {
            self.hasMoreUserPost = false
        }
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
        self.userItemsFetchError = error
    }
    
    // User Info fetch
    func onUserFetchCompleted(user: User?, error: Error?) {
        if let user = user {
            self.userDict[user.uid] = user
        }
        self.userFetchError = error
    }
}
