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

open class RCFile: NSObject {
    open private(set) var fileID: String?
    open fileprivate(set) var data: Data?
    open fileprivate(set) var contentType: String?
    
    open var downloadURL: URL? {
        guard let fileID = self.fileID else {
            return nil
        }
        let dict = ["fileID": fileID]
        let url = "files/:fileID/download"
        return URL(string: RCPatternMatcher(string: url, with: dict).matchedString, relativeTo: Bravo.sdk.config.baseUrl)
    }
    
    private var relativePath: String? {
        guard let fileID = self.fileID else {
            return nil
        }
        let dict = ["fileID": fileID]
        let url = "files/:fileID/download"
        return RCPatternMatcher(string: url, with: dict).matchedString
    }
    
    public init(data: Data, contentType: String) {
        self.contentType = contentType
        self.data = data
        super.init()
    }
    
    public init(fileID: String, contentType: String) {
        self.fileID = fileID
        self.contentType = contentType
        super.init()
    }
    
    public func downloadData(success:((Data) -> Void)?, failure:((RCError) -> Void)?) -> WebServiceOp {
        return WebServiceBlockOp({ operation in
            guard let url = self.relativePath else {
                failure?(RCError.NotFound(message: "No URL"))
                operation.finish()
                return
            }
            WebService().get(relativePath: url, headers: nil, parameters: [:], responseType: .data, success: { (data: Data) in
                success?(data)
                operation.finish()
            }, failure: { error in
                failure?(error)
                operation.finish()
            })
        })
    }
    
    public func uploadData(success:@escaping (() -> Void), failure:@escaping ((RCError) -> Void)) -> WebServiceOp {
        return WebServiceBlockOp({ operation in
            guard let data = self.data, let contentType = self.contentType else {
                failure(RCError.InvalidParameter(message: "Check Data and content Type"))
                operation.finish()
                return
            }
            
            WebService().upload(relativePath: "files/upload", requiresAuth: true, parameters: nil, headers: nil, data: data, contentType: contentType, success: { (string: String) in
                self.fileID = string
                success()
                operation.finish()
            }, failure: { error in
                failure(error)
                operation.finish()
            })
        })
    }
    
}
