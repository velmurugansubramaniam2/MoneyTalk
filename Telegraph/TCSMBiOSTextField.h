//
//  TCSMBiOSTextField.h
//  TCSMBiOS
//
//  Created by Вячеслав Владимирович Будников on 16.10.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMBiOSLabel.h"

@class TCSMBiOSTextField;
@protocol TCSMBiOSTextFieldKeyInputDelegate <NSObject>

@optional
- (void)textFieldDidDelete:(TCSMBiOSTextField *)textField;

@end

@interface TCSMBiOSTextField : UITextField
{
	TCSMBiOSLabel	*_labelInputMask;
	NSArray			*_showInputMaskCharacters;
}

@property (nonatomic, weak) id <TCSMBiOSTextFieldKeyInputDelegate> keyInputDelegate;

//!маска для ввода текста, вместо знака "_" цифра. Пример @"+_(___) ___-__-__"
@property (nonatomic, strong) NSString *inputMask;
//!показывать маску при вводе текста
@property (nonatomic) BOOL showInputMask;

//скрывать курсор при вводе
@property (nonatomic) BOOL hideCursor;

//достпуность копипаста
@property (nonatomic, assign) BOOL disablePaste;
@property (nonatomic, assign) BOOL disableCopy;
//!показывать в маске только символы из массива characters. Пример: показывать только скобки [TCSMBiOSTextField setShowInputMask:YES showCharacters:@[@"(", @")"]];
- (void)setShowInputMask:(BOOL)value showCharacters:(NSArray *)characters;
//!внутреняя обработка ввода текста для форматирования введенного текста по маске ввода
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end
