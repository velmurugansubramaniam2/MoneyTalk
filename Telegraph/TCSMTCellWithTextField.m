//
//  TCSMTCellWithTextField.m
//  Telegraph
//
//  Created by spb-EOrlova on 20.11.15.
//
//

#import "TCSMTCellWithTextField.h"

@implementation TCSMTCellWithTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (TCSMTCellWithTextField *)newCell
{
    TCSMTCellWithTextField *newCell = [[[NSBundle mainBundle] loadNibNamed:@"TCSMTCellWithTextField" owner:nil options:nil] firstObject];
    
    if (newCell)
    {
    }
    
    return newCell;
}

@end
