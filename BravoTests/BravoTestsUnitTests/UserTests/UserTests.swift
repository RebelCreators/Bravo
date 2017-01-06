//
//  BravoTestsUnitTests.swift
//  BravoTestsUnitTests
//
//  Created by default on 1/4/17.
//  Copyright © 2017 Lorenzo Stanton. All rights reserved.
//

import XCTest
import Bravo
import HHSDK
import CoreLocation

let DefaultTestTimeout: TimeInterval = 10
var userName = "bob.\(Date().timeIntervalSince1970)"
var password = "gogogo"
var users = [RCUser]()

class UserTests: XCTestCase {
    
    func test0_0_0RegisterUser() {
        let user = RCUser()!
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
    
    func test1_0_0Login() {
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
    
    func test2_0_0FetchUserByUserName() {
        let ex = expectation(description: "")
        RCUser.userByUserName(userName: userName, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test3_0_0FetchUserByUserID() {
        let ex = expectation(description: "")
        RCUser.userById(userID: RCUser.currentUser!.userID!, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test4_0_0ProfileImageUpload() {
        let ex = expectation(description: "")
        let image = UIImage.init(named: "image.png", in: Bundle.init(for: type(of: self)), compatibleWith: nil)!
        let data = UIImagePNGRepresentation(image)!
        RCUser.currentUser?.setProfileImage(pngData: data, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test5_0_0ProfileImageDownload() {
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
    
    func test6_0_0UpdateUser() {
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
    func test7_0_0FetchUsersByIds() {
        let ex = expectation(description: "")
        
        let group = DispatchGroup()
        var user1 = RCUser()!
        user1.userName = "user1.\(Date().timeIntervalSince1970)"
        user1.password = password
        
        group.enter()
        user1.register(success: { user in
            user1 = user
            group.leave()
        }, failure: { error in
            group.leave()
        })
        
        var user2 = RCUser()!
        user2.userName = "user2.\(Date().timeIntervalSince1970)"
        user2.password = password
        group.enter()
        user2.register(success: { user in
            user2 = user
            group.leave()
        }, failure: { error in
            group.leave()
        })
        
        var user3 = RCUser()!
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
    
    func test8_0_0FetchUsersByUserName() {
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
    
    func test9_0_0UpdateUserProfile() {
        let ex = expectation(description: "")
        let profile = RCUserProfile()!
        profile.appearance = ["hair" : "red"]
        profile.birthDate = Date.init(timeIntervalSince1970: 1000000000)
        profile.details = "this is a test"
        profile.email = "john.doe@gmail.com"
        profile.profileType = .helper
        let bartending = ProfileService.service(name: "bartending", hourlyRate: 30.40, minimumHours: 3.5)
        let cooking = ProfileService.service(name: "cooking", hourlyRate: 40.01, minimumHours: 2.0)
        profile.services = [cooking, bartending]
        
        RCUserProfile.updateCurrentUserProfile(profile: profile, success: { profile in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test_1_0_0UUUpdateCurrentUserLocation() {
        let ex = expectation(description: "")
        let location = RCUserLocation.location(coordinates: CLLocationCoordinate2D(latitude: -121.89452987346158,
                                                                                   longitude: 37.336152840875776))
        location.updateLocation(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test_2_0_0UUFetchCurrentUserProfile() {
        let ex = expectation(description: "")
        
        RCUserProfile.currentUserProfile(success: { profile in
            XCTAssert(profile != nil, "Profile not found")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test_3_0_0UpdateUserProfile() {
        let ex = expectation(description: "")
        let profile = RCUserProfile()!
        profile.appearance = ["hair" : "blue"]
        profile.birthDate = Date.init(timeIntervalSince1970: 1000000000)
        profile.details = "this is a test"
        profile.email = "john.doe@gmail.com"
        profile.profileType = .helper
        let bartending = ProfileService.service(name: "bartending", hourlyRate: 30.40, minimumHours: 3.5)
        let cooking = ProfileService.service(name: "cooking", hourlyRate: 40.01, minimumHours: 2.0)
        profile.services = [cooking, bartending]
        
        RCUserProfile.updateCurrentUserProfile(profile: profile, success: { profile in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test_4_0_0UUFetchCurrentUserProfileByUserName() {
        let ex = expectation(description: "")
        
        RCUserProfile.profiles(userNames: [RCUser.currentUser!.userName!], success: { profiles in
            XCTAssert(profiles.count > 0, "Profiles not found")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test_5_0_0UUFetchuserDistance() {
         let userID = RCUser.currentUser!.userID!
        
        var ex = expectation(description: "logout")
        RCUser.logout(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        
        let cred = URLCredential(user: users[0].userName!, password: password, persistence: .none)
        
        ex = expectation(description: "login")
        RCUser.login(credential: cred, saveToken: true, success: { user in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        
        ex = expectation(description: "udate location")
        let location = RCUserLocation.location(coordinates: CLLocationCoordinate2D(latitude: -122.03132629394531,
                                                                                   longitude: 36.9688209872153))
        location.updateLocation(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        
//        ex = expectation(description: "")
//        let profile = RCUserProfile()!
//        profile.appearance = ["hair" : "orange"]
//        profile.birthDate = Date.init(timeIntervalSince1970: 1000000000)
//        profile.details = "I am the second user"
//        profile.email = "joe@gmail.com"
//        profile.profileType = .client
//        
//        RCUserProfile.updateCurrentUserProfile(profile: profile, success: { profile in
//            ex.fulfill()
//        }, failure: { error in
//            XCTFail(error.localizedDescription)
//            ex.fulfill()
//        })
//        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        
        ex = expectation(description: "")
        RCUserProfile.profiles(userIDs: [userID], success: { profiles in
            XCTAssert(profiles.count > 0, "Profiles not found")
            XCTAssert(profiles.first?.distance != nil, "distance not returned")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
}
