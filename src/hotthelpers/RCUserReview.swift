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

extension RCUser {
    
    public func reviews(success: @escaping ([RCUserReview]) -> Void, failure: @escaping (RCError) -> Void) {
        guard let userID = self.userID else {
            failure(RCError.ConditionNotMet(message: "No user ID"))
            return
        }
        WebService().get(relativePath: "reviews/:userID/id", headers: nil, parameters: ["userID": userID], success: { (requests: [RCUserReview]) in
            success(requests)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
}

public class RCUserReview: RCModel {
    public var user: RCUser?
    public var reviewer: RCUser?
    public var serviceName: String?
    public var comments: String?
    public var serviceRequestId: String?
    private var _rating: NSNumber = 0
    public var rating: NSNumber {
        set {
            _rating = (newValue.intValue > 0) ? (newValue.intValue < 5) ? newValue : 5 : 0
        }
        get {
            return _rating
        }
    }
    public var date: Date?
    
    public static func review(user: RCUser, serviceRequestId: String, serviceName: String, comments: String?, rating: NSNumber, date: Date = Date()) -> RCUserReview {
        let review = RCUserReview()!
        review.user = user
        review.serviceRequestId = serviceRequestId
        review.serviceName = serviceName
        review.comments = comments
        review.rating = rating
        review.date = date
        
        return review
    }
    
    
    static func reviewsForUser(userID: String, success: @escaping ([RCUserReview]) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "reviews/:userID", headers: nil, parameters: ["userID": userID], success: { (requests: [RCUserReview]) in
            success(requests)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
}
