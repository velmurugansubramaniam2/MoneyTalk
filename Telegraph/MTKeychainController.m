//
//  MTKeychainController.m
//  Telegraph
//
//  Created by Max Zhdanov on 09.12.15.
//
//

#import "MTKeychainController.h"
#import "KeychainItemWrapper.h"

@interface MTKeychainController()

@property (nonatomic, strong) KeychainItemWrapper *keychainItemWrapper;

@end




@implementation MTKeychainController

static MTKeychainController * __sharedInstance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        __sharedInstance = [[self alloc] init];
    });
    
    [__sharedInstance keychainItemWrapper];
    
    return __sharedInstance;
}

- (NSString *)bundleSeedID
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess)
        return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *bundleSeedID = [[components objectEnumerator] nextObject];
    CFRelease(result);
    return bundleSeedID;
}

- (KeychainItemWrapper *)keychainItemWrapper
{
    if (!_keychainItemWrapper)
    {
        NSString *bundleSeedID = [self bundleSeedID];
        NSString *accessGroup = [NSString stringWithFormat:@"%@.ru.tcsbank.MTTelegramPROD",bundleSeedID];
        _keychainItemWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"moneyTalk" accessGroup:accessGroup];//
        [_keychainItemWrapper setObject:@"MY_APP_CREDENTIALS" forKey:(id)kSecAttrService];
        [_keychainItemWrapper setObject:@"MY_APP_CREDENTIALS" forKey:(id)kSecAttrAccount];
    }
    
    return _keychainItemWrapper;
}

- (void)setSecValueDictionary:(NSDictionary *)secValueDictionary
{
    @synchronized(_keychainItemWrapper)
    {
        NSData *secData = [NSKeyedArchiver archivedDataWithRootObject:secValueDictionary];
        
        [_keychainItemWrapper setObject:secData forKey:(id)kSecValueData];
    }
}

- (NSDictionary *)getSecValueDictionary
{
    @synchronized(_keychainItemWrapper)
    {
        NSData *secData = [_keychainItemWrapper objectForKey:(id)kSecValueData];
        
        NSDictionary *secValueDictionary = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:secData];
        
        return [secValueDictionary isKindOfClass:[NSDictionary class]] ? secValueDictionary : nil;
    }
}

@end
