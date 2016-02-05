//
//  TCSP2PValidation.h
//  TCSP2P
//
//  Created by a.v.kiselev on 12.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

#define kMaxLength									@"maxLength"
#define kMinLength                                  @"minLength"
#define kRegexp										@"regexp"

@interface TCSP2PValidation : TCSBaseObject

- (NSString *)maxLength;
- (NSString *)regexp;
- (NSInteger)minLength;

@end
