//
//  AppManagerBase.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "AppManagerBase.h"

NSString *kUserDefaultsSuitNameForDeparturesWidget = @"group.com.ewketApps.commuterProDepartures";
NSString *kUserDefaultsSuitNameForRoutesWidget = @"group.com.ewketApps.commuterProRoutes";

NSString *kUserDefaultsNamedBookmarksKey = @"namedBookmarksDictionary";
NSString *kUserDefaultsSavedStopsKey = @"savedStopsCodesList";

NSString *urlSpaceEscapingString = @"%20";

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

+(NSString *)iosDeviceModel{
    return [[UIDevice currentDevice] model];
}

+(NSString *)iosVersionNumber{
    return [[UIDevice currentDevice] systemVersion];
}

//#1CAC78
+(UIColor *)systemGreenColor{
    //    return [UIColor colorWithRed:31.0/255.0 green:154.0/255.0 blue:57.0/255.0 alpha:1.0];
    return [UIColor colorWithRed:28.0/255.0 green:172.0/255.0 blue:120.0/255.0 alpha:1.0];
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
