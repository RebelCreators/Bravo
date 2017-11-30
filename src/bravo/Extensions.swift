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
import RCModel

extension RCEnumMappable {
    
    public static func stringValue<T: RawRepresentable>(_ value: T) -> String? where T.RawValue == UInt {
        return self.enumMappings().reversedDictionary()[NSNumber(value: value.rawValue)]
    }
    
    public static func map<T: RawRepresentable>(_ dict:[String:T]) -> [String : NSNumber]! where T.RawValue == UInt {
        var mapped = [String : NSNumber]()
        for (k, v) in dict {
            mapped[k] = NSNumber(value: v.rawValue)
        }
        return mapped
    }
}

extension Dictionary where Value: Hashable {
    
    public func reversedDictionary() -> [Value: Key] {
        var dict = [Value: Key]()
        for (k, v) in self {
            dict[v] = k
        }
        return dict
    }
}
