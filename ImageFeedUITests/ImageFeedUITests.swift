import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        sleep(5)
        
        let loginTextField = app/*@START_MENU_TOKEN@*/.textFields["Email address"]/*[[".otherElements.textFields[\"Email address\"]",".textFields",".textFields[\"Email address\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        let hideKeyboard = app/*@START_MENU_TOKEN@*/.buttons["selected"]/*[[".otherElements.buttons[\"selected\"]",".buttons[\"selected\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        loginTextField.tap()
        loginTextField.typeText("*****")
        hideKeyboard.tap()
        
        let passwordTextField = app/*@START_MENU_TOKEN@*/.secureTextFields["Password"]/*[[".otherElements.secureTextFields[\"Password\"]",".secureTextFields",".secureTextFields[\"Password\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        passwordTextField.tap()
        passwordTextField.typeText("*****")
        hideKeyboard.tap()
        
        app/*@START_MENU_TOKEN@*/.buttons["Login"]/*[[".otherElements.buttons[\"Login\"]",".buttons",".buttons[\"Login\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)

        let buttonsQuery = app.buttons
        
        buttonsQuery.matching(identifier: "like button no active").element(boundBy: 0).tap()
        buttonsQuery.matching(identifier: "like button active").element(boundBy: 0).tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        
        app/*@START_MENU_TOKEN@*/.buttons["backward button"]/*[[".otherElements.buttons[\"backward button\"]",".buttons[\"backward button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        app.buttons["logout button"].firstMatch.tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}

