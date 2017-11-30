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

import Bravo
import RCModel

open class HHModel: RCModel {
    @objc var modelID: String?
    private var uuid: String = {
        return UUID().uuidString
    }()
    
    open override class func propertyMappings() -> [String : RCPropertyKey] {
        return super.propertyMappings() + ["modelID" : "_id"]
    }
    
    open override var hashValue: Int {
        guard let mID = modelID else {
            return uuid.hashValue
        }
        return mID.hashValue
    }
    
    open override func isEqual(_ object: Any!) -> Bool {
        guard let model = object as? HHModel else {
            return false
        }
        return hashValue == model.hashValue
    }
}

func ==(lhs: HHModel, rhs:HHModel) -> Bool {
    return lhs.isEqual(rhs)
}
