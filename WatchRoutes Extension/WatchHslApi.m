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
#import "Route.h"

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
            NSArray *routes = [self routesFromJSON:responseData error:nil];
            completionBlock(routes, nil);
        }else{
            completionBlock(nil, error);
        }
    }];

}

-(NSArray *)routesFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *routes = [[NSMutableArray alloc] init];
    
    for (NSArray *routeArray in parsedObject) {
        for (NSDictionary *routeDict in routeArray) {
            Route *route = [[Route alloc] init];
            route.routeDurationInSeconds = [self objectOrNilForKey:@"duration" fromDictionary:routeDict];
            route.routeLength = [self objectOrNilForKey:@"length" fromDictionary:routeDict];
            NSArray *legsArray = [self objectOrNilForKey:@"legs" fromDictionary:routeDict];
            if (!legsArray) continue;
            
            route.routeLegs = [self mapRouteLegsFromArray:legsArray];
            
            @try {
                for (RouteLeg *leg in route.routeLegs) {
                    @try {
                        if (!leg.lineCode)
                            continue;
                        
                        leg.lineName = [WatchHslApi parseBusNumFromLineCode:leg.lineCode];
                    }
                    @catch (NSException *exception) {
                        leg.lineName = leg.lineCode;
                    }
                }
            }
            @catch (NSException *exception) {}
            
            [routes addObject:route];
            
            break;
        }
    }
    
    return routes;
}

-(NSArray *)mapRouteLegsFromArray:(NSArray *)arrayResponse{
    NSMutableArray *legsArray = [[NSMutableArray alloc] init];
    int legOrder = 0;
    for (NSDictionary *legDict in arrayResponse) {
        //NSLog(@"a dictionary %@",legDict);
        RouteLeg *leg = [[RouteLeg alloc] initFromHSLandTREDictionary:legDict];
        leg.legOrder = legOrder;
        [legsArray addObject:leg];
        legOrder++;
    }
    
    return legsArray;
}


- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
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


//Expected format is XXXX(X) X
//Parsing logic https://github.com/HSLdevcom/navigator-proto/blob/master/src/routing.coffee#L40
//Original logic - http://developer.reittiopas.fi/pages/en/http-get-interface/frequently-asked-questions.php
+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode{
    //TODO: Test with 1230 for weird numbers of the same 24 bus.
    //    NSArray *codes = [lineCode componentsSeparatedByString:@" "];
    //    NSString *code = [codes objectAtIndex:0];
    
    //Line codes from HSL live could be only 4 characters
    if (lineCode.length < 4)
        return lineCode;
    
    //Can be assumed a metro
    if ([lineCode hasPrefix:@"1300"])
        return @"Metro";
    
    //Can be assumed a ferry
    if ([lineCode hasPrefix:@"1019"])
        return @"Ferry";
    
    //Can be assumed a train line
    if (([lineCode hasPrefix:@"3001"] || [lineCode hasPrefix:@"3002"]) && lineCode.length > 4) {
        NSString * trainLineCode = [lineCode substringWithRange:NSMakeRange(4, 1)];
        if (trainLineCode != nil && trainLineCode.length > 0)
            return trainLineCode;
    }
    
    //2-4. character = line code (e.g. 102)
    NSString *codePart = [lineCode substringWithRange:NSMakeRange(1, 3)];
    while ([codePart hasPrefix:@"0"]) {
        codePart = [codePart substringWithRange:NSMakeRange(1, codePart.length - 1)];
    }
    
    if (lineCode.length <= 4)
        return codePart;
    
    //5 character = letter variant (e.g. T)
    NSString *firstLetterVariant = [lineCode substringWithRange:NSMakeRange(4, 1)];
    if ([firstLetterVariant isEqualToString:@" "])
        return codePart;
    
    if (lineCode.length <= 5)
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    //6 character = letter variant or numeric variant (ignore number variant)
    NSString *secondLetterVariant = [lineCode substringWithRange:NSMakeRange(5, 1)];
    if ([secondLetterVariant isEqualToString:@" "] || [secondLetterVariant intValue])
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    return [NSString stringWithFormat:@"%@%@%@", codePart, firstLetterVariant, secondLetterVariant];
}


@end
