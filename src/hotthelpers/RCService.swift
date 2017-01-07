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

public class RCService: RCModel {
    public var serviceID: String?
    public var owner: RCUser?
    public var details: String?
    public var name: String?
    public var hourlyRate: NSNumber?
    public var minimumHours: NSNumber = 0
    
    open override class func attributeMappings() -> [AnyHashable : Any]! {
        return super.attributeMappings() + ["serviceID" : "_id"]
    }
    
    open override class func mapAttributeTypes() -> [AnyHashable : Any]! {
        return (super.mapAttributeTypes() ?? [:]) + ["owner" : RCUser.self]
    }
    
    public static func servicesForCurrentUser(success: @escaping ([RCService]) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "service/own", headers: nil, parameters: [:], success: { (services: [RCService]) in
            success(services)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public static func servicesForUser(userID: String, success: @escaping ([RCService]) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "service/:userID/user", headers: nil, parameters: ["userID": userID], success: { (services: [RCService]) in
            success(services)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public static func servicesByIDs(serviceIDs: [String], success: @escaping ([RCService]) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "service/id", headers: nil, parameters: ["serviceIDs": serviceIDs], success: { (services: [RCService]) in
            success(services)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func update(success: @escaping (RCService) -> Void, failure: @escaping (RCError) -> Void) {
        guard let serviceID = self.serviceID else {
            failure(RCError.InvalidParameter(message: "Service mush have and id"))
            return
        }
        
        WebService().put(relativePath: "service/update", headers: nil, parameters: self, success: { (service : RCService) in
            success(service)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func save(success: @escaping (RCService) -> Void, failure: @escaping (RCError) -> Void) {
        guard serviceID == nil else {
            failure(RCError.InvalidParameter(message: "Service must not have an id"))
            return
        }
        
        WebService().put(relativePath: "service/save", headers: nil, parameters: self, success: { (service : RCService) in
            success(service)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
}
