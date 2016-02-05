/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGImageMessageViewModel.h"

@interface TGMapMessageViewModel : TGImageMessageViewModel

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude message:(TGMessage *)message authorPeer:(id)authorPeer context:(TGModernViewContext *)context replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor;

@end
