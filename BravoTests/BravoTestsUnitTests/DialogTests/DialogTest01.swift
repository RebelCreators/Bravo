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
    static var user2Name = "\(userName).\(Date().timeIntervalSince1970)"
    static var user1Name = "\(userName).\(Date().timeIntervalSince1970)"
    static var user2: RCUser?
    static var user1: RCUser?
    var me = Test0_0_0_0_4_DialogTest01.self
    
    func test000000RegisterUser() {
        let user = RCUser()!
        user.userName = me.user1Name
        user.password = password
        let ex = expectation(description: "")
        user.register(success: { u in
            self.me.user1 = u
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000001RegisterUser() {
        let user = RCUser()!
        user.userName = me.user2Name
        user.password = password
        let ex = expectation(description: "")
        user.register(success: { u in
            self.me.user2 = u
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000003Login() {
        let cred = URLCredential(user: me.user1Name, password: password, persistence: .none)
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
            XCTAssert(dialogs.first?.currentUsers.count == 1, "there should be one current user")
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
    
    func test000039createStandardDialog() {
        let ex = expectation(description: "")
        RCDialog.create(name: "Test2", details: "this is a test2", success: { dialog in
            currentDialog = dialog
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000069addUserToDialog() {
        let ex = expectation(description: "")
        currentDialog?.addUser(userID: me.user2!.userID!, success: { dialog in
            currentDialog = dialog
            XCTAssert(dialog.currentUsers.count == 2, "there should be two current users")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000099GetMyDialogs() {
        let ex = expectation(description: "")
        RCDialog.subscriptions(success: { dialogs in
            XCTAssert(dialogs.first?.currentUsers.count == 2, "there should be two current users")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000199GetDialogByID() {
        let ex = expectation(description: "")
        RCDialog.dialogWithID(dialogID: currentDialog!.dialogID!, permissions: RCDialogPermission(), success: { dialog in
            XCTAssert(dialog.currentUsers.count == 2, "there should be two current users")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000299sendMessage() {
        let ex = expectation(description: "")
        let message = RCMessage()!
        message.appendPayload(payload: TestPayload())
        currentDialog?.publish(message: message, success: { mesage in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000699removeUserToDialog() {
        let ex = expectation(description: "")
        currentDialog?.removeUser(userID: me.user2!.userID!, success: { dialog in
            XCTAssert(dialog.currentUsers.count == 1, "there should be one current user")
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
