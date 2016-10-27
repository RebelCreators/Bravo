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
import EVReflection
import SwiftKeychainWrapper

public class RCAuthCredential: RCModel {
    var accessToken: String
    var expiration: Date
    var refreshToken: String
    var expires_in = 0
    
    public init(accessToken: String, expiration: Date, refreshToken: String) {
        self.accessToken = accessToken
        self.expiration = expiration
        self.refreshToken = refreshToken
        
        super.init()
    }
    
    override public func transforming() -> [RCValueTransformer] {
        let transformers = [RCValueTransformer]()
        
        return transformers
    }
    
    static func keyChainKey() -> String {
        return NSStringFromClass(RCAuthCredential.self)
    }
    
    public func save() -> Bool {
        return KeychainWrapper.standard.set(self.toJsonString(), forKey: RCAuthCredential.keyChainKey())
    }
    
    public class func savedToken() -> RCAuthCredential? {
        guard KeychainWrapper.standard.hasValue(forKey: RCAuthCredential.keyChainKey()) else {
            return nil
        }
        
        if let retrievedString = KeychainWrapper.standard.string(forKey: RCAuthCredential.keyChainKey()) {
            let cred = RCAuthCredential(json: retrievedString)
            
            if (cred.accessToken.characters.count > 0 && cred.refreshToken.characters.count > 0) {
                return cred
            }
            
            let expiry = (cred.expiration.timeIntervalSince1970 - (60 * 5) - Date().timeIntervalSince1970)
            if cred.accessToken.characters.count > 0 && expiry > 0 {
                return cred
            }
            
            let _ = removeToken()
            
            return  nil
        }
        
        return nil
    }
    
    public func updateExpiry() {
        expiration = Date(timeIntervalSinceNow: TimeInterval(expires_in))
    }
    
    @discardableResult
    public class func removeToken() -> Bool {
        return KeychainWrapper.standard.removeObject(forKey: RCAuthCredential.keyChainKey())
    }
    
    override public func mapping() -> [String : String] {
        return ["accessToken": "access_token", "refreshToken": "refresh_token"]
    }
    
    required convenience public init?(coder: NSCoder) {
        self.init()
    }
    
    required public init() {
        self.accessToken = ""
        self.expiration = Date.distantPast
        self.refreshToken = ""
        super.init()
    }
}
