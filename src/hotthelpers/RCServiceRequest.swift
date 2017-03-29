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
    open var status: RCHelperRequestStatusEnum = .pending // enum
    
    open override class func attributeMappings() -> [AnyHashable : Any]! {
        return super.attributeMappings() + ["helperID" : "helperId"]
    }
    
    open override class func enumAttributeTypes() -> [AnyHashable : Any]! {
        return (super.enumAttributeTypes() ?? [:]) + ["status" : RCHelperRequestStatusEnumObject.self]
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
    public var status: RCRequestStatusEnum = .pending // enum
    public var serviceCharge: NSNumber?
    public var expectedCharge: NSNumber?
    public var dialogID: String?
    public var latLng: RCLocation?
    //you must hydrate yourself - water's good for you
    public var hydratedDialog: RCDialog?
    
    open override class func attributeMappings() -> [AnyHashable : Any]! {
        return super.attributeMappings() + ["dialogID" : "dialogId"]
    }
    
    open override class func listAttributeTypes() -> [AnyHashable : Any]! {
        return (super.listAttributeTypes() ?? [:]) + ["helpers": RCUser.self, "helperStatus": RCHelperStatus.self]
    }
    
    open override class func mapAttributeTypes() -> [AnyHashable : Any]! {
        return (super.mapAttributeTypes() ?? [:])  + ["client": RCUser.self]
    }
    
    open override class func enumAttributeTypes() -> [AnyHashable : Any]! {
        return (super.enumAttributeTypes() ?? [:]) + ["status" : RCRequestStatusEnumObject.self]
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
    
    
    open static func serviceRequestsWithId(requestID: String, success: @escaping (RCServiceRequest) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "servicerequest/:requestID/id", headers: nil, parameters: ["requestID": requestID], success: { (requests: RCServiceRequest) in
            success(requests)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
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
    
    open func review(user: RCUser, review: RCUserReview, success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        guard let currentUser = RCUser.currentUser else {
            failure(RCError.ConditionNotMet(message: "user not logged in"))
            
            return
        }
        review.user = user
        if  client == currentUser {
            
            addHelperReview(review: review, success: success, failure: failure)
            return
        }
        
        var isHelper = false
        
        if !isHelper {
            for helper in helpers ?? [] {
                if helper == currentUser {
                    isHelper = true
                    break
                }
            }
        }
        
        guard isHelper else {
            failure(RCError.AccessDenied(message: "need to be helper or client to cancel"))
            
            return
        }
        
        addClientReview(review: review, success: success, failure: failure)
    }
    
    open func addHelper(helper: RCUser, success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        var params = self.toDictionary()
        params.setValue(helper, forKey: "helper")
        WebService().put(relativePath: "servicerequest/helper/add", headers: nil, parameters: params, success: { (request:RCServiceRequest) in
            self.helpers = request.helpers
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func submit(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().post(relativePath: "servicerequest/submit", headers: nil, parameters: self, success: { (request: RCServiceRequest) in
            self.modelID = request.modelID
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func accept(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/accept", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func reject(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/reject", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func cancel(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        guard let currentUser = RCUser.currentUser else {
            failure(RCError.ConditionNotMet(message: "user not logged in"))
            
            return
        }
        
        if  client == currentUser {
            
            cancelForClient(success: success, failure: failure)
            return
        }
        
        var isHelper = false
        
        if !isHelper {
            for helper in helpers ?? [] {
                if helper == currentUser {
                    isHelper = true
                    break
                }
            }
        }
        
        guard isHelper else {
            failure(RCError.AccessDenied(message: "need to be helper or client to cancel"))
            
            return
        }
        
        cancelForHelper(success: success, failure: failure)
    }
    
    open func submitMeForConsideration(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/submit/consideration", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            self.consideredUsers = request.consideredUsers
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func onWay(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/arriving", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open  func clockIn(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/clockin", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    open func complete(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        guard let currentUser = RCUser.currentUser else {
            failure(RCError.ConditionNotMet(message: "user not logged in"))
            
            return
        }
        
        if  client == currentUser {
            
            completeForClient(success: success, failure: failure)
            return
        }
        
        var isHelper = false
        
        if !isHelper {
            for helper in helpers ?? [] {
                if helper == currentUser {
                    isHelper = true
                    break
                }
            }
        }
        
        guard isHelper else {
            failure(RCError.AccessDenied(message: "need to be helper or client to complete"))
            
            return
        }
        
        completeForHelper(success: success, failure: failure)
    }
    
    //MARK: Private Methods
    
    private func addHelperReview(review: RCUserReview, success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().post(relativePath: "servicerequest/client/addhelperreview", headers: nil, parameters: review, success: { (request: RCUserReview) in
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    private func addClientReview(review: RCUserReview, success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().post(relativePath: "servicerequest/helper/addclientreview", headers: nil, parameters: review, success: { (request: RCUserReview) in
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    private func completeForHelper(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/complete", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    private func completeForClient(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/client/complete", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            self.status = request.status
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    private func cancelForClient(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/client/cancel", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            self.helperStatus = request.helperStatus
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    private func cancelForHelper(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        WebService().put(relativePath: "servicerequest/helper/cancel", headers: nil, parameters: self, success: { (request:RCServiceRequest) in
            self.status = request.status
            success()
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
}
