//
//  TestUtils.swift
//  BravoTestsUnitTests
//
//  Created by lorenzo stanton on 12/3/17.
//  Copyright © 2017 Lorenzo Stanton. All rights reserved.
//

import Foundation
import XCTest
@testable import Bravo

class Utils {
    static let DefaultTestTimeout: TimeInterval = 15
    static let password = "gogogo"
    
    static func newRandomUser() -> RCUser {
        let userName = "bob.\(Date().timeIntervalSince1970)"
        
        let user = RCUser()
        user.userName = userName
        user.password = password
        return user
    }
    
    
    static func registerUser(user: inout RCUser, test: XCTestCase) -> Error? {
        let expectation = test.expectation(description: "register user")
        var error: Error?
        var updatedUser: RCUser?
        user.register(success: { _user in
            updatedUser = _user
            expectation.fulfill()
        }) { (_error) in
            error = _error
            expectation.fulfill()
        }
        test.wait(for: [expectation], timeout: DefaultTestTimeout)
        if let _user = updatedUser {
            user = _user
        }
        return error
    }
    
    
    static func loginUser(user: inout RCUser, test: XCTestCase) -> Error? {
        let expectation = test.expectation(description: "log in User")
        var error: Error?
        guard let userName = user.userName else {
            XCTFail("No user name")
            return BravoError.ConditionNotMet(message: "Username not set")
        }
        var updatedUser: RCUser?
        let cred = URLCredential(user: userName, password: password, persistence: .none)
        RCUser.login(credential: cred, success: { _user in
            updatedUser = _user
            expectation.fulfill()
        }) { (_error) in
            error = _error
            expectation.fulfill()
        }
        test.wait(for: [expectation], timeout: DefaultTestTimeout)
        if let _user = updatedUser {
            user = _user
        }
        
        return error
    }
    
    
    static func logoutCurrentUser(test: XCTestCase) -> Error? {
        if RCUser.currentUser == nil {
            return BravoError.ConditionNotMet(message: "No user logged in")
        }
        let expectation = test.expectation(description: "log in User")
        var error: Error?
        RCUser.logout(success: {
            expectation.fulfill()
        }) { (_error) in
            error = _error
            expectation.fulfill()
        }
        test.wait(for: [expectation], timeout: DefaultTestTimeout)
        return error
    }
    
    static func usersEqual(_ user1: RCUser?, _ user2: RCUser?, assert: Bool = true) -> Bool {
        var equal = true
        equal = equal && user1?.userName == user2?.userName
        if assert {
            XCTAssertTrue(user1?.userName == user2?.userName)
        }
        
        equal = equal && user1?.userID == user2?.userID
        if assert {
            XCTAssertTrue(user1?.userID == user2?.userID)
        }
        
        equal = equal && user1?.gender == user2?.gender
        if assert {
            XCTAssertTrue(user1?.gender == user2?.gender)
        }
        
        equal = equal && user1?.extras ?? [:] == user2?.extras ?? [:]
        if assert {
            XCTAssertTrue(user1?.extras ?? [:] == user2?.extras ?? [:])
        }
        
        equal = equal && user1?.avatar == user2?.avatar
        if assert {
            XCTAssertTrue(user1?.avatar == user2?.avatar)
        }
        
        equal = equal && user1?.firstName == user2?.firstName
        if assert {
            XCTAssertTrue(user1?.firstName == user2?.firstName)
        }
        
        equal = equal && user1?.lastName == user2?.lastName
        if assert {
            XCTAssertTrue(user1?.lastName == user2?.lastName)
        }
        
        return equal
    }
}


extension Bravo {
    
    static func reConfig() {
        let config = BravoPlistConfig.loadPlist(name: "Config", bundle: Bundle(for: Utils.self))
        Bravo.reset().configure(dictionary: config.asDictionary()!["dev"] ?? [:])
        RCDevice.storeInKeyChain = false
    }
}
