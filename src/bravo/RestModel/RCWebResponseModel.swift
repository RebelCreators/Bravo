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

import RCModel


public protocol RCWebResponseModel {
    
    static func generate(from: Any) throws -> Any?
    static var webResponseType: RCResponseType {get}
}


@objc internal class RCNullModel: NSObject, RCWebResponseModel {
    internal static var null = RCNullModel()
    
    public static func generate(from: Any) throws -> Any? {
        return null
    }
    
    public static var webResponseType: RCResponseType {
        return .nodata
    }
}


extension String: RCWebResponseModel {
    public static func generate(from: Any) throws -> Any? {
        return String(describing: from)
    }
    public static var webResponseType: RCResponseType {
        return .json
    }
}


extension Data: RCWebResponseModel {
    public static func generate(from: Any) throws -> Any? {
        return from as? Data
    }
    public static var webResponseType: RCResponseType {
        return .data
    }
}


extension Array: RCWebResponseModel {
    
    public static func generate(from: Any) throws -> Any? {
        guard let array  = from as? [Any] else {
            return nil
        }
        
        guard let T = Element.self as? RCModelProtocol.Type else {
            return nil
        }
        
        return try NSArray(forClass: T, array: array)
    }
    
    public static var webResponseType: RCResponseType {
        return .json
    }
}


extension Dictionary {
    public func union(keys: [Key]) -> Dictionary<Key, Value> {
        var dict = Dictionary<Key, Value>()
        for key in keys {
            if let value = self[key] {
                dict[key] = value
            }
        }
        
        return dict
    }
}


extension Dictionary: RCParameter {
    
    public func toParameterDictionary() throws -> RCParameterDictionary {
        var dict = RCParameterDictionary()
        for (k, v) in self {
            guard let key = k as? String else {
                continue
            }
            
            guard let model = v as? RCModel else {
                guard let model = v as? RCModelProtocol else {
                    let object = v as AnyObject 
                    if let transformer = RCClassTransformers.defaultTransformer(for: type(of: object)) {
                        dict[key] = try? transformer.reverseTransformedValue(object)
                        continue
                    }
                    dict[key] = v
                    
                    continue
                }
                dict[key] = try? RCModelFactory<AnyObject>.model(toJSONObject: model)
                
                continue
            }
            
            dict[key] = try model.toParameterDictionary()
        }
        
        return dict
    }
}


extension NSDictionary: RCParameter {
    
    public func toParameterDictionary() throws -> RCParameterDictionary {
        var dict = RCParameterDictionary()
        for (k, v) in self {
            guard let key = k as? String else {
                continue
            }
            
            guard let model = v as? RCModel else {
                dict[key] = v
                continue
            }
            
            dict[key] = try model.toParameterDictionary()
        }
        
        return dict
    }
}


extension RCModel: RCWebResponseModel, RCParameter {
    
    @objc public subscript(strings: [String]) -> RCParameterDictionary {
        return (try? self.toParameterDictionary().union(keys: strings)) ?? [:]
    }
    
    open class func generate(from: Any) throws -> Any? {
        return try RCModelFactory.model(forClass: self, jsonObject: from) as AnyObject
    }
    
    open func toParameterDictionary() throws -> RCParameterDictionary {
        return try self.toDictionary() as RCParameterDictionary
    }
    
    public static var webResponseType: RCResponseType {
        return .json
    }
}
