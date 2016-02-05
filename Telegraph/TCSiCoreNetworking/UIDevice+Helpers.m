//
//  UIDevice+Helpers.m
//  TCSiCore
//
//  Created by a.v.kiselev on 04/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "UIDevice+Helpers.h"
#import "OpenUDID.h"
#import <sys/utsname.h>

@implementation UIDevice (Helpers)

+ (CGFloat)systemVersion_
{
    static CGFloat systemVersion_ = 0;
    if (systemVersion_ == 0)
    {
        systemVersion_ = (CGFloat)[[[UIDevice currentDevice] systemVersion] floatValue];
    }
    
    return systemVersion_;
}

+ (NSString *)deviceModel
{
	return [UIDevice currentDevice].model;
}

+ (NSString *)deviceOS
{
    NSString *deviceOS = [UIDevice currentDevice].systemVersion;

	return deviceOS;
}

+ (NSString*) deviceId
{
	return [OpenUDID value];
}

+ (NSString*)deviceModelName
{
	struct utsname systemInfo;

	uname(&systemInfo);

	NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

	return machineName;
}

+ (NSString *)platform
{
	return @"ios";
}

+ (NSString *)rootCheck
{
	BOOL rooted = NO;
	NSArray *jailbrokenPath = [NSArray arrayWithObjects:
							   @"/Applications/Cydia.app",
							   @"/Applications/RockApp.app",
							   @"/Applications/Icy.app",
							   @"/usr/sbin/sshd",
							   @"/usr/bin/sshd",
							   @"/usr/libexec/sftp-server",
							   @"/Applications/WinterBoard.app",
							   @"/Applications/SBSettings.app",
							   @"/Applications/MxTube.app",
							   @"/Applications/IntelliScreen.app",
							   @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
							   @"/Applications/FakeCarrier.app",
							   @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
							   @"/private/var/lib/apt",
							   @"/Applications/blackra1n.app",
							   @"/private/var/stash",
							   @"/private/var/mobile/Library/SBSettings/Themes",
							   @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
							   @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
							   @"/private/var/tmp/cydia.log",
							   @"/private/var/lib/cydia", nil];


	for(NSString *string in jailbrokenPath)
		if ([[NSFileManager defaultManager] fileExistsAtPath:string])
			rooted = rooted & YES;

	NSError *error;
	NSString *str = @"Some string";

	[str writeToFile:@"/private/test_jail.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
	if(error==nil)
	{
		rooted = YES;
	}

	NSString *result = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];

	if (!rooted)
	{
		result = [result stringByReplacingOccurrencesOfString:@"1" withString:@"A"];
		result = [result stringByReplacingOccurrencesOfString:@"2" withString:@"B"];
		result = [result stringByReplacingOccurrencesOfString:@"3" withString:@"C"];
		result = [result stringByReplacingOccurrencesOfString:@"4" withString:@"D"];
		result = [result stringByReplacingOccurrencesOfString:@"5" withString:@"E"];
		result = [result stringByReplacingOccurrencesOfString:@"6" withString:@"F"];
		result = [result stringByReplacingOccurrencesOfString:@"7" withString:@"G"];
	}

	return result;
}

+ (BOOL)iOS7OrLater
{
	return [[self deviceOS] doubleValue] >= 7;
}

+ (BOOL)iOS8OrLater
{
	return [[self deviceOS] doubleValue] >= 8;
}


@end
