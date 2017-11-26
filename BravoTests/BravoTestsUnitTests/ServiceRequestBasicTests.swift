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
import  HHSDK

class Test0_0_0_0_3_ServiceRequestBasicTests: XCTestCase {
    static var serviceRequest: RCServiceRequest!
    static var userName1 = "\(userName)1232"
    static var userName2 = "\(userName)2qd2"
    static var user1: RCUser!
    static var user2: RCUser!
    var me = Test0_0_0_0_3_ServiceRequestBasicTests.self
    
    func test000000RegisterUser() {
        let user = RCUser()
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
        let user = RCUser()
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
    func test000019SetupUserProfile() {
        let ex = expectation(description: "")
        let profile = RCUserProfile()
        profile.appearance = ["hair" : "BLUE"]
        profile.birthDate = Date.init(timeIntervalSince1970: 1000000000)
        profile.details = "this is a test"
        profile.email = "john.doe@gmail.com"
        profile.profileType = .client
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
    
    func test000099fetchRequestWithID() {
        let ex = expectation(description: "")
        RCServiceRequest.serviceRequestsWithId(requestID: me.serviceRequest.requestID ?? "", success: { request in
            self.me.serviceRequest = request
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
                found = status.helperID == (RCUser.currentUser?.userID ?? "") && status.status == RCHelperRequestStatusEnum.accepted
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
            var found = false
            for status in self.me.serviceRequest.helperStatus {
                found = status.helperID == (RCUser.currentUser?.userID ?? "") && status.status == RCHelperRequestStatusEnum.onWay
            }
            XCTAssert(found, "Request not accepted")
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
            var found = false
            for status in self.me.serviceRequest.helperStatus {
                found = status.helperID == (RCUser.currentUser?.userID ?? "") && status.status == RCHelperRequestStatusEnum.clockedIn
            }
            XCTAssert(found, "Request not accepted")
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
            var found = false
            for status in self.me.serviceRequest.helperStatus {
                found = status.helperID == (RCUser.currentUser?.userID ?? "") && status.status == RCHelperRequestStatusEnum.completed
            }
            XCTAssert(found, "Request not completed")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        });
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000999CompleteRequestReview() {
        let ex = expectation(description: "")
        let review = RCUserReview.review(user: me.serviceRequest.client!, serviceRequestId:me.serviceRequest.requestID!, serviceName: me.serviceRequest.name!, comments: "Great service!", rating: 5)
        
        me.serviceRequest.review(user: me.serviceRequest.client!, review: review, success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test000999CompleteRequestReview2() {
        let ex = expectation(description: "")
        let review = RCUserReview.review(user: me.serviceRequest.client!, serviceRequestId:me.serviceRequest.requestID!, serviceName: me.serviceRequest.name!, comments: "Great service!", rating: 5)
        
        me.serviceRequest.review(user: me.serviceRequest.client!, review: review, success: {
            XCTFail("should not be able to rat twice")
            ex.fulfill()
        }, failure: { error in
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test001999CancelRequest() {
        let ex = expectation(description: "")
        me.serviceRequest.cancel(success: {
            XCTFail("Should not cancel completed request")
            ex.fulfill()
        }, failure: { error in
            XCTAssert(error.code == 403, "Should be forbidden")
            ex.fulfill()
        });
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }

    func test003999testLogoutANDLogIn() {
        var ex = expectation(description: "")
        RCUser.logout(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        
        let cred = URLCredential(user: me.userName1, password: password, persistence: .none)
        ex = expectation(description: "")
        RCUser.login(credential: cred, saveToken: true, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test004999testGetReviews() {
        let ex = expectation(description: "")
        
        RCUser.currentUser!.reviews(success: { reviews in
            XCTAssert(reviews.count == 1, "There should be one review")
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
