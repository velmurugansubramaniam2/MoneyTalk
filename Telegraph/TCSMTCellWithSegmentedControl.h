//
//  TCSMTTCSMTCellWithSegmentedControl.h
//  Telegraph
//
//  Created by spb-EOrlova on 23.11.15.
//
//

#import <UIKit/UIKit.h>
#import "TCSMTCellWithTextField.h"

@interface TCSMTCellWithSegmentedControl : UITableViewCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

+ (TCSMTCellWithSegmentedControl *)newCell;

@end
