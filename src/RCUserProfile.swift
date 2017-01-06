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

public class ProfileService: RCModel {
    
    public var hourlyRate: NSNumber = 0
    public var minimumHours: NSNumber = 0
    public var name: String?
    public var serviceID: String?
    
    open override class func attributeMappings() -> [AnyHashable : Any]! {
        return super.attributeMappings() + ["serviceID" : "_id"]
    }
    
    public static func service(name: String?, hourlyRate: NSNumber, minimumHours: NSNumber) -> ProfileService {
        let service = ProfileService()!
        service.name = name
        service.hourlyRate = hourlyRate
        service.minimumHours = minimumHours
        
        return service
    }
}

public class RCUserProfile: RCModel {
    
    public var birthDate: Date?
    public var email: String?
    public var details: String?
    public var user: RCUser?
    public var profileImages = [String]()
    public var profileType: RCProfileTypeEnum = .client
    public var appearance = [String: String]()
    public var services = [ProfileService]()
    
    open override class func mapAttributeTypes() -> [AnyHashable : Any]! {
        return (super.mapAttributeTypes() ?? [:]) + ["user" : RCUser.self]
    }
    
    open override class func listAttributeTypes() -> [AnyHashable : Any]! {
        return (super.listAttributeTypes() ?? [:]) + ["services" : ProfileService.self]
    }
    
    open override class func enumAttributeTypes() -> [AnyHashable : Any]! {
        return (super.enumAttributeTypes() ?? [:]) + ["profileType" : RCProfileTypeEnumObject.self]
    }
    
    public static func profiles(userIDs: [String], success: @escaping (([RCUserProfile]) -> Void), failure: @escaping ((RCError) -> Void)) {
        WebService().get(relativePath: "userprofile/id", headers: nil, parameters: ["userIDs": userIDs], success: { (profiles: [RCUserProfile]) in
            success(profiles)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public static func profiles(userNames: [String], success: @escaping (([RCUserProfile]) -> Void), failure: @escaping ((RCError) -> Void)) {
        WebService().get(relativePath: "userprofile/username", headers: nil, parameters: ["userNames": userNames], success: { (profiles: [RCUserProfile]) in
            success(profiles)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public static func currentUserProfile(success: @escaping ((RCUserProfile?) -> Void), failure: @escaping ((RCError) -> Void)) {
        guard let userID = RCUser.currentUser?.userID else {
            failure(.ConditionNotMet(message: "No user logged in"))
            return
        }
        profiles(userIDs: [userID], success: { profiles in
            success(profiles.first)
        }, failure: { error in
            failure(error)
        })
    }
    
    public static func updateCurrentUserProfile(profile: RCUserProfile, success: @escaping ((RCUserProfile) -> Void), failure: @escaping ((RCError) -> Void)) {
        guard RCUser.currentUser != nil else {
            failure(.ConditionNotMet(message: "No user logged in"))
            return
        }
        WebService().put(relativePath: "userprofile/update", headers: nil, parameters: profile, success: { (profile: RCUserProfile) in
            success(profile)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
        
    }
}
