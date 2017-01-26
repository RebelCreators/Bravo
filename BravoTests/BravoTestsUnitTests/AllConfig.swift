//
//  1Config.swift
//  BravoTests
//
//  Created by default on 1/4/17.
//  Copyright © 2017 Lorenzo Stanton. All rights reserved.
//

import XCTest
import Bravo

class Test0_0_0_0_0_AllConfig: XCTestCase {
    
    func test111Configure() {
        let config = BravoPlistConfig.loadPlist(name: "Config", bundle: Bundle(for: type(of: self)))
        Bravo.sdk.configure(dictionary: config.asDictionary()!["production"] ?? [:])
        RCDevice.storeInKeyChain = false
    }
    
}
