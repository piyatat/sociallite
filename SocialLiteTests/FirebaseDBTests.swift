//
//  FIrebaseDBTests.swift
//  SocialLiteTests
//
//  Created by Tei on 14/3/21.
//

import XCTest
@testable import SocialLite_Dev

class FirebaseDBTests: XCTestCase {

    // ******************************
    // TODO: Change these info before running the test
    // ******************************
    // Chagne this to the actual email/password for testing
    static let testEmail = "DemoUser@toremove.com"
    static let testPassword = "MockupPassword"
    // Change this to the actual ID (key) for testing fetch
    // userID should be user with post (for testing fetching user's post)
    static let userID = "lZ9cZuvgG1fjN91ExnQDKJq0Ua93"
    static let postID = "lZ9cZuvgG1fjN91ExnQDKJq0Ua93_637943549"
    
    static let authManager = FirebaseAuthManager()
    static let dbManager = FirebaseDBManager()
    
    override class func setUp() {
        FirebaseDBTests.dbManager.config()
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Post
    func testCreateAndDeletePost_Success() throws {
        let expectation = XCTestExpectation()

        // To ensure that session is active
        FirebaseDBTests.authManager.signIn(email: FirebaseDBTests.testEmail, password: FirebaseDBTests.testPassword) { (result, error) in
            let post = Post(key: "MOCKUP_KEY_FOR_DELETING_TEST", text: "To Remove Post", time: Int(Date.timeIntervalSinceReferenceDate), uid: "MOCKUP_KEY_FOR_DELETING_TEST")
            // Create Post
            FirebaseDBTests.dbManager.updatePost(post, updatedText: "To Remove") { (error, ref) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                XCTAssertNil(error)
                // Delete Post
                FirebaseDBTests.dbManager.deletePost(post) { (error, ref) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    }
                    XCTAssertNil(error)
                    expectation.fulfill()
                }
            }
        }

        self.wait(for: [expectation], timeout: 10)
    }
    
    func testFetchPosts_FromStart_Success() throws {
        let expectation = XCTestExpectation()

        // To ensure that session is active
        FirebaseDBTests.authManager.signIn(email: FirebaseDBTests.testEmail, password: FirebaseDBTests.testPassword) { (result, error) in
            FirebaseDBTests.dbManager.fetchPosts(startAfter: nil) { (snapshot) in
                XCTAssert(snapshot.hasChildren())
                expectation.fulfill()
            } withCancel: { (error) in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testFetchPost_FromPostID_Success() throws {
        let post = Post(key: FirebaseDBTests.postID, text: "", time: 0, uid: "")
        let expectation = XCTestExpectation()

        // To ensure that session is active
        FirebaseDBTests.authManager.signIn(email: FirebaseDBTests.testEmail, password: FirebaseDBTests.testPassword) { (result, error) in
            FirebaseDBTests.dbManager.fetchPost(post) { (snapshot) in
                let items = Post.Load(snapshot: snapshot)
                XCTAssertGreaterThan(items.count, 0)
                if items.count > 0 {
                    XCTAssertEqual(items[0].key, FirebaseDBTests.postID)
                }
                expectation.fulfill()
            } withCancel: { (error) in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testFetchUserPosts_FromStart_Success() throws {
        let expectation = XCTestExpectation()

        // To ensure that session is active
        FirebaseDBTests.authManager.signIn(email: FirebaseDBTests.testEmail, password: FirebaseDBTests.testPassword) { (result, error) in
            FirebaseDBTests.dbManager.fetchUserPosts(for: FirebaseDBTests.userID, startAfter: nil) { (snapshot) in
                debugPrint("UserPosts: ", snapshot)
                let posts = Post.Load(snapshot: snapshot)
                for post in posts {
                    XCTAssertEqual(post.uid, FirebaseDBTests.userID)
                }
                XCTAssert(snapshot.hasChildren())
                expectation.fulfill()
            } withCancel: { (error) in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testUpdatePost_Success() throws {
        let post = Post(key: FirebaseDBTests.postID, text: "", time: 0, uid: "")
        let expectation = XCTestExpectation()
        
        // To ensure that session is active
        FirebaseDBTests.authManager.signIn(email: FirebaseDBTests.testEmail, password: FirebaseDBTests.testPassword) { (result, error) in
            FirebaseDBTests.dbManager.updatePost(post, updatedText: "Test Update Post with Unit Test") { (error, ref) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    
    // MARK: - User
    func testCreateUser_Success() throws {
        let user = User(key: "TO_REMOVE_USER_ID", uid: "TO_REMOVE_USER_ID", displayName: "Unit Tester", email: "ut@ut.com")
        let expectation = XCTestExpectation()
        
        // To ensure that session is active
        FirebaseDBTests.authManager.signIn(email: FirebaseDBTests.testEmail, password: FirebaseDBTests.testPassword) { (result, error) in
            FirebaseDBTests.dbManager.createUser(user) { (error, ref) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testFetchUser_Success() throws {
        let expectation = XCTestExpectation()
        
        // To ensure that session is active
        FirebaseDBTests.authManager.signIn(email: FirebaseDBTests.testEmail, password: FirebaseDBTests.testPassword) { (result, error) in
            FirebaseDBTests.dbManager.fetchUser(fromUserID: FirebaseDBTests.userID) { (snapshot) in
                let items = User.Load(snapshot: snapshot)
                XCTAssertGreaterThan(items.count, 0)
                if items.count > 0 {
                    XCTAssertEqual(items[0].key, FirebaseDBTests.userID)
                }
                expectation.fulfill()
            } withCancel: { (error) in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testUpdateUser__Success() throws {
        let user = User(key: "TO_REMOVE_USER_ID", uid: "TO_REMOVE_USER_ID", displayName: "Unit Tester", email: "ut@ut.com")
        let expectation = XCTestExpectation()
        
        // To ensure that session is active
        FirebaseDBTests.authManager.signIn(email: FirebaseDBTests.testEmail, password: FirebaseDBTests.testPassword) { (result, error) in
            FirebaseDBTests.dbManager.updateUser(user, updatedDisplayName: "New DisplayName for Unit Tester") { (error, ref) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }

}
