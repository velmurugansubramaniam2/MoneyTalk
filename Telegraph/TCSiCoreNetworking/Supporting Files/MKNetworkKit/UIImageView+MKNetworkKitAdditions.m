//
//  UIImageView+MKNetworkKitAdditions.m
//  MKNetworkKitDemo
//
//  Created by Mugunth Kumar (@mugunthkumar) on 18/01/13.
//  Copyright (C) 2011-2020 by Steinlogic Consulting and Training Pte Ltd

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UIImageView+MKNetworkKitAdditions.h"

#import "MKNetworkEngine.h"

#import <objc/runtime.h>

static MKNetworkEngine *DefaultEngine;
static char imageFetchOperationKey;

const float kFromCacheAnimationDuration = 0.1f;
const float kFreshLoadAnimationDuration = 0.35f;

@interface UIImageView (/*Private Methods*/)
@property (strong, nonatomic) MKNetworkOperation *imageFetchOperation;
@end

@implementation UIImageView (MKNetworkKitAdditions)

-(MKNetworkOperation*) imageFetchOperation {
  
  return (MKNetworkOperation*) objc_getAssociatedObject(self, &imageFetchOperationKey);
}

-(void) setImageFetchOperation:(MKNetworkOperation *)imageFetchOperation {
  
  objc_setAssociatedObject(self, &imageFetchOperationKey, imageFetchOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+(void) setDefaultEngine:(MKNetworkEngine*) engine {
  
  DefaultEngine = engine;
}

-(MKNetworkOperation*) setImageFromURL:(NSURL*) url {
  
  return [self setImageFromURL:url placeHolderImage:nil];
}

-(MKNetworkOperation*) setImageFromURL:(NSURL*) url placeHolderImage:(UIImage*) image {
  
  return [self setImageFromURL:url placeHolderImage:image usingEngine:DefaultEngine animation:YES];
}

-(MKNetworkOperation*) setImageFromURL:(NSURL*) url placeHolderImage:(UIImage*) image animation:(BOOL) yesOrNo {
  
  return [self setImageFromURL:url placeHolderImage:image usingEngine:DefaultEngine animation:yesOrNo];
}
-(MKNetworkOperation*) setImageFromURL:(NSURL*) url placeHolderImage:(UIImage*) image usingEngine:(MKNetworkEngine*) imageCacheEngine animation:(BOOL) animation
{
    return  [self setImageFromURL:url placeHolderImage:image size:self.frame.size usingEngine:imageCacheEngine animation:animation];
}


-(MKNetworkOperation*) setImageFromURL:(NSURL*) url placeHolderImage:(UIImage*) image  size:(CGSize)imageSize usingEngine:(MKNetworkEngine*) imageCacheEngine animation:(BOOL) animation {
  
  if(image) self.image = image;
  [self.imageFetchOperation cancel];
  if(!imageCacheEngine) imageCacheEngine = DefaultEngine;
  
  if(imageCacheEngine) {
    self.imageFetchOperation = [imageCacheEngine imageAtURL:url
                                                       size:imageSize
                                          completionHandler:^(UIImage *fetchedImage, NSURL *imageURL, BOOL isInCache)
	  {
											  if (isInCache)
											  {
												  DLog(@"Image with url %@ is taken from cache", imageURL.path);
											  }
											  else
											  {
												  DLog(@"Image with url %@ loaded from server", imageURL.path);
											  }

                                            if(animation)
											{
												[UIView transitionWithView:self.superview
																  duration:isInCache?kFromCacheAnimationDuration:kFreshLoadAnimationDuration
																   options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
																animations:^{
																	 self.image = fetchedImage;
																   } completion:nil];
                                            }
											else
											{
												self.image = fetchedImage;
                                            }
                                            
                                          }
											   errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
										  {
                                            DLog(@"%@", error);
                                          }];
  } else {
    
	  DLog(@"No default engine found and imageCacheEngine parameter is null");
  }
  
  return self.imageFetchOperation;
}

- (MKNetworkOperation*)setImageFromURLString:(NSString *)stringUrl placeHolderImage:(UIImage *)image animation:(BOOL)yesOrNo
{
    return [self setImageFromURL:[NSURL URLWithString:stringUrl] placeHolderImage:image usingEngine:DefaultEngine animation:yesOrNo];
}

- (MKNetworkOperation*)setImageFromURLString:(NSString *)stringUrl animation:(BOOL)yesOrNo
{
    return [self setImageFromURL:[NSURL URLWithString:stringUrl] placeHolderImage:nil usingEngine:DefaultEngine animation:yesOrNo];
}

- (MKNetworkOperation*)setImageFromURLString:(NSString *)stringUrl imageSize:(CGSize)imageSize
{
    return [self setImageFromURL:[NSURL URLWithString:stringUrl] placeHolderImage:nil size:imageSize usingEngine:DefaultEngine animation:YES];
}

- (MKNetworkOperation*)setImageFromURLString:(NSString *)stringUrl
{
    return [self setImageFromURL:[NSURL URLWithString:stringUrl] placeHolderImage:nil usingEngine:DefaultEngine animation:YES];
}
@end
