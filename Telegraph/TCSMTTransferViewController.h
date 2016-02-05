//
//  TCSMTTransferViewController.h
//  Telegraph
//
//  Created by spb-EOrlova on 20.11.15.
//
//

#import <UIKit/UIKit.h>

@class TGUser;

@protocol TCSMTTransferViewControllerDelegate <NSObject>

@optional
- (void)sendTransferMessageWithText:(NSString *)text;

@end

@interface TCSMTTransferViewController : UITableViewController

@property (nonatomic, weak) id <TCSMTTransferViewControllerDelegate> delegate;
@property (nonatomic, strong) TGUser *selectedReceiver;

- (instancetype)initWithConversationId:(int64_t)conversationId;

@end
