//
//  TCSMTSwitchCellTableViewCell.m
//  Telegraph
//
//  Created by Max Zhdanov on 14.12.15.
//
//

#import "TCSMTSwitchCellTableViewCell.h"

@implementation TCSMTSwitchCellTableViewCell

+ (TCSMTSwitchCellTableViewCell *)newCell
{
    TCSMTSwitchCellTableViewCell *newCell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    
    if (newCell)
    {
    }
    
    return newCell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end