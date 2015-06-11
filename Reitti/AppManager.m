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

//#1F9A39
+(UIColor *)systemGreenColor{
    return [UIColor colorWithRed:31.0/255.0 green:154.0/255.0 blue:57.0/255.0 alpha:1.0];
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

+(UIColor *)colorForLegType:(LegTransportType)legTransportType{
    switch (legTransportType) {
        case LegTypeWalk:
            return [UIColor darkGrayColor];
            break;
        case LegTypeFerry:
            return [AppManager systemCyanColor];
            break;
        case LegTypeTrain:
            return [AppManager systemRedColor];
            break;
        case LegTypeBus:
            return [AppManager systemBlueColor];
            break;
        case LegTypeTram:
            return [AppManager systemGreenColor];
            break;
        case LegTypeMetro:
            return [AppManager systemOrangeColor];
            break;
            
        default:
            return [UIColor darkGrayColor];
            break;
    }
}

#pragma mark - system images
+(UIImage *)stopAnnotationImageForStopType:(StopType)stopType{
    
    if (stopType == StopTypeBus) {
        return [UIImage imageNamed:@"busAnnotation3_2.png"];
    }else if (stopType == StopTypeTrain) {
        return [UIImage imageNamed:@"trainAnnotation3_2.png"];
    }else if (stopType == StopTypeTram) {
        return [UIImage imageNamed:@"tramAnnotation3_2.png"];
    }else if (stopType == StopTypeFerry) {
        return [UIImage imageNamed:@"ferryAnnotation3_2.png"];
    }else if (stopType == StopTypeMetro) {
        return [UIImage imageNamed:@"metroAnnotation3_2.png"];
    }else{
        return [UIImage imageNamed:@"busAnnotation3_2.png"];
    }
}

@end
