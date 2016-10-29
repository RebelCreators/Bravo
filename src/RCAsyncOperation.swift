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

open class RCAsyncOperation: Operation {
    
    private var _executing = false
    private var _finished = false
    private var _cancelled = false
    private var finishAfterStart = false
    
    override open var isAsynchronous: Bool { return true }
    
    open override var isCancelled: Bool {
        set {
            willChangeValue(forKey: "isCancelled")
            _cancelled = newValue
            didChangeValue(forKey: "isCancelled")
        }
        
        get {
            return _cancelled
        }
    }
    
    open override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
        
        get {
            return _executing
        }
    }
    
    open override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
        
        get {
            return _finished
        }
    }
    
    open override func start() {
        if finishAfterStart {
            self.finish()
            
            return;
        }
        if !self.isCancelled && self.isReady {
            self.execute()
        }
    }
    
    open override func cancel() {
        if !self.isCancelled && !self.isFinished {
            self.isFinished = true
        }
    }
    
    open func finish() {
        if !self.isReady {
            finishAfterStart = true
            return;
        }
        if !self.isCancelled && !self.isFinished {
            self.isFinished = true
        }
    }
    
    open func execute() {
        assertionFailure("Implement Execute -  RCAsyncOperation")
    }
}
