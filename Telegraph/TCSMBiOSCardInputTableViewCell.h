//
//  TCSMBiOSCardInputTableViewCell.h
//  TCSMBiOS
//
//  Created by Kirill Nepomnyaschiy on 04/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

//#import "TCSMBiOSBaseCell.h"
#import "TCSMBiOSTextField.h"
#import <UIKit/UIKit.h>
#import "TCSMTBaseCellWithSeparators.h"

@class TCSMBiOSCardInputTableViewCell;
@protocol TCSMBiOSCardInputTableViewCellDelegate <NSObject>

@optional
- (void)cardInputCellTextDidChange:(TCSMBiOSCardInputTableViewCell *)cell;
- (void)textFieldDidBeginEditing:(UITextField *)textField;

@end

@interface TCSMBiOSCardInputTableViewCell : TCSMTBaseCellWithSeparators <UITextFieldDelegate>

@property (nonatomic, weak) id <TCSMBiOSCardInputTableViewCellDelegate> delegate;

@property TCSMBiOSTextField *textFieldCardNumber;
@property TCSMBiOSTextField *textFieldCardDate;
@property TCSMBiOSTextField *textFieldCardCVC;

@property (weak, nonatomic) IBOutlet UIView *viewCardContainer;
@property (weak, nonatomic) IBOutlet UIView *saveCardContainer;

@property (weak, nonatomic) IBOutlet UISwitch *switchSaveCard;
@property (weak, nonatomic) IBOutlet UIButton *cardIOButton;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, assign) BOOL extendedModeEnabled;
@property (nonatomic, assign) BOOL secureModeEnabled;

@property (nonatomic, assign) BOOL useDarkIcons;

@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) NSString *placeholderText;

@property (nonatomic, assign) BOOL showSecretContainer;
@property (nonatomic, weak) IBOutlet UIButton *clearSecretContainerButton;

+ (instancetype)cell;
+ (instancetype)cellForCVCInput;
+ (instancetype)cellForRecieverCard;

- (BOOL)validateForm;

- (void)setPlaceholderText:(NSString *)placeholderText;
- (void)setSecureModeEnabled:(BOOL)enabled;
- (void)setPaymentSystemIcon:(UIImage *)icon;
- (void)setCardNumber:(NSString *)cardNumber;

- (NSString *)cardNumber;
- (NSString *)cardExpirationDate;
- (NSString *)cardCVC;
- (NSString *)exampleSavedCardName;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end
