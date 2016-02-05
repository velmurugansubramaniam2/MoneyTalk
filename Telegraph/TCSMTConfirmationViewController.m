//
//  TCSMTConfirmationViewController.m
//  TCSMT
//
//  Created by Max Zhdanov on 26.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTConfirmationViewController.h"
#import "TCSiCoreNetworking.h"
#import "TCSMacroses.h"

@implementation TCSMTConfirmationViewController

@synthesize initialOperation = _initialOperation;
@synthesize initialOperationTicket = _initialOperationTicket;
@synthesize confirmationType = _confirmationType;

@synthesize confirmationDelegate = _confirmationDelegate;
@synthesize canBeConfirmedWithPush = _canBeConfirmedWithPush;

@synthesize success = _success;
@synthesize fail = _fail;

- (void)viewDidLoad
{
    [super viewDidLoad];
	UILabel * label = (UILabel *)self.navigationItem.titleView;

	if ([label isKindOfClass:[UILabel class]])
	{
		[label setTextColor:[UIColor whiteColor]];
	}
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupWithParameters:(NSDictionary *)parameters
{
	self.initialOperationTicket = parameters[kInitialOperationTicket];
	self.confirmationType = parameters[kConfirmationType];
	self.initialOperation = parameters[kInitialOperation];
	self.success = parameters[kSuccessBlock];
	self.fail = parameters[kFailBlock];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIInterfaceOrientation result = [UIApplication sharedApplication].statusBarOrientation;
    return UIInterfaceOrientationIsPortrait(result) ? result : UIInterfaceOrientationPortrait;
}

- (IBAction)closeAction
{
    [self closeActionAnimated:YES];
}

- (void)closeActionAnimated:(BOOL)animated
{
    [self.navigationController dismissViewControllerAnimated:animated completion:nil];
}

#pragma mark -
#pragma mark UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
    return cell;
}

- (void)setCodeFromPush:(NSString *)code
{
    
}

@end
