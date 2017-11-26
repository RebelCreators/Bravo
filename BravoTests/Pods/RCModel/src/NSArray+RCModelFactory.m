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


#import "NSArray+RCModelFactory.h"

#import "RCClassTransformers.h"

@implementation NSArray (RCModelFactory)

+ (NSArray<id<RCModel>> *)arrayForClass:(Class<RCModel>)clazz
                                  array:(NSArray *)array
                                  error:(NSError<RCError> **)error {
    if (array && ![array isKindOfClass:[NSArray class]]) {
        [RCError resolveError:[self errorWithCode:500 reason:@"Input not an array"]
                  withPointer:error];
        return nil;
    }
    
    NSMutableArray *newArray = [NSMutableArray new];
    for (id object in array) {
        RCError *parsingError;
        id model = [RCModelFactory modelForClass:clazz JSONObject:object error:&parsingError];
        [RCError resolveError:parsingError
                  withPointer:error];
        
        if (model) {
            if (![model isKindOfClass:clazz]) {
                NSError *parseError = [self errorWithCode:500 reason:[NSString stringWithFormat:@"Type error expected %@ got %@", NSStringFromClass(clazz), NSStringFromClass([model class])]];
                [RCError resolveError:parseError
                          withPointer:error];
            }
            [newArray addObject:model];
        }
    }
    return newArray.copy;
}

- (NSArray *)toJSONObject:(NSError<RCError> **)error {
    NSMutableArray *newArray = [NSMutableArray new];
    for (id object in self) {
        if ([object conformsToProtocol:@protocol(RCModel)]) {
            NSError *parsingError;
            id jsonObject = [RCModelFactory modelToJSONObject:(id<RCModel>)object  error:&parsingError];
            [RCError resolveError:parsingError withPointer:error];
            if (jsonObject) {
                [newArray addObject:jsonObject];
            }
        } else {
            id<RCTransformer> transformer = [RCClassTransformers defaultTransformerForClass:[object class]];
            if (transformer) {
                NSError *parsingError;
                id jsonObject = [transformer reverseTransformedValue:object error:&parsingError];
                [RCError resolveError:parsingError withPointer:error];
                if (jsonObject) {
                    [newArray addObject:jsonObject];
                }
            } else {
                [newArray addObject:object];
            }
        }
    }
    return newArray.copy;
}

+ (NSError *)errorWithCode:(NSInteger)code reason:(NSString *)reason {
    return [NSError errorWithDomain:@"RCArray" code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(reason, reason)}];
}

@end
