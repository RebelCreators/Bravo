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

public class RCMessage: RCModel {
    public var dialog: RCDialog?
    public var sender: RCUser?
    
    internal var payloads = [RCModel]()
    
    public func hasPayloadType(type: RCModel.Type) -> Bool {
        return payloadForClass() != nil
    }
    
    public func appendPayload(model: RCModel) {
        payloads.append(model)
    }
    
    public func filterPayload(_ filter: (RCModel) -> Bool) -> [RCModel] {
        return payloads.filter({ return  filter($0) })
    }
    
    public func filteringPayload(_ filter: (RCModel) -> Bool) {
        payloads = filterPayload(filter)
    }
    
    public func payloadsForClass<T: RCModel>() -> [T]{
        return payloads.filter({ $0 is T }) as! [T]
    }
    
    public func payloadForClass<T: RCModel>() -> T? {
        return payloadsForClass().first
    }
}
