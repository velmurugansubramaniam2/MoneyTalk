//
//  TCSTGTelegramMoneyTalkProxy.h
//  Telegraph
//
//  Created by spb-EOrlova on 21.12.15.
//
//

#import <Foundation/Foundation.h>
#import "TGActionSheet.h"
#import "TGTelegraph.h"


@interface TCSTGTelegramMoneyTalkProxy : NSObject

+ (instancetype)sharedInstance;

#pragma mark - Progress Window
- (void)showProgressWindowAnimated:(BOOL)animated;
- (void)dismissProgressWindowAnimated:(BOOL)animated;

#pragma mark - Action Sheet
+ (TGActionSheetAction *)tgActionSheetActionWithTitle:(NSString *)title action:(NSString *)action;
+ (TGActionSheetAction *)tgActionSheetActionWithTitle:(NSString *)title action:(NSString *)action type:(TGActionSheetActionType)type;
+ (TGActionSheet *)tgActionSheetWithTitle:(NSString *)title actions:(NSArray *)actions actionBlock:(void (^)(id target, NSString *action))actionBlock target:(id)target;

#pragma mark - AlertView
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool okButtonPressed))completionBlock;
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completionBlock:(void (^)(bool okButtonPressed))completionBlock;

#pragma mark - Phone Format
+ (NSString *)formatPhone:(NSString *)phone forceInternational:(bool)forceInternational;

#pragma mark - Database
+ (TGUser *)loadUser:(int)uid;
+ (TGUser *)selfUser;

#pragma mark - Appearance
+ (UIColor *)tgAccentColor;

@end
