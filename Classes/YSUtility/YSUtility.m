//
//  Utility.m
//  YSUtilityExample
//
//  Created by Yu Sugawara on 2013/02/23.
//  Copyright (c) 2013年 Yu Sugawara. All rights reserved.
//

#import "YSUtility.h"
#include <sys/sysctl.h>

@implementation YSUtility

#pragma mark - Device

+ (BOOL)isPhone
{
    return [self isPhone_];
}

+ (BOOL)isPad
{
    return ![self isPhone_];
}

+ (BOOL)isPhone_
{
    static BOOL s_isPhone;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_isPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    });
    return s_isPhone;
}

+ (NSString*)deviceTypeStr
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? @"iPhone" : @"iPad";
}

+ (BOOL)isRetina
{
    static BOOL s_isRetina;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_isRetina = [UIScreen mainScreen].scale == 2.f;
    });
    return s_isRetina;
}

+ (BOOL)is568h
{
    static BOOL s_is568h;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        s_is568h = height == 568.f;
    });
    return s_is568h;
}

/*
 *  http://stackoverflow.com/a/19044023
 *
 *  Compile Time Check
 *  #ifdef __LP64__
 *      // 64bit
 *  #else
 *      // 32bit
 *  #endif
 */
+ (BOOL)CPU64bit
{
    return sizeof(void*) == 8;
}

+ (BOOL)CPU32bit
{
    return ![self CPU64bit];
}

#pragma mark - Orientation

+ (BOOL)isOrientationPortrait;
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return UIInterfaceOrientationIsPortrait(orientation);
}

+ (BOOL)isOrientationLandscape
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - Language

+ (BOOL)isJapaneseLanguage
{
    NSString *lang = [self currentLanguage];
    return [lang isEqualToString:@"ja"] || [lang hasPrefix:@"ja-"];
}

+ (NSString*)currentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    return [languages objectAtIndex:0];
}

/* http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 */
+ (NSString*)currentISOCountryCode
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey: NSLocaleCountryCode];
}

+ (NSString*)appDisplayName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)deviceName
{
    return [UIDevice currentDevice].name;
}

#pragma mark - Image

+ (UIImage*)appIcon
{
    NSArray *iconNames;
    if ([self isPhone]) {
        iconNames = @[@"AppIcon60x60@3x",
                      @"AppIcon60x60@2x",
                      @"AppIcon60x60"];
    } else {
        iconNames = @[@"AppIcon76x76@3x",
                      @"AppIcon76x76@2x",
                      @"AppIcon76x76"];
    }
    for (NSString *iconName in iconNames) {
        return [UIImage imageNamed:iconName];
    }
    return nil;
}

#pragma mark - Function

+ (BOOL)hasAirDrop
{
    /* 
     AirDropはiOS7から使用可能
     iOS7でAirDropが使用不可な機種は、iPhone4, iPhone4s, iPad2, iPad3
     http://www.apple.com/jp/ios/whats-new/?cid=wwa-jp-kwg-features-com&siclientid=7313&sessguid=717cc813-729c-4e2c-af7e-58b6a38f13f1&userguid=717cc813-729c-4e2c-af7e-58b6a38f13f1&permguid=717cc813-729c-4e2c-af7e-58b6a38f13f1#airdrop
     http://livedoor.blogimg.jp/amaebi4912/imgs/4/0/40a777b0.jpg
     */
    
    static BOOL s_hasAirDrop;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_IPHONE_SIMULATOR
        s_hasAirDrop = NO;
#else
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            // iOS 6.1 or earlier
            s_hasAirDrop = NO;
        } else {
            // iOS 7 or later
            NSString *platform = [self platform];
            
            // iPhone http://theiphonewiki.com/wiki/IPhone
            // iPad http://theiphonewiki.com/wiki/IPad
            
            if ([platform isEqualToString:@"iPhone3,1"] || // iPhone4 GSM
                [platform isEqualToString:@"iPhone3,2"] || // iPhone4 GSM Rev A
                [platform isEqualToString:@"iPhone3,3"] || // iPhone4 CDMA
                [platform isEqualToString:@"iPhone4,1"] || // iPhone4S
                [platform isEqualToString:@"iPad2,1"] || // iPad2G WiFi
                [platform isEqualToString:@"iPad2,2"] || // iPad2G GSM
                [platform isEqualToString:@"iPad2,3"] || // iPad2G CDMA
                [platform isEqualToString:@"iPad2,4"] || // iPad2G Rev A
                [platform isEqualToString:@"iPad3,1"] || // iPad3G WiFi
                [platform isEqualToString:@"iPad3,2"] || // iPad3G GSM
                [platform isEqualToString:@"iPad3,3"])   // iPad3G Global
            {
                s_hasAirDrop = NO;
            }
            else {
                s_hasAirDrop = YES;
            }
        }
#endif
    });
    return s_hasAirDrop;
}

+ (BOOL)isForceTouchEnabled
{
    static BOOL __enabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UITraitCollection *traitCollection = [UIApplication sharedApplication].keyWindow.traitCollection;
        if (![traitCollection respondsToSelector:@selector(forceTouchCapability)]) return ;
        __enabled = [traitCollection forceTouchCapability] == UIForceTouchCapabilityAvailable;
    });
    return __enabled;
}

#pragma mark - Version

+ (NSComparisonResult)compareCurrentSystemVersionAndThisVersion:(NSString*)version
{
    NSString *currentVersion = [UIDevice currentDevice].systemVersion;
    return [currentVersion compare:version options:NSNumericSearch];
}

+ (BOOL)isGreaterThanThisSystemVersion:(NSString*)version
{
    return [self compareCurrentSystemVersionAndThisVersion:version] == NSOrderedAscending;
}

+ (BOOL)isGreaterThanOrEqualToThisSystemVersion:(NSString*)version
{
    return [self compareCurrentSystemVersionAndThisVersion:version] <= NSOrderedSame;
}

+ (BOOL)isSmallerThanOrEqualToThisSystemVersion:(NSString*)version
{
    return [self compareCurrentSystemVersionAndThisVersion:version] >= NSOrderedSame;
}

+ (BOOL)isSmallerThanThisSystemVersion:(NSString*)version
{
    return [self compareCurrentSystemVersionAndThisVersion:version] == NSOrderedDescending;
}

/* http://stackoverflow.com/questions/17070582/using-uiappearance-and-switching-themes */
+ (void)reloadAppearance
{
    NSArray * windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        for (UIView *view in window.subviews) {
            [view removeFromSuperview];
            [window addSubview:view];
        }
    }
}

#pragma mark - ViewController

+ (UIViewController *)visibleViewController
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

#pragma mark - Status bar

+ (CGSize)statusBarSizeToConsideredTheRotation
{
    UIApplication *app = [UIApplication sharedApplication];
    if (app.statusBarHidden) {
        return CGSizeZero;
    }
    if (UIInterfaceOrientationIsPortrait(app.statusBarOrientation)) {
        return app.statusBarFrame.size;
    } else {
        return CGSizeMake(app.statusBarFrame.size.height, app.statusBarFrame.size.width);
    }
}

#pragma mark - Jailbreak

/* http://stackoverflow.com/questions/413242/how-do-i-detect-that-an-sdk-app-is-running-on-a-jailbroken-phone */
+ (BOOL)isJailbroken
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#endif
    BOOL ret = NO;
    NSString *filePath = @"/Applications/Cydia.app";
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        ret = YES;
    }
    FILE *f = fopen("/bin/bash", "r");
    if (f != NULL) {
        //Device is jailbroken
        ret = YES;
    }
    fclose(f);
    
    return ret;
}

#pragma mark - UIDevice-Hardware

/* 
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 UIDevice-Hardware.h
*/

+ (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

+ (NSString *) platform
{
    static NSString *s_platform;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_platform = [self getSysInfoByName:"hw.machine"];
    });
    return s_platform;
}

@end
