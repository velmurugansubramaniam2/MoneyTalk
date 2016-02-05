//
//  TCSMTCardTableViewCell.h
//  Telegraph
//
//  Created by Max Zhdanov on 14.12.15.
//
//

#import <UIKit/UIKit.h>
#import "TCSMTBaseCellWithSeparators.h"

@interface TCSMTCardTableViewCell : TCSMTBaseCellWithSeparators

@property (nonatomic, weak) IBOutlet UILabel *cardNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *paymentSystemLogoImageView;

+ (TCSMTCardTableViewCell *)newCell;

@end
