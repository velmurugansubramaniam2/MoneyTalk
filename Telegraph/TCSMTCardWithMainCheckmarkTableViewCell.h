//
//  TCSMTCardWithMainCheckmarkTableViewCell.h
//  Telegraph
//
//  Created by Max Zhdanov on 14.12.15.
//
//

#import <UIKit/UIKit.h>

@interface TCSMTCardWithMainCheckmarkTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *cardNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *paymentSystemLogoImageView;
@property (nonatomic, weak) IBOutlet UILabel *isMainLabel;

@property (nonatomic, assign) BOOL mainCard;

+ (TCSMTCardWithMainCheckmarkTableViewCell *)newCell;

@end
