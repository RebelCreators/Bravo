#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSArray+RCModelFactory.h"
#import "NSDictionary+RCModelFactory.h"
#import "NSString+RCPropertyKey.h"
#import "RCClassTransformers.h"
#import "RCCommonTransfromers.h"
#import "RCEnumMappable.h"
#import "RCError.h"
#import "RCModel.h"
#import "RCModelFactory.h"
#import "RCOrPropertyKey.h"
#import "RCPropertyKey.h"
#import "RCTransformer.h"

FOUNDATION_EXPORT double RCModelVersionNumber;
FOUNDATION_EXPORT const unsigned char RCModelVersionString[];

