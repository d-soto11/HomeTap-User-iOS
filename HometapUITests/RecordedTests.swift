//
//  RecordedTests.swift
//  HometapUITests
//
//  Created by Daniel Soto on 10/17/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import XCTest

class RecordedTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin() {
        
        let app = XCUIApplication()
        app.buttons["google c b"].tap()
        let expected = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 1)
        
        waitForVisible(element: expected, timeout: 5)
        
    }
    
    func testAddressAdded() {
        
        let app = XCUIApplication()

        // Navigate to Address by tap
        let window = app.children(matching: .window).element(boundBy: 0)
        window.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0).tap()
        // For scrollable content
        let elementsQuery = app.scrollViews.otherElements

        // Add address
        let tablesQuery = app.tables
        tablesQuery.buttons["Agregar una nueva dirección"].tap()

        // Nickname
        let nicknameText = elementsQuery.textFields["Mi Casa"]
        nicknameText.tap()
        nicknameText.typeText("Automated Test House")
        // Address
        elementsQuery.textFields["Calle 100 # 7 - 0"].tap()

        // On Google Place Picker
        let searchbarNavigationBar = app.navigationBars["searchBar"]
        waitForVisible(element: app.navigationBars["searchBar"].buttons["Cancel"], timeout: 5)
        app.navigationBars["searchBar"].buttons["Cancel"].tap()
        waitForVisible(element: searchbarNavigationBar.searchFields["Search"], timeout: 5)
        searchbarNavigationBar.searchFields["Search"].typeText("Torre San Marino")
        waitForVisible(element: elementsQuery.tables.cells.element(boundBy: 2), timeout: 5)
        elementsQuery.tables.cells.element(boundBy: 2).tap()
        
        // Number
        let numberText = elementsQuery.textFields["401"]
        numberText.tap()
        numberText.typeText("3")
        // Meters
        let metersText = elementsQuery.textFields["143 m2"]
        metersText.tap()
        metersText.typeText("120")
        // Floors
        let element = app.scrollViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 3).children(matching: .other).element
        let floorsText = element.children(matching: .other).element(boundBy: 1).textFields["3"]
        floorsText.tap()
        floorsText.typeText("2")
        // Rooms
        let roomsText = elementsQuery.textFields["4"]
        roomsText.tap()
        roomsText.typeText("5")
        // Baths
        let bathroomsText = element.children(matching: .other).element(boundBy: 3).textFields["3"]
        bathroomsText.tap()
        bathroomsText.typeText("3")
        // Wifi
        let wifiText = elementsQuery.textFields["Clave WiFi"]
        wifiText.tap()
        wifiText.typeText("AutomaticWifiPassword")
        
        // Save
        app.buttons["Guardar"].tap()
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0).staticTexts["Automated Test House"]
        waitForVisible(element: cell, timeout: 10)
        
    }
    
    func testPaymentAdded() {
        
        let app = XCUIApplication()
        
        // Navigate to profile by tap
        let window = app.children(matching: .window).element(boundBy: 0)
        window.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 3).tap()
        
        // Add payment
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.buttons["Ver medios de pago"].tap()
        let tablesQuery = app.tables
        tablesQuery.buttons["Agregar un nuevo medio de pago"].tap()
        
        // Name
        let nombreCompletoTextField = elementsQuery.textFields["Nombre completo"]
        nombreCompletoTextField.tap()
        nombreCompletoTextField.typeText("Daniel Soto")
        // Number
        let numberText = elementsQuery.textFields["1234 5678 9123 4567"]
        numberText.tap()
        numberText.typeText("5306956676130183")
        // Date
        let dateText = elementsQuery.textFields["01/30"]
        dateText.tap()
        dateText.typeText("0718")
        // CVC
        let cvcText = elementsQuery.textFields["123"]
        cvcText.tap()
        cvcText.typeText("436")
        
        app.buttons["Guardar"].tap()
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0).staticTexts["MASTERCARD ***0183"]
        
        waitForVisible(element: cell, timeout: 10)
        
    }
    
    func testProfileEdit() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCUIDevice.shared.orientation = .faceUp
        
        let app = XCUIApplication()
    
        // Navigate to profile by tap
        let window = app.children(matching: .window).element(boundBy: 0)
        window.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 3).tap()
        
        // Navigate inside profile
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        
        // Change photo
        scrollViewsQuery.otherElements.containing(.staticText, identifier:"Perfil").children(matching: .button).element(boundBy: 0).tap()
        
        if app.alerts["“HomeTap” Would Like to Access the Camera"].exists {
            app.alerts["“HomeTap” Would Like to Access the Camera"].collectionViews.buttons["OK"].tap()
        }
        if app.alerts["“HomeTap” Would Like to Access Your Photos"].exists {
            app.alerts["“HomeTap” Would Like to Access Your Photos"].collectionViews.buttons["OK"].tap()
        }
        if app.alerts["Necesitamos tu permiso"].exists {
            app.alerts["Necesitamos tu permiso"].collectionViews.buttons["Listo"].tap()
        }
        
        waitForVisible(element: app.collectionViews.children(matching: .cell).matching(identifier: "Photo").element(boundBy: 0), timeout: 5)
        
        app.collectionViews.children(matching: .cell).matching(identifier: "Photo").element(boundBy: 0).tap()
        app.buttons["Listo"].tap()
        
        
        // Change name
        var nameButton = elementsQuery.buttons["Daniel Soto Rey"]
        waitForVisible(element: nameButton, timeout: 2)
        nameButton.tap()
        
        var datoTextField = app.textFields["Daniel Soto Rey"]
        datoTextField.tap()
        datoTextField.clearAndEnterText(text: "Automated Test Name")
        
        app.buttons["Guardar Cambios"].tap()
        
        waitForVisible(element: elementsQuery.buttons["Automated Test Name"], timeout: 2)
        
        // Reverse name
        nameButton = elementsQuery.buttons["Automated Test Name"]
        waitForVisible(element: nameButton, timeout: 2)
        nameButton.tap()
        
        datoTextField = app.textFields["Automated Test Name"]
        datoTextField.tap()
        datoTextField.clearAndEnterText(text: "Daniel Soto Rey")
        
        app.buttons["Guardar Cambios"].tap()
        
        waitForVisible(element: elementsQuery.buttons["Daniel Soto Rey"], timeout: 2)
        
        // Change phone
        var phoneButton = elementsQuery.buttons["3017303973"]
        waitForVisible(element: phoneButton, timeout: 2)
        phoneButton.tap()
        
        datoTextField = app.textFields["3017303973"]
        datoTextField.tap()
        datoTextField.clearAndEnterText(text: "3000000000")
        
        app.buttons["Guardar Cambios"].tap()
        
        waitForVisible(element: elementsQuery.buttons["3000000000"], timeout: 2)
        
        // Reverse phone
        phoneButton = elementsQuery.buttons["3000000000"]
        waitForVisible(element: phoneButton, timeout: 2)
        phoneButton.tap()
        
        datoTextField = app.textFields["3000000000"]
        datoTextField.tap()
        datoTextField.clearAndEnterText(text: "3017303973")
        
        app.buttons["Guardar Cambios"].tap()
        
        waitForVisible(element: elementsQuery.buttons["3017303973"], timeout: 2)
        
        // Change email
        var emailButton = elementsQuery.buttons["dansotorey@gmail.com"]
        waitForVisible(element: emailButton, timeout: 2)
        emailButton.tap()
        
        datoTextField = app.textFields["dansotorey@gmail.com"]
        datoTextField.tap()
        datoTextField.clearAndEnterText(text: "automated@test.com")
        
        app.buttons["Guardar Cambios"].tap()
        
        waitForVisible(element: elementsQuery.buttons["automated@test.com"], timeout: 2)
        
        // Reverse email
        emailButton = elementsQuery.buttons["automated@test.com"]
        waitForVisible(element: emailButton, timeout: 2)
        emailButton.tap()
        
        datoTextField = app.textFields["automated@test.com"]
        datoTextField.tap()
        datoTextField.clearAndEnterText(text: "dansotorey@gmail.com")
        
        app.buttons["Guardar Cambios"].tap()
        
        waitForVisible(element: elementsQuery.buttons["dansotorey@gmail.com"], timeout: 2)
        
    }
    
    func testServiceBooked() {
        
        let app = XCUIApplication()
        // Start Booking
        app.buttons["iconAddService"].tap()
        
        let scrollViewsQuery = app.scrollViews
        
        // Find Homies
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.buttons["Continuar"].tap()
        
        // Chose first Homie
        let window = app.children(matching: .window).element(boundBy: 0)
        let homie1 = window.children(matching: .other).element(boundBy: 1)
        waitForVisible(element: homie1, timeout: 5)
        homie1.tap()
        
        // Confirm Homie
        waitForVisible(element: elementsQuery.buttons["Confirmar Selección"], timeout: 2)
        elementsQuery.buttons["Confirmar Selección"].tap()
        
        // Confirm Plane
        waitForVisible(element: app.buttons["Continuar"], timeout: 2)
        app.buttons["Continuar"].tap()
        
        // Confirm Booking
        waitForVisible(element: elementsQuery.buttons["Confirmar"], timeout: 2)
        elementsQuery.buttons["Confirmar"].tap()
        
        // Pay
        waitForVisible(element: app.buttons["Pagar"], timeout: 2)
        app.buttons["Pagar"].tap()

        // Wait for booking confirmation
        waitForVisible(element: app.otherElements["¡Tu servicio ha sido agendado correctamente!"], timeout: 15)
    }
    
    func testInfoService() {
        let app = XCUIApplication()
        
        app.tables.cells["0"].tap()
    }
    
    func testCancelService() {
        
    }
    
    
    func waitForVisible(element: XCUIElement, timeout: Double) {
        let exists = NSPredicate(format: "exists == 1")
        wait(for: [expectation(for: exists, evaluatedWith: element, handler: nil)], timeout: timeout)
    }
    
}


extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = (stringValue.characters.map { _ in
            XCUIKeyboardKey.delete.rawValue
        }).joined(separator: "")
        
        self.typeText("\(deleteString)\(text)")
    }
}
