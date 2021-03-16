//
//  User+Firebase.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation
import FirebaseDatabase

extension User {
    
    // type method to help parsing object from Firebase Database
    static func Load(snapshot: DataSnapshot) -> [User] {
        var items = [User]()
        if snapshot.key == "Users" {
            // Multiple items
            for child in snapshot.children {
                if let itemSnapshot = child as? DataSnapshot,
                   let item = User(snapshot: itemSnapshot)
                {
                    items.append(item)
                }
            }
        } else {
            // Single item
            if let item = User(snapshot: snapshot) {
                items.append(item)
            }
        }
        return items.reversed()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: AnyObject],
              let uid = value["uid"] as? String,
              let displayName = value["displayName"] as? String,
              let email = value["email"] as? String
        else {
            return nil
        }
        
        self.key = snapshot.key
        self.uid = uid
        self.displayName = displayName
        self.email = email
    }
}
