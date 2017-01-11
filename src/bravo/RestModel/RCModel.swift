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
        
        guard let T = Element.self as? RModel.Type else {
            return nil
        }
        
        var a: [RModel] = []
        for o in array {
            if let obj = T.generate(from: o) as? RModel {
                a.append(obj)
            }
        }
        
        return a
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
                dict[key] = v
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

@objc open class RCModel: MMModel, RModel, RCParameter {
    
    public subscript(strings: [String]) -> RCParameterDictionary {
        return self.toParameterDictionary().union(keys: strings)
    }
    
    open static func generate<T: RModel>(fromJson: String) -> T {
        let data = fromJson.data(using: .utf8)!
        let dict = try! JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
        return T.generate(from: dict) as! T
    }
    
    open static func generate(from: Any) -> Any? {
        guard let dict  = from as? [AnyHashable: Any] else {
            return nil
        }
        
        return try? MTLJSONAdapter.model(of: self, fromJSONDictionary: dict)
    }
    
    open func toParameterDictionary() -> RCParameterDictionary {
        return self.toDictionary() as! RCParameterDictionary
    }
    
    open func toDictionary() -> NSDictionary {
        let dict = (try? MTLJSONAdapter.jsonDictionary(fromModel: self)) as? NSDictionary
        return dict ?? NSDictionary()
    }
    
    open func toJsonString() -> String {
        return String(data: try! JSONSerialization.data(withJSONObject: self.toDictionary(), options: .prettyPrinted), encoding: .utf8)!
    }
}
