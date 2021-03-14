//
//  AuthProtocol.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation

protocol AuthManagerDelegate {
    func onAuthStatusUpdated()
}

protocol AuthManagerProtocol {
    
    var delegate: AuthManagerDelegate? { get set }
    
    func config()
    func signIn(email: String, password: String)
    func signOut()
    func signUp(email: String, password: String)
}
