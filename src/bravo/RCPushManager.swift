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
    
    fileprivate static let once: Bool = {
        guard let delegate = UIApplication.shared.delegate else {
            return false
        }
        let appRegisterForRemoteNotifications = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        
        let rcAppRegisterForRemoteNotifications = #selector(RCPushManager.RCApplication(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        
        return swizzle(originalType: type(of: delegate),
                       originalSelector: appRegisterForRemoteNotifications,
                       swizzledType: type(of: delegate),
                       swizzledSelector: rcAppRegisterForRemoteNotifications)
    }()
    
    public func registerForPushNotifications() {
        _ = RCPushManager.once
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            self.getNotificationSettings()
        }
    }
    
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
    
    private func getNotificationSettings() {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

extension NSObject {
    
    @objc fileprivate func RCApplication(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        RCDevice.updateCurrentDevice(apnsToken: token, success: { }) { (error) in }
        
        if !RCPushManager.once {
            self.RCApplication(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
}
