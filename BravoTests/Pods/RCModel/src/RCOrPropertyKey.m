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


#import "RCOrPropertyKey.h"

@interface RCOrPropertyKey()

@property(nonatomic, copy) NSString *value;
@property(nonatomic, copy) RCOrPropertyKey *parent;

@end

@implementation RCOrPropertyKey

- (instancetype)initWithKey:(NSString *)key {
    if (self = [super init]) {
        self.value = key;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    RCOrPropertyKey *copy = [[RCOrPropertyKey alloc] initWithKey:self.value];
    copy.parent = self.parent;
    
    return copy;
}

- (RCOrPropertyKey *)OR:(NSString *)key {
    RCOrPropertyKey *copy = [self copy];
    copy.value = key;
    copy.parent = self;
    
    return copy;
}

- (NSArray<NSString *> *)propertyKey {
    if (self.parent) {
        NSMutableArray *parentArray = self.parent.propertyKey.mutableCopy;
        [parentArray addObject:self.value];
        return parentArray.copy;
    }
    return @[self.value];
}

@end
