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

open class RCValueTransformer:NSObject {
    private var forward: ((Any) -> Any?)
    private var reverse: ((Any) -> Any?)?
    private(set) var propertyName: String
    
    public init(propertyName: String, forward: @escaping ((Any) -> Any?), reverse: ((Any) -> Any?)?) {
        self.forward = forward
        self.reverse = reverse
        self.propertyName = propertyName
    }
    
    open func transformedValue(_ value: Any?) -> Any? {
        return forward(value)
    }
    
    open func reverseTransformedValue(_ value: Any?) -> Any? {
       return reverse?(value)
    }
}
    

