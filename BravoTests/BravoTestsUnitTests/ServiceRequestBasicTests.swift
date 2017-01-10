//
//  ServiceRequestbasicTests.swift
//  BravoTests
//
//  Created by default on 1/8/17.
//  Copyright © 2017 Lorenzo Stanton. All rights reserved.
//

import XCTest
import Bravo
import  HHSDK

class Test0_0_0_0_3_ServiceRequestBasicTests: XCTestCase {
    static var serviceRequest: RCServiceRequest!
    static var userName1 = "\(userName)1232"
    static var userName2 = "\(userName)2qd2"
    static var user1: RCUser!
    static var user2: RCUser!
    var me = Test0_0_0_0_3_ServiceRequestBasicTests.self
    
    func test000000RegisterUser() {
        let user = RCUser()!
        user.userName = me.userName1
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
    
    func test000003RegisterUser() {
        let user = RCUser()!
        user.userName = me.userName2
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
    
    func test000006Login() {
        let cred = URLCredential(user: me.userName1, password: password, persistence: .none)
        let ex = expectation(description: "")
        RCUser.login(credential: cred, saveToken: true, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000009createRequest() {
        let ex = expectation(description: "")
        let request = RCServiceRequest.service(withName: "bartending", details: "details are required", location: "a location is required", hourlyRate: 10, date: Date.distantFuture, duration: 5, helpers: [me.user2])
        me.serviceRequest = request
        request.submit(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000019fetchClientRequests() {
        let ex = expectation(description: "")
        RCServiceRequest.clientServiceRequests(success: { requests in
            XCTAssert(requests.count == 1, "incorrect number of client requests")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000039fetchHelperRequests() {
        let ex = expectation(description: "")
        RCServiceRequest.helperServiceRequests(success: { requests in
            XCTAssert(requests.count == 0, "incorrect number of helper requests")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000069testLogoutANDLogIn() {
        var ex = expectation(description: "")
        RCUser.logout(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        
        let cred = URLCredential(user: me.userName2, password: password, persistence: .none)
        ex = expectation(description: "")
        RCUser.login(credential: cred, saveToken: true, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000099fetchClientRequests() {
        let ex = expectation(description: "")
        RCServiceRequest.clientServiceRequests(success: { requests in
            XCTAssert(requests.count == 0, "incorrect number of helper requests")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000099fetchHelperRequests() {
        let ex = expectation(description: "")
        RCServiceRequest.helperServiceRequests(success: { requests in
            XCTAssert(requests.count == 1, "incorrect number of helper requests")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000199AcceptRequest() {
        let ex = expectation(description: "")
        me.serviceRequest.accept(success: {
            var found = false
            for status in self.me.serviceRequest.helperStatus {
                found = status.helperID == (RCUser.currentUser?.userID ?? "")
            }
            XCTAssert(found, "Request not accepted")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        });
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000399onWayToRequest() {
        let ex = expectation(description: "")
        me.serviceRequest.onWay(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        });
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000699ClockInRequest() {
        let ex = expectation(description: "")
        me.serviceRequest.clockIn(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        });
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000999CompleteRequest() {
        let ex = expectation(description: "")
        me.serviceRequest.complete(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        });
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
