//
//  AppManagerBase.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "AppManagerBase.h"

//group.com.ewketApps.commuterDepartures
NSString *kUserDefaultsSuitNameForDeparturesWidget = @"group.com.ewketApps.commuterProDepartures";
NSString *kUserDefaultsSuitNameForRoutesWidget = @"group.com.ewketApps.commuterProRoutes";

NSString *kUserDefaultsNamedBookmarksKey = @"namedBookmarksDictionary";
NSString *kUserDefaultsSavedStopsKey = @"savedStopsCodesList";

NSString *urlSpaceEscapingString = @"%20";

NSString *kAppFullName = @"Commuter Pro";
//
NSString *kAppAppstoreLink = @"itms-apps://itunes.apple.com/app/id1023398868";

@implementation AppManagerBase

+(BOOL)isNewInstallOrNewVersion{
    if ([self isNewInstall])
        return YES;

    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *previousBundleVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousBundleVersion"];
    
    return ![currentBundleVersion isEqualToString:previousBundleVersion];
}

+(BOOL)isNewInstall{
    NSString *previousBundleVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousBundleVersion"];
    
    return previousBundleVersion == nil;
}

+(void)setCurrentAppVersion{
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:currentBundleVersion forKey:@"PreviousBundleVersion"];
        [standardUserDefaults synchronize];
    }
}

+(NSString *)currentAppVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+(NSString *)iosDeviceModel{
    return [[UIDevice currentDevice] model];
}

+(NSString *)iosVersionNumber{
    return [[UIDevice currentDevice] systemVersion];
}

+(UIImage *)roundedAppLogoSmall{
    return [UIImage imageNamed:@"app-pro-logo-rounded2-small.png"];
}

+(UIImage *)roundedAppLogoLarge{
    return [UIImage imageNamed:@"app-pro-logo-rounded2.png"];
}

+(UIImage *)appVersionPicture{
//    return [UIImage imageNamed:@"version-5.png"];
    return [UIImage imageNamed:@"version-2.png"];
}

+(NSString *)appAppstoreLink{
    return kAppAppstoreLink;
}

+(NSString *)matkakorttiAppAppstoreUrl{
    return @"itms-apps://itunes.apple.com/app/id1036411677";
}

+(NSString *)mainAppUrl{
//    return @"CommuterMainApp://";
    return @"CommuterProMainApp://";
}

//#1CAC7F
+(UIColor *)systemGreenColor{
    //    return [UIColor colorWithRed:31.0/255.0 green:154.0/255.0 blue:57.0/255.0 alpha:1.0];
    return [UIColor colorWithRed:28.0/255.0 green:172.0/255.0 blue:127.0/255.0 alpha:1.0];
}

//#F46B00
+(UIColor *)systemOrangeColor{
    return [UIColor colorWithRed:244.0f/255 green:107.0f/255 blue:0 alpha:1];
}

//#F44336
+(UIColor *)systemRedColor{
    return [UIColor colorWithRed:244.0f/255 green:67.0f/255 blue:54.0f/255 alpha:1];
}

//#2196F3
+(UIColor *)systemBlueColor{
    return [UIColor colorWithRed:33.0/255 green:150.0/255.0 blue:243.0f/255 alpha:1.0];
}

//#00BCD4
+(UIColor *)systemCyanColor{
    return [UIColor colorWithRed:0.0f/255 green:188.0f/255 blue:212.0f/255 alpha:1];
}

//Tones
+(NSArray *)toneNames{
    return [[NSArray alloc] initWithObjects:@"Choo choo train",
            @"Horse whinny",
            @"Mellow mood",
            @"Time to go 1",
            @"Time to go 2",
            @"Time to go 3",
            @"Time to go 4",
            @"Time to go 5",
            @"Train",
            @"Vibration sound",
            @"Wheels on the bus",nil];
}

+(NSString *)defailtToneName{
    return @"Train";
}

@end
