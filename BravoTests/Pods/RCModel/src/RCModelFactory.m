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


#import "RCModelFactory.h"

#import "NSArray+RCModelFactory.h"
#import "NSDictionary+RCModelFactory.h"
#import "objc/runtime.h"
#import "RCClassTransformers.h"
#import "RCCommonTransfromers.h"
#import "RCTransformer.h"

@interface RCModelPropertyDescription: NSObject
@property (nonatomic, strong) Class classType;
@end

@implementation RCModelPropertyDescription
@end

@interface RCModelDescription: NSObject

@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, copy) NSArray<NSString *> *allProperties;
@property (nonatomic, copy) NSDictionary<NSString *, Class<RCModel>> *arrayClasses;
@property (nonatomic, copy) NSDictionary<NSString *, Class<RCModel>> *dictionaryClasses;
@property (nonatomic, copy) NSDictionary<NSString *, id<RCTransformer>> *enumTransformers;
@property (nonatomic, copy) NSDictionary<NSString *, id<RCPropertyKey>> *outputPropertyMappings;
@property (nonatomic, copy) NSDictionary<NSString *, RCModelPropertyDescription *> *propertyDescriptions;
@property (nonatomic, copy) NSDictionary<NSString *, id<RCPropertyKey>> *propertyMappings;
@property (nonatomic, copy) NSDictionary<NSString *, id<RCTransformer>> *propertyTransformers;

@end

@implementation RCModelDescription
@end

@implementation RCModelFactory

+ (void)initialize {
    [super initialize];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [RCClassTransformers setDefaultTransformerForClass:[NSString class] transformer:[RCCommonTransfromers stringTransformer]];
        [RCClassTransformers setDefaultTransformerForClass:[NSDate class] transformer:[RCCommonTransfromers RFC3339DateTransformer]];
        [RCClassTransformers setDefaultTransformerForClass:[NSData class] transformer:[RCCommonTransfromers base64DataTransformer]];
    });
}

+ (NSDictionary<NSString *, id<RCPropertyKey>> *)standardPropertyMappingsForClass:(Class<RCModel>)clazz {
    NSArray *props = [self propertiesForClass:clazz];
    return [NSDictionary dictionaryWithObjects:props forKeys:props];
}

+ (NSArray <NSString *>*)propertiesForClass:(Class<RCModel>)clazz {
    if (clazz == [NSObject class]) {
        return @[];
    }
    RCModelDescription *description = [self _unsafeModelDescriptionForClass: clazz];
    NSMutableArray *properties = [NSMutableArray arrayWithArray:description.allProperties];
    Class<RCModel> superClass = (Class<RCModel>)[(Class)clazz superclass];
    while ([superClass.superclass conformsToProtocol:@protocol(RCModel)]) {
        [properties addObjectsFromArray:[self propertiesForClass:superClass]];
        superClass = superClass.superclass;
    }
    
    return properties.copy;
}

+ (instancetype)modelForClass:(Class<RCModel>)clazz
                   JSONObject:(id)JSONObject
                        error:(NSError<RCError> **)error {
    
    return [[self _modelTransformer: clazz] transformedValue:JSONObject error:error];
}

+ (instancetype)modelForClass:(Class<RCModel>)clazz
                         JSON:(NSString *)JSON
                        error:(NSError<RCError> **)error {
    @try {
        NSError *parsingError;
        id JSONObject = [NSJSONSerialization JSONObjectWithData:[JSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&parsingError];
        [RCError resolveError:parsingError withPointer:error];
        if (parsingError) {
            return nil;
        }
        return [self modelForClass:clazz JSONObject:JSONObject error:error];
    } @catch (NSException *exception) {
        [RCError resolveError:[self errorWithCode:500 reason:exception.reason] withPointer:error];
        return nil;
    }
}

+ (id)modelToJSONObject:(id<RCModel>)model
                  error:(NSError<RCError> **)error {
    return [[self _modelTransformer:[(NSObject *)model class]] reverseTransformedValue:model error:error];
}

+ (NSString *)modelToJSONString:(id<RCModel>)model
                          error:(NSError<RCError> **)error {
    NSError *parsingError;
    id JSONObject = [self modelToJSONObject:model error:&parsingError];
    [RCError resolveError:parsingError withPointer:error];
    if (parsingError) {
        return nil;
    }
    
    @try {
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject
                                                           options:0
                                                             error:&parsingError];
        [RCError resolveError:parsingError withPointer:error];
        if (parsingError || !JSONData) {
            return nil;
        }
        return [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        [RCError resolveError:[self errorWithCode:500 reason:exception.reason] withPointer:error];
        return nil;
    }
}

+ (NSMutableDictionary <NSString *, RCModelDescription *> *)_modelCache {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *dictionary;
    dispatch_once(&onceToken, ^{
        dictionary = [[NSMutableDictionary alloc] init];
    });
    return dictionary;
}

+ (RCModelDescription *)_modelDescriptionForClass:(Class<RCModel>)clazz {
    @synchronized ([RCModelFactory class]) {
        NSMutableDictionary <NSString *, RCModelDescription *> *cache = [RCModelFactory class]._modelCache;
        RCModelDescription *description = cache[NSStringFromClass(clazz)];
        if (description && description.isReady) {
            return description;
        }
        
        description = [self _unsafeModelDescriptionForClass: clazz];
        if ([(Class)clazz respondsToSelector:@selector(propertyMappings)]) {
            description.propertyMappings = [clazz propertyMappings];
        } else {
            description.propertyMappings = [self standardPropertyMappingsForClass:clazz];
        }
        description.outputPropertyMappings = [(Class)clazz respondsToSelector:@selector(outputPropertyMappings)] ? [clazz outputPropertyMappings] : description.propertyMappings;
        description.isReady = YES;
        
        return description;
    }
}

+ (RCModelDescription *)_unsafeModelDescriptionForClass:(Class<RCModel>)clazz {
    NSMutableDictionary <NSString *, RCModelDescription *> *cache = [RCModelFactory class]._modelCache;
    RCModelDescription *description = cache[NSStringFromClass(clazz)];
    if (description) {
        return description;
    }
    
    description = [[RCModelDescription alloc] init];
    unsigned int count, i;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    NSMutableDictionary<NSString *, RCModelPropertyDescription *> *propertyDescriptions = [[NSMutableDictionary alloc] init];
    for(i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            RCModelPropertyDescription *propertyDescription = [[RCModelPropertyDescription alloc] init];
            NSString *propertyName = [NSString stringWithCString:propName
                                                        encoding:[NSString defaultCStringEncoding]];
            const char *attributes = property_getAttributes(property);
            Class type;
            char buffer[1 + strlen(attributes)];
            strcpy(buffer, attributes);
            char *state = buffer, *attribute;
            while ((attribute = strsep(&state, ",")) != NULL) {
                if (attribute[0] == 'T' && attribute[1] == '@') {
                    NSString *classString = [[NSString alloc] initWithData:[NSData dataWithBytes:(attribute + 3)
                                                                                          length:strlen(attribute) - 4]
                                                                  encoding:NSUTF8StringEncoding];
                    if (classString) {
                        type = NSClassFromString(classString);
                        break;
                    }
                }
            }
            propertyDescription.classType = type;
            propertyDescriptions[propertyName] = propertyDescription;
        }
    }
    free(properties);
    
    description.propertyDescriptions = propertyDescriptions;
    description.allProperties = propertyDescriptions.allKeys ?: @[];
    description.arrayClasses = [(Class)clazz respondsToSelector:@selector(arrayClasses)] ? [clazz arrayClasses] : @{};
    description.dictionaryClasses = [(Class)clazz respondsToSelector:@selector(dictionaryClasses)] ? [clazz dictionaryClasses] : @{};
    description.propertyTransformers = [(Class)clazz respondsToSelector:@selector(transformersForProperties)] ? [clazz transformersForProperties] : @{};
    
    NSMutableDictionary *enumTransformers = [NSMutableDictionary new];
    NSDictionary<NSString *, Class<RCEnumMappable>> *enumClasses = [(Class)clazz respondsToSelector:@selector(enumClasses)] ? [clazz enumClasses] : @{};
    for (NSString *enumKey in enumClasses) {
        NSDictionary<NSString *, NSNumber *> * forwardMappings = [enumClasses[enumKey] enumMappings];
        NSDictionary<NSNumber *, NSString *> *reverseMappings = [NSDictionary dictionaryWithObjects:forwardMappings.allKeys forKeys:forwardMappings.allValues];
        RCTransformer *transformer = [[RCTransformer alloc] initWithForwardBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            if ([value isKindOfClass:[NSNumber class]]) {
                return value;
            }
            if (value && ![value isKindOfClass:[NSString class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Enum input not a string"]
                          withPointer:error];
                return nil;
            }
            
            return forwardMappings[value];
        } reverseBlock:^id _Nullable(id  _Nullable value, NSError *__autoreleasing  _Nullable * _Nullable error) {
            if (!value) {
                return nil;
            }
            if (value && ![value isKindOfClass:[NSNumber class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Enum input not an NSNumber"]
                          withPointer:error];
                return nil;
            }
            return reverseMappings[value];
        }];
        enumTransformers[enumKey] = transformer;
    }
    description.enumTransformers = enumTransformers.copy;
    
    return description;
}

+ (id<RCTransformer>)_modelTransformer:(nonnull Class<RCModel>)clazz {
    @synchronized (clazz) {
        id<RCTransformer> transformer = [RCClassTransformers defaultTransformerForClass:clazz];
        if (transformer) {
            return transformer;
        }
        transformer = [[RCTransformer alloc] initWithForwardBlock:^id (id value, NSError **error) {
            if (value && ![value isKindOfClass:[NSDictionary class]]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Input not a dictionary"]
                          withPointer:error];
                return nil;
            }
            NSDictionary *dictionary = (NSDictionary *)value;
            RCModelDescription *modelDescription = [self _modelDescriptionForClass: clazz];
            id object = [[clazz alloc] init];
            for (NSString *property in modelDescription.propertyMappings) {
                id<RCPropertyKey>propertyKey = modelDescription.propertyMappings[property];
                id value;
                for (NSString *key in propertyKey.propertyKey) {
                    id val = [dictionary valueForKeyPath:key];
                    if (val && ![val isKindOfClass:[NSNull class]]) {
                        value = val;
                        break;
                    }
                }
                if (!value) {
                    continue;
                }
                RCModelPropertyDescription *propertyDescription = modelDescription.propertyDescriptions[property];
                id<RCTransformer> transformer = modelDescription.propertyTransformers[property];
                Class type = propertyDescription.classType;
                if (type && !transformer) {
                    transformer = [RCClassTransformers defaultTransformerForClass:type];
                }
                if (transformer) {
                    NSError *parseError;
                    value = [transformer transformedValue:value error:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                }
                if (modelDescription.enumTransformers[property]) {
                    NSError *parseError;
                    value = [modelDescription.enumTransformers[property] transformedValue:value error:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                } else if (type && [type conformsToProtocol:@protocol(RCModel)]) {
                    NSError *parseError;
                    value = [[self _modelTransformer:type] transformedValue:value error:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                } else if (modelDescription.arrayClasses[property]) {
                    NSError *parseError;
                    value = [NSArray arrayForClass:modelDescription.arrayClasses[property]
                                             array:value
                                             error:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                } else if (modelDescription.dictionaryClasses[property]) {
                    NSError *parseError;
                    value = [NSDictionary dictionaryForClass:modelDescription.dictionaryClasses[property]
                                                  dictionary:value
                                                       error:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                }
                
                if (type && ![value isKindOfClass:type]) {
                    NSError *parseError = [self errorWithCode:500 reason:[NSString stringWithFormat:@"Type error expected %@ got %@ for property (%@)", NSStringFromClass(type), NSStringFromClass([value class]), property]];
                    [RCError resolveError:parseError
                              withPointer:error];
                } else {
                    [self _setPropertyForValue:property value:value forObject:object error:error];
                }
            }
            
            if ([(Class)clazz respondsToSelector:@selector(validateModel:)] && object) {
                NSError *validationError;
                [object validateModel: &validationError];
                [RCError resolveError:validationError
                          withPointer:error];
            }
            return object;
        } reverseBlock:^id (id value, NSError **error) {
            if (value && ![value conformsToProtocol:@protocol(RCModel)]) {
                [RCError resolveError:[self errorWithCode:500 reason:@"Input does not conform to RCModel"]
                          withPointer:error];
                return nil;
            }
            
            if (!value) {
                return nil;
            }
            NSMutableDictionary *outputDictionary = [NSMutableDictionary new];
            RCModelDescription *modelDescription = [self _modelDescriptionForClass: clazz];
            
            for (NSString *property in modelDescription.outputPropertyMappings) {
                NSString *dictionaryKey = modelDescription.outputPropertyMappings[property].propertyKey.firstObject;
                if (!dictionaryKey) {
                    continue;
                }
                
                id objectValue = [value valueForKey:property];
                RCModelPropertyDescription *propertyDescription = modelDescription.propertyDescriptions[property];
                id<RCTransformer> transformer = modelDescription.propertyTransformers[property];
                Class type = propertyDescription.classType;
                if (type && !transformer) {
                    transformer = [RCClassTransformers defaultTransformerForClass:type];
                }
                if (transformer) {
                    NSError *parseError;
                    objectValue = [transformer reverseTransformedValue:objectValue error:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                }
                if (modelDescription.enumTransformers[property]) {
                    NSError *parseError;
                    objectValue = [modelDescription.enumTransformers[property] reverseTransformedValue:objectValue error:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                } else if (type && [objectValue conformsToProtocol:@protocol(RCModel)]) {
                    NSError *parseError;
                    objectValue = [[self _modelTransformer:type] reverseTransformedValue:objectValue error:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                } else if (modelDescription.arrayClasses[property] && [objectValue isKindOfClass:[NSArray class]]) {
                    NSError *parseError;
                    objectValue = [(NSArray *)objectValue toJSONObject:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                } else if (modelDescription.dictionaryClasses[property] && [objectValue isKindOfClass:[NSDictionary class]]) {
                    NSError *parseError;
                    objectValue = [(NSDictionary *)objectValue toJSONObject:&parseError];
                    [RCError resolveError:parseError withPointer:error];
                    if (parseError) {
                        continue;
                    }
                }
                [outputDictionary setValue:objectValue forKeyPath:dictionaryKey];
            }
            
            return outputDictionary.copy;
        }];
        
        [RCClassTransformers setDefaultTransformerForClass:clazz transformer:transformer];
        
        return  transformer;
    }
}

+ (BOOL)_setPropertyForValue:(NSString *)property value:(id)value forObject:(NSObject *)object error:(NSError **)error {
    @try {
        [object setValue:value forKey:property];
        return YES;
    }
    @catch (NSException *exception) {
        [RCError resolveError:[self errorWithCode:500 reason:exception.reason] withPointer:error];
        return NO;
    }
}

+ (NSError *)errorWithCode:(NSInteger)code reason:(NSString *)reason {
    return [NSError errorWithDomain:@"RCModelFactory" code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(reason, reason)}];
}

@end

