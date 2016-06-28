//
//  WatchHslApi.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "WatchHslApi.h"
#import "HSLRouteOptionManager.h"
#import "ReittiStringFormatterE.h"

@implementation WatchHslApi

-(instancetype)init {
    self = [super init];
    if (self) {
        self.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    }
    
    return self;
}

- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock {
    
    //TODO handle options
    NSDictionary *searchParameters = [@{} mutableCopy];
//    if (!optionsDict) {
//        searchParameters = [@{} mutableCopy];
//    } else {
//        searchParameters = [[self apiRequestParametersDictionaryForRouteOptions:optionsDict] mutableCopy];
//    }
    
    [searchParameters setValue:@"asacommuterwidget2" forKey:@"user"];
    [searchParameters setValue:@"rebekah" forKey:@"pass"];
    
    [searchParameters setValue:@"route" forKey:@"request"];
    [searchParameters setValue:@"4326" forKey:@"epsg_in"];
    [searchParameters setValue:@"4326" forKey:@"epsg_out"];
    [searchParameters setValue:@"json" forKey:@"format"];
    
    //    [optionsDict setValue:[WidgetHelpers convert2DCoordToString:fromCoords] forKey:@"from"];
    //    [optionsDict setValue:[WidgetHelpers convert2DCoordToString:toCoords] forKey:@"to"];
    
    [searchParameters setValue:[ReittiStringFormatterE convert2DCoordToString:fromCoords] forKey:@"from"];
    [searchParameters setValue:[ReittiStringFormatterE convert2DCoordToString:toCoords] forKey:@"to"];
    
    [super doApiFetchWithOutMappingWithParams:searchParameters andCompletionBlock:^(NSData *responseData, NSError *error){
        if (!error) {
            
//            for (RouteE *route in responseArray) {
//                route.routeLegs = [self mapRouteLegsFromArray:route.unMappedRouteLegs];
//                route.routeLength = [route.unMappedRouteLength objectAtIndex:0];
//                route.routeDurationInSeconds = [route.unMappedRouteDurationInSeconds objectAtIndex:0];
//                for (RouteLegE *leg in route.routeLegs) {
//                    @try {
//                        if (!leg.lineCode)
//                            continue;
//                        
//                        leg.lineName = [ReittiStringFormatterE parseBusNumFromLineCode:leg.lineCode];
//                    }
//                    @catch (NSException *exception) {
//                        leg.lineName = leg.lineCode;
//                    }
//                }
//            }
            
//            completionBlock(responseArray, nil);
        }else{
            completionBlock(nil, error);
        }
    }];

}

//Will come from parent app in the future.

//#pragma mark - Datasource value mapping
//
//-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(NSDictionary *)searchOptions{
//    NSMutableDictionary *parametersDict = [@{} mutableCopy];
//    
//    if (!searchOptions)
//        return parametersDict;
//    
//    /* Optimization string */
//    NSString *optimizeString;
//    if ((RouteSearchOptimization)searchOptions[@"selectedRouteSearchOptimization"] == RouteSearchOptionFastest) {
//        optimizeString = @"fastest";
//    }else if ((RouteSearchOptimization)searchOptions[@"selectedRouteSearchOptimization"] == RouteSearchOptionLeastTransfer) {
//        optimizeString = @"least_transfers";
//    }else if ((RouteSearchOptimization)searchOptions[@"selectedRouteSearchOptimization"] == RouteSearchOptionLeastWalking) {
//        optimizeString = @"least_walking";
//    }else{
//        optimizeString = @"default";
//    }
//    
//    [parametersDict setObject:optimizeString forKey:@"optimize"];
//    
//    /* Transport type */
//    if (searchOptions[@"selectedRouteTrasportTypes"] != nil) {
//        NSString *transportTypes;
//        NSArray *selectedTrasportTypes = searchOptions[@"selectedRouteTrasportTypes"];
//        if (selectedTrasportTypes.count == self.transportTypeOptions.allKeys.count)
//            transportTypes = @"all";
//        else if (selectedTrasportTypes.count == 0)
//            transportTypes = @"walk";
//        else {
//            NSMutableArray *selected = [@[] mutableCopy];
//            for (NSString *trans in selectedTrasportTypes) {
//                [selected addObject:[self.transportTypeOptions objectForKey:trans]];
//            }
//            transportTypes = [selected componentsJoinedByString:@"|"];
//        }
//        
//        [parametersDict setObject:transportTypes forKey:@"transport_types"];
//    }
//    
//    /* Ticket Zone */
//    if (searchOptions[@"selectedTicketZone"] != nil && ![searchOptions[@"selectedTicketZone"] isEqualToString:@"All HSL Regions (Default)"]) {
//        [parametersDict setObject:[self.ticketZoneOptions objectForKey:searchOptions[@"selectedTicketZone"]] forKey:@"zone"];
//    }
//    
//    /* Change Margine */
//    if (searchOptions[@"selectedChangeMargine"] != nil && ![searchOptions[@"selectedChangeMargine"] isEqualToString:@"3 minutes (Default)"]) {
//        [parametersDict setObject:[self.changeMargineOptions objectForKey:searchOptions[@"selectedChangeMargine"]] forKey:@"change_margin"];
//    }
//    
//    /* Walking Speed */
//    if (searchOptions[@"selectedWalkingSpeed"] != nil && ![searchOptions[@"selectedWalkingSpeed"] isEqualToString:@"Normal Walking (Default)"]) {
//        [parametersDict setObject:[self.walkingSpeedOptions objectForKey:searchOptions[@"selectedWalkingSpeed"]] forKey:@"walk_speed"];
//    }
//    
//    [parametersDict setObject:@"3" forKey:@"show"];
//    
//    //    if ([searchOptions[@"numberOfResults"] integerValue] == 5) {
//    //        [parametersDict setObject:@"5" forKey:@"show"];
//    //    }else{
//    //        [parametersDict setObject:[NSString stringWithFormat:@"%ld", (long)searchOptions[@"numberOfResults"]] forKey:@"show"];
//    //    }
//    
//    /* Options for all search */
//    //    [parametersDict setObject:@"full" forKey:@"detail"];
//    
//    return parametersDict;
//}
//
//-(NSDictionary *)transportTypeOptions{
//    return [HSLRouteOptionManager transportTypeOptions];
//}
//
//-(NSDictionary *)ticketZoneOptions{
//    return [HSLRouteOptionManager ticketZoneOptions];
//}
//
//-(NSDictionary *)changeMargineOptions{
//    return [HSLRouteOptionManager changeMargineOptions];
//}
//
//-(NSDictionary *)walkingSpeedOptions{
//    return [HSLRouteOptionManager walkingSpeedOptions];
//}


@end
