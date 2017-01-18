//
//  DialogTest01.swift
//  BravoTests
//
//  Created by default2 on 1/17/17.
//  Copyright © 2017 Lorenzo Stanton. All rights reserved.
//

import XCTest
import Bravo

var currentDialog: RCDialog?
class Test0_0_0_0_4_DialogTest01: XCTestCase {
    static var user2 = "\(userName).\(Date().timeIntervalSince1970)"
    var me = Test0_0_0_0_4_DialogTest01.self
    
    func test000000RegisterUser() {
        let user = RCUser()!
        user.userName = me.user2
        user.password = password
        let ex = expectation(description: "")
        user.register(success: { u in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000003Login() {
        let cred = URLCredential(user: me.user2, password: password, persistence: .none)
        let ex = expectation(description: "")
        RCUser.login(credential: cred, saveToken: true, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000006createStandardDialog() {
        let ex = expectation(description: "")
        RCDialog.create(name: "Test", details: "this is a test", participants:[RCUser.currentUser!] ,success: { dialog in
            currentDialog = dialog
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000009GetMyDialogs() {
        let ex = expectation(description: "")
        RCDialog.subscriptions(success: { dialogs in
            XCTAssert(dialogs.count == 1, "there should be one dialog")
            XCTAssert(dialogs.first == currentDialog, "dialogs should be equal")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    
    func test000019LeaveDialog() {
        let ex = expectation(description: "")
        currentDialog?.leave(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000029GetMyDialogs() {
        let ex = expectation(description: "")
        RCDialog.subscriptions(success: { dialogs in
            XCTAssert(dialogs.count == 0, "there should be no dialogs")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func testLogout() {
        let ex = expectation(description: "")
        RCUser.logout(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
}
