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

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(NSDictionary *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    if (!searchOptions)
        return parametersDict;
    
    /* Optimization string */
    NSString *optimizeString;
    NSNumber *optimizationNumber = searchOptions[kSelectedRouteSearchOptimizationKey];
    RouteSearchOptimization optimization = (RouteSearchOptimization)[optimizationNumber intValue];
    
    if (optimization == RouteSearchOptionFastest) {
        optimizeString = @"fastest";
    }else if (optimization == RouteSearchOptionLeastTransfer) {
        optimizeString = @"least_transfers";
    }else if (optimization == RouteSearchOptionLeastWalking) {
        optimizeString = @"least_walking";
    }else{
        optimizeString = @"default";
    }
    
    [parametersDict setObject:optimizeString forKey:@"optimize"];
    
    /* Search date and time */
    NSDate * searchDate = searchOptions[kRouteSearchDateKey];
    if (searchDate != nil) {
        NSString *time = [self.hourFormatter stringFromDate:searchDate];
        NSString *date = [self.dateFormatter stringFromDate:searchDate];
        
        NSString *timeType;
        NSNumber *timeTypeValue = searchOptions[kSelectedRouteTimeTypeKey];
        RouteTimeType type = (RouteTimeType)[timeTypeValue intValue];
        if (type == RouteTimeNow || type == RouteTimeDeparture)
            timeType = @"departure";
        else
            timeType = @"arrival";
        
        [parametersDict setObject:time forKey:@"time"];
        [parametersDict setObject:date forKey:@"date"];
        [parametersDict setObject:timeType forKey:@"timetype"];
    }
    
    /* Transport type */
    if (searchOptions[kSelectedRouteTrasportTypesKey] != nil) {
        NSString *transportTypes;
        NSArray *selectedTrasportTypes = searchOptions[kSelectedRouteTrasportTypesKey];
        if (selectedTrasportTypes.count == [HSLRouteOptionManager transportTypeOptions].allKeys.count)
            transportTypes = @"all";
        else if (selectedTrasportTypes.count == 0)
            transportTypes = @"walk";
        else {
            NSMutableArray *selected = [@[] mutableCopy];
            for (NSString *trans in selectedTrasportTypes) {
                NSString *selectedType = [[HSLRouteOptionManager transportTypeOptions] objectForKey:trans];
                if (selectedType) //Just in case. This should never happen ever
                    [selected addObject:selectedType];
                else
                    NSLog(@"========================SOMETHINGGG WASSSS WROOOOOOOOOOONGGGGGG. NOOOOOOOOOOOOOOOOOOO ==========");
            }
            transportTypes = [RouteOptionManagerBase commaSepStringFromArray:selected withSeparator:@"|"];
        }
        
        [parametersDict setObject:transportTypes forKey:@"transport_types"];
    }
    
    /* Ticket Zone */
    if (searchOptions[kSelectedTicketZoneKey] != nil && ![searchOptions[kSelectedTicketZoneKey] isEqualToString:@"All HSL Regions (Default)"]) {
        [parametersDict setObject:[[HSLRouteOptionManager ticketZoneOptions] objectForKey:searchOptions[kSelectedTicketZoneKey]] forKey:@"zone"];
    }
    
    /* Change Margine */
    if (searchOptions[kSelectedChangeMargineKey] != nil && ![searchOptions[kSelectedChangeMargineKey] isEqualToString:@"3 minutes (Default)"]) {
        [parametersDict setObject:[[HSLRouteOptionManager changeMargineOptions] objectForKey:searchOptions[kSelectedChangeMargineKey]] forKey:@"change_margin"];
    }
    
    /* Walking Speed */
    if (searchOptions[kSelectedWalkingSpeedKey] != nil && ![searchOptions[kSelectedWalkingSpeedKey] isEqualToString:@"Normal Walking (Default)"]) {
        [parametersDict setObject:[[HSLRouteOptionManager walkingSpeedOptions] objectForKey:searchOptions[kSelectedWalkingSpeedKey]] forKey:@"walk_speed"];
    }
    
//    [parametersDict setObject:@"3" forKey:@"show"];
    
    if ([searchOptions[kNumberOfRouteResultsKey] integerValue] == 5) {
        [parametersDict setObject:@"5" forKey:@"show"];
    }else{
        [parametersDict setObject:[NSString stringWithFormat:@"%ld", (long)searchOptions[kNumberOfRouteResultsKey]] forKey:@"show"];
    }
    
    /* Options for all search */
    //    [parametersDict setObject:@"full" forKey:@"detail"];
    
    return parametersDict;
}

#pragma mark - Datasource value mapping

+(NSDictionary *)transportTypeOptions{
    return @{@"Bus" : @"bus",
             @"Metro" : @"metro",
             @"Train" : @"train",
             @"Tram" : @"tram",
             @"Ferry" : @"ferry",
             @"Uline" : @"uline",
             @"City Bike" : @"City Bike"};
}

+(NSArray *)allTrasportTypeNames{
    return @[@"Bus", @"Metro", @"Train", @"Tram", @"Ferry", @"Uline", @"City Bike"];//TODO: add city bikes
}

+(NSArray *)getTransportTypeOptionsForDisplay {
    return @[@{displayTextOptionKey : @"Bus", valueOptionKey : @"bus", pictureOptionKey :@"bus-filled-light-100"},
             @{displayTextOptionKey : @"Metro", valueOptionKey : @"metro", pictureOptionKey : @"Subway-100.png"},
             @{displayTextOptionKey : @"Train", valueOptionKey : @"train", pictureOptionKey : @"train-filled-light-64"},
             @{displayTextOptionKey : @"Tram", valueOptionKey : @"tram", pictureOptionKey : @"tram-filled-light-64"},
             @{displayTextOptionKey : @"Ferry", valueOptionKey : @"ferry", pictureOptionKey : @"boat-filled-light-100"},
             @{displayTextOptionKey : @"Uline", valueOptionKey : @"uline", pictureOptionKey : @"bus-filled-light-100"},
              @{displayTextOptionKey : @"City Bike", valueOptionKey : @"bike", pictureOptionKey : @"bikeYellow"}
             ];
}

+(NSDictionary *)ticketZoneOptions{
    return @{@"All HSL Regions (Default)" : @"whole",
             @"Regional" : @"region",
             @"Helsinki Internal" : @"helsinki",
             @"Espoo Internal" : @"espoo",
             @"Vantaa Internal" : @"vantaa"};;
}

+(NSArray *)getTicketZoneOptionsForDisplay{
    return @[@{displayTextOptionKey : @"All HSL Regions (Default)", valueOptionKey : @"whole", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"Regional" , valueOptionKey: @"region"},
             @{displayTextOptionKey : @"Helsinki Internal", valueOptionKey : @"helsinki"},
             @{displayTextOptionKey : @"Espoo Internal", valueOptionKey : @"espoo"},
             @{displayTextOptionKey : @"Vantaa Internal", valueOptionKey : @"vantaa"}];
}

+(NSInteger)getDefaultValueIndexForTicketZoneOptions{
    return 0;
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

+(NSArray *)getChangeMargineOptionsForDisplay{
    return @[@{displayTextOptionKey : @"0 minute" , valueOptionKey: @"0"},
             @{displayTextOptionKey : @"1 minute" , valueOptionKey: @"1"},
             @{displayTextOptionKey : @"3 minutes (Default)", valueOptionKey : @"3", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"5 minutes", valueOptionKey : @"5"},
             @{displayTextOptionKey : @"7 minutes", valueOptionKey : @"7"},
             @{displayTextOptionKey : @"9 minutes", valueOptionKey : @"9"},
             @{displayTextOptionKey : @"10 minutes", valueOptionKey : @"10"}];
}

+(NSInteger)getDefaultValueIndexForChangeMargineOptions{
    return 2;
}

+(NSDictionary *)walkingSpeedOptions{
    return @{@"Slow Walking" : @"20",
             @"Normal Walking (Default)" : @"70",
             @"Fast Walking" : @"150",
             @"Running" : @"250",
             @"Fast Running" : @"350",
             @"Bolting" : @"500"};
}

+(NSArray *)getWalkingSpeedOptionsForDisplay{
    return @[@{displayTextOptionKey : @"Slow Walking", detailOptionKey : @"20 m/minute", valueOptionKey : @"20"},
             @{displayTextOptionKey : @"Normal Walking (Default)" , detailOptionKey : @"70 m/minute", valueOptionKey: @"70", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"Fast Walking", detailOptionKey : @"150 m/minute", valueOptionKey : @"150"},
             @{displayTextOptionKey : @"Running", detailOptionKey : @"250 m/minute", valueOptionKey : @"250"},
             @{displayTextOptionKey : @"Fast Running", detailOptionKey : @"350 m/minute", valueOptionKey : @"350"},
             @{displayTextOptionKey : @"Bolting", detailOptionKey : @"500 m/minute", valueOptionKey : @"500"}];
}

+(NSInteger)getDefaultValueIndexForWalkingSpeedOptions{
    return 1;
}

@end
