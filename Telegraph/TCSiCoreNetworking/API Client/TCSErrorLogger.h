//
//  TCSP2PLogger.h
//  TCSP2P
//
//  Created by Gleb Ustimenko on 12/2/13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSiCoreNetworking.h"

@interface TCSErrorLogger : NSObject

+ (void)logErrorMessage:(NSString *)error onViewController:(id)viewController;

+ (void)logError:(NSError *)error onViewController:(id)viewController;

@end
