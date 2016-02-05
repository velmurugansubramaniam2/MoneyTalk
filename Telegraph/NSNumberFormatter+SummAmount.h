//
//  NSNumberFormatter+SummAmount.h
//  TCSiCore
//
//  Created by Andrey Ilskiy on 10/03/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

@interface NSNumberFormatter (SummAmount)

+ (instancetype)rubleNumberFormatter;


#pragma mark - Checkers

+ (BOOL)hasAmountFractionDigits:(Float64)amount digit:(NSInteger)digit;
+ (BOOL)hasAmountFractionDigits:(Float64)amount;
+ (BOOL)hasAmountFractionDigits4:(Float64)amount;

#pragma mark - Fractions

+ (Float64)fractionAmountFromAmount:(Float64)amount withNumberOfDigits:(NSInteger)numberOfDigits;

#pragma mark - String formatting
//TODO: remove unused methods

+ (NSString *)amountAsFormattedString:(Float64)amount;
+ (NSString *)amountAsString:(Float64)amount;
+ (NSString *)amountAsStringForCommission:(Float64)amount;
+ (NSString *)amountWholeDigits:(Float64)amount;
+ (NSString *)amountFractionDigits:(Float64)amount;
+ (NSString *)amountFractionDigits4:(Float64)amount;
+ (NSString *)setSummDecimalSeparator:(NSString *)amountString;
+ (NSString *)fixDecimalSeparator:(NSString *)decimalString;
+ (NSNumber *)nonFormatAmount:(NSString *)amountString;
+ (NSString *)nonFormatAmountString:(NSString *)amountString;
+ (NSString *)formatInputSumm:(NSString *)aTextFieldString
					   string:(NSString *)string
						range:(NSRange)range;
+ (NSString *)formatInputSumm:(NSString *)aTextFieldString
					   string:(NSString *)string
						range:(NSRange)separatorRange
				 cutSeparator:(BOOL)cutSeparator;
+ (NSString *)formatInputSumm:(NSString *)nonFormatAmountString
					oldString:(NSString *)oldString;

@end
