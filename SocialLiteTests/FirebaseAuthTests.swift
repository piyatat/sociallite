//
//  FirebaseAuthTests.swift
//  SocialLiteTests
//
//  Created by Tei on 14/3/21.
//

import XCTest
@testable import SocialLite_Dev

class FirebaseAuthTests: XCTestCase {
    
    // ******************************
    // TODO: Change these info before running the test
    // ******************************
    // Chagne this to the actual email/password for testing
    static let testEmail = "DemoUser@toremove.com"
    static let testPassword = "MockupPassword"
    
    static let authManager = FirebaseAuthManager()
    
    override class func setUp() {
        // Sign out (in case there is still sign session)
        
    }
    
    override class func tearDown() {
        
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - SignUp Function
    // SignUp with email & password
    func testSignUp_CompleteData_Success() throws {
        let email = "ToRemove_\(Int(Date.timeIntervalSinceReferenceDate))@toremove.com"
        let password = "ToRemove_Password"
        let displayName = "Unit Tester"

        let expectation = XCTestExpectation()
        FirebaseAuthTests.authManager.signUp(email: email, password: password, displayName: displayName) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let _ = result?.user {
                // sign up success
                debugPrint(result as Any)
            }
            // result should contain user object
            XCTAssertNotNil(result?.user)
            // Need to sign out since successful sign up will automatically sign in
            FirebaseAuthTests.authManager.signOut()
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 10)
    }
    // SignUp with no email & password
    func testSignUp_NoEmail_Fail() throws {
        let expectation = XCTestExpectation()
        FirebaseAuthTests.authManager.signUp(email: "", password: "", displayName: "") { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let _ = result?.user {
                // sign up success
                debugPrint(result as Any)
            }
            // result should NOT contain user object
            XCTAssertNil(result?.user)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 10)
    }
    // SignUp with email, but no password
    func testSignUp_NoPassword_Fail() throws {
        // to prevent the same email as other test case
        let email = "ToRemove_\(Int(Date.timeIntervalSinceReferenceDate))@toremove.com"
        let displayName = "Unit Tester"

        let expectation = XCTestExpectation()
        FirebaseAuthTests.authManager.signUp(email: email, password: "", displayName: displayName) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let _ = result?.user {
                // sign up success
                debugPrint(result as Any)
            }
            // result should NOT contain user object
            XCTAssertNil(result?.user)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 10)
    }

    // MARK: - SignIn Function
    // SignIn with email & password
    func testSignIn_CompleteData_Success() throws {
        let expectation = XCTestExpectation()
        FirebaseAuthTests.authManager.signIn(email: FirebaseAuthTests.testEmail, password: FirebaseAuthTests.testPassword) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let _ = result?.user {
                // sign in success
                debugPrint(result as Any)
            }
            // result should contain user object
            XCTAssertNotNil(result?.user)
            // Need to sign out
            FirebaseAuthTests.authManager.signOut()
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 10)
    }
    // Signin with incorrect email
    func testSignIn_InCorrectEmail_Fail() throws {
        let email = "NotExist_Email@toremove.com"
        let password = "Password"

        let expectation = XCTestExpectation()
        FirebaseAuthTests.authManager.signIn(email: email, password: password) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let _ = result?.user {
                // sign in success
                debugPrint(result as Any)
            }
            // result should NOT contain user object
            XCTAssertNil(result?.user)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 10)
    }
    // Signin with incorrect password
    func testSignIn_InCorrectPassword_Fail() throws {
        let password = "WrongPassword"

        let expectation = XCTestExpectation()
        FirebaseAuthTests.authManager.signIn(email: FirebaseAuthTests.testEmail, password: password) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let _ = result?.user {
                // sign in success
                debugPrint(result as Any)
            }
            // result should NOT contain user object
            XCTAssertNil(result?.user)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 10)
    }

}
