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


#import "RCCommonTransfromers.h"

#import "RCError.h"

@implementation RCCommonTransfromers

+ (nonnull NSValueTransformer<RCTransformer> *)base64DataTransformer {
    static dispatch_once_t onceToken;
    static RCTransformer *transformer;
    dispatch_once(&onceToken, ^{
        transformer = [[RCTransformer alloc] initWithForwardBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            
            if (![value isKindOfClass:[NSString class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Type not a base64 encoded string"] withPointer:error];
                return nil;
            }
            NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:0];
            return data;
        } reverseBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            if (![value isKindOfClass:[NSData class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Type not an NSData"] withPointer:error];
                return nil;
            }
            NSData *data = [(NSData *)value base64EncodedDataWithOptions:0];
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }];
    });
    return transformer;
}

+ (nonnull NSValueTransformer<RCTransformer> *)base64StringTransformer {
    static dispatch_once_t onceToken;
    static RCTransformer *transformer;
    dispatch_once(&onceToken, ^{
        transformer = [[RCTransformer alloc] initWithForwardBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            NSError *transformerError;
            NSData *data = [[self base64DataTransformer] transformedValue:value
                                                                    error:&transformerError];
            [RCError resolveError:transformerError withPointer:error];
            if (transformerError || !data) {
                return nil;
            }
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } reverseBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            if (![value isKindOfClass:[NSString class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Type not an NSString"] withPointer:error];
                return nil;
            }
            NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
            return [[self base64DataTransformer] reverseTransformedValue:data error:error];
        }];
    });
    return transformer;
}

+ (NSValueTransformer<RCTransformer> *)RFC3339DateTransformer {
    static dispatch_once_t onceToken;
    static RCTransformer *transformer;
    dispatch_once(&onceToken, ^{
        NSDateFormatter *dateFormatter = nil;
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        transformer = [[RCTransformer alloc] initWithForwardBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            if ([value isKindOfClass:[NSDate class]]) {
                return value;
            }
            if (![value isKindOfClass:[NSString class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Type not a string"] withPointer:error];
                return nil;
            }
            
            return [dateFormatter dateFromString:value];
        } reverseBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            if (![value isKindOfClass:[NSDate class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Type not a Date"] withPointer:error];
                return nil;
            }
            return [dateFormatter stringFromDate:value];
        }];
    });
    return transformer;
}

+ (NSValueTransformer<RCTransformer> *)stringTransformer {
    static dispatch_once_t onceToken;
    static RCTransformer *transformer;
    dispatch_once(&onceToken, ^{
        transformer = [[RCTransformer alloc] initWithForwardBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            
            return [NSString stringWithFormat:@"%@", value];
        } reverseBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            if (![value isKindOfClass:[NSString class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Type not a string"] withPointer:error];
                return nil;
            }
            return value;
        }];
        
    });
    return transformer;
}

+ (nonnull NSValueTransformer<RCTransformer> *)timestampDateTransformer {
    static dispatch_once_t onceToken;
    static RCTransformer *transformer;
    dispatch_once(&onceToken, ^{
        transformer = [[RCTransformer alloc] initWithForwardBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            if ([value isKindOfClass:[NSDate class]]) {
                return value;
            }
            
            if (![value isKindOfClass:[NSNumber class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Type not an NSNumber"] withPointer:error];
                return nil;
            }
            
            return [NSDate dateWithTimeIntervalSinceNow:[value doubleValue]];
        } reverseBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            if (![value isKindOfClass:[NSDate class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Type not a Date"] withPointer:error];
                return nil;
            }
            return @([(NSDate *)value timeIntervalSince1970]);
        }];
    });
    return transformer;
}




+ (NSError *)errorWithCode:(NSInteger)code reason:(NSString *)reason {
    return [NSError errorWithDomain:@"RCCommonTransformers" code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(reason, reason)}];
}

@end
