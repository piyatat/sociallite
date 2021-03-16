//
//  Post+Firebase.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation
import FirebaseDatabase

extension Post {
    
    // type method to help parsing object from Firebase Database
    static func Load(snapshot: DataSnapshot) -> [Post] {
        var items = [Post]()
        if snapshot.key == "Posts" {
            // Multiple items
            for child in snapshot.children {
                if let itemSnapshot = child as? DataSnapshot,
                   let item = Post(snapshot: itemSnapshot)
                {
                    items.append(item)
                }
            }
        } else {
            // Single item
            if let item = Post(snapshot: snapshot) {
                items.append(item)
            }
        }
        return items.reversed()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: AnyObject],
              let text = value["text"] as? String,
              let time = value["time"] as? Int,
              let uid = value["uid"] as? String
        else {
            return nil
        }
        
        self.key = snapshot.key
        self.text = text
        self.time = time
        self.uid = uid
    }
}
