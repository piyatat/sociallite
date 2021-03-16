//
//  FirebaseAuthManager.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import Foundation
import FirebaseAuth

class FirebaseAuthManager: AuthManagerProtocol {
    
    var authHandler: AuthStateDidChangeListenerHandle?
    
    public var user: UserInfo?
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
    func config() {
        // Listen to Auth State change
        self.authHandler = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
            self.userID = self.user?.uid
            // Notify delegate
            self.delegate?.onAuthStatusUpdated()
        }
    }
    
    // MARK: - Auth Functions
    func signIn(email: String, password: String) {
        self.signIn(email: email, password: password) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    func signIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.userID = nil
        } catch {
            // TODO: handle this case
            debugPrint("Error: \(error.localizedDescription)")
        }
    }
    
    func signUp(email: String, password: String) {
        self.signUp(email: email, password: password) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    func signUp(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }
}
