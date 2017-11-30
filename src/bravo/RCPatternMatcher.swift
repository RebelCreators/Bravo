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

public class RCPatternMatcher: NSObject {
    
    var unmatchedParameters:[String: Any]?
    var matchedString:String
    
    public init(string: String, with dict: [String: Any]) {
       let matched = RCPatternMatcher.match(string: string, with: dict)
        matchedString = matched.0
        unmatchedParameters = matched.1.keys.count > 0 ? matched.1 : nil
        
        super.init()
    }
    
    private class func match(string: String, with dict: [String: Any]) -> (String, [String: Any]) {
        let regex = try! NSRegularExpression(pattern: ":([a-z0-9]+)", options: .caseInsensitive)
        let results = regex.matches(in: string, options: [], range: NSMakeRange(0, string.count))
        var output = string as NSString
        if let m = results.first {
            let key = (string as NSString).substring(with: m.rangeAt(1))
            let param = String(describing: dict[key]!)
            if param.count > 0 {
                output = output.replacingCharacters(in: m.range, with: param) as NSString
                var newDict = dict
                newDict.removeValue(forKey: key)
                return match(string: output as String, with: newDict)
            }
        }
        
        return (output as String, dict)
    }
}
