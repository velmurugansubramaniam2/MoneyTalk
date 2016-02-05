//
//  TGTMTCommissionCell.m
//  Telegraph
//
//  Created by Max Zhdanov on 15.12.15.
//
//

#import "TGTMTCommissionCell.h"

@interface TGTMTCommissionCell ()

@end

@implementation TGTMTCommissionCell

+ (TGTMTCommissionCell *)newCell
{
    TGTMTCommissionCell *newCell = [[[NSBundle mainBundle] loadNibNamed:@"TGTMTCommissionCell" owner:nil options:nil] firstObject];
    
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
