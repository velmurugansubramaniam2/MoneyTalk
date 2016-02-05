//
//  TCSAPIStrings.m
//  iCore
//
//  Created by Zabelin Konstantin on 06.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#define STR_CONST(name, value) NSString* const name = @#value
#define API_PATH_CONST(value) NSString* const TCSAPIPath_##value = @#value
#define API_KEY_CONST(value) NSString* const TCSAPIKey_##value = @#value

#import "TCSAPIPaths.h"
#import "TCSAPIKeys.h"

#undef STR_CONST
#undef API_PATH_CONST
#undef API_KEY_CONST