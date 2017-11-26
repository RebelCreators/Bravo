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


#import "RCError.h"

@interface RCError()

@property (nonatomic, strong) RCError *nextError;

@end


@implementation RCError

+ (BOOL)resolveError:(NSError *)error withPointer:(NSError **)pointer {
    if (!error || !pointer) {
        return NO;
    }
    if (error == *pointer) {
        return YES;
    }
    RCError *rcError = [RCError cast:error];
    RCError *pointerError = [RCError cast:*pointer];
    if (!pointerError) {
        *pointer = rcError;
    } else {
        *pointer = [pointerError shiftToFront:rcError];
    }
    return YES;
}

- (NSError <RCError> *)pushToEnd:(NSError *)error {
    RCError *rcError = self;
    while (rcError.nextError) {
        rcError = rcError.nextError;
    }
    rcError.nextError = [RCError cast:error];
    return rcError;
}

- (NSError <RCError> *)shiftToFront:(NSError *)error {
    RCError *rcError = [RCError cast:error];
    while (rcError.nextError) {
        rcError = rcError.nextError;
    }
    [rcError pushToEnd:self];
    
    return rcError;
}

- (NSString *)description {
    if (!self.nextError) {
        return [NSString stringWithFormat:@"%@", [super description]];
    } else {
        return [NSString stringWithFormat:@"%@\n%@", [super description], [self.nextError description]];
    }
}

+ (RCError *)cast:(NSError *)error {
    if (!error) {
        return nil;
    }
    if ([error isKindOfClass:[self class]]) {
        return (RCError *)error;
    }
    
    return [self errorWithDomain:error.domain
                            code:error.code
                        userInfo:error.userInfo];
}

@end
