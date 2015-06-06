//
//  AppManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "AppManager.h"

@implementation AppManager

+(BOOL)isNewInstallOrNewVersion{
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *previousBundleVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousBundleVersion"];
    
    return ![currentBundleVersion isEqualToString:previousBundleVersion];
}

+(void)setCurrentAppVersion{
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:currentBundleVersion forKey:@"PreviousBundleVersion"];
        [standardUserDefaults synchronize];
    }
}


+(UIColor *)systemGreenColor{
    return [UIColor colorWithRed:31.0/255.0 green:154.0/255.0 blue:57.0/255.0 alpha:1.0];
}

+(UIColor *)systemOrangeColor{
    return [UIColor colorWithRed:244.0f/255 green:107.0f/255 blue:0 alpha:1];
}

@end
