//
//  HSLRouteOptionManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/2/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "HSLRouteOptionManager.h"

@interface HSLRouteOptionManager ()

@end

@implementation HSLRouteOptionManager

+(id)sharedManager{
    static HSLRouteOptionManager *sharedManager = nil;
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        sharedManager = [[HSLRouteOptionManager alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Datasource value mapping

+(NSDictionary *)transportTypeOptions{
    return @{@"Bus" : @"bus",
             @"Metro" : @"metro",
             @"Train" : @"train",
             @"Tram" : @"tram",
             @"Ferry" : @"ferry",
             @"Uline" : @"uline"};
}

+(NSDictionary *)ticketZoneOptions{
    return @{@"All HSL Regions (Default)" : @"whole",
             @"Regional" : @"region",
             @"Helsinki Internal" : @"helsinki",
             @"Espoo Internal" : @"espoo",
             @"Vantaa Internal" : @"vantaa"};;
}

+(NSDictionary *)changeMargineOptions{
    return @{@"0 minute" : @"0",
             @"1 minute" : @"1",
             @"3 minutes (Default)" : @"3",
             @"5 minutes" : @"5",
             @"7 minutes" : @"7",
             @"9 minutes" : @"9",
             @"10 minutes" : @"10"};
}

+(NSDictionary *)walkingSpeedOptions{
    return @{@"Slow Walking" : @"20",
             @"Normal Walking (Default)" : @"70",
             @"Fast Walking" : @"150",
             @"Running" : @"250",
             @"Fast Running" : @"350",
             @"Bolting" : @"500"};
}

@end
