//
//  TCSMTAmountCell.m
//  Telegraph
//
//  Created by spb-EOrlova on 01.12.15.
//
//

#import "TCSMTAmountCell.h"

@implementation TCSMTAmountCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (TCSMTAmountCell *)newCell
{
    TCSMTAmountCell *newCell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    
    if (newCell)
    {
    }
    
    return newCell;
}

@end
