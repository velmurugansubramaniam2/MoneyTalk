//
//  TCSMTAmountCell.h
//  Telegraph
//
//  Created by spb-EOrlova on 01.12.15.
//
//

#import "TCSMTCellWithTextField.h"

@interface TCSMTAmountCell : TCSMTCellWithTextField

@property (weak, nonatomic) IBOutlet UILabel *commissionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
