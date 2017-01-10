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

open class RCHelperStatus: HHModel {
    open var helperID: String?
    open var status: String? // enum
    
    open override class func attributeMappings() -> [AnyHashable : Any]! {
        return super.attributeMappings() + ["helperID" : "helperId"]
    }
}

open class RCServiceRequest: HHModel {
    public var requestID: String? {
        return modelID
    }
    public var client: RCUser?
    public var helpers: [RCUser]?
    public var location: String?
    public var hourlyRate: NSNumber?
    public var duration: NSNumber? // in hours
    public var details: String?
    public var name: String?
    public var date: Date?
    public var clientCompleted = false
    public var helpersCompleted: [String] = []
    public var consideredUsers: [String] = []
    public var helperStatus: [RCHelperStatus] = []
    public var status: String? // enum
    public var serviceCharge: NSNumber?
    
    open override class func listAttributeTypes() -> [AnyHashable : Any]! {
        return (super.listAttributeTypes() ?? [:]) + ["helpers": RCUser.self, "helperStatus": RCHelperStatus.self]
    }
    
    open override class func mapAttributeTypes() -> [AnyHashable : Any]! {
        return (super.mapAttributeTypes() ?? [:])  + ["client": RCUser.self]
    }
    
    open static func service(withName: String, details: String, location: String, hourlyRate: NSNumber, date: Date, duration: NSNumber, helpers: [RCUser]? = nil) -> RCServiceRequest {
        let request = RCServiceRequest()!
        request.name = withName
        request.details = details
        request.location = location
        request.hourlyRate = hourlyRate
        request.date = date
        request.duration = duration
        request.helpers = helpers
        
        return request
    }
    
    open static func clientServiceRequests(success: @escaping ([RCServiceRequest]) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "servicerequest/client/list", headers: nil, parameters: [:], success: { (requests: [RCServiceRequest]) in
            success(requests)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open static func helperServiceRequests(success: @escaping ([RCServiceRequest]) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "servicerequest/helper/list", headers: nil, parameters: [:], success: { (requests: [RCServiceRequest]) in
            success(requests)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func addHelper(helper: RCUser, success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        var params = self.toDictionary()
        params.setValue(helper, forKey: "helper")
        WebService().put(relativePath: "servicerequest/helper/add", headers: nil, parameters: params, success: { (request:RCServiceRequest) in
            let _ = request
            self.helpers = request.helpers
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func submit(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().post(relativePath: "servicerequest/submit", headers: nil, parameters: self, success: { (request: RCServiceRequest) in
            let _ = request
            self.modelID = request.modelID
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func accept(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/accept", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            let _ = request
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func reject(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/reject", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            let _ = request
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func cancel(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        //TODO: Implement
    }
    
    open func submitMeForConsideration(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/submit/consideration", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            let _ = request
            self.consideredUsers = request.consideredUsers
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func onWay(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/arriving", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            let _ = request
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open  func clockIn(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/clockin", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            let _ = request
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func complete(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/complete", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            let _ = request
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
}

//getCurrentUserClientServiceRequests*
//getCurrentUserHelperServiceRequests*
//
//submitServiceRequest*
//acceptServiceRequest / if is helper and "pending" *
//rejectServiceRequest / if is helper and "pending" *
//cancelServiceRequest*
//addCurrentUserForConideration *
//arrivingStatus/ if is in helpers *
//workingStatus / if is in helpers or client*
//completeService / if is in helpers or client *
//addHelpersToServiceRequest / before will be pending once helper is added accteped *


