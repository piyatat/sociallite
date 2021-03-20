//
//  DummyAuthManager.swift
//  SocialLite_Dev
//
//  Created by Tei on 19/3/21.
//

import Foundation

// Dummy Ojbect for using in UI Testing
class DummyAuthManager: AuthManagerProtocol {
    
    // user auth dict [Email: Password]
    private var userDict = ["DemoUser@toremove.com": "MockupPassword"]
    
    // userID of the login user, should be nil if there is no user login
    // userID will be the same as email
    public var userID: String?
    public var delegate: AuthManagerDelegate?
    
    
    // MARK: - Setup Function
    // This is the designated function for setting up the instance
    // should be called before any other functions
    func config() {
        
    }
    
    // MARK: - Auth Functions
    // Sign-in with email & password
    func signIn(email: String, password: String) {
        if let userPassword = self.userDict[email], userPassword == password {
            self.userID = email
            self.delegate?.onSignInCompleted(email: email, error: nil)
            self.delegate?.onAuthStatusUpdated()
        } else {
            self.delegate?.onSignInCompleted(email: email, error: NSError(domain: "com.pc", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sign In Error"]))
        }
    }
    // Sign-out for the current login user
    func signOut() {
        let email = self.userID
        self.userID = nil
        self.delegate?.onSignOutCompleted(email: email, error: nil)
        self.delegate?.onAuthStatusUpdated()
    }
    // Sign-up with email & password & displayName
    func signUp(email: String, password: String, displayName: String) {
        if let _ = userDict[email] {
            // duplicated email
            self.delegate?.onSignUpCompleted(userID: nil, email: email, displayName: displayName, error: NSError(domain: "com.pc", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sign Up Error"]))
        } else {
            self.userDict[email] = password
            self.delegate?.onSignUpCompleted(userID: email, email: email, displayName: displayName, error: nil)
            
            // Sign-in
            self.signIn(email: email, password: password)
        }
    }
}
