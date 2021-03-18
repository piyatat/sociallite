//
//  AuthProtocol.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation

protocol AuthManagerDelegate {
    // This function should be called when there is changed in auth status (sign-in, sign-out)
    func onAuthStatusUpdated()
    // This function should be called after sign-in is done (regardless of success of not)
    func onSignInCompleted(email: String, error: Error?)
    // This function should be called after sign-out is done (regardless of success of not)
    func onSignOutCompleted(email: String?, error: Error?)
    // This function should be called after sign-up is done (regardless of success of not)
    // If success, should provide userID
    func onSignUpCompleted(userID: String?, email: String, displayName: String, error: Error?)
}

protocol AuthManagerProtocol {
    // userID of the login user, should be nil if there is no user login
    var userID: String? { get set }
    var delegate: AuthManagerDelegate? { get set }
    
    // This is the designated function for setting up the instance
    // should be called before any other functions
    func config()
    // Sign-in with email & password
    func signIn(email: String, password: String)
    // Sign-out for the current login user
    func signOut()
    // Sign-up with email & password & displayName
    func signUp(email: String, password: String, displayName: String)
}
