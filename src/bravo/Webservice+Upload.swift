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

class RCMultiPartRequest: NSObject {
    var data: Data?
    var request: URLRequest?
    
    init(url: URL, parameters:RCParameter?, headers:[String : String]?, files:[RCFileInfo]) {
        super.init()
        urlRequestWithFiles(url: url, parameters: parameters, headers: headers, files: files)
    }
    
    private func urlRequestWithFiles(url: URL, parameters:RCParameter?, headers:[String : String]?, files:[RCFileInfo]) {
        // create url request to send
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = Alamofire.HTTPMethod.post.rawValue
        let boundaryConstant = "------RCFormBoundaryaXVQszCOi7uv7hU0";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        mutableURLRequest.allHTTPHeaderFields = headers
        
        // create upload data to send
        var uploadData = Data()
        var index: Int?
        for file in files {
            // add image
            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: .utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"file\(index != nil ? "\(index!)" : "")\"; filename=\"\(file.name)\"\r\n".data(using: .utf8)!)
            uploadData.append("Content-Type: \(file.contentType)\r\n\r\n".data(using: .utf8)!)
            uploadData.append(file.data)
            index = index != nil ? index! + 1 : 0
        }
        // add parameters
        for (key, value) in parameters?.toParameterDictionary() ?? [:] {
            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: .utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: .utf8)!)
        }
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: .utf8)!)
        
        self.request = mutableURLRequest
        self.data = uploadData
    }
}

extension WebService {
    
    open func upload<ModelType: RModel>(relativePath: String, files:[RCFileInfo], requiresAuth: Bool = false, parameters: RCParameter? = nil, headers: [String: String]? = nil, success:@escaping ((ModelType) -> Void), failure:@escaping ((RCError) -> Void)) {
        
        let matcher = RCPatternMatcher(string: relativePath, with: parameters?.toParameterDictionary() ?? [:])
        let unmatchedParameters = matcher.unmatchedParameters ?? [:]
        let url = URL(string: matcher.matchedString , relativeTo: Bravo.sdk.config.baseUrl)!
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
        let rcRequest = RCMultiPartRequest(url: url, parameters: unmatchedParameters, headers: headers, files: files)
        Alamofire.upload(rcRequest.data!, with: rcRequest.request!).responseJSON { response in
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
                
                self.processSuccessFail(object: res, success: { (obj : ModelType) in
                    success(obj)
                    }, failure: failure)
                
                return
            }
            failure(RCError.OtherNSError(nsError: error as NSError))
        }
    }
}
