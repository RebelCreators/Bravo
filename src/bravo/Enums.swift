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

@objc public enum RCGenderEnum: UInt {
    case none,
    female,
    male
    
    public var description: String {
        return RCGenderEnumMapper.stringValue(self) ?? ""
    }
    
    public var localizedValue: String {
        return NSLocalizedString(self.description, comment: "RCGenderEnum Localized")
    }
}

@objc public class RCGenderEnumMapper: NSObject, RCEnumMappable {
    public static func enumMappings() -> [String : NSNumber] {
        return self.map(["none": .none,
                         "female": .female,
                         "male": .male] as [String: RCGenderEnum])
    }
}

@objc public enum RCProfileTypeEnum: UInt {
    case client,
    helper
    
    public var description: String {
        return RCProfileTypeEnumMapper.stringValue(self) ?? ""
    }
}

@objc public class RCProfileTypeEnumMapper: NSObject, RCEnumMappable {
    public static func enumMappings() -> [String : NSNumber] {
        return self.map(["client": .client,
                         "helper": .helper] as [String: RCProfileTypeEnum])
    }
}

@objc public enum RCRequestStatusEnum: UInt {
    case pending,
    canceled,
    completed
    
    public var description: String {
        return RCRequestStatusEnumMapper.stringValue(self) ?? ""
    }
}

@objc public class RCRequestStatusEnumMapper: NSObject, RCEnumMappable {
    public static func enumMappings() -> [String : NSNumber] {
        return self.map(["pending": .pending,
                         "canceled": .canceled,
                         "completed": .completed] as [String: RCRequestStatusEnum])
    }
}

@objc public enum RCDialogPermissionsEnum: UInt {
    case anyone,
    anyParticipant,
    onlyOwner
    
    public var description: String {
        return RCDialogPermissionsEnumMapper.stringValue(self) ?? ""
    }
}

@objc public class RCDialogPermissionsEnumMapper: NSObject, RCEnumMappable {
    public static func enumMappings() -> [String : NSNumber] {
        return self.map(["anyone": .anyone,
                         "any_participant": .anyParticipant,
                         "only_owner": .onlyOwner] as [String: RCDialogPermissionsEnum])
    }
}
