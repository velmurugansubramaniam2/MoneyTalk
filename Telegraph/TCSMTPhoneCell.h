//
//  TCSMTPhoneCell.h
//  Telegraph
//
//  Created by Max Zhdanov on 16.12.15.
//
//

#import "TCSMTCellWithTextField.h"

@interface TCSMTPhoneCell : TCSMTCellWithTextField

+ (TCSMTPhoneCell *)newCell;

- (NSString *)formattedPhoneString;

@end
