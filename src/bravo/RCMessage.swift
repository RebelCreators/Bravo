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

public let RCMessageKey = "com.rebel.creators.message.key"

public protocol RCPayload {
    static var contentType: String {get}
}

public class RCMessage: RCModel {
    public var senderId: String?
    public var dialogId: String?
    public var date: Date?
    
    internal var payloads = [RCPayloadWrapper]()
    
    public func hasPayloadType<T: RCModel where T:RCPayload>(type: T.Type) -> Bool {
        let payload: T? = payloadForClass()
        return payload != nil
    }
    
    public func appendPayload<T: RCModel where T:RCPayload>(payload: T) {
        payloads.append(RCPayloadWrapper.create(objectType: type(of: payload).contentType, object: payload))
    }
    
    public func payloadsForClass<T: RCModel where T:RCPayload>() -> [T]{
        return payloads.filter({ return $0.type == T.contentType }).map({ $0.hydrateObject() })
    }
    
    public func payloadForClass<T: RCModel where T:RCPayload>() -> T? {
        return payloadsForClass().first
    }
}

extension RCMessage {
    open override class func listAttributeTypes() -> [AnyHashable : Any]! {
        return (super.listAttributeTypes() ?? [:]) + ["payloads": RCPayloadWrapper.self]
    }
}

internal class RCPayloadWrapper: RCModel {
    override var dictionaryValue:[AnyHashable : Any] {
        var dict = super.dictionaryValue!
        var string = object?.toJsonString() ?? ""
        dict["contents"] = string.toBase64()
        return dict
    }
    var type: String?
    var contents: String?
    fileprivate var object: RCModel?
    
    fileprivate static func create(objectType: String, object: RCModel) -> RCPayloadWrapper {
        let wrapper = RCPayloadWrapper()!
        wrapper.object = object
        wrapper.type = objectType
        return wrapper
    }
    
    override class func ommitKeys() -> [String] {
        return super.ommitKeys() + ["object"]
    }
    
    fileprivate func hydrateObject<T: RCModel>() -> T {
        guard let obj = object else {
            var string = contents?.fromBase64() ?? ""
            let object = T.generate(fromJson: string) as! T
            self.object = object
            
            return object
        }
        return object as! T
    }
}
