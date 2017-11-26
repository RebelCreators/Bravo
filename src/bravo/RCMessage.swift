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

public let RCMessageKey = "com.rebel.creators.message.key"

public protocol RCPayload {
    static var contentType: String {get}
}

public class RCMessage: RCModel {
    public var senderId: String?
    public var dialogId: String?
    public var date: Date?
    public var extras = [String: String]()
    
    internal var payloads = [RCPayloadWrapper]()
    
    public func hasPayloadType<T: RCModel>(type: T.Type) -> Bool where T:RCPayload {
        let payload: T? = payloadForClass()
        return payload != nil
    }
    
    public func appendPayload<T: RCModel>(payload: T) where T:RCPayload {
        payloads.append(RCPayloadWrapper.create(objectType: type(of: payload).contentType, object: payload))
    }
    
    public func payloadsForClass<T: RCModel>() -> [T] where T:RCPayload {
        return payloads.filter({ return $0.type == T.contentType }).map({ $0.hydrateObject() }).filter({ $0 != nil }) as! [T]
    }
    
    public func payloadForClass<T: RCModel>() -> T? where T:RCPayload {
        return payloadsForClass().first
    }
}

extension RCMessage {
    
    open override class func arrayClasses() -> [String : RCModelProtocol.Type] {
        return (super.arrayClasses() ?? [:]) + ["payloads": RCPayloadWrapper.self]
    }
}

internal class RCPayloadWrapper: RCModel {
    var type: String?
    var contents: String?
    private var object: RCModel?
    
    fileprivate static func create(objectType: String, object: RCModel) -> RCPayloadWrapper {
        let wrapper = RCPayloadWrapper()
        wrapper.object = object
        wrapper.type = objectType
        return wrapper
    }
    
    override class func transformersForProperties() -> [String : ValueTransformer] {
        return super.transformersForProperties() + ["contents": RCCommonTransfromers.base64StringTransformer()]
    }
    
    override class func propertyMappings() -> [String : RCPropertyKey] {
        return super.propertyMappings() - ["object"]
    }
    
    fileprivate func hydrateObject<T: RCModel>() -> T? {
        guard let obj = object else {
            var string = contents?.fromBase64() ?? ""
            let object: T? = T.generate(fromJson: string)
            self.object = object
            
            return object
        }
        return object as! T
    }
}
