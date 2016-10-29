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

import UIKit

public protocol WebServiceOp {
    func exeInBackground(dependencies: [Operation?]?, requirements: [Operation?]?)
    func exeInBackground(dependencies: [Operation?]?)
    func exeInBackground(requirements: [Operation?]?)
    func exeInBackground()
    func onFinished(_ block: @escaping (() -> Void)) -> WebServiceBlockOp
    func asOperation() -> Operation
}

open class WebServiceBlockOp: RCAsyncBlockOperation, WebServiceOp {
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .background)
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    private var didFinish: (() -> Void)?
    
    public func asOperation() -> Operation {
        return self
    }
    
    @discardableResult
    open func onFinished(_ block: @escaping (() -> Void)) -> WebServiceBlockOp {
        didFinish = block
        return self
    }
    
    open override func finish() {
        super.finish()
        self.didFinish?()
        self.didFinish = nil
    }
    
    open func exeInBackground(dependencies: [Operation?]?) {
        exeInBackground(dependencies: dependencies, requirements: nil)
    }
    
    open func exeInBackground(requirements: [Operation?]?) {
        exeInBackground(dependencies: nil, requirements: requirements)
    }
    
    open func exeInBackground() {
        exeInBackground(dependencies: nil, requirements: nil)
    }
    
    open func exeInBackground(dependencies: [Operation?]?, requirements: [Operation?]?) {
        
        for op in dependencies ?? [] {
            if let op = op {
                if !op.isFinished && !op.isCancelled {
                    addDependency(op)
                }
            }
        }
        
        for op in requirements ?? [] {
            if let op = op {
                queue.addOperation(op)
                addDependency(op)
            }
        }
        
        queue.addOperation(self)
    }
}
