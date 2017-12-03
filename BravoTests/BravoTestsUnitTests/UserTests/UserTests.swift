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
import CoreLocation

let DefaultTestTimeout: TimeInterval = 15
var userName = "bob.\(Date().timeIntervalSince1970)"
var password = "gogogo"
var users = [RCUser]()
class Test0_0_0_0_1_UserTests: XCTestCase {
    
    func test00000RegisterUser() {
        let user = RCUser()
        user.userName = userName
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
    
    func test00001Login() {
        let cred = URLCredential(user: userName, password: password, persistence: .none)
        let ex = expectation(description: "")
        RCUser.login(credential: cred, saveToken: true, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00002FetchUserByUserName() {
        let ex = expectation(description: "")
        RCUser.userByUserName(userName: userName, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00003FetchUserByUserID() {
        let ex = expectation(description: "")
        RCUser.userById(userID: RCUser.currentUser!.userID!, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00004ProfileImageUpload() {
        let ex = expectation(description: "")
        let image = UIImage.init(named: "image.png", in: Bundle.init(for: type(of: self)), compatibleWith: nil)!
        let data = UIImagePNGRepresentation(image)!
        RCUser.currentUser?.setProfileImage(pngData: data, success: { user in
            XCTAssert(user.avatar != nil, "Images not set")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00005ProfileImageDownload() {
        let ex = expectation(description: "")
        let image = UIImage.init(named: "image.png", in: Bundle.init(for: type(of: self)), compatibleWith: nil)!
        let imageData = UIImagePNGRepresentation(image)!
        RCUser.currentUser?.profileImage(success: { data in
            guard let data = data else {
                XCTFail("No image Data")
                return
            }
            
            XCTAssert(data == imageData, "Images not equal")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00006UpdateUser() {
        let ex = expectation(description: "")
        let fname = "John"
        let lname = "smith"
        let extras = ["Test": "Value"]
        let gender = RCGenderEnum.male
        
        RCUser.currentUser?.firstName = fname
        RCUser.currentUser?.lastName = lname
        RCUser.currentUser?.extras = extras
        RCUser.currentUser?.gender = gender
        RCUser.currentUser?.updateUser(success: { user in
            XCTAssert(user.firstName == fname, "fname not equal")
            XCTAssert(user.lastName == lname, "lname not equal")
            XCTAssert(user.extras?["Test"] == extras["Test"], "extras not saved")
            XCTAssert(user.gender == gender, "gender not updated")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    func test00006FetchUsersByIds() {
        let ex = expectation(description: "")
        
        let group = DispatchGroup()
        var user1 = RCUser()
        user1.userName = "user1.\(Date().timeIntervalSince1970)"
        user1.password = password
        
        group.enter()
        user1.register(success: { user in
            user1 = user
            group.leave()
        }, failure: { error in
            group.leave()
        })
        
        var user2 = RCUser()
        user2.userName = "user2.\(Date().timeIntervalSince1970)"
        user2.password = password
        group.enter()
        user2.register(success: { user in
            user2 = user
            group.leave()
        }, failure: { error in
            group.leave()
        })
        
        var user3 = RCUser()
        user3.userName = "user3.\(Date().timeIntervalSince1970)"
        user3.password = password
        group.enter()
        user3.register(success: { user in
            user3 = user
            group.leave()
        }, failure: { error in
            group.leave()
        })
        
        group.notify(queue: .main) {
            users = [user1, user2, user3]
            RCUser.userByIds(userIDs: users.map({$0.userID!}), success: { u in
                XCTAssert(users.count == u.count, "User counts not equal")
                ex.fulfill()
            }, failure: { error in
                XCTFail(error.localizedDescription)
                ex.fulfill()
            })
        }
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00007FetchUsersByUserName() {
        let ex = expectation(description: "")
        RCUser.userByUserNames(userNames: users.map({ $0.userName! }), success: { u in
            XCTAssert(users.count == u.count, "User counts not equal")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00059UpdateDevice() {
        let ex = expectation(description: "")
        RCDevice.updateCurrentDevice(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00069DeleteDevice() {
        let ex = expectation(description: "")
        RCDevice.deleteCurrentDevice(success: {
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
