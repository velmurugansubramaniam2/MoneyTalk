//
//  MTKeychainController.h
//  Telegraph
//
//  Created by Max Zhdanov on 09.12.15.
//
//

#import <Foundation/Foundation.h>

@interface MTKeychainController : NSObject

+ (instancetype)sharedInstance;

- (void)setSecValueDictionary:(NSDictionary *)secValueDictionary;
- (NSDictionary *)getSecValueDictionary;

@end
