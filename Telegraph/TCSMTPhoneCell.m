//
//  TCSMTPhoneCell.m
//  Telegraph
//
//  Created by Max Zhdanov on 16.12.15.
//
//

#import "TCSMTPhoneCell.h"
#import "TCSUtils.h"
#import "NSCharacterSet+Helpers.h"
#import "TCSMTLocalConstants.h"

@implementation TCSMTPhoneCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.textField setInputMask:kPlaceholderPhoneNumber];
    [self.textField setShowInputMask:YES];
    [self.textField setText:@"+7 ("];
}

+ (TCSMTPhoneCell *)newCell
{
    TCSMTPhoneCell *newCell = [[[NSBundle mainBundle] loadNibNamed:@"TCSMTPhoneCell" owner:nil options:nil] firstObject];
    
    if (newCell)
    {
    }
    
    return newCell;
}

- (NSString *)formattedPhoneString
{
    return [self stringByRemovingAllNondecimalCharacters];
}

- (NSString *)stringByRemovingAllNondecimalCharacters
{
    NSString *phone = self.textField.text;
    
    if (phone > 0)
    {
        NSMutableCharacterSet *digitsAndPlus = [NSCharacterSet characterSetAllExceptDecimalDigits].mutableCopy;
        [digitsAndPlus removeCharactersInString:@"+"];
        
        NSString *formattedPhone = [[phone componentsSeparatedByCharactersInSet:digitsAndPlus] componentsJoinedByString:@""];
        return formattedPhone;
    }
    
    return @"";
}

@end
