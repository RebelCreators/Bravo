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

import UserNotifications
import UIKit
import Foundation

public class RCPushManager: NSObject {
    public static let shared = RCPushManager()
    
    public enum Error: Swift.Error {
        case registrationInProgress
        case unauthorized
        case error(Swift.Error)
    }
    
    private var success:(() -> Void)?
    private var failure:((Error) -> Void)?
    private var isProccessing = false
    private var successContext: AnyObject?
    private var failureContext: AnyObject?
    
    public func registerForPushNotifications(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        guard !isProccessing else {
            failure(.registrationInProgress)
            return
        }
        isProccessing = true
        DispatchQueue.main.async {
            _ = RCPushManager.contexRegisterForRemoteNotificationsWithDeviceToken
            _ = RCPushManager.contexFailToRegisterForRemoteNotificationsWithError
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                self.notificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else {
                        failure(.unauthorized)
                        self.isProccessing = false
                        return
                    }
                    DispatchQueue.main.async {
                        
                        self.successContext = NotificationCenter.default.addObserver(forName: Notification.RCApplication.didRegisterForRemoteNotification, object: nil, queue: OperationQueue.main, using: {(notification) in
                            guard let successContext = self.successContext, let failureContext = self.failureContext  else {
                                return
                            }
                            
                            NotificationCenter.default.removeObserver(successContext)
                            NotificationCenter.default.removeObserver(failureContext)
                            self.failureContext = nil
                            self.successContext = nil
                            guard let deviceToken = notification.userInfo?[Notification.RCApplication.Keys.token] as? Data else {
                                return
                            }
                            let tokenParts = deviceToken.map { data -> String in
                                return String(format: "%02.2hhx", data)
                            }
                            
                            let token = tokenParts.joined()
                            
                            if RCUser.currentUser != nil {
                                RCDevice.updateCurrentDevice(apnsToken: token, success: {
                                    DispatchQueue.main.async {
                                        success()
                                        self.isProccessing = false
                                    }
                                }) { (error) in
                                    failure(.error(error))
                                    self.isProccessing = false
                                }
                            } else {
                                RCDevice.updateCurrentDeviceLocally(apnsToken: token)
                                success()
                                self.isProccessing = false
                            }
                        })
                        
                        self.failureContext = NotificationCenter.default.addObserver(forName: Notification.RCApplication.didFailToRegisterForRemoteNotification, object: nil, queue: OperationQueue.main, using: { (notification) in
                            guard let successContext = self.successContext, let failureContext = self.failureContext  else {
                                return
                            }
                            
                            NotificationCenter.default.removeObserver(successContext)
                            NotificationCenter.default.removeObserver(failureContext)
                            self.failureContext = nil
                            self.successContext = nil
                            guard let error = notification.userInfo?[Notification.RCApplication.Keys.error] as? Swift.Error else {
                                return
                            }
                            
                            failure(.error(error))
                            self.isProccessing = false
                        })
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
    public func notificationSettings(success: @escaping (UNNotificationSettings) -> Void ) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                success(settings)
            }
        }
    }
    
    fileprivate static let contexRegisterForRemoteNotificationsWithDeviceToken: Bool = {
        guard let delegate = UIApplication.shared.delegate else {
            return false
        }
        let appRegisterForRemoteNotifications = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        
        let rcAppRegisterForRemoteNotifications = #selector(NSObject.RCApplication(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        
        return swizzle(originalType: type(of: delegate),
                       originalSelector: appRegisterForRemoteNotifications,
                       swizzledType: type(of: delegate),
                       swizzledSelector: rcAppRegisterForRemoteNotifications)
    }()
    
    fileprivate static let contexFailToRegisterForRemoteNotificationsWithError: Bool = {
        guard let delegate = UIApplication.shared.delegate else {
            return false
        }
        let appFailRegisterForRemoteNotifications = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
        
        let rcAppFailRegisterForRemoteNotifications = #selector(NSObject.RCApplication(_:didFailToRegisterForRemoteNotificationsWithError:))
        
        return swizzle(originalType: type(of: delegate),
                       originalSelector: appFailRegisterForRemoteNotifications,
                       swizzledType: type(of: delegate),
                       swizzledSelector: rcAppFailRegisterForRemoteNotifications)
    }()
    
    @discardableResult
    private static func swizzle(originalType: AnyClass, originalSelector: Selector, swizzledType: AnyClass, swizzledSelector: Selector) -> Bool {
        
        guard let swizzledMethod = class_getInstanceMethod(swizzledType, swizzledSelector) else {
            return false
        }
        
        let didAddMethod = class_addMethod(originalType, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        guard let originalMethod = class_getInstanceMethod(originalType, originalSelector) else {
            return false
        }
        
        if didAddMethod {
            class_replaceMethod(originalType, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            return true
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        return false
    }
}

extension Notification {
    fileprivate struct RCApplication {
        static let didRegisterForRemoteNotification = Notification.Name("com.rebel.creators.did.register.for.notification")
        static let didFailToRegisterForRemoteNotification = Notification.Name("com.rebel.creators.did.fail.to.register.for.notification")
        
        fileprivate struct Keys {
            static let token = "com.rebel.creators.apns.token"
            static let error = "com.rebel.creators.apns.error"
        }
    }
}

extension NSObject {
    
    @objc fileprivate func RCApplication(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(name: Notification.RCApplication.didRegisterForRemoteNotification, object: self, userInfo: [Notification.RCApplication.Keys.token: deviceToken])
        
        if !RCPushManager.contexRegisterForRemoteNotificationsWithDeviceToken {
            self.RCApplication(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
    
    @objc fileprivate func RCApplication(_ application: UIApplication,
                                         didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationCenter.default.post(name: Notification.RCApplication.didFailToRegisterForRemoteNotification, object: self, userInfo: [Notification.RCApplication.Keys.error: error])
        
        if !RCPushManager.contexFailToRegisterForRemoteNotificationsWithError {
            self.RCApplication(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }
}
