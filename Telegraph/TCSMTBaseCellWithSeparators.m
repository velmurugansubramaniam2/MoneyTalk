//
//  TCSMTBaseCellWithSeparators.m
//  Telegraph
//
//  Created by Max Zhdanov on 15.12.15.
//
//

#import "TCSMTBaseCellWithSeparators.h"
#import "UIImage+CS_Extensions.h"

#define kSeparatorLineHeight		1.0f / [[UIScreen mainScreen] scale]

@interface TCSMTBaseCellWithSeparators ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topSeparatorHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomSeparatorHeight;

@property (nonatomic, weak) IBOutlet UIImageView *topSeparator;
@property (nonatomic, weak) IBOutlet UIImageView *bottomSeparator;

@end

@implementation TCSMTBaseCellWithSeparators

+ (TCSMTBaseCellWithSeparators *)newCell
{
    TCSMTBaseCellWithSeparators *newCell = [[[NSBundle mainBundle] loadNibNamed:@"TCSMTBaseCellWithSeparators" owner:nil options:nil] firstObject];
    
    if (newCell)
    {
    }
    
    return newCell;
}

- (void)setCustomSeparatorColor:(UIColor *)customSeparatorColor
{
    _customSeparatorColor = customSeparatorColor;
    
    self.topSeparator.image = [UIImage imageWithColor:_customSeparatorColor];
    self.bottomSeparator.image = [UIImage imageWithColor:_customSeparatorColor];
}

- (void)setShouldHideTopSeparator:(BOOL)shouldHideTopSeparator
{
    _shouldHideTopSeparator = shouldHideTopSeparator;
    
    self.topSeparator.alpha = !_shouldHideTopSeparator ? 1 : 0;
}

- (void)awakeFromNib
{
    [super layoutSubviews];
    
    self.topSeparatorHeight.constant = kSeparatorLineHeight;
    self.bottomSeparatorHeight.constant = kSeparatorLineHeight;
    
    UIColor *defaultColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
    [self setCustomSeparatorColor:defaultColor];
    
    self.topSeparator.alpha = !self.shouldHideTopSeparator ? 1 : 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
