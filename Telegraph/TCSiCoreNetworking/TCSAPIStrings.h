//
//  TCSAPIStrings.h
//  iCore
//
//  Created by Zabelin Konstantin on 06.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#define STR_CONST(name, value) extern NSString* const name
#define API_PATH_CONST(value) extern NSString* const TCSAPIPath_##value
#define API_KEY_CONST(value) extern NSString* const TCSAPIKey_##value

#import "TCSAPIPaths.h"
#import "TCSAPIKeys.h"

#undef STR_CONST
#undef API_PATH_CONST
#undef API_KEY_CONST