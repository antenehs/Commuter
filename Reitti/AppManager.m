//
//  AppManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "AppManager.h"

@implementation AppManager

+(BOOL)shouldShowWelcomeView{
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *previousBundleVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousBundleVersion"];
    
    BOOL toReturn = NO;
    
    if (![currentBundleVersion isEqualToString:previousBundleVersion] ) {
        toReturn = YES;
        
        NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        if (standardUserDefaults) {
            [standardUserDefaults setObject:currentBundleVersion forKey:@"PreviousBundleVersion"];
            [standardUserDefaults synchronize];
        }
    }
    
    return toReturn;
}

@end
