//
//  NSNumberFormatter+SummAmount.m
//  TCSiCore
//
//  Created by Andrey Ilskiy on 10/03/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSNumberFormatter+SummAmount.h"
#import "TCSMacroses.h"

#define kSummGroupingSeparator @" "

@implementation NSNumberFormatter (SummAmount)

+ (instancetype)rubleNumberFormatter
{
    NSNumberFormatter * const this = [NSNumberFormatter new];
    this.numberStyle = NSNumberFormatterCurrencyStyle;
    this.currencySymbol = @"₽";
    this.currencyDecimalSeparator = @",";
    this.currencyGroupingSeparator = @"";
    this.currencyCode = @"RUB";
    
    return this;
}

+ (id)currentDecimalSeparator
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
}


#pragma mark - Checkers

+ (BOOL)hasAmountFractionDigits:(Float64)amount digit:(NSInteger)digit
{
    Float64 fractionAmount = [self fractionAmountFromAmount:amount withNumberOfDigits:digit];
    
    return (round(fractionAmount) == 0) ? YES : NO;
}

+ (BOOL)hasAmountFractionDigits:(Float64)amount
{
    return [NSNumberFormatter hasAmountFractionDigits:amount digit:2];
}

+ (BOOL)hasAmountFractionDigits4:(Float64)amount
{
    return [NSNumberFormatter hasAmountFractionDigits:amount digit:4];
}




#pragma mark - Fractions

+ (Float64)fractionAmountFromAmount:(Float64)amount withNumberOfDigits:(NSInteger)numberOfDigits
{
    amount = fabs(amount);
    double fractionAmount = (amount - floor(amount))*pow(10, numberOfDigits);
    
    return fractionAmount;
}




#pragma mark - String formatting

+ (NSString *)amountAsFormattedString:(Float64)amount
{
    if ([self hasAmountFractionDigits:amount])
    {
        return [self amountWholeDigits:amount];
    }
    
    return [self amountAsString:amount];
}

+ (NSString *)amountAsString:(Float64)amount
{
    return [NSString stringWithFormat:@"%@%@%@", [self amountWholeDigits:amount], [self currentDecimalSeparator], [self amountFractionDigits:amount]];
}

+ (NSString *)amountAsStringForCommission:(Float64)amount
{
    return [NSString stringWithFormat:@"%@%@%@", [self amountWholeDigits:amount], [self currentDecimalSeparator], [NSNumberFormatter amountFractionDigits:amount]];
}

+ (NSString *)amountWholeDigits:(Float64)amount
{
    NSString *string = [[self rubleNumberFormatter] stringFromNumber:@(amount)];
    NSArray *array = [string componentsSeparatedByString:[self currentDecimalSeparator]];
    
    if ([array count] == 2)
    {
        return [array objectAtIndex:0];
    }
    
    return string;
}

+ (NSString *)amountFractionDigits:(Float64)amount
{
    Float64 fractionAmount = [NSNumberFormatter fractionAmountFromAmount:amount withNumberOfDigits:2];
    Float64 retVal = round(fractionAmount);
    
    return [NSString stringWithFormat:retVal < 10 ? @"%02.0f" : @"%.0f", retVal];
}

/*
 Метод возвращает дробную часть amount с точностью 4 знака после запятой
 */
+ (NSString *)amountFractionDigits4:(Float64)amount
{
    Float64 fractionAmount = [NSNumberFormatter fractionAmountFromAmount:amount withNumberOfDigits:4];
    Float64 retVal = round(fractionAmount);
    
    return [NSString stringWithFormat:retVal < 1000 ? @"%04.0f": @"%.0f",retVal];
}


+ (NSString *)setSummDecimalSeparator:(NSString *)amountString
{
    NSString *separator = [self currentDecimalSeparator];
    
    NSString *refinedString = amountString;
    refinedString = [refinedString stringByReplacingOccurrencesOfString:@"." withString:separator];
    refinedString = [refinedString stringByReplacingOccurrencesOfString:@"," withString:separator];
    
    return refinedString;
}

+ (NSString *)fixDecimalSeparator:(NSString *)decimalString
{
    return [decimalString stringByReplacingOccurrencesOfString:@"," withString:[self currentDecimalSeparator]];
}

+ (NSNumber *)nonFormatAmount:(NSString *)amountString
{
    NSString *strAmount = [NSNumberFormatter nonFormatAmountString:amountString];
    
    NSNumber *number = @([strAmount floatValue]);
    
    return number;
}

+ (NSString *)nonFormatAmountString:(NSString *)amountString
{
    NSString *strAmount = [NSNumberFormatter fixDecimalSeparator:amountString];
    
    strAmount = [strAmount stringByReplacingOccurrencesOfString:@" " withString:@""];
    strAmount = [strAmount stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return strAmount;
}

/*
 Метод возвращает форматированное значение суммы.
 Используется при вводе в UITextField
 */
+ (NSString *)formatInputSumm:(NSString *)aTextFieldString
                       string:(NSString *)string
                        range:(NSRange)range
{
    return [self formatInputSumm:aTextFieldString
                          string:string
                           range:range
                    cutSeparator:YES];
}

+ (NSString *)formatInputSumm:(NSString *)aTextFieldString
                       string:(NSString *)string
                        range:(NSRange)separatorRange
                 cutSeparator:(BOOL)cutSeparator
{
    NSString *separator = [self currentDecimalSeparator];
    
    string = [string stringByReplacingOccurrencesOfString:@"." withString:separator];
    string = [string stringByReplacingOccurrencesOfString:@"," withString:separator];
    
    NSString * regExpString = [NSString stringWithFormat:@"[0-9]*\\%@?[0-9]{0,2}", separator];
    
    NSMutableString * resString = [NSMutableString stringWithString:aTextFieldString ?: @""];
    [resString replaceCharactersInRange:separatorRange withString:string];
    
    NSError * error = nil;
    NSRegularExpression * regExp= [NSRegularExpression regularExpressionWithPattern: regExpString
                                                                            options: NSRegularExpressionCaseInsensitive
                                                                              error: &error];
    resString = (NSMutableString*)[resString stringByReplacingOccurrencesOfString:kSummGroupingSeparator withString:@""];
    NSRange wholeRange = NSMakeRange(0, resString.length);
    NSTextCheckingResult * checkResult = [regExp firstMatchInString:resString options:0 range:wholeRange];
    if (checkResult == nil) {
        DLog(@"checkResult == nil");
        return aTextFieldString;
    }
    
    if ([checkResult numberOfRanges] == 0 && resString.length > 0) {
        DLog(@"[checkResult numberOfRanges] == 0 && string.length > 0");
        return aTextFieldString;
    }
    
    NSRange firstRange = [checkResult rangeAtIndex:0];
    if (!NSEqualRanges(firstRange, wholeRange))
    {
        DLog(@"!NSEqualRanges(firstRange, wholeRange)");
        return aTextFieldString;
    }
    
    separatorRange = [resString rangeOfString:separator];
    NSString *strCurrencyAfterDot = nil;
    
    if (separatorRange.location != NSNotFound)
    {
        strCurrencyAfterDot = [resString substringFromIndex:separatorRange.location];
        resString = (NSMutableString*)[resString substringToIndex:(separatorRange.location + (cutSeparator ? 0 : 1))];
    }
    
    static NSNumberFormatter *currencyFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setGroupingSize:3];
        [currencyFormatter setNumberStyle:NSNumberFormatterNoStyle];
        [currencyFormatter setGroupingSeparator:kSummGroupingSeparator];
        [currencyFormatter setDecimalSeparator:separator];
        [currencyFormatter setUsesGroupingSeparator:YES];
    });
    
    if ([resString longLongValue] > LONG_LONG_MAX - 1)
    {
        return aTextFieldString;
    }
    
    NSString *str = [currencyFormatter stringFromNumber:[NSDecimalNumber numberWithLongLong:[resString longLongValue]]];
    
    if ([strCurrencyAfterDot length] > 0)
    {
        str = [NSString stringWithFormat:@"%@%@",str,strCurrencyAfterDot];
    }
    
    return str;
}

+ (NSString *)formatInputSumm:(NSString *)nonFormatAmountString oldString:(NSString *)oldString
{
    NSString *separator = [self currentDecimalSeparator];
    
    nonFormatAmountString = [self setSummDecimalSeparator:nonFormatAmountString];
    NSString * regExpString = [NSString stringWithFormat:@"[0-9]*\\%@?[0-9]{0,2}", separator];
    
    NSMutableString * resString = nonFormatAmountString ? [NSMutableString stringWithString:nonFormatAmountString] : [NSMutableString string];
    
    NSError * error = nil;
    NSRegularExpression * regExp= [NSRegularExpression regularExpressionWithPattern: regExpString
                                                                            options: NSRegularExpressionCaseInsensitive
                                                                              error: &error];
    resString = (NSMutableString*)[resString stringByReplacingOccurrencesOfString:kSummGroupingSeparator withString:@""];
    NSRange wholeRange = NSMakeRange(0, resString.length);
    NSTextCheckingResult * checkResult = [regExp firstMatchInString:resString options:0 range:wholeRange];
    if (checkResult == nil) {
        DLog(@"checkResult == nil");
        return oldString;
    }
    
    if ([checkResult numberOfRanges] == 0 && resString.length > 0) {
        DLog(@"[checkResult numberOfRanges] == 0 && string.length > 0");
        return oldString;
    }
    
    NSRange firstRange = [checkResult rangeAtIndex:0];
    if (!NSEqualRanges(firstRange, wholeRange))
    {
        DLog(@"!NSEqualRanges(firstRange, wholeRange)");
        return oldString;
    }
    
    NSRange range = [resString rangeOfString:separator];
    NSString *strCurrencyAfterDot = nil;
    
    if (range.length >0)
    {
        strCurrencyAfterDot = [resString substringFromIndex:range.location];
        resString = (NSMutableString*)[resString substringToIndex:range.location];
    }
    
    NSNumberFormatter * currencyFormatter = nil;
    currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setGroupingSize:3];
    [currencyFormatter setNumberStyle:NSNumberFormatterNoStyle];
    [currencyFormatter setGroupingSeparator:kSummGroupingSeparator];
    [currencyFormatter setDecimalSeparator:[self currentDecimalSeparator]];
    [currencyFormatter setUsesGroupingSeparator:YES];
    
    if ([resString integerValue] > NSIntegerMax-1)
    {
        return oldString;
    }
    
    NSString *str = [currencyFormatter stringFromNumber:[NSDecimalNumber numberWithInteger:[resString integerValue]]];
    
    if ([strCurrencyAfterDot length]>0)
    {
        str = [NSString stringWithFormat:@"%@%@",str,strCurrencyAfterDot];
    }
    
    return str;
}


@end
