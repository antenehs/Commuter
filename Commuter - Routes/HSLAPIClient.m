//
//  HSLAPIClient.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLAPIClient.h"
#import "WidgetHelpers.h"
#import "HSLRouteOptionManager.h"
#import "ReittiStringFormatterE.h"

@implementation HSLAPIClient

- (id)init{
    self = [super init];
    if (self) {
        self.apiClient = [[APIClient alloc] init];
        self.apiClient.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    }
    
    return self;
}

#pragma mark - route search
- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock {
    
    NSDictionary *searchParameters;
    if (!optionsDict) {
        searchParameters = [@{} mutableCopy];
    } else {
        searchParameters = [[self apiRequestParametersDictionaryForRouteOptions:optionsDict] mutableCopy];
    }
    
    [searchParameters setValue:@"asacommuterwidget2" forKey:@"user"];
    [searchParameters setValue:@"rebekah" forKey:@"pass"];
    
    [super searchRouteForFromCoords:fromCoords andToCoords:toCoords withOptions:searchParameters andCompletionBlock:completionBlock];
}

#pragma mark - stop search

-(void)fetchStopForCode:(NSString *)code completionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    [optionsDict setValue:@"asacommuterwidget" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchStopForCode:code withOptions:optionsDict andCompletionBlock:completionBlock];
}

#pragma mark - Datasource value mapping

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(NSDictionary *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    if (!searchOptions)
        return parametersDict;
    
    /* Optimization string */
    NSString *optimizeString;
    if ((RouteSearchOptimization)searchOptions[@"selectedRouteSearchOptimization"] == RouteSearchOptionFastest) {
        optimizeString = @"fastest";
    }else if ((RouteSearchOptimization)searchOptions[@"selectedRouteSearchOptimization"] == RouteSearchOptionLeastTransfer) {
        optimizeString = @"least_transfers";
    }else if ((RouteSearchOptimization)searchOptions[@"selectedRouteSearchOptimization"] == RouteSearchOptionLeastWalking) {
        optimizeString = @"least_walking";
    }else{
        optimizeString = @"default";
    }
    
    [parametersDict setObject:optimizeString forKey:@"optimize"];
    
    /* Transport type */
    if (searchOptions[@"selectedRouteTrasportTypes"] != nil) {
        NSString *transportTypes;
        NSArray *selectedTrasportTypes = searchOptions[@"selectedRouteTrasportTypes"];
        if (selectedTrasportTypes.count == self.transportTypeOptions.allKeys.count)
            transportTypes = @"all";
        else if (selectedTrasportTypes.count == 0)
            transportTypes = @"walk";
        else {
            NSMutableArray *selected = [@[] mutableCopy];
            for (NSString *trans in selectedTrasportTypes) {
                [selected addObject:[self.transportTypeOptions objectForKey:trans]];
            }
            transportTypes = [ReittiStringFormatterE commaSepStringFromArray:selected withSeparator:@"|"];
        }
        
        [parametersDict setObject:transportTypes forKey:@"transport_types"];
    }
    
    /* Ticket Zone */
    if (searchOptions[@"selectedTicketZone"] != nil && ![searchOptions[@"selectedTicketZone"] isEqualToString:@"All HSL Regions (Default)"]) {
        [parametersDict setObject:[self.ticketZoneOptions objectForKey:searchOptions[@"selectedTicketZone"]] forKey:@"zone"];
    }
    
    /* Change Margine */
    if (searchOptions[@"selectedChangeMargine"] != nil && ![searchOptions[@"selectedChangeMargine"] isEqualToString:@"3 minutes (Default)"]) {
        [parametersDict setObject:[self.changeMargineOptions objectForKey:searchOptions[@"selectedChangeMargine"]] forKey:@"change_margin"];
    }
    
    /* Walking Speed */
    if (searchOptions[@"selectedWalkingSpeed"] != nil && ![searchOptions[@"selectedWalkingSpeed"] isEqualToString:@"Normal Walking (Default)"]) {
        [parametersDict setObject:[self.walkingSpeedOptions objectForKey:searchOptions[@"selectedWalkingSpeed"]] forKey:@"walk_speed"];
    }
    
    [parametersDict setObject:@"3" forKey:@"show"];
    
//    if ([searchOptions[@"numberOfResults"] integerValue] == 5) {
//        [parametersDict setObject:@"5" forKey:@"show"];
//    }else{
//        [parametersDict setObject:[NSString stringWithFormat:@"%ld", (long)searchOptions[@"numberOfResults"]] forKey:@"show"];
//    }
    
    /* Options for all search */
//    [parametersDict setObject:@"full" forKey:@"detail"];
    
    return parametersDict;
}

-(NSDictionary *)transportTypeOptions{
    return [HSLRouteOptionManager transportTypeOptions];
}

-(NSDictionary *)ticketZoneOptions{
    return [HSLRouteOptionManager ticketZoneOptions];
}

-(NSDictionary *)changeMargineOptions{
    return [HSLRouteOptionManager changeMargineOptions];
}

-(NSDictionary *)walkingSpeedOptions{
    return [HSLRouteOptionManager walkingSpeedOptions];
}

@end
