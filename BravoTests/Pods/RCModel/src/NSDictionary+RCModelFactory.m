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


#import "NSDictionary+RCModelFactory.h"

#import "RCClassTransformers.h"

@implementation NSDictionary (RCModelFactory)

+ (NSDictionary<NSString *,id<RCModel>> *)dictionaryForClass:(Class<RCModel>)clazz
                                                  dictionary:(NSDictionary *)dictionary
                                                       error:(NSError<RCError> **)error {
    if (dictionary && ![dictionary isKindOfClass:[NSDictionary class]]) {
        [RCError resolveError:[self errorWithCode:500 reason:@"Input not a dictionary"]
                  withPointer:error];
        return nil;
    }
    
    NSMutableDictionary *newDict = [NSMutableDictionary new];
    for (NSString *key in dictionary) {
        id object = dictionary[key];
        RCError *parsingError;
        id model = [RCModelFactory modelForClass:clazz JSONObject:object error:&parsingError];
        [RCError resolveError:parsingError
                  withPointer:error];
        
        if (model) {
            if (![model isKindOfClass:clazz]) {
                NSError *parseError = [self errorWithCode:500 reason:[NSString stringWithFormat:@"Type error expected %@ got %@ for key %@", NSStringFromClass(clazz), NSStringFromClass([model class]), key]];
                [RCError resolveError:parseError
                          withPointer:error];
            }
            newDict[key] = model;
        }
    }
    return newDict.copy;
}

- (NSDictionary <NSString *, id>*)toJSONObject:(NSError<RCError> **)error {
    NSMutableDictionary <NSString *, id>* newDict = [NSMutableDictionary new];
    for (NSString *key in self) {
        if (![key isKindOfClass:[NSString class]]) {
            [RCError resolveError:[[self class] errorWithCode:500
                                                       reason:[NSString stringWithFormat:@"Dictionary key %@ not NSSting", NSStringFromClass([key class])]]
                      withPointer:error];
            continue;
        }
        id object = self[key];
        if ([object conformsToProtocol:@protocol(RCModel)]) {
            NSError *parsingError;
            id jsonObject = [RCModelFactory modelToJSONObject:(id<RCModel>)object  error:&parsingError];
            [RCError resolveError:parsingError withPointer:error];
            if (jsonObject) {
                newDict[key] = jsonObject;
            }
        } else {
            id<RCTransformer> transformer = [RCClassTransformers defaultTransformerForClass:[object class]];
            if (transformer) {
                NSError *parsingError;
                id jsonObject = [transformer reverseTransformedValue:object error:&parsingError];
                [RCError resolveError:parsingError withPointer:error];
                if (jsonObject) {
                    newDict[key] = jsonObject;
                }
            } else {
                newDict[key] = object;
            }
        }
    }
    return newDict.copy;
}

+ (NSError *)errorWithCode:(NSInteger)code reason:(NSString *)reason {
    return [NSError errorWithDomain:@"RCDictionary" code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(reason, reason)}];
}

@end
