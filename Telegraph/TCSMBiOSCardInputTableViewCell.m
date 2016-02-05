//  TCSMBiOSCardInputTableViewCell.m
//  TCSMBiOS
//
//  Created by Kirill Nepomnyaschiy on 04/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMBiOSCardInputTableViewCell.h"

#import <AVFoundation/AVFoundation.h>
#import "CardIO.h"
#import "CardIOPaymentViewController.h"
#import "TCSMacroses.h"
#import "NSString+Luhn.h"
#import "UIView+AutoLayout.h"


#define TCSMBiOSCreditCardPaymentSystemInputDefault         @"____ __________________"
#define TCSMBiOSCreditCardPaymentSystemInputMaskVisa 	    @"____ ____ ____ ____"
#define TCSMBiOSCreditCardPaymentSystemInputMaskMasterCard  @"____ ____ ____ ____"
#define TCSMBiOSCreditCardPaymentSystemInputMaskMaestro16   @"____ ____ ____ _____"
#define TCSMBiOSCreditCardPaymentSystemInputMaskMaestro19   @"________ ____________"
#define TCSMBiOSCreditCardPaymentSystemInputMaskMaestro22   @"________ ______________"

@interface TCSMBiOSCardInputTableViewCell () <CardIOPaymentViewControllerDelegate, TCSMBiOSTextFieldKeyInputDelegate>
{
	IBOutlet UIView *_viewCardNumber;
	IBOutlet UIView *_viewCardDate;
	IBOutlet UIView *_viewCardCVC;
	
	UIBarButtonItem *_buttonInputAccessoryDone;
	
	BOOL _paymentLogoHidden;
	BOOL _expanded;
	
	BOOL _cvcValidationFailed;
	BOOL _dateValidationFailed;
	BOOL _cardNumberValidationFailed;
	
	CardIOCreditCardType _creditCardType;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardDateXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardCVCXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardNumberWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardNumberXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardIOButtonXConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *imagePaymentLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelSaveCard;

@property (strong, nonatomic) NSString *fullCardNumber;

@property (weak, nonatomic) IBOutlet /*TCSMBButton*/ UIButton *nextButton;

@property (strong, nonatomic) NSDictionary *placeholderAttributes;
@property (strong, nonatomic) NSDictionary *invalidPlaceholderAttributes;

@property (nonatomic, weak) IBOutlet UIView *secretContainerView;
@property (nonatomic, weak) IBOutlet UILabel *secretCardNumberLabel;

@end

@implementation TCSMBiOSCardInputTableViewCell

+ (instancetype)cell
{
	TCSMBiOSCardInputTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"TCSMBiOSCardInputTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setShowSecretContainer:NO];
    
	return cell;
}

+ (instancetype)cellForCVCInput
{
	TCSMBiOSCardInputTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"TCSMBiOSCardInputTableViewCell" owner:self options:nil] objectAtIndex:0];
	
	[cell setExtendedModeEnabled:YES];
	[cell setSecureModeEnabled:YES];
	[cell setCardNumberExpanded:NO animated:NO];
	[cell setPaymentLogoHidden:NO animated:NO];
	[cell setScanButtonHidden:YES animated:NO];
	[cell setNextButtonHidden:YES animated:NO];
	[cell.saveCardContainer setHidden:YES];
    [cell setShowSecretContainer:NO];
	
	return cell;
}

+ (instancetype)cellForRecieverCard
{
	TCSMBiOSCardInputTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"TCSMBiOSCardInputTableViewCell" owner:self options:nil] objectAtIndex:0];
	[cell.contentView setBackgroundColor:[UIColor whiteColor]];
	[cell.viewCardContainer setBackgroundColor:[UIColor whiteColor]];
	[cell setUseDarkIcons:YES];
	[cell setExtendedModeEnabled:NO];
    [cell setShowSecretContainer:NO];
//	[cell setTextColor:[TCSMBiOSDesign3 colorN1]];
//	[cell setPlaceholderColor:[TCSMBiOSDesign3 colorN4]];
//	[cell setPlaceholderText:LOC(@"c2c.cell.card.reciever.placeholder")];
	
	return cell;
}

#pragma mark Lazy initializers


- (NSDictionary *)placeholderAttributes
{
	if (!_placeholderAttributes && self.placeholderColor)
	{
		NSDictionary *placeholderAttributes = @{NSForegroundColorAttributeName:self.placeholderColor};
		_placeholderAttributes = placeholderAttributes;
	}
	return _placeholderAttributes;
}

- (NSDictionary *)invalidPlaceholderAttributes
{
	if (!_invalidPlaceholderAttributes)
	{
		NSDictionary *invalidPlaceholderAttributes = @{NSForegroundColorAttributeName:[UIColor redColor]};
		_invalidPlaceholderAttributes = invalidPlaceholderAttributes;
	}
	return _invalidPlaceholderAttributes;
}

#pragma mark Setters & Getters


- (void)setCardNumber:(NSString *)cardNumber
{
	_fullCardNumber = cardNumber;
	
	[self updatePaymentSystem];
	[self updateInputMasks];
	[self updatePaymentLogo];
	[self updatePlaceholders];
}

- (NSString *)cardNumber
{
    return [self numbersStringFromString:self.fullCardNumber];
}

- (NSString *)cardExpirationDate
{
	return self.textFieldCardDate.text;
}

- (NSString *)cardCVC
{
	return _textFieldCardCVC.text;
}


- (NSString *)exampleSavedCardName
{
	NSString *resultCardName = nil;
	
	if ([self cardNumber].length > 4)
	{
		NSString *prefix;
		switch (_creditCardType) {
			case CardIOCreditCardTypeVisa:
			{
				prefix = @"VISA *";
				break;
			}
			case CardIOCreditCardTypeMastercard:
			{
				prefix = @"MasterCard *";
				break;
			}
			case CardIOCreditCardTypeDiscover:
			{
				prefix = @"Maestro *";
				break;
			}
			default:
				prefix = @"*";
				break;
		}
		
		NSString *lastSymbols = [[self cardNumber] substringFromIndex:[self cardNumber].length - 4];
		
		resultCardName = [NSString stringWithFormat:@"%@%@", prefix, lastSymbols];
	}
	else
	{
        resultCardName = LOC(@"Transfer.NewCard");
	}
	
	return resultCardName;
}

- (void)setUseDarkIcons:(BOOL)useDarkIcons
{
	_useDarkIcons = useDarkIcons;
	
	[self.cardIOButton setImage:[UIImage imageNamed:useDarkIcons ? @"scan_card_grey" : @"scan_card"] forState:UIControlStateNormal];
	[self.nextButton setImage:[UIImage imageNamed:useDarkIcons ? @"next_grey" : @"next_white"] forState:UIControlStateNormal];
}

- (void)setTextColor:(UIColor *)textColor
{
	_textColor = textColor;
	
	[_textFieldCardNumber setTextColor:textColor];
	[_textFieldCardNumber setTintColor:textColor];
	[_textFieldCardDate setTextColor:textColor];
	[_textFieldCardDate setTintColor:textColor];
	[_textFieldCardCVC setTextColor:textColor];
	[_textFieldCardCVC setTintColor:textColor];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
	_placeholderColor = placeholderColor;
	_placeholderAttributes = nil;
	
	[self updatePlaceholders];
}

- (void)setExtendedModeEnabled:(BOOL)enabled
{
	_extendedModeEnabled = enabled;
	
	[self.saveCardContainer setHidden:!enabled];
	
	[self setNextButtonHidden:YES animated:NO];
	[self setScanButtonHidden:NO animated:NO];
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
	_placeholderText = placeholderText;
	
	[self updatePlaceholders];
}

- (void)setPaymentSystemIcon:(UIImage *)icon
{
	if (icon)
	{
		[self setPaymentLogoHidden:NO animated:YES];
		[self.imagePaymentLogo setImage:icon];
	}
	else
	{
		[self setPaymentLogoHidden:YES animated:NO];
	}
}

- (void)setShowSecretContainer:(BOOL)showSecretContainer
{
    _showSecretContainer = showSecretContainer;
    
    if (_showSecretContainer)
    {
        self.secretCardNumberLabel.text = [NSString stringWithFormat:@"* %@",[self.cardNumber substringFromIndex:self.cardNumber.length - 4]];
    }
    
    self.secretContainerView.hidden = !_showSecretContainer;
}

#pragma mark Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    
	_creditCardType = CardIOCreditCardTypeUnrecognized;
	
	[self setExtendedModeEnabled:YES];
	[self setPaymentLogoHidden:YES  animated:NO];
	[self setNextButtonHidden:YES   animated:NO];
	[self setScanButtonHidden:NO    animated:NO];
	
//	[self.contentView setBackgroundColor:[TCSMBiOSDesign3 colorForNavigationBar]];
//	[self.viewCardContainer setBackgroundColor:[UIColor UIColorFromRGB:0x515A68]];
	
//	self.placeholderColor = [TCSMBiOSDesign3 colorN3];
	
	[_viewCardNumber setBackgroundColor:nil];
	[_viewCardDate setBackgroundColor:nil];
	[_viewCardCVC setBackgroundColor:nil];
	
	_buttonInputAccessoryDone = [[UIBarButtonItem alloc] initWithTitle:LOC(@"button.done") style:UIBarButtonItemStyleDone target:self action:@selector(buttonAction:)];
	
//	self.nextButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
//	self.cardIOButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
	
	UIEdgeInsets textFieldInsets = UIEdgeInsetsMake(2, 0, 0, 0);
	self.textFieldCardNumber = [[TCSMBiOSTextField alloc] init];
	[self.textFieldCardNumber setInputMask:@"____ ____ ____ _____"];
	[self.textFieldCardNumber setShowInputMask:NO];
	[self.textFieldCardNumber setKeyboardType:UIKeyboardTypeNumberPad];
//	[self.textFieldCardNumber setKeyboardAppearance:UIKeyboardAppearanceDark];
	[self.textFieldCardNumber setFont:[UIFont systemFontOfSize:17.0 weight:UIFontWeightLight]];
	[self.textFieldCardNumber setDelegate:self];
	
	[_viewCardNumber addSubview:self.textFieldCardNumber];
	[self.textFieldCardNumber autoPinEdgesToSuperviewEdgesWithInsets:textFieldInsets];
	
	self.textFieldCardDate = [[TCSMBiOSTextField alloc] init];
	[self.textFieldCardDate setInputMask:@"__/__"];
	[self.textFieldCardDate setShowInputMask:NO];
	[self.textFieldCardDate setDisablePaste:YES];
	[self.textFieldCardDate setDelegate:self];
	[self.textFieldCardDate setKeyboardType:UIKeyboardTypeNumberPad];
//	[self.textFieldCardDate setKeyboardAppearance:UIKeyboardAppearanceDark];
	[self.textFieldCardDate setFont:[UIFont systemFontOfSize:17.0 weight:UIFontWeightLight]];
	[self.textFieldCardDate setKeyInputDelegate:self];
	
	[_viewCardDate addSubview:self.textFieldCardDate];
	[self.textFieldCardDate autoPinEdgesToSuperviewEdgesWithInsets:textFieldInsets];
	
	self.textFieldCardCVC = [[TCSMBiOSTextField alloc] init];
	[self.textFieldCardCVC setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[self.textFieldCardCVC setInputMask:@"___"];
	[self.textFieldCardCVC setKeyboardType:UIKeyboardTypeNumberPad];
//	[self.textFieldCardCVC setKeyboardAppearance:UIKeyboardAppearanceDark];
	[self.textFieldCardCVC setFont:[UIFont systemFontOfSize:17.0 weight:UIFontWeightLight]];
	[self.textFieldCardCVC setSecureTextEntry:YES];
	[self.textFieldCardCVC setDelegate:self];
	[self.textFieldCardCVC setKeyInputDelegate:self];
	[_viewCardCVC addSubview:self.textFieldCardCVC];
	
	[self.textFieldCardCVC autoPinEdgesToSuperviewEdgesWithInsets:textFieldInsets];
	
	[self setCardNumberExpanded:YES animated:NO];
	
	[self updatePlaceholders];
	
	[self.labelSaveCard setBackgroundColor:nil];
    self.labelSaveCard.text = LOC(@"Transfer.saveCard");
	[self.switchSaveCard setBackgroundColor:nil];
	
	if (!_textColor)
		[self setTextColor:[UIColor blackColor]];
}

#pragma mark TCSMBiOSTextFieldKeyInputDelegate

- (void)textFieldDidDelete:(TCSMBiOSTextField *)textField
{
	if (textField.text.length == 0)
	{
		if (textField == _textFieldCardCVC)
		{
			[_textFieldCardDate becomeFirstResponder];
		}
		else if (textField == _textFieldCardDate)
		{
			[_textFieldCardNumber becomeFirstResponder];
		}
	}
}


#pragma mark UITextFieldDelegate

+ (UIToolbar *)toolBarWithButton:(UIBarButtonItem *)buttonDone buttonCancel:(UIBarButtonItem *)buttonCancel
{
    UIToolbar *toolBarInputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
    [toolBarInputAccessoryView setTranslucent:YES];
    [toolBarInputAccessoryView setBarStyle:UIBarStyleBlack];
    [toolBarInputAccessoryView setTintColor:[UIColor orangeColor]];
    [toolBarInputAccessoryView setBarTintColor:[UIColor purpleColor]];
    UIBarButtonItem *flexiableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [NSMutableArray new];
    
    if (buttonCancel) [items addObject:buttonCancel];
    [items addObject:flexiableItem];
    if (buttonDone) [items addObject:buttonDone];
    
    [toolBarInputAccessoryView setItems:items];
    
    return toolBarInputAccessoryView;
}

- (UIView *)textFieldInputAccessoryView:(UITextField *)textField
{
	return [TCSMBiOSCardInputTableViewCell toolBarWithButton:_buttonInputAccessoryDone buttonCancel:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
    {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField setInputAccessoryView:nil];//[self textFieldInputAccessoryView:textField]];
	
	if (self.secureModeEnabled)
	{
		if (textField == self.textFieldCardNumber || textField == self.textFieldCardDate)
			return NO;
	}
	
	if (textField == self.textFieldCardNumber)
	{
		_cardNumberValidationFailed = NO;
		
		if (!_expanded)
		{
			[self setCardNumberExpanded:YES animated:YES];
			[self updateButtonsStates];
		}
	}
	else if (textField == self.textFieldCardDate)
	{
		_dateValidationFailed = NO;
	}
	else if (textField == self.textFieldCardCVC)
	{
		_cvcValidationFailed = NO;
	}
	
	return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if (textField == self.textFieldCardNumber)
	{
		NSString *oldString = textField.text;
		
		// Case when user pastes full card number on top of existing card number with different card type
		if (range.location == 0)
		{
			[self updatePaymentSystemWithCardNumber:string];
			[self updateInputMasksWithCardNumber:string];
		}
		
		if (![self.textFieldCardNumber shouldChangeCharactersInRange:range replacementString:string])
		{
			UITextPosition *beginning = textField.beginningOfDocument;
			UITextPosition *cursorLocation = [textField positionFromPosition:beginning offset:(NSInteger)(range.location + string.length)];
			
			TCSMBiOSTextField *tcsTextField = (TCSMBiOSTextField *)textField;
			NSString *availableString = [self numbersStringFromString:tcsTextField.text];
			
            [self updateInputMasksWithCardNumber:availableString];
            
			[tcsTextField setText:@""];
			
			BOOL result = [tcsTextField shouldChangeCharactersInRange:(NSRange){0, [tcsTextField.text length]} replacementString:availableString];
			
			if (cursorLocation)
			{
				if ([[oldString substringWithRange:range] isEqualToString:@" "])
				{
					cursorLocation = [textField positionFromPosition:cursorLocation offset:-1];
				}
				else
				{
					NSUInteger location = range.location + 1;
					NSUInteger length = [string length];
					
					NSString *insertedString = nil;
					if (location + length <= [tcsTextField.text length])
					{
						insertedString = [tcsTextField.text substringWithRange:NSMakeRange(location, length)];
					}
					
					if ([insertedString isEqualToString:@" "])
					{
						NSInteger cursorOffset = [textField offsetFromPosition:textField.beginningOfDocument toPosition:cursorLocation];
						
						if (cursorOffset < (NSInteger)textField.text.length)
							cursorLocation = [textField positionFromPosition:cursorLocation offset:1];
					}
				}
				
				NSString *oldNumbers = [self numbersStringFromString:oldString];
				NSString *currentNumbers = [self numbersStringFromString:tcsTextField.text];
				
				// keep cursor at last character when user is backspacing and new mask is longer then old mask
				if ([oldNumbers rangeOfString:currentNumbers].location != NSNotFound && [oldString rangeOfString:textField.text].location == NSNotFound) {
					UITextRange *selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
					[textField setSelectedTextRange:selectedTextRange];
				}
				else
				{
					// set start/end location to same spot so that nothing is highlighted
					UITextRange *selectedTextRange = [textField textRangeFromPosition:cursorLocation toPosition:cursorLocation];
					[textField setSelectedTextRange:selectedTextRange];
				}
			}
			
			[self textFieldDidChange:textField];
			
			return result;
		}
	}
	else if (textField == self.textFieldCardCVC || textField == self.textFieldCardDate)
	{
		TCSMBiOSTextField *tcsTextField = (TCSMBiOSTextField *)textField;
		if (![tcsTextField shouldChangeCharactersInRange:range replacementString:string])
		{
			NSString *availableString = [self numbersStringFromString:tcsTextField.text];
			
			BOOL result = [tcsTextField shouldChangeCharactersInRange:(NSRange){0, [tcsTextField.text length]} replacementString:availableString];
			
			[self textFieldDidChange:textField];
			return result;
		}
	}
	
	return YES;
}


- (void)updatePaymentSystem
{
	[self updatePaymentSystemWithCardNumber:[self cardNumber]];
}

- (void)updatePaymentSystemWithCardNumber:(NSString *)cardNumber
{
	char firstCardNumberSymbol;
	
	if (cardNumber.length > 0)
		firstCardNumberSymbol = (char)[cardNumber characterAtIndex:0];
	else
		firstCardNumberSymbol = '\0';
	
	
	CardIOCreditCardType cardType;
	
	switch (firstCardNumberSymbol)
	{
		case CardIOCreditCardTypeVisa:
		{
			cardType = CardIOCreditCardTypeVisa;
			break;
		}
        case CardIOCreditCardTypeMastercard:
		{
			cardType = CardIOCreditCardTypeMastercard;
			break;
		}
		case CardIOCreditCardTypeDiscover:
		{
			cardType = CardIOCreditCardTypeDiscover;
			break;
		}
		default:
		{
			cardType = CardIOCreditCardTypeUnrecognized;
			break;
		}
	}
	
	_creditCardType = cardType;
}

#pragma mark Input processing

- (void)textFieldDidChange:(UITextField *)textField
{
	if (textField == self.textFieldCardNumber)
	{
		_cardNumberValidationFailed = NO;
		
		[self updateCardNumberTextField];
		[self updatePaymentSystem];
		[self updateInputMasks];
		[self updatePaymentLogo];
		[self updatePlaceholders];
		[self updateButtonsStates];
		
		if (_creditCardType == CardIOCreditCardTypeUnrecognized)
		{
			self.textFieldCardNumber.textColor = [UIColor redColor];
		}
	}
	else if (textField == self.textFieldCardDate)
	{
		_dateValidationFailed = NO;
		
		if (textField.text.length >= 5)
		{
			[textField setTextColor:[self validateDate] ? self.textColor : [UIColor redColor]];
			if ([self validateDate] && [textField isFirstResponder])
			{
				[textField resignFirstResponder];
				[self.textFieldCardCVC becomeFirstResponder];
			}
			else
				[textField setTextColor:[UIColor redColor]];
		}
		else
			[textField setTextColor:self.textColor];
	}
	
	else if (textField == self.textFieldCardCVC)
	{
		_cvcValidationFailed = NO;
		
		[textField setTextColor:self.textColor];
		
		if ([self validateCVC])
			[textField resignFirstResponder];
	}
	
	id <TCSMBiOSCardInputTableViewCellDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(cardInputCellTextDidChange:)])
	{
		[delegate cardInputCellTextDidChange:self];
	}
	
	[self updatePlaceholders];
}



- (void)updateCardNumberTextField
{
	TCSMBiOSTextField *textField = self.textFieldCardNumber;
	
	_fullCardNumber = textField.text;
	if (self.textFieldCardNumber.text.length >= self.textFieldCardNumber.inputMask.length)
	{
		[self validateCardNumberAndCollapse];
	}
	else
	{
		[textField setTextColor:self.textColor];
	}
}


- (void)updateButtonsStates
{
	if (_extendedModeEnabled)
	{
		TCSMBiOSTextField *textField = self.textFieldCardNumber;
		
		NSString *cardNumber = [self cardNumber];
		
		if (_creditCardType == CardIOCreditCardTypeDiscover)
		{
			if (cardNumber.length >= 13)
			{
				if (cardNumber.length <= 22)
				{
					[self setNextButtonHidden:NO animated:YES];
					[self setScanButtonHidden:YES animated:YES];
				}
				else
				{
					[self setNextButtonHidden:YES animated:YES];
					[self setScanButtonHidden:YES animated:YES];
				}
			}
			else if (cardNumber.length > 0)
			{
				[self setNextButtonHidden:YES animated:YES];
				[self setScanButtonHidden:NO animated:YES];
			}
		}
		else if (_fullCardNumber.length >= textField.inputMask.length && [NSString luhnCheck:self.cardNumber] && _expanded)
		{
			[self setNextButtonHidden:NO animated:YES];
			[self setScanButtonHidden:YES animated:YES];
		}
		else
		{
			[self setNextButtonHidden:YES animated:YES];
			[self setScanButtonHidden:!_expanded animated:YES];
		}
	}
	else
	{
		[self setNextButtonHidden:YES animated:NO];
		[self setScanButtonHidden:NO animated:YES];
	}
}

- (void)updatePaymentLogo
{
	TCSMBiOSTextField *textField = self.textFieldCardNumber;
	
	if (textField.text.length >= 1)
	{
		NSString *paymentSystemIconName = [self paymentSystemIconNameForCardType:_creditCardType];
		UIImage *paymentSystemIcon = paymentSystemIconName ? [UIImage imageNamed:paymentSystemIconName] : nil;
		
		if (paymentSystemIconName)
		{
			[self setPaymentLogoHidden:NO animated:YES];
			[self.imagePaymentLogo setImage:paymentSystemIcon];
		}
		else
		{
			[self setPaymentLogoHidden:YES animated:NO];
			[self.textFieldCardNumber setTextColor:[UIColor redColor]];
		}
	}
	else
	{
		[self setPaymentLogoHidden:YES animated:YES];
	}
}


- (void)updatePlaceholders
{
	NSString *placeholderText = self.placeholderText ? self.placeholderText : @"";
	NSString *cvcPlaceholderText = [self paymentSystemSecurityCodeNameForCardType:_creditCardType];
	
	NSDictionary *cardNumberAttributes = _cardNumberValidationFailed ? self.invalidPlaceholderAttributes : self.placeholderAttributes;
	NSDictionary *cardDateAttributes = _dateValidationFailed ? self.invalidPlaceholderAttributes : self.placeholderAttributes;
	NSDictionary *cardCVCAttributes = _cvcValidationFailed ? self.invalidPlaceholderAttributes : self.placeholderAttributes;
	
	[self.textFieldCardNumber setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholderText attributes:cardNumberAttributes]];
	[self.textFieldCardDate setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"ММ/ГГ" attributes:cardDateAttributes]];
	[self.textFieldCardCVC setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:cvcPlaceholderText attributes:cardCVCAttributes]];
}

#pragma mark Button handling


- (IBAction)buttonAction:(id)sender
{
	if (sender == self.nextButton)
	{
		[self validateCardNumberAndCollapse];
	}
	else if (sender == self.cardIOButton)
	{
		[self openCardScaner];
	}
	else if (sender == _buttonInputAccessoryDone)
	{
		[self endEditing:NO];
	}
}

- (void)resetValidationResults
{
	_cvcValidationFailed = NO;
	_dateValidationFailed = NO;
	_cardNumberValidationFailed = NO;
	
	[self updatePlaceholders];
	[self setTextColor:_textColor];
}

#pragma mark Validation

- (BOOL)validateForm
{
	BOOL result = YES;
	
	[self resetValidationResults];
	
	if (self.secureModeEnabled)
	{
		BOOL cvcIsValid = [self validateCVC];
		if (!cvcIsValid)
		{
			_cvcValidationFailed = YES;
			self.textFieldCardCVC.textColor = [UIColor redColor];
		}
		result &= cvcIsValid;
	}
	else
	{
		if (self.extendedModeEnabled)
		{
			BOOL cvcIsValid = [self validateCVC];
			if (!cvcIsValid)
			{
				_cvcValidationFailed = YES;
				self.textFieldCardCVC.textColor = [UIColor redColor];
			}
			result &= cvcIsValid;
			
			BOOL dateIsValid = [self validateDate];
			if (!dateIsValid)
			{
				_dateValidationFailed = YES;
				self.textFieldCardDate.textColor = [UIColor redColor];
			}
			result &= dateIsValid;
		}
		
		
		BOOL cardNumberIsValid = YES;
		if (_creditCardType == CardIOCreditCardTypeDiscover)
		{
			cardNumberIsValid = self.textFieldCardNumber.text.length > 0;
		}
		else if (_creditCardType == CardIOCreditCardTypeUnrecognized)
		{
			cardNumberIsValid = NO;
		}
		else
		{
			cardNumberIsValid = [NSString luhnCheck:self.cardNumber];
		}
		
		if (!cardNumberIsValid)
		{
			_cardNumberValidationFailed = YES;
			_textFieldCardNumber.textColor = [UIColor redColor];
		}
		
		result &= cardNumberIsValid;
	}
	
	[self updatePlaceholders];
	
	return result;
}

- (void)validateCardNumberAndCollapse
{
	TCSMBiOSTextField *textField = self.textFieldCardNumber;
	BOOL cardNumberIsValid = [NSString luhnCheck:[self cardNumber]];
	
	if (_expanded)
	{
		if (cardNumberIsValid)
		{
			[textField resignFirstResponder];
			if (self.extendedModeEnabled && !self.secureModeEnabled)
			{
				[textField resignFirstResponder];
				[self.textFieldCardDate becomeFirstResponder];
			}
			else
			{
				[textField resignFirstResponder];
			}
			
			[textField setTextColor:self.textColor];
			[self setCardNumberExpanded:NO animated:YES];
			[self setNextButtonHidden:YES animated:YES];
			[self setScanButtonHidden:YES animated:YES];
		}
		else
		{
			[textField setTextColor:[UIColor redColor]];
		}
	}
}

- (BOOL)validateCVC
{
	return [self validateString:self.textFieldCardCVC.text inputMask:self.textFieldCardCVC.inputMask];
}

- (BOOL)validateDate
{
	BOOL resultExpirationDate = [self validateString:self.textFieldCardDate.text inputMask:self.textFieldCardDate.inputMask];
	if (resultExpirationDate == YES)
	{
		NSArray *components = [self.textFieldCardDate.text componentsSeparatedByString:@"/"];
		NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnit)(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
		if ([[components objectAtIndex:1] integerValue] < currentDateComponents.year%1000)
		{
			resultExpirationDate = NO;
		}
		else if ([[components objectAtIndex:1] integerValue] == currentDateComponents.year%1000 && [[components objectAtIndex:0] integerValue] < currentDateComponents.month)
		{
			resultExpirationDate = NO;
		}
		else if ([[components objectAtIndex:0] integerValue] > 12)
		{
			resultExpirationDate = NO;
		}
	}
	
	return resultExpirationDate;
}



#pragma mark Internal animated status trans itions


- (void)setPaymentLogoHidden:(BOOL)hidden animated:(BOOL)animated
{
	CGFloat alpha = hidden ? 0 : 1;
	CGFloat width = hidden ? 0 : 30;
	CGFloat numberX = hidden ? 15 : 48;
	CGFloat logoX = hidden ? -30 : 15;
	
	[self.contentView layoutIfNeeded];
	
	if (_paymentLogoHidden != hidden)
	{
		_paymentLogoHidden = hidden;
		
		if(animated)
		{
			__strong __typeof(self) weakSelf = self;
			[UIView animateWithDuration:0.5 animations:^{
				__strong __typeof(self) strongSelf = weakSelf;
				
				strongSelf.imagePaymentLogo.alpha = alpha;
				strongSelf.logoWidthConstraint.constant = width;
				strongSelf.cardNumberXConstraint.constant = numberX;
				strongSelf.logoXConstraint.constant = logoX;
				
				[strongSelf.contentView layoutIfNeeded];
			}];
		}
		else
		{
			self.imagePaymentLogo.alpha = alpha;
			self.logoWidthConstraint.constant = width;
			self.cardNumberXConstraint.constant = numberX;
			self.logoXConstraint.constant = logoX;
		}
	}
}



-(void)setNextButtonHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self setHidden:hidden button:self.nextButton constraint:self.nextButtonXConstraint animated:animated];
}
-(void)setScanButtonHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self setHidden:hidden button:self.cardIOButton constraint:self.cardIOButtonXConstraint animated:animated];
}

- (void)setHidden:(BOOL)hidden button:(UIButton *)button constraint:(NSLayoutConstraint *)constraint animated:(BOOL)animated
{
	UIButton *buttonToHide = nil;
	UIButton *buttonToShow = nil;
	
	NSLayoutConstraint *constraintToHide = nil;
	NSLayoutConstraint *constraintToShow = nil;
	
	const CGFloat kHiddenConstant = -100;
	const CGFloat kVisibleConstant = 12;
	
	if (hidden && (!button.hidden || !animated))
	{
		buttonToHide = button;
		constraintToHide = constraint;
	}
	else if (!hidden && (button.hidden || !animated))
	{
		buttonToShow = button;
		constraintToShow = constraint;
	}
	
	if (buttonToHide || buttonToShow)
	{
		if (animated) {
			[self.contentView layoutIfNeeded];
			
			__strong __typeof(self) weakSelf = self;
			[UIView animateWithDuration:0.5
								  delay:0.0
				 usingSpringWithDamping:1.0
				  initialSpringVelocity:1.0
								options:0
							 animations:^{
								 __strong __typeof(self) strongSelf = weakSelf;
								 
								 [constraintToHide setConstant:kHiddenConstant];
								 [constraintToShow setConstant:kVisibleConstant];
								 
								 [buttonToShow setHidden:NO];
								 
								 [strongSelf.contentView layoutIfNeeded];
							 } completion:^(BOOL finished) {
								
								 if (constraintToHide.constant == kHiddenConstant)
								 {
									  [buttonToHide setHidden:YES];
								 }
							 }];
		}
		else
		{
			[constraintToHide setConstant:kHiddenConstant];
			[constraintToShow setConstant:kVisibleConstant];
			
			[buttonToShow setHidden:NO];
			[buttonToHide setHidden:YES];
			[self.contentView layoutIfNeeded];
		}
	}
}

- (void)setCardNumberExpanded:(BOOL)expanded animated:(BOOL)animated
{
	if (!_extendedModeEnabled)
	{
		expanded = YES;
	}
	
	if (_secureModeEnabled)
	{
		expanded = NO;
	}
	
	[self resetValidationResults];
	
	CGFloat viewWidth = self.frame.size.width;
	
	__block CGFloat cvcViewX = self.cardCVCXConstraint.constant;
	__block CGFloat dateViewX = self.cardDateXConstraint.constant;
	__block CGFloat numberViewWidth = self.cardNumberWidthConstraint.constant;
    CGFloat expAndCVVAlpha = 0.0f;
	
	CGFloat maxWidth = self.frame.size.width - 60;
	CGFloat minWidth = 60;
	
	NSString *cardNumberText = self.textFieldCardNumber.text;
	
	if (_expanded == expanded) return;
	
	_expanded = expanded;
	
	if (expanded)
	{
		cvcViewX = -100;
		dateViewX = -(viewWidth / 2 + 100);
		numberViewWidth = maxWidth;
		cardNumberText = self.fullCardNumber;
	}
	else
	{
        expAndCVVAlpha = 1.0f;
		cvcViewX = 8;
		dateViewX = -10;//-[self defaultDateOffset];
		numberViewWidth = minWidth;
		if (self.fullCardNumber)
			cardNumberText = [@"*" stringByAppendingString:[self.fullCardNumber substringFromIndex:self.fullCardNumber.length - 4]];
	}
	
	if (cardNumberText)
		self.textFieldCardNumber.text = cardNumberText;
	
	[self.contentView layoutIfNeeded];
	
	if (animated)
	{
		__weak __typeof(self) weakSelf = self;
		[UIView animateWithDuration:0.6
							  delay:0.0
			 usingSpringWithDamping:1.0
			  initialSpringVelocity:1.0
							options:0
						 animations:^{
							 __strong __typeof(self) strongSelf = weakSelf;
							 
							 strongSelf.cardCVCXConstraint.constant = cvcViewX;
							 strongSelf.cardDateXConstraint.constant = dateViewX;
							 strongSelf.cardNumberWidthConstraint.constant = numberViewWidth;
							
                             strongSelf.textFieldCardNumber.text = cardNumberText;
                             
                             strongSelf.textFieldCardDate.alpha = expAndCVVAlpha;
                             strongSelf.textFieldCardCVC.alpha = expAndCVVAlpha;
                             
							 [strongSelf.contentView layoutIfNeeded];
						 } completion:nil];
	}
	else
	{
		self.cardCVCXConstraint.constant = cvcViewX;
		self.cardDateXConstraint.constant = dateViewX;
		self.cardNumberWidthConstraint.constant = numberViewWidth;
        
        self.textFieldCardDate.alpha = expAndCVVAlpha;
        self.textFieldCardCVC.alpha = expAndCVVAlpha;
		
		[self.contentView layoutIfNeeded];
	}
}


#pragma mark - CardIOPaymentViewControllerDelegate

- (void)setupCardScaner:(CardIOPaymentViewController *)cardScaner
{
	[cardScaner setKeepStatusBarStyle:YES];
	[cardScaner setSuppressScanConfirmation:YES];
	[cardScaner setUseCardIOLogo:YES];
	[cardScaner setDisableManualEntryButtons:YES];
	[cardScaner setCollectExpiry:NO];
	[cardScaner setCollectCVV:NO];
}

- (void)openCardScaner
{
	[self.textFieldCardCVC resignFirstResponder];
	[self.textFieldCardNumber resignFirstResponder];
	[self.textFieldCardDate resignFirstResponder];
	
	[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (granted)
			{
				CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
				scanViewController.disableBlurWhenBackgrounding = YES;
				scanViewController.navigationBarStyle = UIBarStyleBlack;
//				scanViewController.appToken = @"f887b591cf3042a3992c767b746bc115";
				[self setupCardScaner:scanViewController];
//				[scanViewController setModalPresentationStyle:UIModalPresentationFormSheet];
//				UIViewController *parentViewController = [self firstAvailableUIViewController];
//				[parentViewController presentViewController:scanViewController animated:YES completion:nil];
			}
			else
			{
//                MBAlertManager *alert = [MBAlertManager alertWithTitle:nil message:LOC(@"warning.noAccessToPhotoCamera")];
//                [alert addAction:[MBAlertAction actionWithTitle:LOC(@"button.close") style:MBAlertActionStyleCancel handler:nil]];
//				[alert show];
			}
		});
	}];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
	//	DLog(@"Scan succeeded with info: %@", info);
	
	[paymentViewController dismissViewControllerAnimated:YES completion:nil];
	
	if ( info.cvv && [info.cvv length] > 0)
	{
		[self.textFieldCardCVC setText:info.cvv];
	}
	
	if (info.expiryMonth > 0 && info.expiryYear > 0)
	{
		[self.textFieldCardDate setText:@""];
		
		NSString *newString = [NSString stringWithFormat:@"%02lu/%@", (unsigned long)info.expiryMonth, [[NSString stringWithFormat:@"%lu", (unsigned long)info.expiryYear] substringFromIndex:2]];
		[self.textFieldCardDate shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:newString];
	}
	
	[self.textFieldCardNumber setText:@""];
	
	[self setCardNumber:info.cardNumber];
	[self textField:self.textFieldCardNumber shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:info.cardNumber];
	
	//	DLog(@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber,
	//		 (unsigned long)info.expiryMonth,
	//		 (unsigned long)info.expiryYear,
	//		 info.cvv);
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
	//DLog(@"User cancelled scan");
	[paymentViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark Payment system detection

- (void)updateInputMasks
{
	NSString *cardNumber = [self cardNumber];
	[self updateInputMasksWithCardNumber:cardNumber];
}

- (void)updateInputMasksWithCardNumber:(NSString *)cardNumber
{
	switch (_creditCardType)
	{
		case CardIOCreditCardTypeVisa:
		{
			self.textFieldCardNumber.inputMask = TCSMBiOSCreditCardPaymentSystemInputMaskVisa;
			[self.textFieldCardCVC setInputMask:@"___"];
			break;
		}
		case CardIOCreditCardTypeMastercard:
		{
			self.textFieldCardNumber.inputMask = TCSMBiOSCreditCardPaymentSystemInputMaskMasterCard;
			[self.textFieldCardCVC setInputMask:@"___"];
			break;
		}
		case CardIOCreditCardTypeDiscover:
		{
			if (cardNumber.length <= 16)
			{
				self.textFieldCardNumber.inputMask = TCSMBiOSCreditCardPaymentSystemInputMaskMaestro16;
			}
			else if (cardNumber.length <= 19)
			{
				self.textFieldCardNumber.inputMask = TCSMBiOSCreditCardPaymentSystemInputMaskMaestro19;
			}
			else
			{
				self.textFieldCardNumber.inputMask = TCSMBiOSCreditCardPaymentSystemInputMaskMaestro22;
			}
			
			[self.textFieldCardCVC setInputMask:@"___"];
			break;
		}
		default:
		{
			[self.textFieldCardCVC setInputMask:@"____"];
			self.textFieldCardNumber.inputMask = TCSMBiOSCreditCardPaymentSystemInputDefault;
			break;
		}
	}
}

- (NSString *)paymentSystemSecurityCodeNameForCardType:(CardIOCreditCardType)creditCardType
{
	NSString *securityCodeName;
	
	switch (creditCardType)
	{
		case CardIOCreditCardTypeVisa:
			securityCodeName = @"CVV";
			break;
			
		case CardIOCreditCardTypeMastercard:
		case CardIOCreditCardTypeDiscover:
			securityCodeName = @"CVC";
			break;
			
		default:
			securityCodeName = @"CVC";
			break;
	}
	
	return securityCodeName;
}


- (NSString *)paymentSystemIconNameForCardType:(CardIOCreditCardType)creditCardType
{
	NSString *iconName;
	
	switch (creditCardType)
	{
		case CardIOCreditCardTypeVisa:
		{
			iconName = _useDarkIcons ? @"psIconVisa" : @"psIconVisa_White";
			break;
		}
		case CardIOCreditCardTypeMastercard:
		{
			iconName = @"psIconMastercard";
			break;
		}
		case CardIOCreditCardTypeDiscover:
		{
			iconName = @"psIconMaestro";
			break;
		}
		default:
		{
			if (self.textFieldCardNumber.text.length == 0) {
				iconName = @"psIcons";
			}
			break;
		}
	}
	
	return iconName;
}

- (NSString *)numbersStringFromString:(NSString *)string
{
    if ([string length] >0)
    {
        static NSCharacterSet *nonDecimalDigitCharacterSet_ = nil;
        @synchronized(self)
        {
            if (nonDecimalDigitCharacterSet_ == nil)
            {
                nonDecimalDigitCharacterSet_ = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            }
            
            return [[string componentsSeparatedByCharactersInSet:nonDecimalDigitCharacterSet_] componentsJoinedByString:@""];
        }
    }
    
    return @"";
}

- (BOOL)validateString:(NSString *)text inputMask:(NSString *)mask
{
    NSCharacterSet *maskCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSString *nonFormatText = [[text componentsSeparatedByCharactersInSet:[maskCharacterSet invertedSet]] componentsJoinedByString:@""];
    maskCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"_"];
    NSString *nonFormatMask = [[mask componentsSeparatedByCharactersInSet:[maskCharacterSet invertedSet]] componentsJoinedByString:@""];
    
    if ([nonFormatText length] == [nonFormatMask length])
        return YES;
    
    return NO;
}

@end
