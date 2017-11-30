// Copyright (c) 2017 Rebel Creators
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
    
    public func downloadData(success:((Data) -> Void)?, failure:((BravoError) -> Void)?) -> WebServiceOp {
        return WebServiceBlockOp({ operation in
            guard let url = self.relativePath else {
                failure?(BravoError.NotFound(message: "No URL"))
                operation.finish()
                return
            }
            WebService().get(relativePath: url, headers: nil, parameters: [:], success: { (data: Data) in
                success?(data)
                operation.finish()
            }, failure: { error in
                failure?(error)
                operation.finish()
            }).exeInBackground()
        })
    }
    
    public func upload(success:@escaping (() -> Void), failure:@escaping ((BravoError) -> Void)) -> WebServiceOp {
        return RCFile.uploadFiles(files: [self], success: success, failure: failure)
    }
    
    static public func uploadFiles(files: [RCFile], success:@escaping (() -> Void), failure:@escaping ((BravoError) -> Void)) -> WebServiceOp {
        return WebServiceBlockOp({ operation in
            var fileInfo = [RCFileInfo]()
            for file in files {
                guard let data = file.data, let contentType = file.contentType else {
                    continue
                }
                let info = RCFileInfo(name: "file", contentType: contentType, data: data)
                fileInfo.append(info)
            }
            guard files.count > 0 else {
                failure(BravoError.InvalidParameter(message: "Check Data and content Type"))
                operation.finish()
                return
            }
            
            WebService().upload(relativePath: "files/upload", files: fileInfo, requiresAuth: true, parameters: nil, headers: nil, success: { (strings: [String]) in
                //self.fileID = string
                for i in 0..<strings.count {
                    guard i < files.count else {
                        continue
                    }
                    files[i].fileID = strings[i]
                }
                success()
                operation.finish()
            }, failure: { error in
                failure(error)
                operation.finish()
            })
        })
    }
    
}
