//
//  TCSMTConfigManager.m
//  TCSMT
//
//  Created by a.v.kiselev on 01.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTConfigManager.h"
//@import UIKit;

#import "TCSAPIClient.h"
#import "TCSUtils.h"
#import "NSDate+Calendar.h"
#import "NSDateFormatter+Helpers.h"
#import "NSError+TCSAdditions.h"

#define kSecondsInAMinute		60
#define kSecondsInAnHour		(kSecondsInAMinute * 60)
#define kSecondsInADay			(kSecondsInAnHour * 24)

NSString * const TCSMTNeedForceUpdateApplication = @"TCSMTNeedForceUpdateNotification";

NSString * const TCSMTNeedForceUpdateApplicationReleaseNotes = @"TCSMTNeedForceUpdateApplicationReleaseNotes";
NSString * const TCSMTNeedForceUpdateApplicationReleaseNotesTitle = @"TCSMTNeedForceUpdateApplicationReleaseNotesTitle";
NSString * const TCSMTNeedForceUpdateApplicationActionBlock = @"TCSMTNeedForceUpdateApplicationActionBlock";

@interface TCSMTConfigManager ()

@property (nonatomic, assign) NSTimeInterval lastUpdate;

@end

@implementation TCSMTConfigManager
@synthesize lastUpdate = _lastUpdate;

@synthesize config = _config;


static TCSMTConfigManager * __sharedInstance = nil;
+ (instancetype)sharedInstance
{    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        __sharedInstance = [[self alloc] init];
        [__sharedInstance setLastUpdate:[[[NSUserDefaults standardUserDefaults]objectForKey:kConfigLastUpdate] doubleValue]];
    });
    
	return __sharedInstance;
}

+ (TCSMTConfig *)config
{
	return [[TCSMTConfigManager sharedInstance]config];
}

- (void)setLastUpdate:(NSTimeInterval)lastUpdate
{
    _lastUpdate = lastUpdate;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:_lastUpdate] forKey:kConfigLastUpdate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)configDictionary
{
    NSDictionary *configDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"config"];
    
    return configDictionary;
}

- (void)saveConfig:(NSDictionary *)configDictionary
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:configDictionary forKey:@"config"];
    [prefs synchronize];
}

- (id)init
{
	if (self = [super init])
	{
        _config = [[TCSMTConfig alloc] initWithDictionary:[self configDictionary]];//[TCSMTStorage config];
        
		if (!_config)
		{
			NSString *filePath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
			if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
			{
				NSData *data = [NSData dataWithContentsOfFile:filePath];
				NSError *error = nil;
				NSDictionary *dic = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] objectForKey:kPayload];
				_config = [[TCSMTConfig alloc] initWithDictionary:dic];
			}

			ALog(@"Config is taken from file!");
//            NSLog(@"Config is taken from file!");
		}
	}
	
	return self;
}

- (BOOL)shouldUpdateConfig
{
    NSInteger daysDifference = [NSDate daysDiffrenceFromDate:self.lastUpdate second:[[NSDate date] timeIntervalSince1970]];
    
    if (labs(daysDifference) > 0)
    {
        return YES;
    }
    
    return NO;
}

- (void)updateConfig
{
    if ([self shouldUpdateConfig])
    {
        __weak __typeof(self) weakSelf = self;
        
        [[TCSAPIClient sharedInstance]api_configUpdateSuccess:^ (NSDictionary * configPayloadDictionary)
         {
             TCSMTConfig * config = [[TCSMTConfig alloc]initWithDictionary:configPayloadDictionary];

             [self saveConfig:configPayloadDictionary];

             __strong __typeof(weakSelf) strongSelf = weakSelf;
             if (strongSelf) {
                 if (config != nil)
                 {
                     strongSelf->_config = config;
                     strongSelf.lastUpdate = [[NSDate date] timeIntervalSince1970];
                 }
                 else
                 {
                     ALog(@"\nFAILED to get config from data base!");
                 }

                 [strongSelf checkVersion];
             }
         }
                                                         failure:^(NSError *error)
         {
             DLog(@"\n\nFAILED Update config!\n\n %@", error.errorMessage);
         }];
    }
}

- (BOOL)checkVersion
{
	TCSCompatibility *mtCompatibility = [_config mtCompatibility];
	CGFloat const newVersion = [mtCompatibility newVersion];
	CGFloat const currentAppVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
	CGFloat const leastCompatibleVersion = [mtCompatibility leastCompatibleVersion];

	BOOL const forceUpdate = currentAppVersion < leastCompatibleVersion;
	if (forceUpdate)
	{
		void (^block)() = ^
		{
			[[UIApplication sharedApplication] openURL:mtCompatibility.url];
		};

		NSDictionary * const userInfo = @{TCSMTNeedForceUpdateApplicationReleaseNotes : mtCompatibility.releaseNotes, TCSMTNeedForceUpdateApplicationReleaseNotesTitle : mtCompatibility.releaseNotesTitle, TCSMTNeedForceUpdateApplicationActionBlock : block};

		NSNotificationCenter * const defaultCenter = [NSNotificationCenter defaultCenter];
		[defaultCenter postNotificationName:TCSMTNeedForceUpdateApplication object:self userInfo:userInfo];
	}

	return !forceUpdate;
}



+ (NSString *)stringFromTimeIntervalSince1970:(NSTimeInterval)timeInterval format:(TCSP2PDateFormat)dateFormat
{
	NSString * stringFromTimeInterval = nil;

	switch (dateFormat)
	{
		case TCSP2PDateFormatHumanTimer:
		{
			NSTimeInterval timeIntervalToProcess = timeInterval;
			int days = 0;
			int hours = 0;
			int minutes = 0;
			int seconds = 0;

			days = (int)(timeIntervalToProcess / kSecondsInADay);

			if (days > 0)
			{
				NSString * wordWithEnding = nil;

				switch ([TCSUtils wordEndingWithCountOf:days])
				{
					case TCSWordEndingByCountTypeResidue1:
						wordWithEnding = LOC(@"wordEnding_day_1");
						break;

					case TCSWordEndingByCountTypeFrom5To20OrResidue0:
						wordWithEnding = LOC(@"wordEnding_day_5_20_reduce0");
						break;

					case TCSWordEndingByCountTypeResidueFrom2To4:
						wordWithEnding = LOC(@"wordEnding_day_reduce2_4");
						break;

					default:
						break;
				}

				stringFromTimeInterval = [NSString stringWithFormat:@"%d %@",days,wordWithEnding];
			}
			else
			{
				timeIntervalToProcess = timeIntervalToProcess - (kSecondsInADay * days);

				hours = (int)(timeIntervalToProcess / kSecondsInAnHour);
				timeIntervalToProcess = timeIntervalToProcess - (kSecondsInAnHour * hours);

				minutes = (int)(timeIntervalToProcess / kSecondsInAMinute);
				timeIntervalToProcess = timeIntervalToProcess - (kSecondsInAMinute * minutes);

				seconds = (int)timeIntervalToProcess;

				stringFromTimeInterval = [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds];
			}

		}
			break;

		default: //форматы берутся из конфига
		{
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
			NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterRUEuropeMoscow];

			[dateFormatter setDateFormat:[self stringForDateFormat:dateFormat]];

			stringFromTimeInterval = [dateFormatter stringFromDate:date];
		}
			break;
	}

	return stringFromTimeInterval;
}


+ (NSTimeInterval)timeIntervalFromStringDate:(NSString *)date format:(TCSP2PDateFormat) dateFormat
{
    if (date.length != 0)
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterRUEuropeMoscow];
        [dateFormatter setDateFormat:[self stringForDateFormat:dateFormat]];
        NSDate *dateX = [dateFormatter dateFromString:date];
        NSTimeInterval ret = [dateX timeIntervalSince1970];

        return ret;
    }
    else

        return 0;
}

+ (NSString *)timeSensativeDateWithTimeInterval:(TCSMillisecondsTimestamp *)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval.seconds];
    NSDate *currentDate = [NSDate date];

    NSDateComponents *components = [NSDate dateDiffrenceFromDate:[date timeIntervalSince1970] second:[currentDate timeIntervalSince1970]];
    NSString *displayDateString = nil;

	NSCalendar * currentCalendar = [NSCalendar currentCalendar];
	NSDateComponents *currentDateComponents = [currentCalendar components:NSDayCalendarUnit fromDate:currentDate];
	NSDateComponents *dateComponents = [currentCalendar components:NSDayCalendarUnit fromDate:date];

    if (([components year]
        || [components month]
        || [components day]
        || [currentDate compare:date] == NSOrderedAscending) || ([dateComponents day] != [currentDateComponents day]))  // 12 нояб. 16:45 < вчера и раньше
    {
        displayDateString = [self stringFromTimeIntervalSince1970:timeInterval.seconds format:TCSP2PDateFormatRecently];
    }
    else if ([components hour])	// сегодня в ЧЧ:ММ
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterRUEuropeMoscow];

		NSString * dateFormatToday = [[[TCSMTConfigManager sharedInstance]config] dateFormatToday];
        [dateFormatter setDateFormat:dateFormatToday];

        displayDateString = [NSString stringWithFormat:@"%@ %@", LOC(@"title_today_at"),[dateFormatter stringFromDate:date]];
    }
    else if ([components minute]) // ММ минут назад
    {
        NSString *minutes = LOC(@"date_format_minutes");

        if ([components minute] < 2)
        {
            minutes = LOC(@"date_format_minute");
        }
        else if ([components minute] < 5)
        {
            minutes = LOC(@"date_format_minutes2");
        }

        displayDateString = [NSString stringWithFormat:@"%ld %@ %@", labs((long)[components minute]), minutes, LOC(@"date_format_ago")];
    }
    else
    {
        displayDateString = LOC(@"date_format_at_this_moment");
    }

    return displayDateString;
}



+ (NSString *)stringForDateFormat:(TCSP2PDateFormat)dateFormat
{
	NSString * mask = @"";
	TCSMTConfig * config = [[TCSMTConfigManager sharedInstance]config];

	switch (dateFormat)
	{
		case TCSP2PDateFormatFull:
			mask = [config dateFormatFull];
			break;
		case TCSP2PDateFormatLong:
			mask = [config dateFormatLong];
			break;
		case TCSP2PDateFormatRecently:
			mask = [config dateFormatRecently];
			break;
		case TCSP2PDateFormatShort:
			mask = [config dateFormatShort];
			break;
		case TCSP2PDateFormatTime:
			mask = [config dateFormatTime];
			break;
        case TCSP2PDateFormatCardExpiry:
            mask = [config dateFormatCardExpiry];
            break;
		default:
			break;
	}

	return mask;
}


//+ (NSString *)urlStringForImageWithId:(NSString *)imageId
//							 moduleId:(NSString *)moduleId
//								 size:(CGSize)size
//						   shouldCrop:(BOOL)shouldCrop
//							sessionId:(NSString *)sessionId
//{
//	NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://%@/%@/%@",[[[TCSAPIClient sharedInstance] configuration] domainName],[[[TCSAPIClient sharedInstance] configuration] domainPath],API_image];
//
//	[urlString appendString:[NSString stringWithFormat:@"?%@=%@", kId, [imageId encodeURL]]];
//	[urlString appendString:[NSString stringWithFormat:@"&%@=%@", kSessionId, sessionId]];
//
//	if ([moduleId length] > 0)
//	{
//		[urlString appendString:[NSString stringWithFormat:@"&%@=%@", kModuleId, moduleId]];
//	}
//
//	if (size.width != 0 && size.height != 0)
//	{
////		size = [TCSUtils sizeAccordingToRetina:size];
//		[urlString appendString:[NSString stringWithFormat:@"&width=%d&height=%d", (int)size.width, (int)size.height]];
//	}
//
//	if (shouldCrop)
//	{
//		[urlString appendFormat:@"&%@=%@", kMode, kCrop];
//	}
//	else
//	{
//		[urlString appendFormat:@"&%@=%@", kMode, kFit];
//	}
//
//	return urlString;
//}


@end
