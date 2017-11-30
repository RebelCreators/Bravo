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


#import "RCTransformer.h"

@interface RCTransformer()

@property(nonatomic, copy) RCTransformationBlock forwardBlock;
@property(nonatomic, copy) RCTransformationBlock reverseBlock;

@end

@implementation NSValueTransformer(RCTransformer)

- (nullable id)transformedValue:(nullable id)value error:(NSError * _Nullable* _Nullable)error {
    return [self transformedValue:value];
}

- (nullable id)reverseTransformedValue:(nullable id)value error:(NSError * _Nullable* _Nullable)error {
    return [self reverseTransformedValue:value];
}

@end

@implementation RCTransformer

- (nonnull instancetype)initWithForwardBlock:(RCTransformationBlock)forward reverseBlock:(RCTransformationBlock)reverse {
    if (self = [super init]) {
        self.forwardBlock = forward;
        self.reverseBlock = reverse;
    }
    
    return self;
}

- (id)transformedValue:(id)value {
    return self.forwardBlock(value, nil);
}

- (id)reverseTransformedValue:(id)value {
    return self.reverseBlock(value, nil);
}

- (nullable id)transformedValue:(nullable id)value error:(NSError * _Nullable* _Nullable)error {
    return self.forwardBlock(value, error);
}

- (nullable id)reverseTransformedValue:(nullable id)value error:(NSError * _Nullable* _Nullable)error {
    return self.reverseBlock(value, error);
}

- (BOOL)allowsReverseTransformation {
    return YES;
}

@end
