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


#import <Foundation/Foundation.h>

#import "RCError.h"
#import "RCPropertyKey.h"
#import "RCEnumMappable.h"

@protocol RCModel

- (nonnull instancetype)init;
+ (nonnull instancetype)alloc;

@optional

+ (nonnull NSDictionary<NSString *, Class<RCModel>> *)arrayClasses;
+ (nonnull NSDictionary<NSString *, Class<RCModel>> *)dictionaryClasses;
+ (nonnull NSDictionary<NSString *, Class<RCEnumMappable>> *)enumClasses;
+ (nonnull NSDictionary<NSString *, id<RCPropertyKey>> *)outputPropertyMappings;
+ (nonnull NSDictionary<NSString *, id<RCPropertyKey>> *)propertyMappings;
+ (nonnull NSDictionary<NSString *, NSValueTransformer *> *)transformersForProperties;
- (BOOL)validateModel:(NSError * _Nullable * _Nullable)error;

@end

@interface RCModelFactory<ModelType> : NSObject

+ (nullable ModelType)modelForClass:(nonnull Class<RCModel>)clazz
                         JSONObject:(nonnull id)JSONObject
                              error:(NSError<RCError> * _Nullable* _Nullable)error;

+ (nullable ModelType)modelForClass:(nonnull Class<RCModel>)clazz
                               JSON:(nonnull NSString *)JSON
                              error:(NSError<RCError> * _Nullable* _Nullable)error;

+ (nullable id)modelToJSONObject:(nonnull id<RCModel>)model
                           error:(NSError<RCError> * _Nullable* _Nullable)error;

+ (nullable NSString *)modelToJSONString:(nonnull id<RCModel>)model
                                   error:(NSError<RCError> * _Nullable* _Nullable)error;

+ (nonnull NSArray <NSString *>*)propertiesForClass:(nonnull Class<RCModel>)clazz;

+ (nonnull NSDictionary<NSString *, id<RCPropertyKey>> *)standardPropertyMappingsForClass:(nonnull Class<RCModel>)clazz;

@end

