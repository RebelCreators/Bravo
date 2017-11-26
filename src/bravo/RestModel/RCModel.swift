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

@objc public class RCNullModel: RCModel {
    static var null = RCNullModel()
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

extension Array: RModel {
    
    public static func generate(from: Any) -> Any? {
        guard let array  = from as? [Any] else {
            return nil
        }
        
        guard let T = Element.self as? RCModelProtocol.Type else {
            return nil
        }
        
        return try? NSArray(forClass: T, array: array)
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
    
    public func toParameterDictionary() -> RCParameterDictionary {
        var dict = RCParameterDictionary()
        for (k, v) in self {
            guard let key = k as? String else {
                continue
            }
            
            guard let model = v as? RCModel else {
                guard let model = v as? RCModelProtocol else {
                    if let object = v as? AnyObject {
                        if let transformer = RCClassTransformers.defaultTransformer(for: type(of: object)) {
                            dict[key] = try? transformer.reverseTransformedValue(object)
                            continue
                        }
                    }
                    dict[key] = v
                    
                    continue
                }
                dict[key] = try? RCModelFactory<AnyObject>.model(toJSONObject: model)
                
                continue
            }
            
            dict[key] = model.toParameterDictionary()
        }
        
        return dict
    }
}


extension NSDictionary: RCParameter {
    
    public func toParameterDictionary() -> RCParameterDictionary {
        var dict = RCParameterDictionary()
        for (k, v) in self {
            guard let key = k as? String else {
                continue
            }
            
            guard let model = v as? RCModel else {
                dict[key] = v
                continue
            }
            
            dict[key] = model.toParameterDictionary()
        }
        
        return dict
    }
}


extension RCModel: RModel, RCParameter {
    
    @objc public subscript(strings: [String]) -> RCParameterDictionary {
        return self.toParameterDictionary().union(keys: strings)
    }
    
    open class func generate<T: RCModel>(fromJson: String) -> T? {
        return try? (RCModelFactory.model(forClass: T.self, json: fromJson) as T)
    }
    
    @objc open class func generate(from: Any) -> Any? {
        return try? (RCModelFactory.model(forClass: self, jsonObject: from) as AnyObject)
    }
    
    @objc open func toParameterDictionary() -> RCParameterDictionary {
        return (try? self.toDictionary() as RCParameterDictionary) ?? [:]
    }
}
