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


#import "RCModel.h"

@implementation RCModel

- (nullable NSString *)toJSONString:(NSError<RCError> * _Nullable * _Nullable)error {
    return [RCModelFactory modelToJSONString:self error:error];
}

- (nullable NSDictionary<NSString *, NSObject *> *)toDictionary:(NSError<RCError> * _Nullable * _Nullable)error {
    return [RCModelFactory modelToJSONObject:self error:error];
}

+ (nullable instancetype)fromJSONString:(nonnull NSString *)jsonString error:(NSError<RCError> * _Nullable * _Nullable)error {
    return [RCModelFactory modelForClass:[self class] JSON:jsonString error:error];
}

+ (nullable instancetype)fromDictionary:(nonnull NSDictionary<NSString *, NSObject *> *)dict error:(NSError<RCError> * _Nullable * _Nullable)error {
    return [RCModelFactory modelForClass:[self class] JSONObject:dict error:error];
}

+ (NSDictionary<NSString *, id<RCPropertyKey>> *)propertyMappings {
    return [RCModelFactory standardPropertyMappingsForClass:self];
}

+ (NSDictionary<NSString *, id<RCPropertyKey>> *)outputPropertyMappings {
    return [self propertyMappings];
}

+ (nonnull NSDictionary<NSString *, Class<RCEnumMappable>> *)enumClasses {
    return @{};
}

+ (NSDictionary<NSString *, Class<RCModel>> *)arrayClasses {
    return @{};
}

+ (NSDictionary<NSString *, Class<RCModel>> *)dictionaryClasses {
    return @{};
}

+ (NSDictionary<NSString *, NSValueTransformer *> *)transformersForProperties {
    return @{};
}

+ (NSError *)errorWithCode:(NSInteger)code reason:(NSString *)reason {
    return [NSError errorWithDomain:@"RCModel" code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(reason, reason)}];
}

@end
