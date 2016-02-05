//
//  TGTMTCommissionCell.h
//  Telegraph
//
//  Created by Max Zhdanov on 15.12.15.
//
//

#import <UIKit/UIKit.h>

@interface TGTMTCommissionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *commissionLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

+ (TGTMTCommissionCell *)newCell;

@end
