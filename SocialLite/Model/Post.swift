//
//  Post.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation

struct Post {
    let key: String
    let text: String
    let time: Int
    let uid: String
    
    func toAnyObject() -> Any {
        return [
            "text": self.text,
            "time": self.time,
            "uid": self.uid
        ]
    }
}
