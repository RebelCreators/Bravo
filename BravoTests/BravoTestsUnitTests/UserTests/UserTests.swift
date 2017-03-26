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
import HHSDK
import CoreLocation

let DefaultTestTimeout: TimeInterval = 10
var userName = "bob.\(Date().timeIntervalSince1970)"
var password = "gogogo"
var users = [RCUser]()
var _userProfile: RCUserProfile?
class Test0_0_0_0_1_UserTests: XCTestCase {
    
    func test00000RegisterUser() {
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
    
    func test00008UpdateUserProfile() {
        let ex = expectation(description: "")
        let profile = RCUserProfile()!
        profile.appearance = ["hair" : "red"]
        profile.birthDate = Date.init(timeIntervalSince1970: 1000000000)
        profile.details = "this is a test"
        profile.email = "john.doe@gmail.com"
        profile.profileType = .helper
        
        RCUserProfile.updateCurrentUserProfile(profile: profile, success: { profile in
            _userProfile = profile
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00009AddUserImagesUpload() {
        let ex = expectation(description: "")
        let image1 = UIImage.init(named: "image1.JPG", in: Bundle.init(for: type(of: self)), compatibleWith: nil)!
        let imageData1 = UIImagePNGRepresentation(image1)!
        let image2 = UIImage.init(named: "image2.jpg", in: Bundle.init(for: type(of: self)), compatibleWith: nil)!
        let imageData2 = UIImagePNGRepresentation(image2)!
        
        _userProfile?.addProfileImages(pngDataForImages: [imageData1, imageData2], keep: [], success: { profile in
            XCTAssert(profile.profileImages.count == 2, "userphoto count incorrect")
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func test00009AddUserImagesZDownload() {
        let files =  _userProfile?.pngProfilePhotos() ?? []
        
        var dependency: WebServiceOp?
        for file in files  {
            let ex = expectation(description: "")
            let op =  file.downloadData(success: { data in
                let image = UIImage(data: data)
                XCTAssert(image != nil, "image not found")
                ex.fulfill()
            }, failure: { error in
                XCTFail(error.localizedDescription)
                ex.fulfill()
            })
            op.exeInBackground(dependencies: [dependency?.asOperation()])
            dependency = op
            waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
        }
    }
    
    func test00009UUUpdateCurrentUserLocation() {
        let ex = expectation(description: "")
        let location = RCLocation.location(coordinates: CLLocationCoordinate2D(latitude: 37.336152840875776,
                                                                                   longitude: -121.89452987346158))
        location.updateLocation(success: {
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00019UUFetchCurrentUserProfile() {
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
    
    func test00029UpdateUserProfile() {
        let ex = expectation(description: "")
        let profile = RCUserProfile()!
        profile.appearance = ["hair" : "blue"]
        profile.birthDate = Date.init(timeIntervalSince1970: 1000000000)
        profile.details = "this is a test"
        profile.email = "john.doe@gmail.com"
        profile.profileType = .helper
        
        RCUserProfile.updateCurrentUserProfile(profile: profile, success: { profile in
            ex.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
            ex.fulfill()
        })
        waitForExpectations(timeout: DefaultTestTimeout, handler: nil)
    }
    
    func test00039UUFetchCurrentUserProfileByUserName() {
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
    
    func test00049UUFetchuserDistance() {
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
        let location = RCLocation.location(coordinates: CLLocationCoordinate2D(latitude: 36.9688209872153,
                                                                                   longitude: -122.03132629394531))
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
    
    func test00049UUUUFetchuserDistanceNear() {
        let ex = expectation(description: "")
        RCUserProfile.helpersNearMe(kilometers: 50, offset: 0, limit: 5, success: { profiles in
            XCTAssert(profiles.count > 0 && profiles.count <= 5, "distance not returned")
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
