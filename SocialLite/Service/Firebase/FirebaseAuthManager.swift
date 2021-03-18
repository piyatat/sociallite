//
//  FirebaseAuthManager.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation
import FirebaseAuth

// There is completion block version for each functions
// to make it easier for testing

// The delegate callback version will call completion block version
// and call delegate in the completion block

class FirebaseAuthManager: AuthManagerProtocol {
    // For storing auth listener (which listen to auth chagne event)
    private var authHandler: AuthStateDidChangeListenerHandle?
    // Firebase user object of the current login user
    private var user: UserInfo?
    
    // userID of the login user, should be nil if there is no user login
    public var userID: String?
    public var delegate: AuthManagerDelegate?
    
    deinit {
        if let handler = self.authHandler {
            // Remove listener
            Auth.auth().removeStateDidChangeListener(handler)
        }
        self.authHandler = nil
        self.user = nil
        self.userID = nil
        self.delegate = nil
    }
    
    // MARK: - Setup Function
    // This is the designated function for setting up the instance
    // should be called before any other functions
    func config() {
        // Listen to auth state change event
        self.authHandler = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
            self.userID = self.user?.uid
            // Notify delegate
            self.delegate?.onAuthStatusUpdated()
        }
    }
    
    // MARK: - Auth Functions
    // Sign-in with email & password
    // - delegate callback version
    func signIn(email: String, password: String) {
        self.signIn(email: email, password: password) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            // Notify delegate
            self.delegate?.onSignInCompleted(email: email, error: error)
            if let user = result?.user {
                if user.uid == self.user?.uid {
                    // Re-login with the same user, Firebase won't fire auth change event
                    self.userID = user.uid
                    // Notify delegate
                    self.delegate?.onAuthStatusUpdated()
                } else {
                    // Login with difference user (difference from prevous session)
                    // Firebase will fire auth change event
                    // No need to notify delegate from this block
                }
            }
        }
    }
    // - completion block version
    func signIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    
    // Sign-out for the current login user
    // - delegate callback version
    func signOut() {
        self.signOut { (email, error) in
            // Notify delegate
            self.delegate?.onSignOutCompleted(email: email, error: error)
        }
    }
    // - completion block version
    func signOut(handler: @escaping ((String?, Error?) -> Void)) {
        let email = self.user?.email
        var error: Error?
        do {
            try Auth.auth().signOut()
            // Clear userID, but not clear user object (need to use it for checking when re-login later)
            // Since if re-login with the same user, Firebase won't fire auth change event
            // Need to notify delegate manually
            self.userID = nil
        } catch let e {
            debugPrint("Error: \(e.localizedDescription)")
            error = e
        }
        handler(email, error)
    }
    
    
    // Sign-up with email & password & displayName
    // - delegate callback version
    func signUp(email: String, password: String, displayName: String) {
        self.signUp(email: email, password: password, displayName: displayName) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            // Notify delegate
            self.delegate?.onSignUpCompleted(userID: result?.user.uid, email: email, displayName: displayName, error: error)
        }
    }
    // - completion block version
    func signUp(email: String, password: String, displayName: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }
}
