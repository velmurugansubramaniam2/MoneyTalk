#import "TGNeoAttachmentViewModel.h"

#import "TGNeoImageViewModel.h"
#import "TGNeoLabelViewModel.h"

#import "TGStringUtils.h"

#import "TGBridgeMessage.h"
#import "TGBridgeUser.h"

@interface TGNeoAttachmentViewModel ()
{
    TGNeoImageViewModel *_iconModel;
    TGNeoLabelViewModel *_textModel;
}
@end

@implementation TGNeoAttachmentViewModel

- (instancetype)initWithAttachments:(NSArray *)attachments author:(TGBridgeUser *)author forChannel:(bool)forChannel users:(NSDictionary *)users font:(UIFont *)font subTitleColor:(UIColor *)subTitleColor normalColor:(UIColor *)normalColor compact:(bool)compact
{
    bool hasAttachment = false;
    NSString *messageText = nil;
    NSMutableAttributedString *attributedText = nil;
    NSString *messageIcon = nil;
    bool useNormalColor = false;
    
    for (TGBridgeMediaAttachment *attachment in attachments)
    {
        if ([attachment isKindOfClass:[TGBridgeImageMediaAttachment class]])
        {
            hasAttachment = true;
            TGBridgeImageMediaAttachment *imageAttachment = (TGBridgeImageMediaAttachment *)attachment;
            if (imageAttachment.caption.length > 0)
            {
                messageText = imageAttachment.caption;
                if (compact)
                    useNormalColor = true;
            }
            else
            {
                messageText = TGLocalized(@"Message.Photo");
            }
            
            if (!(useNormalColor && compact))
                messageIcon = @"MediaPhoto";
        }
        else if ([attachment isKindOfClass:[TGBridgeVideoMediaAttachment class]])
        {
            hasAttachment = true;
            TGBridgeVideoMediaAttachment *videoAttachment = (TGBridgeVideoMediaAttachment *)attachment;
            if (videoAttachment.caption.length > 0)
            {
                messageText = videoAttachment.caption;
                if (compact)
                    useNormalColor = true;
            }
            else
            {
                messageText = TGLocalized(@"Message.Video");
            }
            
            if (!(useNormalColor && compact))
                messageIcon = @"MediaVideo";
        }
        else if ([attachment isKindOfClass:[TGBridgeAudioMediaAttachment class]])
        {
            hasAttachment = true;
            messageText = TGLocalized(@"Message.Audio");
            
            messageIcon = @"MediaAudio";
        }
        else if ([attachment isKindOfClass:[TGBridgeDocumentMediaAttachment class]])
        {
            hasAttachment = true;
            TGBridgeDocumentMediaAttachment *documentAttachment = (TGBridgeDocumentMediaAttachment *)attachment;
            
            if (documentAttachment.isSticker)
            {
                if (documentAttachment.stickerAlt.length > 0)
                    messageText = [NSString stringWithFormat:@"%@ %@", documentAttachment.stickerAlt, TGLocalized(@"Message.Sticker")];
                else
                    messageText = TGLocalized(@"Message.Sticker");
            }
            else
            {
                if (documentAttachment.fileName.length > 0)
                    messageText = documentAttachment.fileName;
                else
                    messageText = TGLocalized(@"Message.File");
                
                messageIcon = @"MediaDocument";
            }
        }
        else if ([attachment isKindOfClass:[TGBridgeLocationMediaAttachment class]])
        {
            hasAttachment = true;
            messageText = TGLocalized(@"Message.Location");
            
            messageIcon = @"MediaLocation";
        }
        else if ([attachment isKindOfClass:[TGBridgeContactMediaAttachment class]])
        {
            hasAttachment = true;
            messageText = TGLocalized(@"Message.Contact");
        }
        else if ([attachment isKindOfClass:[TGBridgeActionMediaAttachment class]])
        {
            hasAttachment = true;
            
            TGBridgeActionMediaAttachment *actionAttachment = (TGBridgeActionMediaAttachment *)attachment;
            NSString *actionText = nil;
            NSArray *additionalAttributes = nil;
            
            switch (actionAttachment.actionType)
            {
                case TGBridgeMessageActionChatEditTitle:
                {
                    if (forChannel)
                    {
                        messageText = TGLocalized(@"Notification.ChannelTitleUpdated");
                    }
                    else
                    {
                        NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                        NSString *formatString = TGLocalized(@"Notification.RenamedChat");
                        
                        actionText = [NSString stringWithFormat:formatString, authorName];
                        
                        NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                        if (formatNameRange.location != NSNotFound)
                        {
                            additionalAttributes = [TGNeoAttachmentViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                        }
                    }
                }
                    break;
                    
                case TGBridgeMessageActionChatEditPhoto:
                {
                    NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                    bool changed = actionAttachment.actionData[@"photo"];
                 
                    if (forChannel)
                    {
                        messageText = changed ? TGLocalized(@"Notification.ChannelPhotoUpdated") : TGLocalized(@"Notification.ChannelPhotoRemoved");
                    }
                    else {
                        NSString *formatString = changed ? TGLocalized(@"Notification.ChangedGroupPhoto") : TGLocalized(@"Notification.RemovedGroupPhoto");
                        
                        actionText = [NSString stringWithFormat:formatString, authorName];
                        
                        NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                        if (formatNameRange.location != NSNotFound)
                        {
                            additionalAttributes = [TGNeoAttachmentViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                        }
                    }
                }
                    break;
                    
                case TGBridgeMessageActionUserChangedPhoto:
                {
                    
                }
                    break;
                    
                case TGBridgeMessageActionChatAddMember:
                case TGBridgeMessageActionChatDeleteMember:
                {
                    NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                    TGBridgeUser *user = users[@([actionAttachment.actionData[@"uid"] int32Value])];
                    
                    if (user.identifier == author.identifier)
                    {
                        NSString *formatString = (actionAttachment.actionType == TGBridgeMessageActionChatAddMember) ? TGLocalized(@"Notification.JoinedChat") : TGLocalized(@"Notification.LeftChat");
                        actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                        
                        NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                        if (formatNameRange.location != NSNotFound)
                        {
                            additionalAttributes = [TGNeoAttachmentViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                        }
                    }
                    else
                    {
                        NSString *userName = [TGStringUtils initialsForFirstName:user.firstName lastName:user.lastName single:false];
                        NSString *formatString = (actionAttachment.actionType == TGBridgeMessageActionChatAddMember) ? TGLocalized(@"Notification.Invited") : TGLocalized(@"Notification.Kicked");
                        actionText = [[NSString alloc] initWithFormat:formatString, authorName, userName];
                        
                        NSRange formatNameRangeFirst = [formatString rangeOfString:@"%@"];
                        NSRange formatNameRangeSecond = formatNameRangeFirst.location != NSNotFound ? [formatString rangeOfString:@"%@" options:0 range:NSMakeRange(formatNameRangeFirst.location + formatNameRangeFirst.length, formatString.length - (formatNameRangeFirst.location + formatNameRangeFirst.length))] : NSMakeRange(NSNotFound, 0);
                        
                        if (formatNameRangeFirst.location != NSNotFound && formatNameRangeSecond.location != NSNotFound)
                        {
                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            
                            NSRange rangeFirst = NSMakeRange(formatNameRangeFirst.location, authorName.length);
                            [array addObjectsFromArray:[TGNeoAttachmentViewModel _mediumFontAttributeForRange:rangeFirst]];
                            [array addObjectsFromArray:[TGNeoAttachmentViewModel _mediumFontAttributeForRange:NSMakeRange(rangeFirst.length - formatNameRangeFirst.length + formatNameRangeSecond.location, userName.length)]];
                            
                            additionalAttributes = array;
                        }
                    }
                }
                    break;
                    
                case TGBridgeMessageActionJoinedByLink:
                {
                    NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                    NSString *formatString = TGLocalizedStatic(@"Notification.JoinedGroupByLink");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionAttachment.actionData[@"title"]];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        additionalAttributes = [TGNeoAttachmentViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                    }
                }
                    break;
                    
                case TGBridgeMessageActionCreateChat:
                {
                    NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                    NSString *formatString = TGLocalizedStatic(@"Notification.CreatedChatWithTitle");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionAttachment.actionData[@"title"]];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        additionalAttributes = [TGNeoAttachmentViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                    }
                }
                    break;
                    
                case TGBridgeMessageActionContactRegistered:
                {
                    messageText = TGLocalized(@"Notification.Joined");
                }
                    break;
                    
                case TGBridgeMessageActionChannelCreated:
                {
                    messageText = TGLocalized(@"Notification.ChannelCreated");
                }
                    break;
                    
                case TGBridgeMessageActionChannelInviter:
                {
                    TGBridgeUser *user = users[@([actionAttachment.actionData[@"uid"] int32Value])];
                    NSString *authorName = [TGStringUtils initialsForFirstName:user.firstName lastName:user.lastName single:false];
                    NSString *formatString = TGLocalizedStatic(@"Notification.ChannelInviter");
                    
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        additionalAttributes = [TGNeoAttachmentViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
            if (actionText != nil)
            {
                attributedText = [[NSMutableAttributedString alloc] initWithString:actionText attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0f weight:UIFontWeightRegular], NSForegroundColorAttributeName: subTitleColor }];
                
                if (additionalAttributes != nil)
                {
                    NSUInteger count = additionalAttributes.count;
                    for (NSUInteger i = 0; i < count; i += 2)
                    {
                        NSRange range = NSMakeRange(0, 0);
                        [(NSValue *)[additionalAttributes objectAtIndex:i] getValue:&range];
                        NSDictionary *attributes = [additionalAttributes objectAtIndex:i + 1];
                        
                        if (range.location + range.length <= attributedText.length)
                            [attributedText addAttributes:attributes range:range];
                    }
                }
                
                _inhibitsInitials = true;
            }
        }
        else if ([attachment isKindOfClass:[TGBridgeUnsupportedMediaAttachment class]])
        {
            hasAttachment = true;
            messageText = TGLocalized(@"Message.Unsupported");
        }
    }
    
    if (!hasAttachment)
        return nil;
    
    self = [super init];
    if (self != nil)
    {
        if (attributedText != nil)
        {
            _textModel = [[TGNeoLabelViewModel alloc] initWithAttributedText:attributedText];
            [self addSubmodel:_textModel];
        }
        else
        {
            if (messageIcon != nil && !compact)
            {
                _iconModel = [[TGNeoImageViewModel alloc] initWithImage:[UIImage imageNamed:messageIcon] tintColor:subTitleColor];
                if (!compact)
                    _iconModel.frame = CGRectMake(0, 0.5f, 17, 18);
                else
                    _iconModel.frame = CGRectMake(0, -2, 17, 18);
                [self addSubmodel:_iconModel];
            }
            
            CGFloat textOffset = 0;
            if (_iconModel != nil)
                textOffset = CGRectGetMaxX(_iconModel.frame) + 2;
            
            UIColor *color = useNormalColor ? normalColor : subTitleColor;
            
            _textModel = [[TGNeoLabelViewModel alloc] initWithText:messageText font:font color:color attributes:nil];
            _textModel.multiline = false;
            [self addSubmodel:_textModel];
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat textOffset = 0;
    if (_iconModel != nil)
        textOffset = CGRectGetMaxX(_iconModel.frame) + 2;
    
    _textModel.frame = CGRectMake(textOffset, 0, frame.size.width - textOffset, 20);
}

+ (NSArray *)_mediumFontAttributeForRange:(NSRange)range
{
    NSDictionary *fontAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:16.0f weight:UIFontWeightMedium], NSForegroundColorAttributeName: [UIColor whiteColor] };
    return [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
}

@end
