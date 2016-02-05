//
//  TCSMTCellWithButton.m
//  Telegraph
//
//  Created by spb-EOrlova on 14.12.15.
//
//

#import "TCSMTCellWithButton.h"
#import "TCSTGTelegramMoneyTalkProxy.h"

@implementation TCSMTCellWithButton

+ (TCSMTCellWithButton *)newCell
{
    TCSMTCellWithButton *newCell = [[[NSBundle mainBundle] loadNibNamed:@"TCSMTCellWithButton" owner:nil options:nil] firstObject];
    
    if (newCell)
    {
    }
    
    return newCell;
}


- (void)awakeFromNib
{
    [self.performTransferButton.layer setCornerRadius:3.0f];
    self.performTransferButton.backgroundColor = [TCSTGTelegramMoneyTalkProxy tgAccentColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
