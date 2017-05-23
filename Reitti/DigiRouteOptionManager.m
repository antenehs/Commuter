//
//  DigiRouteOptionManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/21/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "DigiRouteOptionManager.h"
#import "ReittiDateHelper.h"
#import "GraphQLQueryEnum.h"

@implementation DigiRouteOptionManager

+(id)sharedManager{
    static DigiRouteOptionManager *sharedManager = nil;
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        sharedManager = [[DigiRouteOptionManager alloc] init];
    });
    
    return sharedManager;
}

+(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(NSDictionary *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    if (!searchOptions)
        return parametersDict;
    
    /* Optimization string */
    GraphQLQueryEnum *optimizeString;
    NSNumber *optimizationNumber = searchOptions[kSelectedRouteSearchOptimizationKey];
    RouteSearchOptimization optimization = (RouteSearchOptimization)[optimizationNumber intValue];
    
    if (optimization == RouteSearchOptionFastest) {
        optimizeString = [GraphQLQueryEnum forStringRepresentation:@"QUICK"];
    }else if (optimization == RouteSearchOptionLeastTransfer) {
        optimizeString =  [GraphQLQueryEnum forStringRepresentation:@"TRANSFERS"];
    }else if (optimization == RouteSearchOptionLeastWalking) {
        optimizeString = [GraphQLQueryEnum forStringRepresentation:@"SAFE"];
    }else{
        optimizeString = [GraphQLQueryEnum forStringRepresentation:@"QUICK"];;
    }
    
    [parametersDict setObject:optimizeString forKey:@"optimize"];
    
    /* Search date and time */
    NSDate * searchDate = searchOptions[kRouteSearchDateKey];
    if (searchDate != nil) {
        NSString *date = [[ReittiDateHelper sharedFormatter] digitransitQueryDateStringFromDate:searchDate];
        NSString *time = [[ReittiDateHelper sharedFormatter] digitransitQueryTimeStringFromDate:searchDate];
        
        NSNumber *arriveBy = @NO;
        NSNumber *timeTypeValue = searchOptions[kSelectedRouteTimeTypeKey];
        RouteTimeType type = (RouteTimeType)[timeTypeValue intValue];
        if (type == RouteTimeNow || type == RouteTimeDeparture)
            arriveBy = @NO;
        else
            arriveBy = @YES;
        
        [parametersDict setObject:time forKey:@"time"];
        [parametersDict setObject:date forKey:@"date"];
        [parametersDict setObject:arriveBy forKey:@"arriveBy"];
    }
    
    /* Transport type */
    if (searchOptions[kSelectedRouteTrasportTypesKey] != nil) {
        NSString *transportTypes;
        NSArray *selectedTrasportTypes = searchOptions[kSelectedRouteTrasportTypesKey];
        if (selectedTrasportTypes.count == [self transportTypeOptions].allKeys.count)
            transportTypes = @"WALK,TRANSIT";
        else if (selectedTrasportTypes.count == 0)
            transportTypes = @"WALK";
        else {
            //Add walk to all of the requests
            NSMutableArray *selected = [@[@"WALK"] mutableCopy];
            for (NSString *trans in selectedTrasportTypes) {
                NSString *selectedType = [[self transportTypeOptions] objectForKey:trans];
                if (selectedType) //Just in case. This should never happen ever
                    [selected addObject:selectedType];
                else
                    NSLog(@"========================SOMETHINGGG WASSSS WROOOOOOOOOOONGGGGGG. NOOOOOOOOOOOOOOOOOOO ==========");
            }
            transportTypes = [RouteOptionManagerBase commaSepStringFromArray:selected withSeparator:@","];
        }
        
        [parametersDict setObject:transportTypes forKey:@"modes"];
        [parametersDict setObject:@YES forKey:@"allowBikeRental"];
    }
    
    /* Change Margine */
    if (searchOptions[kSelectedChangeMargineKey] != nil && ![searchOptions[kSelectedChangeMargineKey] isEqualToString:@"3 minutes (Default)"]) {
        [parametersDict setObject:[[self changeMargineOptions] objectForKey:searchOptions[kSelectedChangeMargineKey]] forKey:@"minTransferTime"];
    }
    
    /* Walking Speed */
    if (searchOptions[kSelectedWalkingSpeedKey] != nil && ![searchOptions[kSelectedWalkingSpeedKey] isEqualToString:@"Normal Walking (Default)"]) {
        [parametersDict setObject:[[self walkingSpeedOptions] objectForKey:searchOptions[kSelectedWalkingSpeedKey]] forKey:@"walkSpeed"];
    }
    
    //    [parametersDict setObject:@"3" forKey:@"show"];
    
    if ([searchOptions[kNumberOfRouteResultsKey] integerValue] == 5) {
        [parametersDict setObject:@5 forKey:@"numItineraries"];
    }else{
        [parametersDict setObject:searchOptions[kNumberOfRouteResultsKey] forKey:@"numItineraries"];
    }
    
    /* Options for all search */
    //    [parametersDict setObject:@"full" forKey:@"detail"];
    
    return parametersDict;
}


#pragma mark - transport option
+(NSDictionary *)transportTypeOptions{
    return @{@"Bus"       : @"BUS",
             @"Metro"     : @"SUBWAY",
             @"Train"     : @"RAIL",
             @"Tram"      : @"TRAM",
             @"Ferry"     : @"FERRY",
             @"Airplane"  : @"AIRPLANE",
             @"City Bike" : @"BICYCLE_RENT"};
}

+(NSArray *)allTrasportTypeNames{
    return @[@"Bus", @"Metro", @"Train", @"Tram", @"Ferry", @"Airplane", @"City Bike"];
}

+(NSArray *)getDefaultTransportTypeNames {
    return @[@"Bus", @"Metro", @"Train", @"Tram", @"Ferry", @"Airplane"];
}

+(NSArray *)getTransportTypeOptionsForDisplay {
    return @[@{displayTextOptionKey : @"Bus", valueOptionKey : @"BUS", pictureOptionKey :@"bus-filled-light-100"},
             @{displayTextOptionKey : @"Metro", valueOptionKey : @"SUBWAY", pictureOptionKey : @"Subway-100.png"},
             @{displayTextOptionKey : @"Train", valueOptionKey : @"RAIL", pictureOptionKey : @"train-filled-light-64"},
             @{displayTextOptionKey : @"Tram", valueOptionKey : @"TRAM", pictureOptionKey : @"tram-filled-light-64"},
             @{displayTextOptionKey : @"Ferry", valueOptionKey : @"FERRY", pictureOptionKey : @"boat-filled-light-100"},
             @{displayTextOptionKey : @"Airplane", valueOptionKey : @"AIRPLANE", pictureOptionKey : @"airplaneLight"},
             @{displayTextOptionKey : @"City Bike", valueOptionKey : @"BICYCLE_RENT", pictureOptionKey : @"bikeYellow"}
             ];
}

#pragma mark - change margin (minTransferTime)
+(NSDictionary *)changeMargineOptions{
    return @{@"0 minute"            : @0,
             @"1 minute"            : @60,
             @"3 minutes (Default)" : @180,
             @"5 minutes"           : @300,
             @"7 minutes"           : @420,
             @"9 minutes"           : @540,
             @"10 minutes"          : @600};
}

+(NSArray *)getChangeMargineOptionsForDisplay{
    return @[@{displayTextOptionKey : @"0 minute" , valueOptionKey: @0},
             @{displayTextOptionKey : @"1 minute" , valueOptionKey: @60},
             @{displayTextOptionKey : @"3 minutes (Default)", valueOptionKey : @180, defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"5 minutes", valueOptionKey : @300},
             @{displayTextOptionKey : @"7 minutes", valueOptionKey : @420},
             @{displayTextOptionKey : @"9 minutes", valueOptionKey : @540},
             @{displayTextOptionKey : @"10 minutes", valueOptionKey : @600}];
}

+(NSInteger)getDefaultValueIndexForChangeMargineOptions{
    return 2;
}


#pragma mark - walking speed
+(NSDictionary *)walkingSpeedOptions{
    return @{@"Slow Walking"            : @0.5,
             @"Normal Walking (Default)": @1.4,
             @"Fast Walking"            : @3,
             @"Running"                 : @6,
             @"Fast Running"            : @9,
             @"Bolting"                 : @12};
}

+(NSArray *)getWalkingSpeedOptionsForDisplay{
    return @[@{displayTextOptionKey : @"Slow Walking", detailOptionKey : @"0.5 m/s", valueOptionKey : @0.5},
             @{displayTextOptionKey : @"Normal Walking (Default)" , detailOptionKey : @"1.4 m/s", valueOptionKey: @1.4, defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"Fast Walking", detailOptionKey : @"3 m/s", valueOptionKey : @3},
             @{displayTextOptionKey : @"Running", detailOptionKey : @"6 m/s", valueOptionKey : @6},
             @{displayTextOptionKey : @"Fast Running", detailOptionKey : @"9 m/s", valueOptionKey : @9},
             @{displayTextOptionKey : @"Bolting", detailOptionKey : @"12 m/s", valueOptionKey : @12}];
}

+(NSInteger)getDefaultValueIndexForWalkingSpeedOptions{
    return 1;
}

@end
