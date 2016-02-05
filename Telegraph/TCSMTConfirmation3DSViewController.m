//
//  TCSMT3DSConfirmationViewController.m
//  TCSMT
//
//  Created by Max Zhdanov on 29.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTConfirmation3DSViewController.h"
#import "TCSAPIClient.h"
#import "NSString+httpRequestString.h"
#import "TCSAPIDefinitions.h"
#import "NSString+encoding.h"
#import "TCSAPIClient+TCSAPIClient_CommonAPIRequests.h"
#import "TCSTGTelegramMoneyTalkProxy.h"
#import "TCSMacroses.h"

NSString *const TCSNotificationConfirmationCancelled = @"TCSNotificationConfirmationCancelled";

@interface TCSMTConfirmation3DSViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSString *initialOperationTicket;
@property (nonatomic, strong) NSString *confirmationType;
@property (nonatomic, strong) NSString *initialOperation;

@property (nonatomic, copy) void (^success)(MKNetworkOperation *);
@property (nonatomic, copy) void (^fail)(MKNetworkOperation *, NSError *);

@end


@implementation TCSMTConfirmation3DSViewController
{
    NSMutableData *webData;
}

@synthesize webView = _webView;
@synthesize urlString = _urlString;
@synthesize paReq = _paReq;
@synthesize md = _md;
@synthesize paRes = _paRes;

- (void)setupWithParameters:(NSDictionary *)parameters
{
    self.initialOperationTicket = parameters[kInitialOperationTicket];
    self.confirmationType = parameters[kConfirmationType];
    self.initialOperation = parameters[kInitialOperation];
    self.success = parameters[kSuccessBlock];
    self.fail = parameters[kFailBlock];

	self.urlString = parameters[kUrl];
	self.paReq = parameters[kRequestSecretCode];
	self.md = parameters[kMerchantData];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOC(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelConfirmation)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[TCSTGTelegramMoneyTalkProxy tgAccentColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self requestPaRes];
}

- (void)requestPaRes
{
    [[TCSTGTelegramMoneyTalkProxy sharedInstance] showProgressWindowAnimated:YES];
    
    NSDictionary *params = @{kPaReq : self.paReq,
                                kMD : self.md,
                             kTermUrl : @"https://www.tcsbank.ru"};
    
    MKNetworkOperation *operation = [[[TCSAPIClient sharedInstance] engine] operationWithURLString:_urlString params:params httpMethod:@"POST"];
    [operation setShouldContinueWithInvalidCertificate:YES];

	__weak NSString * urlString = self.urlString;
	__weak UIWebView * weakWebView = self.webView;
    
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
         
         NSString *customCharsetName = nil;
         
         NSArray *contentTypes = [[completedOperation.readonlyResponse allHeaderFields][@"Content-Type"] componentsSeparatedByString:@";"];
         
         for (NSString *substring in contentTypes)
         {
             NSString *substringWithoutWhitespaces = [substring stringByReplacingOccurrencesOfString:@" " withString:@""];
             
             if ([substringWithoutWhitespaces rangeOfString:@"charset"].location != NSNotFound)
             {
                 NSArray *contentTypeChunks = [substringWithoutWhitespaces componentsSeparatedByString:@"="];
                 
                 for (NSString *charsetSubstring in contentTypeChunks)
                 {
                     NSString *charsetSubstringWithoutWhitespaces = [charsetSubstring stringByReplacingOccurrencesOfString:@" " withString:@""];
                     
                     if (![charsetSubstringWithoutWhitespaces isEqualToString:@"charset"])
                     {
                         customCharsetName = charsetSubstringWithoutWhitespaces;
                     }
                 }
             }
         }
         
         NSString *htmlString = nil;
         
         if (customCharsetName != nil)
         {
             htmlString = [[NSString alloc] initWithData:[completedOperation responseData] encoding:[NSString stringEncodingFromEncodingName:customCharsetName]];
         }
         else
         {
             htmlString = [completedOperation responseString];
         }

         UIWebView *strongWebView = weakWebView;

         if (strongWebView)
         {
             NSURLResponse *response = [completedOperation readonlyResponse];
             [strongWebView loadData:[completedOperation responseData]
                         MIMEType:[response MIMEType]
                 textEncodingName:[response textEncodingName]
                          baseURL:[response URL]];
         }
     }
     errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
         [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[kErrorMessage] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:nil];
     }];
    
    [[[TCSAPIClient sharedInstance] engine] enqueueOperation:operation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", ((NSURL*)request.URL).absoluteString);
    
    NSData *data = [request HTTPBody];
    NSString* paresString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DLog(@"\n\nPARES: %@\n\n",paresString);
    paresString = [paresString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSRange range = [paresString rangeOfString:[NSString stringWithFormat:@"%@=",kPaRes]];
    if (range.length > 0)
    {
        self.paRes = [paresString stringFromURLStringWithValueForParameter:kPaRes];//[TCSUtils parameterValue:kPaRes fromURLString:paresString];
        [self confirmWithPaRes:self.paRes];
        
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	
}

- (void)confirmWithPaRes:(NSString *)pares
{    
    __weak __typeof(self) weakSelf = self;
    [[TCSAPIClient sharedInstance] api_confirmWithSMSCode:pares
                                         initialOperation:self.initialOperation
                                   initialOperationTicket:self.initialOperationTicket
                                         confirmationType:self.confirmationType
                                                  success:^(MKNetworkOperation *operation)
     {
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf)
            {
                strongSelf.success(operation);
            }
        }];
    }
                                                    failure:^(NSError *error)
    {
		void(^completionBlock)() = ^
		{
			__strong __typeof(weakSelf) strongSelf = weakSelf;
			if (strongSelf.fail)
			{
				strongSelf.fail(nil, error);
            }
		};

		[weakSelf.navigationController dismissViewControllerAnimated:YES completion:completionBlock];
	}];
}

- (void)cancelConfirmation
{
    NSString *errorString = @"Error";
    
    __weak typeof (self) weakSelf = self;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.fail(nil, [NSError errorWithDomain:errorString code:0 userInfo:@{NSLocalizedDescriptionKey : errorString}]);
        [[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationConfirmationCancelled object:nil];
    }];
}

@end
