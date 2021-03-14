//
//  User.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation

struct User {
    let key: String
    let uid: String
    let displayName: String
    let email: String
    
    func toAnyObject() -> Any {
        return [
            "uid": self.uid,
            "displayName": self.displayName,
            "email": self.email
        ]
    }
}
