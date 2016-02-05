//
//  UIImage+PDF.m
//
//  Created by Nigel Barber on 15/10/2011.
//  Copyright 2011 Mindbrix Limited. All rights reserved.
//

#import "UIImage+PDF.h"
#import "tgmath.h"
#import "NSURL+Helpers.h"
#import "PDFView.h"
#import "NSString+MD5.h"
#import "NSData+MD5.h"

@implementation  UIImage( PDF )


#pragma mark - Control cache

static NSCache *_imagesCache;
static BOOL _shouldCache = NO;
static BOOL _shouldCacheOnDisk = YES;

/*!
 @abstract
 Set the caching in memory of images on and off
 
 @param shouldCache to activate the caching
 
 @discussion this method sets up an NSCache for the images and the flag responsible to check them when reqeusted
 
 */
+(void)setShouldCacheInMemory:(BOOL)shouldCache
{
    _shouldCache = shouldCache;
    
    if( _shouldCache && !_imagesCache )
    {
        _imagesCache = [[ NSCache alloc ] init ];
    }
}

+(void)setShouldCacheOnDisk:(BOOL)shouldCache
{
    _shouldCacheOnDisk = shouldCache;
}


#pragma mark - Convenience methods

+(UIImage *) imageOrPDFNamed:(NSString *)resourceName
{
    if([[ resourceName pathExtension ] isEqualToString: @"pdf" ])
    {
        return [ UIImage originalSizeImageWithPDFNamed:resourceName ];
    }
    else
    {
        return [ UIImage imageNamed:resourceName ];
    }
}

+(UIImage *) imageOrPDFWithContentsOfFile:(NSString *)path
{
    if([[ path pathExtension ] isEqualToString: @"pdf" ])
    {
        return [ UIImage originalSizeImageWithPDFURL:[ NSURL fileURLWithPath:path ]];
    }
    else
    {
        return [ UIImage imageWithContentsOfFile:path ];
    }
}

+(CGFloat) screenScale
{
    return [[UIScreen mainScreen] scale];
}


#pragma mark - Cacheing

+(NSString *)cacheFilenameForData:(NSData *)resourceData atSize:(CGSize)size atScaleFactor:(CGFloat)scaleFactor atPage:(NSUInteger)page
{
    NSString *cacheFilename = nil;
    
    NSFileManager *fileManager = [ NSFileManager defaultManager ];
    
    NSString *cacheRoot = [ NSString stringWithFormat:@"%@ - %@ - %lu", [ resourceData MD5 ], NSStringFromCGSize(CGSizeMake( size.width * scaleFactor, size.height * scaleFactor )), (unsigned long)page ];
    NSString *MD5 = [ cacheRoot MD5 ];
    
    NSString *cachesDirectory = [ NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0 ];
    NSString *cacheDirectory = [ NSString stringWithFormat:@"%@/__PDF_CACHE__", cachesDirectory ];
    [ fileManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL ];
    
    cacheFilename = [ NSString stringWithFormat:@"%@/%@.png", cacheDirectory, MD5 ];
        
    return cacheFilename;
}

+(NSString *)cacheFilenameForURL:(NSURL *)resourceURL atSize:(CGSize)size atScaleFactor:(CGFloat)scaleFactor atPage:(NSUInteger)page
{
    NSString *cacheFilename = nil;
    
    NSFileManager *fileManager = [ NSFileManager defaultManager ];
    
    NSString *filePath = [ resourceURL path ];
    
    NSDictionary *fileAttributes = [ fileManager attributesOfItemAtPath:filePath error:NULL ];
    
    NSString *cacheRoot = [ NSString stringWithFormat:@"%@ - %@ - %@ - %@ - %lu", [ filePath lastPathComponent ], [ fileAttributes objectForKey:NSFileSize ], [ fileAttributes objectForKey:NSFileModificationDate ], NSStringFromCGSize(CGSizeMake( size.width * scaleFactor, size.height * scaleFactor )), (unsigned long)page ];
    NSString *MD5 = [ cacheRoot MD5 ];
    
    NSString *cachesDirectory = [ NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0 ];
    NSString *cacheDirectory = [ NSString stringWithFormat:@"%@/__PDF_CACHE__", cachesDirectory ];
    [ fileManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL ];
    
    cacheFilename = [ NSString stringWithFormat:@"%@/%@.png", cacheDirectory, MD5 ];
    
    return cacheFilename;
}


#pragma mark - Resource name

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atSize:(CGSize)size atPage:(NSUInteger)page
{
    return [ self imageWithPDFURL:[ NSURL resourceURLForName:resourceName ] atSize:size atPage:page ];
}

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atSize:(CGSize)size
{
    return [ self imageWithPDFURL:[ NSURL resourceURLForName:resourceName ] atSize:size ];
}

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atWidth:(CGFloat)width atPage:(NSUInteger)page
{
    return [ self imageWithPDFURL:[ NSURL resourceURLForName:resourceName ] atWidth:width atPage:page ];
}

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atWidth:(CGFloat)width
{
    return [ self imageWithPDFURL:[ NSURL resourceURLForName:resourceName ] atWidth:width ];
}

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atHeight:(CGFloat)height atPage:(NSUInteger)page
{
    return [ self imageWithPDFURL:[ NSURL resourceURLForName:resourceName ] atHeight:height atPage:page ];
}

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atHeight:(CGFloat)height
{
    return [ self imageWithPDFURL:[ NSURL resourceURLForName:resourceName ] atHeight:height ];
}

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName fitSize:(CGSize)size atPage:(NSUInteger)page
{
    return [ self imageWithPDFURL:[ NSURL resourceURLForName:resourceName] fitSize:size atPage:page ];
}

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName fitSize:(CGSize)size
{
    return [ self imageWithPDFURL:[ NSURL resourceURLForName:resourceName] fitSize:size ];
}

+(UIImage *) originalSizeImageWithPDFNamed:(NSString *)resourceName atPage:(NSUInteger)page
{
    return [ self originalSizeImageWithPDFURL:[ NSURL resourceURLForName:resourceName ] atPage:page ];
}

+(UIImage *) originalSizeImageWithPDFNamed:(NSString *)resourceName
{
    return [ self originalSizeImageWithPDFURL:[ NSURL resourceURLForName:resourceName ]];
}


#pragma mark - Resource Data

+(UIImage *) originalSizeImageWithPDFData:(NSData *)data
{
    CGRect mediaRect = [ PDFView mediaRectForData:data atPage:1 ];

    return [ UIImage imageWithPDFData:data atSize:mediaRect.size atPage:1 ];
}

+(UIImage *)imageWithPDFData:(NSData *)data atWidth:(CGFloat)width
{
    return [ UIImage imageWithPDFData:data atWidth:width atPage:1 ];
}

+(UIImage *)imageWithPDFData:(NSData *)data atWidth:(CGFloat)width atPage:(NSUInteger)page
{
    if ( data == nil )
        return nil;
    
    CGRect mediaRect = [ PDFView mediaRectForData:data atPage:page ];
    CGFloat aspectRatio = mediaRect.size.width / mediaRect.size.height;
    CGSize size = CGSizeMake( width, ceil( width / aspectRatio ));
    
    return [ UIImage imageWithPDFData:data atSize:size atPage:page ];
}

+(UIImage *)imageWithPDFData:(NSData *)data atHeight:(CGFloat)height
{
    return [ UIImage imageWithPDFData:data atHeight:height atPage:1 ];
}

+(UIImage *)imageWithPDFData:(NSData *)data atHeight:(CGFloat)height atPage:(NSUInteger)page
{
    if ( data == nil )
        return nil;
    
    CGRect mediaRect = [ PDFView mediaRectForData:data atPage:page ];
    CGFloat aspectRatio = mediaRect.size.width / mediaRect.size.height;
    CGSize size = CGSizeMake( ceil( height * aspectRatio ), height );
    
    return [ UIImage imageWithPDFData:data atSize:size atPage:page ];
}

+(UIImage *)imageWithPDFData:(NSData *)data fitSize:(CGSize)size
{
    return [ UIImage imageWithPDFData:data fitSize:size atPage:1 ];
}

+(UIImage *)imageWithPDFData:(NSData *)data fitSize:(CGSize)size atPage:(NSUInteger)page
{
    if ( data == nil )
        return nil;
    
    CGRect mediaRect = [ PDFView mediaRectForData:data atPage:page ];
    CGFloat scaleFactor = MAX( mediaRect.size.width / size.width, mediaRect.size.height / size.height );
    CGSize newSize = CGSizeMake( ceil( mediaRect.size.width / scaleFactor ), ceil( mediaRect.size.height / scaleFactor ));
    
    // Return image
    return [ UIImage imageWithPDFData:data atSize:newSize atPage:page ];
}

+(UIImage *)imageWithPDFData:(NSData *)data atSize:(CGSize)size
{
    return [ UIImage imageWithPDFData:data atSize:size atPage:1 ];
}

+(UIImage *)imageWithPDFData:(NSData *)data atSize:(CGSize)size atPage:(NSUInteger)page
{
    if(data == nil || CGSizeEqualToSize(size, CGSizeZero) || page == 0)
        return nil;
    
    UIImage *pdfImage = nil;
    
    CGFloat screenScale = [self screenScale];
    NSString *cacheFilename = [ self cacheFilenameForData:data atSize:size atScaleFactor:[self screenScale] atPage:page ];
    
    if(_shouldCacheOnDisk && [[ NSFileManager defaultManager ] fileExistsAtPath:cacheFilename ])
    {
        pdfImage = [ UIImage imageWithCGImage:[[ UIImage imageWithContentsOfFile:cacheFilename ] CGImage ] scale:[self screenScale] orientation:UIImageOrientationUp ];
    }
    else
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(NULL, size.width * screenScale, size.height * screenScale, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
        CGContextScaleCTM(ctx, screenScale, screenScale);
        
        [PDFView renderIntoContext:ctx url:nil data:data size:size page:page];
        CGImageRef image = CGBitmapContextCreateImage(ctx);
        pdfImage = [[UIImage alloc] initWithCGImage:image scale:screenScale orientation:UIImageOrientationUp];
        
        CGImageRelease(image);
        CGContextRelease(ctx);
        CGColorSpaceRelease(colorSpace);
        
        if(_shouldCacheOnDisk && cacheFilename)
        {
            [ UIImagePNGRepresentation( pdfImage ) writeToFile:cacheFilename atomically:NO ];
        }
    }
    
    return pdfImage;
}


#pragma mark - Resource URLs

+(UIImage *) imageWithPDFURL:(NSURL *)URL atSize:(CGSize)size atPage:(NSUInteger)page
{
    if(URL == nil || CGSizeEqualToSize(size, CGSizeZero) || page == 0)
        return nil;
    
    UIImage *pdfImage = nil;
    
    CGFloat screenScale = [self screenScale];
    NSString *cacheFilename = [ self cacheFilenameForURL:URL atSize:size atScaleFactor:[self screenScale] atPage:page ];
    
    /**
     * Check in Memory cached image before checking file system
     */
    if (_shouldCache)
    {
        pdfImage = [_imagesCache objectForKey:cacheFilename];
        if (pdfImage) return pdfImage;
    }
    
    
    if(_shouldCacheOnDisk && [[ NSFileManager defaultManager ] fileExistsAtPath:cacheFilename ])
    {
        pdfImage = [ UIImage imageWithCGImage:[[ UIImage imageWithContentsOfFile:cacheFilename ] CGImage ] scale:screenScale orientation:UIImageOrientationUp ];
    }
    else 
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(NULL, size.width * screenScale, size.height * screenScale, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
        CGContextScaleCTM(ctx, screenScale, screenScale);
        
        [PDFView renderIntoContext:ctx url:URL data:nil size:size page:page];
        CGImageRef image = CGBitmapContextCreateImage(ctx);
        pdfImage = [[UIImage alloc] initWithCGImage:image scale:screenScale orientation:UIImageOrientationUp];
        
        CGImageRelease(image);
        CGContextRelease(ctx);
        CGColorSpaceRelease(colorSpace);
        
        if(_shouldCacheOnDisk && cacheFilename)
        {
            [ UIImagePNGRepresentation( pdfImage ) writeToFile:cacheFilename atomically:NO ];
        }
    }
    
    /**
     * Cache image to in memory if active
     */
    if (pdfImage && cacheFilename && _shouldCache)
    {
        [_imagesCache setObject:pdfImage forKey:cacheFilename];
    }
    
	return pdfImage;
}

+(UIImage *) imageWithPDFURL:(NSURL *)URL atSize:(CGSize)size
{
    return [ self imageWithPDFURL:URL atSize:size atPage:1 ];
}

+(UIImage *) imageWithPDFURL:(NSURL *)URL fitSize:(CGSize)size atPage:(NSUInteger)page
{
    if ( URL == nil )
        return nil;
    
    // Get dimensions
    CGRect mediaRect = [ PDFView mediaRectForURL:URL atPage:page ];
    
    // Calculate scale factor
    CGFloat scaleFactor = MAX(mediaRect.size.width / size.width, mediaRect.size.height / size.height);
    
    // Create new size
    CGSize newSize = CGSizeMake( ceil( mediaRect.size.width / scaleFactor ), ceil( mediaRect.size.height / scaleFactor ));
    
    // Return image
    return [ UIImage imageWithPDFURL:URL atSize:newSize atPage:page ];
}

+(UIImage *) imageWithPDFURL:(NSURL *)URL fitSize:(CGSize)size
{
    return [ UIImage imageWithPDFURL:URL fitSize:size atPage:1 ];
}

+(UIImage *) imageWithPDFURL:(NSURL *)URL atWidth:(CGFloat)width atPage:(NSUInteger)page
{
    if ( URL == nil )
        return nil;
    
    CGRect mediaRect = [ PDFView mediaRectForURL:URL atPage:page ];
    CGFloat aspectRatio = mediaRect.size.width / mediaRect.size.height;
    
    CGSize size = CGSizeMake( width, ceil( width / aspectRatio ));
    
    return [ UIImage imageWithPDFURL:URL atSize:size atPage:page ];
}

+(UIImage *) imageWithPDFURL:(NSURL *)URL atWidth:(CGFloat)width
{
    return [ UIImage imageWithPDFURL:URL atWidth:width atPage:1 ];
}


+(UIImage *) imageWithPDFURL:(NSURL *)URL atHeight:(CGFloat)height atPage:(NSUInteger)page
{
    if ( URL == nil )
        return nil;
    
    CGRect mediaRect = [ PDFView mediaRectForURL:URL atPage:page ];
    CGFloat aspectRatio = mediaRect.size.width / mediaRect.size.height;
    
    CGSize size = CGSizeMake( ceil( height * aspectRatio ), height );
    
    return [ UIImage imageWithPDFURL:URL atSize:size atPage:page ];
}

+(UIImage *) imageWithPDFURL:(NSURL *)URL atHeight:(CGFloat)height
{
    return [ UIImage imageWithPDFURL:URL atHeight:height atPage:1 ];
}

+(UIImage *) originalSizeImageWithPDFURL:(NSURL *)URL atPage:(NSUInteger)page
{
    if ( URL == nil )
        return nil;
    
    CGRect mediaRect = [ PDFView mediaRectForURL:URL atPage:page ];
    
    return [ UIImage imageWithPDFURL:URL atSize:mediaRect.size atPage:page ];
}

+(UIImage *) originalSizeImageWithPDFURL:(NSURL *)URL
{
    return [ UIImage originalSizeImageWithPDFURL:URL atPage:1 ];
}


@end
