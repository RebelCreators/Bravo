//
//  RCUserTests.swift
//  BravoTestsUnitTests
//
//  Created by lorenzo stanton on 12/3/17.
//  Copyright © 2017 Lorenzo Stanton. All rights reserved.
//

import XCTest
import RCModel
import Bravo

class RCUserTests: XCTestCase {
    var currentUser: RCUser!
    
    override func setUp() {
        super.setUp()
        
        Bravo.reConfig()
        
        var currentUser = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &currentUser, test: self))
        
        XCTAssertNil(Utils.loginUser(user: &currentUser, test: self))
        XCTAssertTrue(Utils.usersEqual(currentUser, RCUser.currentUser!))
        self.currentUser = currentUser
    }
    
    func testLoginWithoutLoggingOut() {
        var user = Utils.newRandomUser()
        XCTAssertTrue(Utils.usersEqual(RCUser.currentUser, self.currentUser))
        XCTAssertNil(Utils.registerUser(user: &user, test: self))
        XCTAssertNil(Utils.loginUser(user: &user, test: self))
        XCTAssertTrue(Utils.usersEqual(RCUser.currentUser, user))
        XCTAssertFalse(Utils.usersEqual(RCUser.currentUser, self.currentUser, assert: false))
    }
    
    func testRegisteringUserTwice() {
        var user = self.currentUser!
        let error = Utils.registerUser(user: &user, test: self)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.code, 409)
    }
    
    func testFetchUserByUserName() {
        var newUser = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &newUser, test: self))
        
        let ex = expectation(description: "should fetch user")
        RCUser.userByUserName(userName: newUser.userName!, success: { user in
            XCTAssertTrue(Utils.usersEqual(newUser, user))
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testFetchUserByUserID() {
        var newUser = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &newUser, test: self))
        
        let ex = expectation(description: "")
        RCUser.userById(userID: newUser.userID!, success: { user in
            XCTAssertTrue(Utils.usersEqual(newUser, user))
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testUpdateUser() {
        let ex = expectation(description: "")
        let fname = "John"
        let lname = "smith"
        let extras = ["Test": "Value"]
        let gender = RCGenderEnum.male
        
        currentUser.firstName = fname
        currentUser.lastName = lname
        currentUser.extras = extras
        currentUser.gender = gender
        currentUser.updateUser(success: { user in
            XCTAssertTrue(Utils.usersEqual(self.currentUser, user))
            XCTAssert(user.extras?["Test"] == extras["Test"], "extras not saved")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testLoggoutCurrentUser() {
        XCTAssertNil(Utils.logoutCurrentUser(test: self))
    }
    
    func testFetchUsersByIds() {
        var user1 = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &user1, test: self))
        
        var user2 = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &user2, test: self))
        
        var user3 = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &user3, test: self))
        
        let ex = expectation(description: "should fetch users")
        
        let users = [user1, user2, user3]
        RCUser.userByIds(userIDs: users.map({$0.userID!}), success: { u in
            XCTAssert(users.count == u.count, "User counts not equal")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testFetchUsersByUsernames() {
        var user1 = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &user1, test: self))
        
        var user2 = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &user2, test: self))
        
        var user3 = Utils.newRandomUser()
        XCTAssertNil(Utils.registerUser(user: &user3, test: self))
        
        let ex = expectation(description: "should fetch users")
        
        let users = [user1, user2, user3]
        RCUser.userByUserNames(userNames: users.map({$0.userName!}), success: { u in
            XCTAssert(users.count == u.count, "User counts not equal")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    
    func testProfileImageUpload() {
        let ex = expectation(description: "should upload profile image")
        let image = UIImage.init(named: "image.png", in: Bundle.init(for: type(of: self)), compatibleWith: nil)!
        let data = UIImagePNGRepresentation(image)!
        currentUser.setProfileImage(pngData: data, success: { user in
            XCTAssert(user.avatar != nil, "Images not set")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testProfileImageDownload() {
        //upload image first
        testProfileImageUpload()
        
        let ex = expectation(description: "should download profile image")
        let image = UIImage.init(named: "image.png", in: Bundle.init(for: type(of: self)), compatibleWith: nil)!
        let imageData = UIImagePNGRepresentation(image)!
        currentUser.profileImage(success: { data in
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
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testUpdateDevice() {
        let ex = expectation(description: "")
        RCDevice.updateCurrentDevice(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    func testDeleteDevice() {
        let ex = expectation(description: "")
        RCDevice.deleteCurrentDevice(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: Utils.DefaultTestTimeout, handler: nil)
    }
    
    override func tearDown() {
        currentUser = nil
        _ = Utils.logoutCurrentUser(test: self)
        
        super.tearDown()
    }
}
