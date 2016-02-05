//
//  TCSMTReceiverSelectionViewController.m
//  Telegraph
//
//  Created by spb-EOrlova on 01.12.15.
//
//

#import "TCSMTReceiverSelectionViewController.h"
#import "TCSTGTelegramMoneyTalkProxy.h"
#import "TCSMacroses.h"

@interface TCSMTReceiverSelectionViewController ()
{
    int64_t _conversationId;
}

@property (nonatomic, strong) NSArray *receiversArray;

@end

@implementation TCSMTReceiverSelectionViewController

#pragma mark - Getters

- (NSArray *)receiversArray
{
    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_conversationId];
    TGUser *selfUser = [TCSTGTelegramMoneyTalkProxy selfUser];
    
    NSMutableSet *set = [NSMutableSet setWithArray:conversation.chatParticipants.chatParticipantUids];
    [set minusSet:[NSSet setWithObject:@(selfUser.uid)]];
    _receiversArray = set.allObjects;
    
    return _receiversArray;
}

#pragma mark - Init

- (instancetype)initWithConversationId:(int64_t)conversationId
{
    self = [super init];
    if (self)
    {
        _conversationId = conversationId;
    }
    
    return self;
}


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOC(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[TCSTGTelegramMoneyTalkProxy tgAccentColor]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.receiversArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    TGUser *user = [self userForIndexPath:indexPath];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    [cell.textLabel setText:fullName];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectReceiver:)])
    {
        [self.delegate didSelectReceiver:[self userForIndexPath:indexPath]];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (TGUser *)userForIndexPath:(NSIndexPath *)indexPath
{
    int32_t uid = [self.receiversArray[indexPath.row] intValue];
    TGUser *user = [TGDatabaseInstance() loadUser:uid];
    
    return user;
}


- (void)cancelAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
