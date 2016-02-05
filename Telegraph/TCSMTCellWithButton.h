//
//  TCSMTCellWithButton.h
//  Telegraph
//
//  Created by spb-EOrlova on 14.12.15.
//
//

#import <UIKit/UIKit.h>

@interface TCSMTCellWithButton : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *performTransferButton;

+ (TCSMTCellWithButton *)newCell;

@end
