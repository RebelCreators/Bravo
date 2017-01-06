/*
 * Copyright (c) 2015 Magnet Systems, Inc.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
 
#import <Foundation/Foundation.h>
#import "MMModel.h"

typedef NS_ENUM(NSInteger, RCServiceIOType){
    RCServiceIOTypeVoid = 0,
    RCServiceIOTypeString,
    RCServiceIOTypeEnum,
    RCServiceIOTypeBoolean,
    RCServiceIOTypeChar, // byte in Java
    RCServiceIOTypeUnichar, // char in Java
    RCServiceIOTypeShort,
    RCServiceIOTypeInteger,
    RCServiceIOTypeLongLong, // long in Java
    RCServiceIOTypeFloat,
    RCServiceIOTypeDouble,
    RCServiceIOTypeBigDecimal, // TBD
    RCServiceIOTypeBigInteger, // TBD
    RCServiceIOTypeDate,
    RCServiceIOTypeUri, // TBD
    RCServiceIOTypeArray,
    RCServiceIOTypeDictionary,
    RCServiceIOTypeData, // TBD
    RCServiceIOTypeBytes, // TBD
    RCServiceIOTypeMagnetNode,
};

@protocol MMEnumAttributeContainer;

@interface MMValueTransformer : NSValueTransformer

+ (instancetype)dateTransformer;

+ (instancetype)urlTransformer;

+ (instancetype)dataTransformer;

+ (instancetype)unicharTransformer;

+ (instancetype)floatTransformer;

+ (instancetype)doubleTransformer;

+ (instancetype)longLongTransformer;

+ (instancetype)booleanTransformer;

+ (instancetype)enumTransformerForContainerClass:(Class<MMEnumAttributeContainer>)containerClass;

+ (instancetype)resourceNodeTransformerForClass:(Class)clazz;

+ (instancetype)listTransformerForType:(RCServiceIOType)type clazz:(Class)clazz;

+ (instancetype)mapTransformerForType:(RCServiceIOType)type clazz:(Class)clazz;

+ (instancetype)bigDecimalTransformer;

+ (RCServiceIOType)serviceTypeForClass:(Class)clazz;

@end
