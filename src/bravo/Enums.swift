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
prefix operator <<

prefix func <<<T: RCEnumerable>(right: Int) -> T {
    return T(1 << right)
}

public func ==(lhs: RCEnumerable, rhs: RCEnumerable) -> Bool {
    return lhs.isEqual(rhs)
}

public final class RCGenderEnum: RCEnumerable {
    public static let none: RCGenderEnum = <<0
    public static let female: RCGenderEnum = <<2
    public static let male: RCGenderEnum = <<3
    
    public override var description: String {
        
        switch self {
        case RCGenderEnum.none:
            return "None"
        case RCGenderEnum.female:
            return "Female"
        case RCGenderEnum.male:
            return "Male"
        default:
            break
        }
        
        return ""
    }
}

@objc public class RCGenderEnumObject: NSObject, MMEnumAttributeContainer {
    public static func mappings() -> [AnyHashable : Any]! {
        return ["none" : RCGenderEnum.none, "male" : RCGenderEnum.male, "female" : RCGenderEnum.female]
    }
}

public final class RCProfileTypeEnum: RCEnumerable {
    public static let client: RCProfileTypeEnum = <<0
    public static let helper: RCProfileTypeEnum = <<2
    
    public override var description: String {
        
        switch self {
        case RCProfileTypeEnum.helper:
            return "helper"
        case RCProfileTypeEnum.client:
            return "client"
        default:
            break
        }
        
        return ""
    }
}

@objc public class RCProfileTypeEnumObject: NSObject, MMEnumAttributeContainer {
    public static func mappings() -> [AnyHashable : Any]! {
        return ["client" : RCProfileTypeEnum.client, "helper" : RCProfileTypeEnum.helper]
    }
}