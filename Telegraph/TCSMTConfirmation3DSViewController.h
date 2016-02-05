//
//  TCSMT3DSConfirmationViewController.h
//  TCSMT
//
//  Created by Max Zhdanov on 29.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const TCSNotificationConfirmationCancelled;

@interface TCSMTConfirmation3DSViewController : UIViewController <UIWebViewDelegate,NSURLConnectionDelegate>

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *paReq;
@property (nonatomic, strong) NSString *md;
@property (nonatomic, strong) NSString *paRes;

- (void)setupWithParameters:(NSDictionary *)parameters;

@end
