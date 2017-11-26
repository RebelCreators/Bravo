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

public enum BravoError: Error {
    case InvalidParameter(message: String)
    case ConditionNotMet(message: String)
    case NoPassword
    case AccessDenied(message: String)
    case NotFound(message: String?)
    case UnexpectedError(message: String)
    case HttpError(message: String, code: Int)
    case OtherNSError(nsError: NSError)
    case WithError(error: Error)
    
    public var code: Int {
        switch self {
        case .InvalidParameter:
            return 400
        case .ConditionNotMet:
            return 412
        case .NoPassword:
            return 404
        case .UnexpectedError:
            return 500
        case let .OtherNSError(nsError):
            return nsError.code
        case .AccessDenied:
            return 401
        case .NotFound:
            return 404
        case let .HttpError(_, code):
            return code
        case let .WithError(error):
            return 1000
        }
        
    }
    public var description: String {
        switch self {
        case let .InvalidParameter(message):
            return message
        case let .ConditionNotMet(message):
            return message
        case .NoPassword:
            return "No Password"
        case let .UnexpectedError(message):
            return message
        case let .OtherNSError(nsError):
            return nsError.localizedDescription
        case let .AccessDenied(message):
            return message
        case let .NotFound(message):
            return message ?? "" + " (Not Found)"
        case let .HttpError(message, code):
            return "\(message) - \(code)"
        case let .WithError(error):
            return error.localizedDescription
        }
    }
    
    public var localizedDescription: String {
        return description
    }
}
