//
//  SocialLiteUITests.swift
//  SocialLiteUITests
//
//  Created by Tei on 14/3/21.
//

import XCTest

class SocialLiteUITests: XCTestCase {
    
    static var app = XCUIApplication()
    
    override class func setUp() {
        // Pass launch param to setup App in testing mode
        SocialLiteUITests.app.launchArguments.append("UITesting")
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSignIn_WrongPassword_Fail() throws {
        let app = SocialLiteUITests.app
        app.launch()

        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("DemoUser@toremove.com")

        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("WrongPassword")

        let returnButton = app.buttons["Return"]
        returnButton.tap()

        let signInButton = app.buttons["Sign In"]
        signInButton.tap()

        let elementsQuery = app.alerts["Error"].scrollViews.otherElements
        elementsQuery.buttons["OK"].tap()
    }

    func testSignIn_Success() throws {
        let app = SocialLiteUITests.app
        app.launch()

        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("DemoUser@toremove.com")

        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("MockupPassword")

        let returnButton = app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        returnButton.tap()

        let signInButton = app.buttons["Sign In"]
        signInButton.tap()
    }

    func testSignUp_DuplicatedEmail_Fail() throws {
        let app = SocialLiteUITests.app
        app.launch()

        let signUpButton = app.buttons["Sign Up"]
        signUpButton.tap()

        let enterEmailAddressTextField = app.textFields["Enter Email Address"]
        enterEmailAddressTextField.tap()
        enterEmailAddressTextField.typeText("DemoUser@toremove.com")

        let enterDisplayNameTextField = app.textFields["Enter Display Name"]
        enterDisplayNameTextField.tap()
        enterDisplayNameTextField.typeText("Tester")

        let enterPasswordSecureTextField = app.secureTextFields["Enter Password"]
        enterPasswordSecureTextField.tap()
        enterPasswordSecureTextField.typeText("Password")

        let returnButton = app.buttons["Return"]
        returnButton.tap()

        let createAccountButton = app.buttons["Create Account"]
        createAccountButton.tap()

        let elementsQuery = app.alerts["Error"].scrollViews.otherElements
        elementsQuery.buttons["OK"].tap()
    }

    func testSignUp_Success() throws {
        let app = SocialLiteUITests.app
        app.launch()

        let signUpButton = app.buttons["Sign Up"]
        signUpButton.tap()

        let enterEmailAddressTextField = app.textFields["Enter Email Address"]
        enterEmailAddressTextField.tap()
        enterEmailAddressTextField.typeText("Test@test.com")

        let enterDisplayNameTextField = app.textFields["Enter Display Name"]
        enterDisplayNameTextField.tap()
        enterDisplayNameTextField.typeText("Tester")

        let enterPasswordSecureTextField = app.secureTextFields["Enter Password"]
        enterPasswordSecureTextField.tap()
        enterPasswordSecureTextField.typeText("Password")

        let returnButton = app.buttons["Return"]
        returnButton.tap()

        let createAccountButton = app.buttons["Create Account"]
        createAccountButton.tap()

        app.navigationBars["Timeline"].buttons["Logout"].tap()
    }

    func testTimeLine_CreatePost() throws {
        let app = SocialLiteUITests.app
        app.launch()
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("DemoUser@toremove.com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("MockupPassword")
        
        let returnButton = app.buttons["Return"]
        returnButton.tap()
        
        let signInButton = app.buttons["Sign In"]
        signInButton.tap()
        
        app.navigationBars["Timeline"].buttons["rectangle.badge.plus"].tap()
        
        // There is no function to query TextEditor at the moment, have to query it with textViews instead
        let textView = app.textViews.firstMatch
        textView.tap()
        
        // Cannot typeText() into textView at the moment
        // have to simulate typing each key in keyboard
        app.keys["T"].tap()
        app.keys["e"].tap()
        app.keys["s"].tap()
        app.keys["t"].tap()
        app.keys["space"].tap()
        app.keys["n"].tap()
        app.keys["e"].tap()
        app.keys["w"].tap()
        app.keys["space"].tap()
        app.keys["p"].tap()
        app.keys["o"].tap()
        app.keys["s"].tap()
        app.keys["t"].tap()
        app.buttons["Post"].tap()
    }
    
    func testTimeLine_DeletePost() throws {
        let app = SocialLiteUITests.app
        app.launch()

        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("DemoUser@toremove.com")

        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("MockupPassword")

        let returnButton = app.buttons["Return"]
        returnButton.tap()

        let signInButton = app.buttons["Sign In"]
        signInButton.tap()

        let ellipsisButton = app.scrollViews.otherElements.containing(.activityIndicator, identifier:"Progress halted").children(matching: .other).element.children(matching: .button).matching(identifier: "ellipsis").element(boundBy: 0)
        ellipsisButton.tap()
        let removeThisPostButton = app.sheets["Post Options"].scrollViews.otherElements.buttons["Remove this post"]
        removeThisPostButton.tap()
        ellipsisButton.tap()
        removeThisPostButton.tap()
    }

    func testTimeLine_LoadMore() throws {
        let app = SocialLiteUITests.app
        app.launch()

        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("DemoUser@toremove.com")

        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("MockupPassword")

        let returnButton = app.buttons["Return"]
        returnButton.tap()

        let signInButton = app.buttons["Sign In"]
        signInButton.tap()

        let scrollViewsQuery = app.scrollViews
        let element = scrollViewsQuery.otherElements.containing(.activityIndicator, identifier:"Progress halted").children(matching: .other).element
        element.swipeUp()
        element.swipeUp()

        let loadMoreButton = scrollViewsQuery.otherElements.buttons["Load More ..."]
        loadMoreButton.tap()

        element.swipeUp()
    }

    func testUserTimeLine_LoadMore() throws {
        let app = SocialLiteUITests.app
        app.launch()

        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("DemoUser@toremove.com")

        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("MockupPassword")

        let returnButton = app.buttons["Return"]
        returnButton.tap()

        let signInButton = app.buttons["Sign In"]
        signInButton.tap()

        let scrollViewsQuery = app.scrollViews
        let element = scrollViewsQuery.otherElements.containing(.activityIndicator, identifier:"Progress halted").children(matching: .other).element
        element.children(matching: .button).matching(identifier: "DemoUser@toremove.com, DemoUser@toremove.com").firstMatch.tap()

        element.swipeUp()
        element.swipeUp()

        let loadMoreButton = scrollViewsQuery.otherElements.buttons["Load More ..."]
        loadMoreButton.tap()

        app.navigationBars["DemoUser@toremove.com"].buttons["Timeline"].tap()
    }
}
