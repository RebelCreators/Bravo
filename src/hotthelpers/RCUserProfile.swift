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

import Foundation
import Bravo
import RCModel

public class RCUserProfile: HHModel {
    
    static public var currentProfile: RCUserProfile?
    public var distance: NSNumber?
    public var birthDate: Date?
    public var email: String?
    public var details: String?
    public var user: RCUser?
    public var profileImages = [String]()
    public var profileType: RCProfileTypeEnum = .client
    public var appearance = [String: String]()
    //owners are not included in profile services
    public var services = [RCService]()
    public var homeCity: String?
    
    open override class func arrayClasses() -> [String : RCModelProtocol.Type] {
        return super.arrayClasses() + ["services" : RCService.self]
    }
    
    open override class func enumClasses() -> [String : RCEnumMappable.Type] {
        return super.enumClasses() + ["profileType" : RCProfileTypeEnumMapper.self]
    }
    
    public func addProfileImages(pngDataForImages: [Data], keep: [String], success:@escaping ((RCUserProfile) -> Void), failure:@escaping ((BravoError)->Void)) {
        let files = pngDataForImages.map({ return RCFile(data: $0, contentType: "image/png") })
        RCFile.uploadFiles(files: files, success: {
            let profile = self.copy() as! RCUserProfile
            var photos = keep
            for file in files {
                guard let fileID = file.fileID else {
                    continue
                }
                photos.append(fileID)
            }
            profile.profileImages = photos
            RCUserProfile.updateCurrentUserProfile(profile: profile, success: { profile in
                self.profileImages = profile.profileImages
                success(profile)
            }, failure: failure)
        }, failure: failure).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func pngProfilePhotos() -> [PNGPhoto] {
        return profileImages.map( { PNGPhoto(photoID: $0) }) ?? []
    }
    
    public static func profiles(userIDs: [String], success: @escaping (([RCUserProfile]) -> Void), failure: @escaping ((BravoError) -> Void)) {
        WebService().get(relativePath: "userprofile/id", headers: nil, parameters: ["userIDs": userIDs], success: { (profiles: [RCUserProfile]) in
            success(profiles)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public static func helpersNearMe(kilometers: Int, offset: Int, limit: Int, success: @escaping (([RCUserProfile]) -> Void), failure: @escaping ((BravoError) -> Void)) {
        WebService().get(relativePath: "userprofile/near", headers: nil, parameters: ["offset": offset, "limit": limit, "km": kilometers], success: { (profiles: [RCUserProfile]) in
            success(profiles)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public static func profiles(userNames: [String], success: @escaping (([RCUserProfile]) -> Void), failure: @escaping ((BravoError) -> Void)) {
        WebService().get(relativePath: "userprofile/username", headers: nil, parameters: ["userNames": userNames], success: { (profiles: [RCUserProfile]) in
            success(profiles)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public static func currentUserProfile(success: @escaping ((RCUserProfile?) -> Void), failure: @escaping ((BravoError) -> Void)) {
        guard let userID = RCUser.currentUser?.userID else {
            failure(.ConditionNotMet(message: "No user logged in"))
            return
        }
        profiles(userIDs: [userID], success: { profiles in
            self.currentProfile = profiles.first
            success(profiles.first)
        }, failure: { error in
            failure(error)
        })
    }
    
    public static func updateCurrentUserProfile(profile: RCUserProfile, success: @escaping ((RCUserProfile) -> Void), failure: @escaping ((BravoError) -> Void)) {
        guard RCUser.currentUser != nil else {
            failure(.ConditionNotMet(message: "No user logged in"))
            return
        }
        WebService().put(relativePath: "userprofile/update", headers: nil, parameters: profile, success: { (profile: RCUserProfile) in
            self.currentProfile = profile
            success(profile)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
        
    }
}
