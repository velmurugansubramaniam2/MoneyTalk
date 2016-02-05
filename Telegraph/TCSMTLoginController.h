//
//  TCSMTLoginController.h
//  Telegraph
//
//  Created by spb-EOrlova on 21.12.15.
//
//

#import <Foundation/Foundation.h>
#import "TCSAuthorizationStateManager.h"

@interface TCSMTLoginController : NSObject

@property (nonatomic, strong, readonly) UIViewController *fromViewController;
@property (nonatomic, strong, readonly) UIViewController *destinationViewController;

+ (instancetype)sharedInstance;

- (void)showViewController:(UIViewController *)destinationViewController
        fromViewController:(UIViewController *)fromViewController;

@end
