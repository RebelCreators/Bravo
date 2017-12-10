// Copyright (c) 2017 Rebel Creators
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
import Bravo
import RCModel

public class TestPayload: RCModel, RCPayload {
    @objc public static var contentType: String { return "test" }
    @objc public  var strings:[String] = []
}


class BasicDialogTests: XCTestCase {
    
    var user2: RCUser!
    var user1: RCUser!
    var currentUser: RCUser!
    var currentDialog: RCDialog?
    
    override func setUp() {
        super.setUp()
        
        Bravo.reConfig()
        
        var currentUser = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &currentUser, test: self))
        
        XCTAssertNil(Utils.loginUser(user: &currentUser, test: self))
        XCTAssertTrue(Utils.usersEqual(currentUser, RCUser.currentUser!))
        self.currentUser = currentUser
        
        var user1 = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &user1, test: self))
        self.user1 = user1
        
        var user2 = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &user2, test: self))
        self.user2 = user2
    }
    
    override func tearDown() {
        currentUser = nil
        _ = Utils.logoutCurrentUser(test: self)
        
        super.tearDown()
    }
    
    func testCreateStandardDialog() {
        let ex = expectation(description: "")
        RCDialog.create(name: "Test", details: "this is a test dialog", participants: [currentUser!], success: { dialog in
            self.currentDialog = dialog
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testGetMyDialogs() {
        testCreateStandardDialog()
        
        let ex = expectation(description: "")
        RCDialog.subscriptions(success: { dialogs in
            XCTAssert(dialogs.count == 1, "there should be one dialog")
            XCTAssert(dialogs.first == self.currentDialog, "dialogs should be equal")
            XCTAssert(dialogs.first?.currentUsers.count == 1, "there should be one current user")
            XCTAssert(dialogs.first?.allUsers.count == 1, "there should be one current user")
            XCTAssert( Utils.usersEqual(dialogs.first?.creator, self.currentUser), "current user should be creator")
            
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    
    func testLeaveDialog() {
        testCreateStandardDialog()
        
        let ex = expectation(description: "")
        currentDialog?.leave(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    
    func testGetMyDialogsAfterLeaving() {
        testLeaveDialog()
        
        let ex = expectation(description: "")
        RCDialog.subscriptions(success: { dialogs in
            XCTAssert(dialogs.count == 0, "there should be no dialogs")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    
    func testAddUserToDialog() {
        testCreateStandardDialog()
        
        let ex = expectation(description: "")
        currentDialog?.addUser(userID: user1.userID!, success: { dialog in
            self.currentDialog = dialog
            XCTAssert(dialog.currentUsers.count == 2, "there should be two current users")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testGetMyDialogsAfterAddingUser() {
        testAddUserToDialog()
        
        let ex = expectation(description: "should get dialogs")
        RCDialog.subscriptions(success: { dialogs in
            XCTAssert(dialogs.first?.currentUsers.count == 2, "there should be two current users")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout:  Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testFindDialogs() {
        testAddOtherUserToDialog()
        let ex = expectation(description: "should get dialogs")
        RCDialog.dialogsWithUsers(userIDs: [currentUser.userID!, user1.userID!, user2.userID!], permissions: RCDialogPermissionDefault, success: { (dialogs) in
            XCTAssert(dialogs.count == 1, "there should be one dialog")
            ex.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        }
        waitForExpectations(timeout:  Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testFindDialogsWithWrongPermissions() {
        testAddOtherUserToDialog()
        let ex = expectation(description: "should not get dialogs")
        RCDialog.dialogsWithUsers(userIDs: [currentUser.userID!, user1.userID!, user2.userID!], permissions: RCDialogPermissionPublic, success: { (dialogs) in
            XCTAssert(dialogs.count == 0, "there should be no dialogs")
            ex.fulfill()
        }) { (error) in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        }
        waitForExpectations(timeout:  Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testGetDialogByID() {
        testAddUserToDialog()
        
        let ex = expectation(description: "")
        RCDialog.dialogWithID(dialogID: currentDialog!.dialogID!, permissions: RCDialogPermissionDefault, success: { dialog in
            XCTAssert(dialog.currentUsers.count == 2, "there should be two current users")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testSendMessage() {
        testCreateStandardDialog()
        
        let message = RCMessage()
        let testPayload = TestPayload()
        let firstString = "this is a test!"
        testPayload.strings.append(firstString)
        try? message.appendPayload(payload: testPayload)
        
        let exBlock = expectation(description: "")
        currentDialog?.onMessage() { message in
            do {
                let payload: TestPayload? = try message.payloadForClass()
                XCTAssert(payload?.strings.first == firstString, "payloads should match")
            } catch {
                XCTFail(error.localizedDescription)
            }
            exBlock.fulfill()
        }
        
        let exBlock2 = expectation(description: "")
        currentDialog?.onMessage() { message in
            do {
                let payload: TestPayload? = try message.payloadForClass()
                XCTAssert(payload?.strings.first == firstString, "payloads should match")
            } catch {
                XCTFail(error.localizedDescription)
            }
            exBlock2.fulfill()
        }
        
        expectation(forNotification: NSNotification.Name(rawValue: Notification.RC.RCDidReceiveMessage.rawValue), object: nil) { notification in
            do {
                let payload: TestPayload? = try (notification.userInfo?[RCMessageKey] as? RCMessage)?.payloadForClass()
                return payload?.strings.first == firstString
            } catch {
                XCTFail(error.localizedDescription)
            }
            return false
        }
        
        let ex = expectation(description: "should send message")
        currentDialog?.publish(message: message, success: { mesage in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout + 10, handler: nil)
    }
    
    func testRemoveUserFromDialog() {
        testAddUserToDialog()
        let ex = expectation(description: "")
        currentDialog?.removeUser(userID: user1.userID!, success: { dialog in
            XCTAssert(dialog.currentUsers.count == 1, "there should be one current user")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testAddOtherUserToDialog() {
        testAddUserToDialog()
        let ex = expectation(description: "")
        currentDialog?.addUser(userID: user2.userID!, success: { dialog in
            XCTAssert(dialog.currentUsers.count == 3, "there should be three current users")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testAddUserToDialogWhenUnauthorized() {
        testAddUserToDialog()
        XCTAssertNil(Utils.logoutCurrentUser(test: self))
        var user = self.user1!
        XCTAssertNil(Utils.loginUser(user: &user, test: self))
        
        let ex = expectation(description: "Should not be able to add user")
        currentDialog?.addUser(userID: user2.userID!, success: { dialog in
            XCTFail("should not have access")
            ex.fulfill()
        }, failure: { error in
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testRemoveUserFromDialogWhenUnauthorized() {
        testAddOtherUserToDialog()
        XCTAssertNil(Utils.logoutCurrentUser(test: self))
        var user = self.user1!
        XCTAssertNil(Utils.loginUser(user: &user, test: self))
        
        let ex = expectation(description: "")
        currentDialog?.removeUser(userID: user2.userID!, success: { dialog in
            XCTFail("should not have access")
            ex.fulfill()
        }, failure: { error in
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testSendMessageAsParticipant() {
        testAddUserToDialog()
        XCTAssertNil(Utils.logoutCurrentUser(test: self))
        var user = self.user1!
        XCTAssertNil(Utils.loginUser(user: &user, test: self))
        
        let message = RCMessage()
        let testPayload = TestPayload()
        let firstString = "this is a test!"
        testPayload.strings.append(firstString)
        try? message.appendPayload(payload: testPayload)
        
        let exBlock = expectation(description: "")
        currentDialog?.onMessage() { message in
            do {
                let payload: TestPayload? = try message.payloadForClass()
                XCTAssert(payload?.strings.first == firstString, "payloads should match")
            } catch {
                XCTFail(error.localizedDescription)
            }
            exBlock.fulfill()
        }
        
        let exBlock2 = expectation(description: "")
        currentDialog?.onMessage() { message in
            do {
                let payload: TestPayload? = try message.payloadForClass()
                XCTAssert(payload?.strings.first == firstString, "payloads should match")
            } catch {
                XCTFail(error.localizedDescription)
            }
            exBlock2.fulfill()
        }
        
        expectation(forNotification: NSNotification.Name(rawValue: Notification.RC.RCDidReceiveMessage.rawValue), object: nil) { notification in
            do {
                let payload: TestPayload? = try (notification.userInfo?[RCMessageKey] as? RCMessage)?.payloadForClass()
                return payload?.strings.first == firstString
            } catch {
                XCTFail(error.localizedDescription)
            }
            return false
        }
        
        let ex = expectation(description: "should send message")
        currentDialog?.publish(message: message, success: { mesage in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout + 30, handler: nil)
    }
    
    func testLeaveDialogAndSendMessage() {
        testAddUserToDialog()
        XCTAssertNil(Utils.logoutCurrentUser(test: self))
        var user = self.user1!
        XCTAssertNil(Utils.loginUser(user: &user, test: self))
        
        let ex = expectation(description: "")
        currentDialog?.leave(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
        
        let message = RCMessage()
        let testPayload = TestPayload()
        let firstString = "this is a test!"
        testPayload.strings.append(firstString)
        try? message.appendPayload(payload: testPayload)
        
        let ex2 = expectation(description: "should send message")
        currentDialog?.publish(message: message, success: { mesage in
            XCTFail("should not have access")
            ex2.fulfill()
        }, failure: { error in
            ex2.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testGetMessages() {
        testAddUserToDialog()
        
        let message = RCMessage()
        let testPayload = TestPayload()
        let firstString = "this is a test!"
        testPayload.strings.append(firstString)
        try? message.appendPayload(payload: testPayload)
        
        let ex1 = expectation(description: "should send message")
        currentDialog?.publish(message: message, success: { mesage in
            ex1.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex1.fulfill()
        })
        
        let ex2 = expectation(description: "should send message")
        currentDialog?.publish(message: message, success: { mesage in
            ex2.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex2.fulfill()
        })
        
        let ex3 = expectation(description: "should send message")
        currentDialog?.publish(message: message, success: { mesage in
            ex3.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex3.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
        
        let ex4 = expectation(description: "")
        currentDialog?.messages(offset: 0, limit: 1000, success: { messages in
            XCTAssert(messages.count == 3, "there should be three messages")
            ex4.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex4.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testGetMessagesAsParticipant() {
        testGetMessages()
        XCTAssertNil(Utils.logoutCurrentUser(test: self))
        var user = self.user1!
        XCTAssertNil(Utils.loginUser(user: &user, test: self))
        
        let ex = expectation(description: "")
        currentDialog?.messages(offset: 0, limit: 1000, success: { messages in
            XCTAssert(messages.count == 3, "there should be three messages")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
}
