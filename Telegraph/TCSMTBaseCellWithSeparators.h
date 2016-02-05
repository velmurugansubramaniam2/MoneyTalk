//
//  TCSMTBaseCellWithSeparators.h
//  Telegraph
//
//  Created by Max Zhdanov on 15.12.15.
//
//

#import <UIKit/UIKit.h>

@interface TCSMTBaseCellWithSeparators : UITableViewCell

@property (nonatomic, assign) BOOL shouldHideTopSeparator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingMargingBottomSeparatorConstraint;
@property (nonatomic, strong) UIColor *customSeparatorColor;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

+ (TCSMTBaseCellWithSeparators *)newCell;

@end
