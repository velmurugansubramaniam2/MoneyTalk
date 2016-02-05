//
//  TCSMTCellWithTextField.h
//  Telegraph
//
//  Created by spb-EOrlova on 20.11.15.
//
//

#import <UIKit/UIKit.h>
#import "TCSMTBaseCellWithSeparators.h"
#import "TCSMBiOSTextField.h"

@interface TCSMTCellWithTextField : TCSMTBaseCellWithSeparators

@property (weak, nonatomic) IBOutlet TCSMBiOSTextField *textField;

+ (TCSMTCellWithTextField *)newCell;

@end
