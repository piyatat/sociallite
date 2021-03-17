//
//  AuthProtocol.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation

protocol AuthManagerDelegate {
    func onAuthStatusUpdated()
    func onSignInCompleted(email: String, error: Error?)
    func onSignOutCompleted(email: String?, error: Error?)
    func onSignUpCompleted(userID: String?, email: String, displayName: String, error: Error?)
}

protocol AuthManagerProtocol {
    
    var userID: String? { get set }
    var delegate: AuthManagerDelegate? { get set }
    
    func config()
    func signIn(email: String, password: String)
    func signOut()
    func signUp(email: String, password: String, displayName: String)
}
