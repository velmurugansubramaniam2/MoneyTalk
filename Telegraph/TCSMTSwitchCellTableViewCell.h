//
//  TCSMTSwitchCellTableViewCell.h
//  Telegraph
//
//  Created by Max Zhdanov on 14.12.15.
//
//

#import <UIKit/UIKit.h>

@interface TCSMTSwitchCellTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UISwitch *switchItem;

+ (TCSMTSwitchCellTableViewCell *)newCell;

@end
