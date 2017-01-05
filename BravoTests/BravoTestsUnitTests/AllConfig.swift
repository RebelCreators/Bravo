//
//  1Config.swift
//  BravoTests
//
//  Created by default on 1/4/17.
//  Copyright © 2017 Lorenzo Stanton. All rights reserved.
//

import XCTest
import Bravo

class AllConfig: XCTestCase {
    
    func test111Configure() {
        Bravo.sdk.configure(urlPath: "http://localhost:3000/", clientID: "dafdfdfdsfafdxadsfdsfafds", clientSecret: "dsjfle32421jde1r23sdsfeqfwer21r324234fewqe3")
    }
    
}
