//
//  TCSMTConfirmationViewController.h
//  TCSMT
//
//  Created by Max Zhdanov on 26.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKNetworkOperation;

@protocol TCSMTConfirmationResultDelegate <NSObject>

- (void)closeWithResult:(NSDictionary *)responseDictionary;

@end

@interface TCSMTConfirmationViewController : UIViewController

@property (nonatomic, strong) NSString *initialOperationTicket;
@property (nonatomic, strong) NSString *confirmationType;
@property (nonatomic, strong) NSString *initialOperation;

@property (nonatomic, copy) void (^success)(MKNetworkOperation *);
@property (nonatomic, copy) void(^fail)(MKNetworkOperation *, NSError *);

@property (nonatomic, weak)id<TCSMTConfirmationResultDelegate>confirmationDelegate;
@property (nonatomic, assign) BOOL canBeConfirmedWithPush;

- (void)setupWithParameters:(NSDictionary *)parameters;

- (IBAction)closeAction;
- (UIBarButtonItem *)detailLeftButton;
- (void)setCodeFromPush:(NSString *)code;

- (void)closeActionAnimated:(BOOL)animated;


@end
