//
//  AppManagerBase.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "AppManagerBase.h"

//group.com.ewketApps.commuterDepartures
NSString *kUserDefaultsSuitNameForDeparturesWidget = @"group.com.ewketApps.commuterDepartures";
NSString *kUserDefaultsSuitNameForProDeparturesWidget = @"group.com.ewketApps.commuterProDepartures";
NSString *kUserDefaultsSuitNameForRoutesExtension = @"group.com.ewketApps.commuterProRoutes";
NSString *KUserDefaultsSuitNameForWatchRoutes = @"group.com.ewketApps.commuterWatchRoutes";

NSString *kUserDefaultsNamedBookmarksKey = @"namedBookmarksDictionary";
NSString *kUserDefaultsSavedStopsKey = @"StopCodes";
//NSString *kUserDefaultsSelectedSavedStopsKey = @"SelectedStopCodes";
NSString *kUserDefaultsStopSourceApiKey = @"StopSourceApi";
NSString *kUserDefaultsRouteSearchOptionsKey = @"kUserDefaultsRouteSearchOptionsKey";

NSString *urlSpaceEscapingString = @"%20";

NSString *kProAppFullName = @"Commuter Pro";
NSString *kAppFullName = @"Commuter";

NSString *kGoProDetailUrl = @"http://commuterapp.weebly.com/commuter-pro.html";
NSString *kFeatureTrackingUrl = @"http://commuterapp.weebly.com/commuter-usage-tracking.html";

NSString *kProAppAppstoreLink = @"itms-apps://itunes.apple.com/app/id1023398868";
NSString *kAppAppstoreLink = @"itms-apps://itunes.apple.com/app/id861274235";

NSString *kAppRateAppstoreLink = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=861274235&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
NSString *kProAppRateAppStoreLink = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1023398868&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";

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

+(BOOL)isProVersion{
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    
    if (!infoPlist)
        return YES;
    
    NSNumber * isProVersion = infoPlist[@"IsProVersion"];
    if (isProVersion)
        return [isProVersion boolValue];
    
    return YES;
}

+(BOOL)isDebugMode {
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

+(NSString *)nsUserDefaultsStopsWidgetSuitName{
    if ([self isProVersion])
        return kUserDefaultsSuitNameForProDeparturesWidget;
    else
        return kUserDefaultsSuitNameForDeparturesWidget;
}

+(NSString *)nsUserDefaultsRoutesExtensionSuitName{
    return kUserDefaultsSuitNameForRoutesExtension;
}

+(NSString *)nsUserDefaultsWatchRoutesSuitName{
    return KUserDefaultsSuitNameForWatchRoutes;
}

+(NSString *)appFullName{
    if ([self isProVersion])
        return kProAppFullName;
    else
        return kAppFullName;
}

+(UIImage *)roundedAppLogoSmall{
    if ([self isProVersion])
        return [UIImage imageNamed:@"app-pro-logo-rounded2-small.png"];
    else
        return [UIImage imageNamed:@"app-logo-rounded-small.png"];
}

+(UIImage *)roundedAppLogoLarge{
    if ([self isProVersion])
        return [UIImage imageNamed:@"app-pro-logo-rounded2.png"];
    else
        return [UIImage imageNamed:@"app-logo-new-rounded.png"];
}

+(UIImage *)appVersionPicture{
    if ([self isProVersion])
        return [UIImage imageNamed:@"versionNumber5"];
    else
        return [UIImage imageNamed:@"versionNumber5"];
}

+(NSString *)appAppstoreLink{
    if ([self isProVersion])
        return kProAppAppstoreLink;
    else
        return kAppAppstoreLink;
}

+(NSString *)appAppstoreRateLink{
    if ([self isProVersion])
        return kProAppRateAppStoreLink;
    else
        return kAppRateAppstoreLink;
}

+(NSString *)matkakorttiAppAppstoreUrl{
    return @"itms-apps://itunes.apple.com/app/id1036411677";
}

+(NSString *)mainAppUrl{
    if ([self isProVersion])
        return @"CommuterProMainApp://";
    else
        return @"CommuterMainApp://";
}

//#1CAC7F
+(UIColor *)systemGreenColor{
    return [UIColor colorWithRed:28.0/255.0 green:172.0/255.0 blue:127.0/255.0 alpha:1.0];
//    return [UIColor colorWithRed:0.318 green:0.718 blue:0.259 alpha:1.00];
//    return [UIColor colorWithRed:0.306 green:0.698 blue:0.467 alpha:1.00];
//    return [UIColor colorWithRed:0.275 green:0.635 blue:0.400 alpha:1.00];
}

//#F46B00
//#fa4220
+(UIColor *)systemOrangeColor{
//    return [UIColor colorWithRed:244.0f/255 green:107.0f/255 blue:0 alpha:1];
    return [UIColor colorWithRed:0.980 green:0.259 blue:0.125 alpha:1.00];
}

//#F44336
+(UIColor *)systemRedColor{
//    return [UIColor colorWithRed:244.0f/255 green:67.0f/255 blue:54.0f/255 alpha:1];
//    return [UIColor colorWithRed:0.580 green:0.110 blue:0.075 alpha:1.00];
//    return [UIColor colorWithRed:0.682 green:0.165 blue:0.129 alpha:1.00];
    return [UIColor colorWithRed:0.741 green:0.180 blue:0.145 alpha:1.00];
}

//#2196F3
+(UIColor *)systemBlueColor{
//    return [UIColor colorWithRed:33.0/255 green:150.0/255.0 blue:243.0f/255 alpha:1.0];
//    return [UIColor colorWithRed:0.129 green:0.353 blue:0.667 alpha:1.00];
    return [UIColor colorWithRed:0.157 green:0.435 blue:0.812 alpha:1.00];
}

//#00BCD4
+(UIColor *)systemCyanColor{
    return [UIColor colorWithRed:0.0f/255 green:188.0f/255 blue:212.0f/255 alpha:1];
}

+(UIColor *)systemPurpleColor{
    return [UIColor colorWithRed:0.557 green:0.267 blue:0.678 alpha:1.0];
}

//#fcbc19
+(UIColor *)systemYellowColor{
    return [UIColor colorWithRed:0.988 green:0.737 blue:0.098 alpha:1.00];
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
