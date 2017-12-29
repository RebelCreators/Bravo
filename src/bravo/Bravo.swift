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
import Alamofire
import SocketIO
import RCModel

public func + <K,V> (lhs : [K : V], rhs : [K : V]) -> [K : V] {
    var dict = lhs
    for (k,v) in rhs {
        dict[k] = v
    }
    
    return dict
}

public func + (lhs : [String : RCPropertyKey], rhs : [String : String]) -> [String : RCPropertyKey] {
    var dict = lhs
    for (k,v) in rhs {
        dict[k] = v as NSString
    }
    
    return dict
}

public func - (lhs : [String : RCPropertyKey], rhs : [String]) -> [String : RCPropertyKey] {
    var dict = lhs
    for k in rhs {
        dict[k] = nil
    }
    
    return dict
}

prefix operator ??

public prefix func ??<T>(o:T?) -> Bool {
    return o != nil
}

public class BravoPlistConfig: NSObject {
    private var data: Any?
    
    public static func loadPlist(name: String, bundle: Bundle = Bundle.main) -> BravoPlistConfig {
        let config = BravoPlistConfig()
        guard let fileUrl = bundle.url(forResource: name, withExtension: "plist"), let data = try? Data(contentsOf: fileUrl) else {
            assertionFailure("Bravo not configured correctly, make sure \(name) exists in bundle: \(bundle.localizedInfoDictionary?["CFBundleDisplayName"] ?? "null")")
            return config
        }
        
        config.data = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        return config
    }
    
    public func asDictionary<T>() -> [String: T]? {
        return data as? [String: T]
    }
    
    public func asArray() -> [[String: Any]]? {
        return data as? [[String: Any]]
    }
}

public class Bravo: NSObject {
    
    public private(set) static var sdk = Bravo()
    private(set) var config: Config!
    public var credential: RCAuthCredential?
    public let pushManager = RCPushManager()
    @discardableResult
    public static func reset() -> Bravo {
        sdk = Bravo()
        return sdk
    }
    
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reAuthenticate(_:)), name: Notification.RC.RCNeedsAuthentication, object: nil)
        RCSocket.shared = RCSocket()
        RCSocket.shared.intitialize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reAuthenticate(_ notification: Notification) {
        if RCUser.canRefresh() {
            RCUser.resume(success: { _ in
                if let webRequest = notification.userInfo?[NSNotification.rcWebRequestKey] as? RCWebRequestProtocol {
                    webRequest.begin()
                }
                
            }, failure: { error in })
        } else if credential != nil {
            RCUser.logout(success: nil, failure: nil)
        }
    }
    
    @discardableResult
    public func observeAndReconnect() -> Bravo {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        return self
    }
    
    @discardableResult
    public func configure(baseURL: URL, clientID: String, clientSecret: String) -> Bravo {
        config = Config(baseUrl: baseURL, clientID: clientID, clientSecret: clientSecret)
        return self
    }
    
    @discardableResult
    public func configure(withString baseURL: String, clientID: String, clientSecret: String) -> Bravo {
        let url = URL(string: baseURL)!
        config = Config(baseUrl: url, clientID: clientID, clientSecret: clientSecret)
        return self
    }
    
    @discardableResult
    public func configure(dictionary: [String: Any]) -> Bravo {
        guard  let baseURL = dictionary["baseURL"] as? String, let clientID = dictionary["clientID"] as? String, let clientSecret = dictionary["clientSecret"] as? String else {
            assertionFailure("Bravo not configured correctly")
            return self
        }
        
        return configure(withString: baseURL, clientID: clientID, clientSecret: clientSecret)
    }
    
    public func hasBearerAuthToken() -> Bool {
        return credential?.accessToken != nil
    }
    
    public func bearerAuthToken() -> String {
        return "Bearer \(credential?.accessToken ?? "")"
    }
}


extension Bravo {
    
    @objc public func applicationDidBecomeActive(_ notification: Notification) {
        RCSocket.shared.reconnect()
    }
    
    @objc public func applicationDidEnterBackground(_ notification: Notification) {
        RCSocket.shared.disconnect()
    }
}


extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
