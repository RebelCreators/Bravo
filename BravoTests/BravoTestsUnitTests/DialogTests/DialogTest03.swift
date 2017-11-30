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

class Test0_0_0_0_4_DialogTest03: XCTestCase {
    static var user2Name = "\(userName).\(Date().timeIntervalSince1970)"
    static var user1Name = "\(userName).\(Date().timeIntervalSince1970)"
    static var user3Name = "\(userName).\(Date().timeIntervalSince1970)"
    static var user2: RCUser?
    static var user1: RCUser?
    static var user3: RCUser?
    var me = Test0_0_0_0_4_DialogTest03.self
    
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
        RCDialog.create(name: "Test2", details: "this is a test2", participants: [me.user2!], success: { dialog in
            currentDialog = dialog
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000009DialogsWithUsers() {
        let ex = expectation(description: "")
        RCDialog.dialogsWithUsers(userIDs: [me.user1!.userID!, me.user2!.userID!, me.user3!.userID!], permissions: RCDialogPermissionDefault, success: { (dialogs) in
            XCTAssert(dialogs.count == 0, "no dialogs should be found")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000019addUserToDialog() {
        let ex = expectation(description: "")
        currentDialog?.addUser(userID: me.user3!.userID!, success: { dialog in
            currentDialog = dialog
            XCTAssert(dialog.currentUsers.count == 3, "there should be three current users")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000039DialogsWithUsers() {
        let ex = expectation(description: "")
        RCDialog.dialogsWithUsers(userIDs: [me.user1!.userID!, me.user2!.userID!, me.user3!.userID!], permissions: RCDialogPermissionDefault, success: { (dialogs) in
            XCTAssert(dialogs.count == 1, "one dialog should be found")
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
