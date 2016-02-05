/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedRemoteImageMessage.h"

#import "TGMessage.h"

#import "TGAppDelegate.h"

@implementation TGPreparedRemoteImageMessage

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash imageInfo:(TGImageInfo *)imageInfo caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage
{
    self = [super init];
    if (self != nil)
    {
#ifdef DEBUG
        NSAssert(imageId != 0, @"imageId should not be 0");
        NSAssert(accessHash != 0, @"accessHash should not be 0");
        NSAssert(imageInfo != nil, @"imageInfo should not be nil");
#endif
        
        _imageId = imageId;
        _accessHash = accessHash;
        _imageInfo = imageInfo;
        _caption = caption;
        _replyMessage = replyMessage;
    }
    return self;
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
    imageAttachment.imageId = _imageId;
    imageAttachment.accessHash = _accessHash;
    imageAttachment.imageInfo = _imageInfo;
    imageAttachment.caption = _caption;
    [attachments addObject:imageAttachment];
    
    if (_replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = _replyMessage.mid;
        replyMedia.replyMessage = _replyMessage;
        [attachments addObject:replyMedia];
    }
    
    message.mediaAttachments = attachments;
    
    return message;
}

+ (NSString *)filePathForRemoteImageId:(int64_t)imageId
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });
    
    NSString *photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", imageId];
    NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
    
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
    return imagePath;
}

@end
