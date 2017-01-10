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

public enum RCResponseType {
    case json
    case data
    case nodata
}

open class WebService: NSObject {
    
    public override init() {
        super.init()
    }
    
    open func post<ModelType: RModel>(relativePath: String, requiresAuth: Bool = true, headers: [String : String]?, parameters: RCParameter, responseType: RCResponseType = .json, success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) -> WebServiceOp {
        return WebServiceBlockOp({ operation in
            self.request(webRequest: RCWebRequest(relativePath: relativePath, requiresAuth: requiresAuth, method: .post, headers: headers, parameters: parameters, responseType: responseType, success: { res in
                guard ModelType.self != RCNullModel.self else {
                    success(RCNullModel.null as! ModelType)
                    operation.finish()
                    return
                }
                self.processSuccessFail(object: res, success: { (obj : ModelType) in
                    success(obj)
                    operation.finish()
                }, failure: { error in
                    failure(error)
                    operation.finish()
                })
            }, failure: { error in
                failure(error)
                operation.finish()
            }))
        })
    }
    
    open func get<ModelType: RModel>(relativePath: String, requiresAuth: Bool = true, headers: [String : String]?, parameters: RCParameter, responseType: RCResponseType = .json, success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) -> WebServiceOp {
        return WebServiceBlockOp({ operation in
            self.request(webRequest: RCWebRequest(relativePath: relativePath, requiresAuth: requiresAuth, method: .get, headers: headers, parameters: parameters, encoding: URLEncoding.default,responseType: responseType, success: { res in
                guard ModelType.self != RCNullModel.self else {
                    success(RCNullModel.null as! ModelType)
                    operation.finish()
                    return
                }
                self.processSuccessFail(object: res, success: { (obj : ModelType) in
                    success(obj)
                    operation.finish()
                }, failure: { error in
                    failure(error)
                    operation.finish()
                })
            }, failure: { error in
                failure(error)
                operation.finish()
            }))
        })
    }
    
    open func put<ModelType: RModel>(relativePath: String, requiresAuth: Bool = true, headers: [String : String]?, parameters: RCParameter, responseType: RCResponseType = .json, success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) -> WebServiceOp {
        return WebServiceBlockOp({ operation in
            self.request(webRequest: RCWebRequest(relativePath: relativePath, requiresAuth: requiresAuth, method: .put, headers: headers, parameters: parameters, responseType: responseType, success: { res in
                guard ModelType.self != RCNullModel.self else {
                    success(RCNullModel.null as! ModelType)
                    operation.finish()
                    return
                }
                self.processSuccessFail(object: res, success: { (obj : ModelType) in
                    success(obj)
                    operation.finish()
                }, failure: { error in
                    failure(error)
                    operation.finish()
                })
            }, failure: { error in
                failure(error)
                operation.finish()
            }))
        })
    }
    
    open func delete<ModelType: RModel>(relativePath: String, requiresAuth: Bool = true, headers: [String : String]?, parameters: RCParameter, responseType: RCResponseType = .json, success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) -> WebServiceOp {
        return WebServiceBlockOp({ operation in
            self.request(webRequest: RCWebRequest(relativePath: relativePath, requiresAuth: requiresAuth, method: .delete, headers: headers, parameters: parameters, responseType: responseType, success: { res in
                guard ModelType.self != RCNullModel.self else {
                    success(RCNullModel.null as! ModelType)
                    operation.finish()
                    return
                }
                self.processSuccessFail(object: res, success: { (obj : ModelType) in
                    success(obj)
                    operation.finish()
                }, failure: { error in
                    failure(error)
                    operation.finish()
                })
            }, failure: { error in
                failure(error)
                operation.finish()
            }))
        })
    }
    
    open func authenticate<ModelType: RModel>(relativePath: String, parameters: RCParameter, success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) -> WebServiceOp {
        return WebServiceBlockOp({ operation in
            let utf8str = "\(Bravo.sdk.config.clientID):\(Bravo.sdk.config.clientSecret)".data(using: .utf8)
            let base64Encoded = utf8str!.base64EncodedString()
            
            let headers = ["Authorization": "Basic \(base64Encoded)", "Content-Type": "application/x-www-form-urlencoded"]
            self.request(webRequest: RCWebRequest(relativePath: relativePath, requiresAuth: false, method: .post, headers: headers, parameters: parameters, encoding: URLEncoding.default, success: { dict in
                self.processSuccessFail(object: dict, success: { (obj : ModelType) in
                    success(obj)
                    operation.finish()
                }, failure: { error in
                    failure(error)
                    operation.finish()
                })
            }, failure: { error in
                failure(error)
                operation.finish()
            }))
        })
    }
    
    internal func request(webRequest: RCWebRequest) {
        
        var headers = webRequest.headers
        
        if webRequest.requiresAuth {
            if headers == nil {
                headers = [:]
            }
            if Bravo.sdk.hasBearerAuthToken() {
                headers?["Authorization"] = Bravo.sdk.bearerAuthToken()
            } else {
                NotificationCenter.default.post(name: Notification.RC.RCNeedsAuthentication, object: self, userInfo: [RCWebRequest.rcWebRequestKey: webRequest])
                
                webRequest.failure(RCError.AccessDenied(message: "Access Denied"))
                return
            }
        }
        
        let matcher = RCPatternMatcher(string: webRequest.relativePath, with: webRequest.parameters.toParameterDictionary())
        let url = URL(string: matcher.matchedString , relativeTo: Bravo.sdk.config.baseUrl)!
        let updatedParameters = matcher.unmatchedParameters
        
        switch webRequest.responseType {
        case .data:
            Alamofire.request(url, method: webRequest.method, parameters: updatedParameters, encoding: webRequest.encoding, headers: headers)
                .responseData(completionHandler: { response in
                    guard !webRequest.requiresAuth || response.response?.statusCode != 401 else {
                        
                        NotificationCenter.default.post(name: Notification.RC.RCNeedsAuthentication, object: self, userInfo: [RCWebRequest.rcWebRequestKey: webRequest])
                        
                        webRequest.failure(RCError.AccessDenied(message: "Access Denied"))
                        return
                    }
                    
                    guard let error = response.result.error else {
                        guard let res = response.result.value else {
                            let error = AFError.responseValidationFailed(reason: .dataFileNil)
                            webRequest.failure(RCError.OtherNSError(nsError: error as NSError))
                            return
                        }
                        
                        guard response.response?.statusCode == 200 else {
                            webRequest.failure(RCError.HttpError(message: "HTTP ERROR", code: response.response?.statusCode ?? 0))
                            
                            return
                        }
                        
                        webRequest.success(res)
                        
                        return
                    }
                    webRequest.failure(RCError.OtherNSError(nsError: error as NSError))
                })
            break
        case .json:
            Alamofire.request(url, method: webRequest.method, parameters: updatedParameters, encoding: webRequest.encoding, headers: headers)
                .responseJSON() { (response) -> Void in
                    guard !webRequest.requiresAuth || response.response?.statusCode != 401 else {
                        
                        NotificationCenter.default.post(name: Notification.RC.RCNeedsAuthentication, object: self, userInfo: [RCWebRequest.rcWebRequestKey: webRequest])
                        
                        webRequest.failure(RCError.AccessDenied(message: "Access Denied"))
                        return
                    }
                    
                    guard let error = response.result.error else {
                        guard let res: Any = (response.result.value as? [String: Any] ?? response.result.value as? [Any]) else {
                            let error = AFError.responseValidationFailed(reason: .dataFileNil)
                            webRequest.failure(RCError.OtherNSError(nsError: error as NSError))
                            return
                        }
                        
                        guard response.response?.statusCode == 200 else {
                            webRequest.failure(self.getError(dict: res as? [String: Any], code: response.response?.statusCode ?? 0 ))
                            
                            return
                        }
                        
                        webRequest.success(res)
                        
                        return
                    }
                    webRequest.failure(RCError.OtherNSError(nsError: error as NSError))
            }
            break
        case .nodata:
            Alamofire.request(url, method: webRequest.method, parameters: updatedParameters, encoding: webRequest.encoding, headers: headers)
                .response(completionHandler: { response in
                    guard !webRequest.requiresAuth || response.response?.statusCode != 401 else {
                        
                        NotificationCenter.default.post(name: Notification.RC.RCNeedsAuthentication, object: self, userInfo: [RCWebRequest.rcWebRequestKey: webRequest])
                        
                        webRequest.failure(RCError.AccessDenied(message: "Access Denied"))
                        return
                    }
                    
                    guard let error = response.error else {
                        
                        guard response.response?.statusCode == 200 else {
                            webRequest.failure(RCError.HttpError(message: "HTTP ERROR", code: response.response?.statusCode ?? 0))
                            
                            return
                        }
                        
                        webRequest.success(NSNull())
                        
                        return
                    }
                    
                    webRequest.failure(RCError.OtherNSError(nsError: error as NSError))
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
    
    
    func getError(dict: [String: Any]?, code: Int) -> RCError {
        guard  let message = dict?["message"] as? String else {
            return RCError.HttpError(message: "HTTP ERROR", code: code)
        }
        
        return RCError.HttpError(message: message, code: code)
    }
}
