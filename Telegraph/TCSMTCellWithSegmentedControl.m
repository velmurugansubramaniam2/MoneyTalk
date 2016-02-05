//
//  TCSMTTCSMTCellWithSegmentedControl.m
//  Telegraph
//
//  Created by spb-EOrlova on 23.11.15.
//
//

#import "TCSMTCellWithSegmentedControl.h"
#import "TCSTGTelegramMoneyTalkProxy.h"

@implementation TCSMTCellWithSegmentedControl

- (void)awakeFromNib
{
    // Initialization code
    self.segmentedControl.tintColor = [TCSTGTelegramMoneyTalkProxy tgAccentColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (TCSMTCellWithSegmentedControl *)newCell
{
    TCSMTCellWithSegmentedControl *newCell = [[[NSBundle mainBundle] loadNibNamed:@"TCSMTCellWithSegmentedControl" owner:nil options:nil] firstObject];
    
    if (newCell)
    {
    }
    
    return newCell;
}

@end
