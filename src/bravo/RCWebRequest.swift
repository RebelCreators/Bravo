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

extension NSNotification {
    static public var rcWebRequestKey: String {
        return "com.rebelcreators.url.request"
    }
}

public protocol RCWebRequestProtocol {
    func begin()
}

open class RCWebRequest<T: RCWebResponseModel>: NSObject, RCWebRequestProtocol {
    open private(set) var relativePath: String
    open fileprivate(set) var requiresAuth: Bool = true
    open private(set) var method: Alamofire.HTTPMethod
    open private(set) var headers: [String : String]?
    open private(set) var parameters: RCParameter
    open private(set) var encoding: ParameterEncoding
    open private(set) var responseType: T.Type
    open private(set) var success:((Any) -> Void)
    open private(set) var failure:((BravoError) -> Void)
    
    public init(relativePath: String, requiresAuth: Bool, method: Alamofire.HTTPMethod, headers: [String : String]?, parameters: RCParameter, encoding: ParameterEncoding = JSONEncoding.default, success:@escaping ((Any) -> Void), failure:@escaping ((BravoError) -> Void)) {
        self.relativePath = relativePath
        self.requiresAuth = requiresAuth
        self.method = method
        self.headers = headers
        self.parameters = parameters
        self.encoding = encoding
        self.responseType = T.self
        self.success = success
        self.failure = failure
        
        super.init()
    }
    
    public func begin() {
        WebService().request(webRequest: self)
    }
}

