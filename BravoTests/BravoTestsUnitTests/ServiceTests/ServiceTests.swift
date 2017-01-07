//
//  ServiceTests.swift
//  BravoTests
//
//  Created by default on 1/6/17.
//  Copyright © 2017 Lorenzo Stanton. All rights reserved.
//

import XCTest
import HHSDK
import Bravo

var currentService: RCService?

class Test0_0_0_0_2_ServiceTests: XCTestCase {
    
    func test000000RegisterUser() {
        let user = RCUser()!
        user.userName = "\(userName)2"
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
    
    func test0000011Login() {
        let cred = URLCredential(user: "\(userName)2", password: password, persistence: .none)
        let ex = expectation(description: "")
        RCUser.login(credential: cred, saveToken: true, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00000createService() {
        let service = RCService()
        service?.owner = RCUser.currentUser
        service?.details = "I cook a mean BBQ"
        service?.hourlyRate = 15.00
        service?.name = "BBQ"
        let ex = expectation(description: "")
        service?.save(success: { service in
            currentService = service
            XCTAssert(service.serviceID != nil, "No ID")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00001updateService() {
        let service = currentService
        let newName = "BestBBQEver"
        service?.name = newName
        let ex = expectation(description: "")
        service?.update(success: { service in
            currentService = service
            XCTAssert(service.serviceID != nil, "No ID")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00002fetchMyServices() {
        let ex = expectation(description: "")
        RCService.servicesForCurrentUser(success: { services in
            XCTAssert(services.count > 0, "No Services")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00003fetchServicesByUserID() {
        let ex = expectation(description: "")
        RCService.servicesForUser(userID: RCUser.currentUser!.userID!, success: { services in
            XCTAssert(services.count > 0, "No Services")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00004fetchServicesByServiceID() {
        let ex = expectation(description: "")
        RCService.servicesByIDs(serviceIDs: [currentService!.serviceID!], success: { services in
            XCTAssert(services.count > 0, "No Services")
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
