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

public class RCDevice: RCModel {
    @objc public var deviceToken: String?
    @objc public var apnsToken: String?
    public static var storeInKeyChain = true
    public static var currentDevice: RCDevice {
        return localDevice()
    }
    
    private static var deviceKey = "com.rebelcreators.device.key"
    
    public static func deleteCurrentDevice(success: @escaping () -> Void, failure:@escaping (BravoError) -> Void) {
        let device = localDevice()
        WebService().post(relativePath: "device/delete", headers: nil, parameters: device, success: {
            success()
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public static func updateCurrentDevice(success: @escaping () -> Void, failure:@escaping (BravoError) -> Void) {
        _ = localDevice()
        updateCurrentDevice(apnsToken: nil, success: success, failure: failure)
    }
    
    public static func updateCurrentDeviceLocally(apnsToken: String?) {
        let device = localDevice()
        device.apnsToken = apnsToken
        device.save()
    }
    
    public static func updateCurrentDevice(apnsToken: String?, success: @escaping () -> Void, failure:@escaping (BravoError) -> Void) {
        let device = localDevice()
        device.apnsToken = apnsToken
        device.save()
        WebService().put(relativePath: "device/update", headers: nil, parameters: device, success: {
            success()
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    private func save() {
        guard let jsonString = try? self.toJSONString() else {
            return
        }
        if RCDevice.storeInKeyChain {
            KeychainWrapper.standard.set(jsonString, forKey: RCDevice.deviceKey)
        } else {
            UserDefaults.standard.set(jsonString, forKey: RCDevice.deviceKey)
        }
    }
    
    private static func localDevice() -> RCDevice {
        var device: RCDevice!
        if storeInKeyChain {
            device = localDeviceFromKeyChain()
        } else {
            device = localDeviceFromUserDefaults()
        }
        
        return device
    }
    
    private static func localDeviceFromKeyChain() -> RCDevice {
        guard KeychainWrapper.standard.hasValue(forKey: deviceKey) else {
            return generateNewDevice()
        }
        
        guard let deviceString = KeychainWrapper.standard.string(forKey: deviceKey) else {
            return generateNewDevice()
        }
        
        let device: RCDevice? = try? RCDevice.fromJSONString(deviceString)
        
        return device ?? generateNewDevice()
    }
    
    private static func localDeviceFromUserDefaults() -> RCDevice {
        guard let deviceString = UserDefaults.standard.string(forKey: deviceKey) else {
            return generateNewDevice()
        }
        
        let device: RCDevice? = try? RCDevice.fromJSONString(deviceString)
        
        return device ?? generateNewDevice()
    }
    
    private static func generateNewDevice() -> RCDevice {
        let device = RCDevice()
        device.deviceToken = UUID().uuidString
        device.save()
        
        return device
    }
}
