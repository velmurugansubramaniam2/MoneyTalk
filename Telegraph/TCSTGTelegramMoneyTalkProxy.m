//
//  TCSTGTelegramMoneyTalkProxy.m
//  Telegraph
//
//  Created by spb-EOrlova on 21.12.15.
//
//

#import "TCSTGTelegramMoneyTalkProxy.h"
#import "TGPhoneUtils.h"
#import "TGProgressWindow.h"
#import "TGAlertView.h"
#import "TCSMacroses.h"

@interface TCSTGTelegramMoneyTalkProxy ()
@property (strong, nonatomic) TGProgressWindow *progressWindow;
@end

@implementation TCSTGTelegramMoneyTalkProxy

+ (instancetype)sharedInstance
{
    static TCSTGTelegramMoneyTalkProxy *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^
    {
        _sharedInstance = [[TCSTGTelegramMoneyTalkProxy alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

- (void)dealloc
{
    _progressWindow = nil;
}

#pragma mark - Progress Window
- (TGProgressWindow *)progressWindow
{
    if (!_progressWindow)
    {
        _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    return _progressWindow;
}

- (void)showProgressWindowAnimated:(BOOL)animated
{
    [self.progressWindow show:animated];
}

- (void)dismissProgressWindowAnimated:(BOOL)animated
{
    [self.progressWindow dismiss:animated];
}

#pragma mark - Action Sheet
+ (TGActionSheetAction *)tgActionSheetActionWithTitle:(NSString *)title action:(NSString *)action
{
    return [[TGActionSheetAction alloc] initWithTitle:title action:action];
}

+ (TGActionSheetAction *)tgActionSheetActionWithTitle:(NSString *)title action:(NSString *)action type:(TGActionSheetActionType)type
{
    return [[TGActionSheetAction alloc] initWithTitle:title action:action type:type];
}

+ (TGActionSheet *)tgActionSheetWithTitle:(NSString *)title actions:(NSArray *)actions actionBlock:(void (^)(id target, NSString *action))actionBlock target:(id)target
{
    TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:title actions:actions actionBlock:actionBlock target:target];
    return actionSheet;
}

#pragma mark - AlertView
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool okButtonPressed))completionBlock
{
    if (!(message.length == 0 && [title isEqualToString:LOC(@"Error.ErrorTitle")]))
    {
        [[[TGAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle completionBlock:completionBlock] show];
    }
}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completionBlock:(void (^)(bool okButtonPressed))completionBlock
{
    [[[TGAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles completionBlock:completionBlock] show];
}

#pragma mark - Phone Format
+ (NSString *)formatPhone:(NSString *)phone forceInternational:(bool)forceInternational
{
    return [TGPhoneUtils formatPhone:phone forceInternational:forceInternational];
}

#pragma mark - Database
+ (TGUser *)loadUser:(int)uid
{
    return [TGDatabaseInstance() loadUser:uid];
}

+ (TGUser *)selfUser
{
    return [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
}

#pragma mark - Appearance
+ (UIColor *)tgAccentColor
{
    return TGAccentColor();
}


@end
