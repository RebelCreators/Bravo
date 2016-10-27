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

import EVReflection
import Foundation

@objc public class RCNullModel: RCModel {
    static var null = RCNullModel()
}

public protocol RCEnumType {
    init?(rawValue: String)
    var rawValue: String { get }
}

public enum Pie: String, RCEnumType {
    
    case Apple = "Apple"
    case Peach = "Peach"
    case Pumpkin = "Pumpkin"
}



class Foo: RCModel {
    var test: Pie = .Peach
    var test2: Pie = .Peach
    var innerFoo: RCModel?
    
    public required init() {
        super.init()
    }
    
    required convenience public init?(coder: NSCoder) {
        self.init()
    }
    
    override func updateEnumForClass(enumObject: Any?, enumKey: String) {
        print("e \(enumObject)  ee \(enumKey)")
        if let enumObject = enumObject, enumKey == "test" {
            test = enumObject as! Pie
        }
    }
}

public protocol RModel {
    
    static func generate(from: Any) -> Any?
    
}

extension String: RModel {
    public static func generate(from: Any) -> Any? {
        return String(describing: from)
    }
}

extension Data: RModel {
    public static func generate(from: Any) -> Any? {
        return from as? Data
    }
}

@objc public class RCModel: EVObject, RModel, NSCopying {
    
    public static func generate(from: Any) -> Any? {
        guard let dict  = from as? [String: Any] else {
            return nil
        }
        
        return self.init(dictionary: removeNSNull(dict: dict) as NSDictionary)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(dictionary: self.toDictionary())
    }
    
    public func mapping() -> [String: String] {
        return [:]
    }
    
    public func transforming() -> [RCValueTransformer] {
        var transformers = [RCValueTransformer]()
        for (key, clazz) in keysForEnums() ?? [:] {
            transformers.append(RCValueTransformer(propertyName: key, forward: { any in
                if let string = any as? String {
                    self.updateEnumForClass(enumObject: clazz.init(rawValue: string), enumKey: key)
                }
                return nil
                }, reverse: { any in
                    
                    for (k, value) in self.keysValuesForEnums() ?? [:] {
                        if let e = value as? RCEnumType, key == k {
                            return e.rawValue
                        }
                    }
                    return nil
            }))
        }
        return transformers
    }
    
    public func updateEnumForClass(enumObject: Any?, enumKey: String) { }
    
    public func keysForEnums() -> [String: RCEnumType.Type]? {
        var output:[String: RCEnumType.Type]? = [String: RCEnumType.Type]()
        let mirror = Mirror(reflecting: self)
        for (key, value) in mirror.children {
            let childMirror = Mirror(reflecting: value)
            if let key = key, childMirror.displayStyle == .`enum`, let type = childMirror.subjectType as? RCEnumType.Type {
                output?[key] = type
            }
        }
        
        return (output?.count ?? 0) > 0 ? output : nil
    }
    
    public func keysValuesForEnums() -> [String: Any]? {
        var output:[String: Any]? = [String: Any]()
        let mirror = Mirror(reflecting: self)
        for (key, value) in mirror.children {
            let childMirror = Mirror(reflecting: value)
            if let key = key, childMirror.displayStyle == .`enum`, childMirror.subjectType is RCEnumType.Type {
                output?[key] = value
            }
        }
        
        return (output?.count ?? 0) > 0 ? output : nil
    }
    
    override public func setValue(_ value: Any!, forUndefinedKey key: String) {
        guard  keysForEnums()?[key] != nil else {
            super.setValue(value, forUndefinedKey: key)
            return
        }
    }
    
    override public func propertyConverters() ->  [(String?, ((Any?)->())?, (() -> Any?)? )] {
        var transforming = [(String?, ((Any?)->())?, (() -> Any?)? )]()
        
        let transformers = self.transforming()
        
        for trans in  transformers {
            transforming.append((trans.propertyName
                , { self.setValue(trans.transformedValue($0), forKey: trans.propertyName) }
                , { return trans.reverseTransformedValue($0)}))
        }
        
        return transforming
    }
    
    override public func propertyMapping() -> [(String?, String?)] {
        var mapping = [(String?, String?)]()
        for (k,v) in self.mapping() {
            mapping.append((k, v))
        }
        
        return mapping
    }
    
    private static func removeNSNull(dict: [String : Any]) -> [String : Any] {
        var updatedDict = [String : Any]()
        for (k,v) in dict {
            if let array = v as? NSArray {
                updatedDict[k] = removeNSNull(array: array as? [Any] ?? [])
            } else if let dict = v as? NSDictionary {
                updatedDict[k] = removeNSNull(dict: dict as? [String: Any] ?? [:])
            } else if v is NSNull || (v as? String) ?? "" == "<null>" {
                continue
            } else {
                updatedDict[k] = v
            }
        }
        
        return updatedDict
    }
    
    private static func removeNSNull(array: [Any]) -> [Any] {
        var updatedArray = [Any]()
        for v in array {
            if let array = v as? NSArray {
                updatedArray.append(removeNSNull(array: array as? [Any] ?? []))
            } else if let dict = v as? NSDictionary {
                updatedArray.append(removeNSNull(dict: dict as? [String : Any] ?? [:]))
            } else if v is NSNull || (v as? String) ?? "" == "<null>" {
                continue
            } else {
                updatedArray.append(v)
            }
        }
        
        return updatedArray
    }
}
