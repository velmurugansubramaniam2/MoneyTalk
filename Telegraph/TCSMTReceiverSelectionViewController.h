//
//  TCSMTReceiverSelectionViewController.h
//  Telegraph
//
//  Created by spb-EOrlova on 01.12.15.
//
//

#import <UIKit/UIKit.h>

@class TGUser;

@protocol TCSMTReceiverSelectionDelegate <NSObject>

@optional
- (void)didSelectReceiver:(TGUser *)receiver;

@end

@interface TCSMTReceiverSelectionViewController : UITableViewController
@property (nonatomic, weak) id <TCSMTReceiverSelectionDelegate> delegate;

- (instancetype)initWithConversationId:(int64_t)conversationId;

@end
