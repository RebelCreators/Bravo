// Copyright (c) 2017 Rebel Creators
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


#import <Foundation/Foundation.h>

#import "RCModelFactory.h"
#import "RCPropertyKey.h"


@interface RCModel : NSObject <RCModel, NSCopying, NSCoding>

//NSCoding

+ (nonnull NSArray <NSString *> *)propertiesForNSCoding;

- (nonnull instancetype)init;

+ (nullable instancetype)fromJSONString:(nonnull NSString *)jsonString error:(NSError<RCError> * _Nullable * _Nullable)error;
+ (nullable instancetype)fromDictionary:(nonnull NSDictionary<NSString *, NSObject *> *)dict error:(NSError<RCError> * _Nullable * _Nullable)error;

- (nullable NSString *)toJSONString:(NSError<RCError> * _Nullable * _Nullable)error;
- (nullable NSDictionary<NSString *, NSObject *> *)toDictionary:(NSError<RCError> * _Nullable * _Nullable)error;


@end

