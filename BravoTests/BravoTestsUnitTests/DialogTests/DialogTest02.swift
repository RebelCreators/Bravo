// Copyright (c) 2016 Rebel Creators
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

class Test0_0_0_0_4_DialogTest02: XCTestCase {
    static var user2Name = "\(userName).\(Date().timeIntervalSince1970)"
    static var user1Name = "\(userName).\(Date().timeIntervalSince1970)"
    static var user3Name = "\(userName).\(Date().timeIntervalSince1970)"
    static var user2: RCUser?
    static var user1: RCUser?
    static var user3: RCUser?
    var me = Test0_0_0_0_4_DialogTest02.self
    
    func test000000RegisterUsers() {
        var user = RCUser()
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
        
        user = RCUser()
        user.userName = me.user2Name
        user.password = password
        let ex2 = expectation(description: "")
        user.register(success: { u in
            self.me.user2 = u
            ex2.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex2.fulfill()
        })
        
        user = RCUser()
        user.userName = me.user3Name
        user.password = password
        let ex3 = expectation(description: "")
        user.register(success: { u in
            self.me.user3 = u
            ex3.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex3.fulfill()
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
        let permissions = RCDialogPermissionAnyParticipant
        permissions.join = .anyone
        RCDialog.create(name: "Test2", details: "this is a test2", permissions: permissions, success: { dialog in
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
        let message = RCMessage()
        let testPayload = TestPayload()
        let firstString = "this is a test!"
        testPayload.strings.append(firstString)
        message.appendPayload(payload: testPayload)
        currentDialog?.publish(message: message, success: { mesage in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        let exBlock = expectation(description: "")
        currentDialog?.onMessage() { message in
            let payload: TestPayload? = message.payloadForClass()
            XCTAssert(payload?.strings.first == firstString, "payloads should match")
            
            exBlock.fulfill()
        }
        
        let exBlock2 = expectation(description: "")
        currentDialog?.onMessage() { message in
            let payload: TestPayload? = message.payloadForClass()
            XCTAssert(payload?.strings.first == firstString, "payloads should match")
            
            exBlock2.fulfill()
        }
        
        expectation(forNotification: Notification.RC.RCDidReceiveMessage.rawValue, object: nil) { notification in
            let payload: TestPayload? = (notification.userInfo?[RCMessageKey] as? RCMessage)?.payloadForClass()
            
            return payload?.strings.first == firstString
        }
        
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
    
    func test000999addUserToDialog() {
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
    
    func test001999testLogoutANDLogIn() {
        var ex = expectation(description: "")
        RCUser.logout(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        
        let cred = URLCredential(user: me.user2!.userName!, password: password, persistence: .none)
        ex = expectation(description: "")
        RCUser.login(credential: cred, saveToken: true, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test003999addUserToDialog() {
        let ex = expectation(description: "")
        currentDialog?.addUser(userID: me.user3!.userID!, success: { dialog in
            ex.fulfill()
        }, failure: { error in
             XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test004999removeUserFromDialog() {
        let ex = expectation(description: "")
        currentDialog?.removeUser(userID: me.user1!.userID!, success: { dialog in
            ex.fulfill()
        }, failure: { error in
             XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test005999sendMessage() {
        let ex = expectation(description: "")
        let message = RCMessage()
        let testPayload = TestPayload()
        let firstString = "this is a test!"
        testPayload.strings.append(firstString)
        message.appendPayload(payload: testPayload)
        currentDialog?.publish(message: message, success: { mesage in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        let exBlock = expectation(description: "")
        currentDialog?.onMessage() { message in
            let payload: TestPayload? = message.payloadForClass()
            XCTAssert(payload?.strings.first == firstString, "payloads should match")
            
            exBlock.fulfill()
        }
        
        let exBlock3 = expectation(description: "")
        RCDialog.onMessage(context: self, dialogID: nil) { message in
            let payload: TestPayload? = message.payloadForClass()
            XCTAssert(payload?.strings.first == firstString, "payloads should match")
            
            exBlock3.fulfill()
        }
        
        let exBlock2 = expectation(description: "")
        currentDialog?.onMessage() { message in
            let payload: TestPayload? = message.payloadForClass()
            XCTAssert(payload?.strings.first == firstString, "payloads should match")
            
            exBlock2.fulfill()
        }
        
        expectation(forNotification: Notification.RC.RCDidReceiveMessage.rawValue, object: nil) { notification in
            let payload: TestPayload? = (notification.userInfo?[RCMessageKey] as? RCMessage)?.payloadForClass()
            
            return payload?.strings.first == firstString
        }
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        currentDialog?.removeOnMessageListeners()
        RCDialog.removeOnMessageListeners(context: self)
    }
    
    func test007999leaveDialogAndJoin() {
        let ex = expectation(description: "")
        currentDialog?.leave(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        
        let ex1 = expectation(description: "")
        currentDialog?.join(success: { dialog in
            ex1.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex1.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    
    func test008999leaveDialog() {
        let ex = expectation(description: "")
        currentDialog?.leave(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test009999GetMyDialogs() {
        let ex = expectation(description: "")
        RCDialog.subscriptions(success: { dialogs in
            XCTAssert(dialogs.count == 0, "there should be  no dialogs")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test039999join() {
        let ex1 = expectation(description: "")
        currentDialog?.join(success: { dialog in
            ex1.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex1.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test069999GetMyDialogs() {
        let ex = expectation(description: "")
        RCDialog.subscriptions(success: { dialogs in
            XCTAssert(dialogs.count == 1, "there should be one dialog")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test099999leaveDialog() {
        let ex = expectation(description: "")
        currentDialog?.leave(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test199999sendMessage() {
        let ex = expectation(description: "")
        let message = RCMessage()
        let testPayload = TestPayload()
        let firstString = "this is a test!"
        testPayload.strings.append(firstString)
        message.appendPayload(payload: testPayload)
        currentDialog?.publish(message: message, success: { mesage in
            XCTFail("should not have access")
            ex.fulfill()
        }, failure: { error in
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
