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
import SwiftKeychainWrapper

import RCModel

@objc public class RCAuthCredential: RCModel {
    @objc var accessToken: String = ""
    @objc var expiration: Date = Date.distantPast
    @objc var refreshToken: String = ""
    @objc var expires_in: TimeInterval = 0
    
    public init(accessToken: String, expiration: Date, refreshToken: String) {
        self.accessToken = accessToken
        self.expiration = expiration
        self.refreshToken = refreshToken
        
        super.init()
    }
    
    public required init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func keyChainKey() -> String {
        return NSStringFromClass(RCAuthCredential.self)
    }
    
    public func save() -> Bool {
        guard let jsonString = try? self.toJSONString() else {
            return false
        }
        return KeychainWrapper.standard.set(jsonString, forKey: RCAuthCredential.keyChainKey())
    }
    
    public class func savedToken() -> RCAuthCredential? {
        guard KeychainWrapper.standard.hasValue(forKey: RCAuthCredential.keyChainKey()) else {
            return nil
        }
        
        if let retrievedString = KeychainWrapper.standard.string(forKey: RCAuthCredential.keyChainKey()) {
            guard let cred: RCAuthCredential = try? RCAuthCredential.fromJSONString(retrievedString) else {
                return nil
            }
            
            if (cred.accessToken.count > 0 && cred.refreshToken.count > 0) {
                return cred
            }
            
            let expiry = (cred.expiration.timeIntervalSince1970 - (60 * 5) - Date().timeIntervalSince1970)
            if cred.accessToken.count > 0 && expiry > 0 {
                return cred
            }
            
            let _ = removeToken()
            
            return  nil
        }
        
        return nil
    }
    
    public func updateExpiry() {
        expiration = Date(timeIntervalSinceNow: expires_in)
    }
    
    @discardableResult
    public class func removeToken() -> Bool {
        return KeychainWrapper.standard.removeObject(forKey: RCAuthCredential.keyChainKey())
    }
    
    open override class func propertyMappings() -> [String : RCPropertyKey] {
        return super.propertyMappings() + ["accessToken": "access_token", "refreshToken": "refresh_token"]
    }
}
