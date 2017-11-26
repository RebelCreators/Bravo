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
import HHSDK
import Bravo

var currentService: RCService?

class Test0_0_0_0_2_ServiceTests: XCTestCase {
    static var user2 = "\(userName)2"
    var me = Test0_0_0_0_2_ServiceTests.self
    
    func test000000RegisterUser() {
        let user = RCUser()
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
    
    func test0000011Login() {
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
    
    func test000001SetupUserProfile() {
        let ex = expectation(description: "")
        let profile = RCUserProfile()
        profile.appearance = ["hair" : "red"]
        profile.birthDate = Date.init(timeIntervalSince1970: 1000000000)
        profile.details = "this is a test"
        profile.email = "john.doe@gmail.com"
        profile.profileType = .helper
        //should not save
        let bartending = RCService()
        bartending.name = "bartending"
        bartending.hourlyRate = 10
        profile.services = [bartending]
        
        RCUserProfile.updateCurrentUserProfile(profile: profile, success: { profile in
            XCTAssert(profile.services.count == 0, "Services should not be saved in profile")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00000createService() {
        let service = RCService()
        service.owner = RCUser.currentUser
        service.details = "I cook a mean BBQ"
        service.hourlyRate = 15.00
        service.name = "BBQ"
        let ex = expectation(description: "")
        service.save(success: { service in
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
    
    func test00005fetchProfile() {
        let ex = expectation(description: "")
        RCUserProfile.currentUserProfile(success: { profile in
            XCTAssert((profile?.services.count ?? 0) > 0, "No Services in profile")
            XCTAssert((profile?.services.filter({ $0.owner != nil}) ?? []).count == 0, "owner should not be in service when in profile")
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
