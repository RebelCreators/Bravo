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
import Alamofire
import EVReflection

public enum RCResponseType {
   case json
   case data
   case nodata
}

open class WebService: NSObject {
    
    public override init() {
        super.init()
    }
    
    open func post<ModelType: RModel>(relativePath: String, requiresAuth: Bool = true, headers: [String : String]?, parameters: [String : Any], responseType: RCResponseType = .json, success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) {
        request(relativePath: relativePath, requiresAuth: requiresAuth, method: .post, headers: headers, parameters: parameters, responseType: responseType, success: { res in
            guard ModelType.self != RCNullModel.self else {
                success(RCNullModel.null as! ModelType)
                return
            }
            self.processSuccessFail(object: res, success: { (obj : ModelType) in
                success(obj)
                }, failure: failure)
            }, failure: failure)
    }
    
    open func get<ModelType: RModel>(relativePath: String, requiresAuth: Bool = true, headers: [String : String]?, parameters: [String : Any], responseType: RCResponseType = .json, success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) {
        request(relativePath: relativePath, requiresAuth: requiresAuth, method: .get, headers: headers, parameters: parameters, responseType: responseType, success: { res in
            guard ModelType.self != RCNullModel.self else {
                success(RCNullModel.null as! ModelType)
                return
            }
            self.processSuccessFail(object: res, success: { (obj : ModelType) in
                success(obj)
                }, failure: failure)
            }, failure: failure)
    }
    
    open func put<ModelType: RModel>(relativePath: String, requiresAuth: Bool = true, headers: [String : String]?, parameters: [String : Any], responseType: RCResponseType = .json, success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) {
        request(relativePath: relativePath, requiresAuth: requiresAuth, method: .put, headers: headers, parameters: parameters, responseType: responseType, success: { res in
            guard ModelType.self != RCNullModel.self else {
                success(RCNullModel.null as! ModelType)
                return
            }
            self.processSuccessFail(object: res, success: { (obj : ModelType) in
                success(obj)
                }, failure: failure)
            }, failure: failure)
    }
    
    open func authenticate<ModelType: RModel>(relativePath: String, parameters: [String : Any], success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) {
        
        let utf8str = "\(Bravo.sdk.config.clientID):\(Bravo.sdk.config.clientSecret)".data(using: .utf8)
        let base64Encoded = utf8str!.base64EncodedString()
        
        let headers = ["Authorization": "Basic \(base64Encoded)", "Content-Type": "application/x-www-form-urlencoded"]
        request(relativePath: relativePath, requiresAuth: false, method: .post, headers: headers, parameters: parameters, success: { dict in
            self.processSuccessFail(object: dict, success: { (obj : ModelType) in
                success(obj)
                }, failure: failure)
            }, failure: failure)
    }
    
    private func request(relativePath: String, requiresAuth: Bool, method: Alamofire.HTTPMethod, headers: [String : String]?, parameters: [String: Any], responseType: RCResponseType = .json, success:@escaping ((Any) -> Void), failure:@escaping ((RCError) -> Void)) {
        
        var headers = headers
        
        if requiresAuth {
            if headers == nil {
                headers = [:]
            }
            if Bravo.sdk.hasBearerAuthToken() {
                headers?["Authorization"] = Bravo.sdk.bearerAuthToken()
            } else {
                NotificationCenter.default.post(name: Notification.RC.RCNeedsAuthentication, object: self, userInfo: nil)
                
                failure(RCError.AccessDenied(message: "Access Denied"))
                return
            }
        }
        
        let matcher = RCPatternMatcher(string: relativePath, with: parameters)
        let url = URL(string: matcher.matchedString , relativeTo: Bravo.sdk.config.baseUrl)!
        let updatedParameters = matcher.unmatchedParameters
    
        switch responseType {
        case .data:
            Alamofire.request(url, method: method, parameters: updatedParameters, headers: headers)
                .responseData(completionHandler: { response in
                    guard !requiresAuth || response.response?.statusCode != 401 else {
                        
                        NotificationCenter.default.post(name: Notification.RC.RCNeedsAuthentication, object: self, userInfo: nil)
                        
                        failure(RCError.AccessDenied(message: "Access Denied"))
                        return
                    }
                    
                    guard let error = response.result.error else {
                        guard let res = response.result.value else {
                            let error = AFError.responseValidationFailed(reason: .dataFileNil)
                            failure(RCError.OtherNSError(nsError: error as NSError))
                            return
                        }
                        
                        guard response.response?.statusCode == 200 else {
                            failure(RCError.HttpError(message: "HTTP ERROR", code: response.response?.statusCode ?? 0))
                            
                            return
                        }
                        
                        success(res)
                        
                        return
                    }
                    failure(RCError.OtherNSError(nsError: error as NSError))
                })
            break
        case .json:
                Alamofire.request(url, method: method, parameters: updatedParameters, headers: headers)
                    .responseJSON() { (response) -> Void in
                        guard !requiresAuth || response.response?.statusCode != 401 else {
                            
                            NotificationCenter.default.post(name: Notification.RC.RCNeedsAuthentication, object: self, userInfo: nil)
                            
                            failure(RCError.AccessDenied(message: "Access Denied"))
                            return
                        }
                        
                        guard let error = response.result.error else {
                            guard let res = response.result.value as? [String: Any] else {
                                let error = AFError.responseValidationFailed(reason: .dataFileNil)
                                failure(RCError.OtherNSError(nsError: error as NSError))
                                return
                            }
                            
                            guard response.response?.statusCode == 200 else {
                                failure(RCError.HttpError(message: "HTTP ERROR", code: response.response?.statusCode ?? 0))
                                
                                return
                            }
                            
                            success(res)
                            
                            return
                        }
                        failure(RCError.OtherNSError(nsError: error as NSError))
            }
            break
        case .nodata:
            Alamofire.request(url, method: method, parameters: updatedParameters, headers: headers)
                .response(completionHandler: { response in
                    guard !requiresAuth || response.response?.statusCode != 401 else {
                        
                        NotificationCenter.default.post(name: Notification.RC.RCNeedsAuthentication, object: self, userInfo: nil)
                        
                        failure(RCError.AccessDenied(message: "Access Denied"))
                        return
                    }
                    
                    guard let error = response.error else {
                        
                        guard response.response?.statusCode == 200 else {
                            failure(RCError.HttpError(message: "HTTP ERROR", code: response.response?.statusCode ?? 0))
                            
                            return
                        }
                        
                        success(NSNull())
                        
                        return
                    }
                    
                    failure(RCError.OtherNSError(nsError: error as NSError))
                })
            break
        }
    }
    internal func processSuccessFail<T: RModel>(object: Any, success: ((T) -> Void), failure:((RCError) -> Void)) -> Void {
        
        if let o = T.generate(from: object) as? T {
            success(o)
        } else {
            failure(RCError.UnexpectedError(message: "Could Not Parse"))
        }
    }
}
