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

public class Bravo: NSObject {
    
    public static var sdk = Bravo()
    var config: Config!
    public var credential: RCAuthCredential?
    
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reAuthenticate(_:)), name: Notification.RC.RCNeedsAuthentication, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reAuthenticate(_ notification: Notification) {
        if RCUser.canRefresh() {
            RCUser.resume(success: { _ in }, failure: { error in
                RCUser.logout(success: nil, failure: nil)
            })
        } else if credential != nil {
            RCUser.logout(success: nil, failure: nil)
        }
    }
    
    public func configure(url: URL, clientID: String, clientSecret: String) {
        config = Config(baseUrl: url, clientID: clientID, clientSecret: clientSecret)
    }
    
    public func configure(urlPath: String, clientID: String, clientSecret: String) {
        let url = URL(string: urlPath)!
        config = Config(baseUrl: url, clientID: clientID, clientSecret: clientSecret)
    }
    
    public func hasBearerAuthToken() -> Bool {
        return credential?.accessToken != nil
    }
    
    public func bearerAuthToken() -> String {
        return "Bearer \(credential?.accessToken ?? "")"
    }
}
