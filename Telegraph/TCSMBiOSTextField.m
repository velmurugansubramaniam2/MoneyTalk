//
//  TCSMBiOSTextField.m
//  TCSMBiOS
//
//  Created by Вячеслав Владимирович Будников on 16.10.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMBiOSTextField.h"

@interface TCSMBiOSTextField () <UIKeyInput>

@end

@implementation TCSMBiOSTextField

NSMutableString *filteredPhoneStringFromStringWithFilter(NSString *string, NSString *filter);

- (void)setInputMask:(NSString *)inputMask
{
	_inputMask = inputMask;
	if (_labelInputMask == nil)
 	{
		_labelInputMask = [[TCSMBiOSLabel alloc] initWithFrame:self.bounds];
		[self addSubview:_labelInputMask];
		[_labelInputMask setText:inputMask];
		[_labelInputMask setFont:self.font];
		[_labelInputMask setTextColor:[UIColor clearColor]];
		[_labelInputMask setHidden:YES];
	}
}

- (void)deleteBackward
{
	[super deleteBackward];
	
	id <TCSMBiOSTextFieldKeyInputDelegate> delegate = self.keyInputDelegate;
	if ([delegate respondsToSelector:@selector(textFieldDidDelete:)])
	{
		[delegate textFieldDidDelete:self];
	}
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
	if (self.hideCursor)
	{
		return CGRectZero;
	}
	else
	{
		return [super caretRectForPosition:position];
	}
}

- (void)setShowInputMask:(BOOL)value
{
	[_labelInputMask setHidden:!value];
}

- (void)setShowInputMask:(BOOL)value showCharacters:(NSArray *)characters
{
	[_labelInputMask setHidden:!value];
	_showInputMaskCharacters = [NSArray arrayWithArray:characters];
}

NSMutableString *filteredPhoneStringFromStringWithFilter(NSString *string, NSString *filter)
{
	NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
	char outputString[([filter length])];
	BOOL done = NO;
	
	while(onFilter < [filter length] && !done)
	{
		char originalChar = onOriginal >= string.length ? '\0' : (char)[string characterAtIndex:onOriginal];
        
        char filterChar = (char)[filter characterAtIndex:onFilter];
		switch (filterChar) {
			case '_':
				if(originalChar=='\0')
				{
					// We have no more input numbers for the filter.  We're done.
					done = YES;
					break;
				}
				if(isdigit(originalChar))
				{
					outputString[onOutput] = originalChar;
					onOriginal++;
					onFilter++;
					onOutput++;
				}
				else
				{
					onOriginal++;
				}
				break;
			default:
				// Any other character will automatically be inserted for the user as they type (spaces, - etc..) or deleted as they delete if there are more numbers to come.
				outputString[onOutput] = filterChar;
				onOutput++;
				onFilter++;
				if(originalChar == filterChar)
					onOriginal++;
				break;
		}
	}
	
	outputString[onOutput] = '\0'; // Cap the output string
    
    NSMutableString *result = [NSMutableString stringWithUTF8String:outputString];
    
    return result?:[[NSMutableString alloc] initWithBytes:outputString length:sizeof(outputString) encoding:NSASCIIStringEncoding];
}

- (NSRange)fixRange:(NSRange)range oldString:(NSString *)olsString mask:(NSString *)mask
{
    NSString *strToDelete = [olsString substringWithRange:range];
    
    if ([mask rangeOfString:strToDelete].length > 0)
    {
        if (range.location > 0)
        {
            range.location = range.location - 1;
            range.length = range.length + 1;
        }
    }
    
    return range;
}

- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if (string == nil)
	{
		return YES;
	}
	//self.inputMask = @"+7 (___) ___ - ____";
	
	if(self.inputMask == nil) return YES; // No filter provided, allow anything
	
    if (range.length == 1 && string.length == 0)// && [[self.text substringWithRange:range] isEqualToString:@" "]) // мы удаляем символ маски
    {
        NSRange previouseRange = range;
        
        for (NSInteger i = (NSInteger)range.location; i >= 0; i--)
        {
            NSRange newRange = [self fixRange:previouseRange oldString:self.text mask:self.inputMask];
            
            if (newRange.location == previouseRange.location)
            {
                break;
            }
            else
            {
                previouseRange = newRange;
            }
        }
        
        range = previouseRange;
    }
	
    NSString *changedString = [self.text stringByReplacingCharactersInRange:range withString:string];

    self.text = filteredPhoneStringFromStringWithFilter(changedString, self.inputMask);
	
	if ([_labelInputMask isHidden] == NO)
 	{
        NSMutableString *maskPlaseholder = [[NSMutableString alloc] init];
        for (NSUInteger i = 0; i < [self.inputMask length]; i++)
        {
            NSRange maskPlaseholderRange = {i,1};
            if (i >= self.text.length)
            {
                [maskPlaseholder appendString:[self.inputMask substringWithRange:maskPlaseholderRange]];
            }
            else
            {
                [maskPlaseholder appendString:[self.text substringWithRange:maskPlaseholderRange]];
            }
        }
        
		if ([_showInputMaskCharacters count] > 0)
		{
			NSMutableAttributedString *attributedForMask = [[NSMutableAttributedString alloc] initWithString:maskPlaseholder];
			for (NSString *character in _showInputMaskCharacters)
			{
				NSRange textRange = [maskPlaseholder rangeOfString:character];
				[attributedForMask setAttributes:@{NSForegroundColorAttributeName:self.textColor} range:textRange];
			}
			
			[_labelInputMask setAttributedText:attributedForMask];
		}
		else
		{
			[_labelInputMask setText:maskPlaseholder];
		}
	}

	return NO;
}

#pragma mark - Copy/Paste

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:))
    return !self.disablePaste;
    
    if (action == @selector(copy:) || action == @selector(cut:))
    return !self.disableCopy;
    
    return [super canPerformAction:action withSender:sender];
}

@end
