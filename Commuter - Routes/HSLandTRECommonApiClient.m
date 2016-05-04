//
//  HSLandTRECommonApiClient.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLandTRECommonApiClient.h"
#import "RouteE.h"
#import "BusStopE.h"
#import "ReittiStringFormatterE.h"
#import "ReittiStringFormatter.h"

@interface HSLandTRECommonApiClient ()

@end

@implementation HSLandTRECommonApiClient

- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock {
    
    if (!optionsDict) {
        optionsDict = [@{} mutableCopy];
    }
    
    [optionsDict setValue:@"route" forKey:@"request"];
    [optionsDict setValue:@"4326" forKey:@"epsg_in"];
    [optionsDict setValue:@"4326" forKey:@"epsg_out"];
    [optionsDict setValue:@"json" forKey:@"format"];
    
//    [optionsDict setValue:[WidgetHelpers convert2DCoordToString:fromCoords] forKey:@"from"];
//    [optionsDict setValue:[WidgetHelpers convert2DCoordToString:toCoords] forKey:@"to"];
    
    [optionsDict setValue:[ReittiStringFormatter convert2DCoordToString:fromCoords] forKey:@"from"];
    [optionsDict setValue:[ReittiStringFormatter convert2DCoordToString:toCoords] forKey:@"to"];
    
    NSDictionary *mappingDict = @{
                                  @"length" : @"unMappedRouteLength",
                                  @"duration" : @"unMappedRouteDurationInSeconds",
                                  @"legs" : @"unMappedRouteLegs"
                                  };
    
    [self.apiClient doJsonApiFetchWithParams:optionsDict mappingDictionary:mappingDict mapToClass:[RouteE class] mapKeyPath:@"" andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error) {
            
            for (RouteE *route in responseArray) {
                route.routeLegs = [self mapRouteLegsFromArray:route.unMappedRouteLegs];
                route.routeLength = [route.unMappedRouteLength objectAtIndex:0];
                route.routeDurationInSeconds = [route.unMappedRouteDurationInSeconds objectAtIndex:0];
                for (RouteLegE *leg in route.routeLegs) {
                    @try {
                        if (!leg.lineCode)
                            continue;

                        leg.lineName = [ReittiStringFormatterE parseBusNumFromLineCode:leg.lineCode];
                    }
                    @catch (NSException *exception) {
                        leg.lineName = leg.lineCode;
                    }
                }
            }
        
            completionBlock(responseArray, nil);
        }else{
            completionBlock(nil, error);
        }
    }];
}

//-(NSArray *)routeFromJSON:(NSData *)data error:(NSError **)error{
//    NSError *localError = nil;
//    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
//    
//    if (localError != nil) {
//        *error = localError;
//        return nil;
//    }
//    
//    NSMutableArray *routes = [[NSMutableArray alloc] init];
//    @try {
//        for (NSArray *routeDictionaryArray in parsedObject) {
//            RouteE *route = [[RouteE alloc] init];
//            
//            NSArray *legsArray = [routeDictionaryArray[0] objectForKey:@"legs"];
//            route.routeLegs = [self mapRouteLegsFromArray:legsArray];
//            
//            NSNumber *routeLengthArray = [routeDictionaryArray[0] objectForKey:@"length"];
//            route.routeLength = routeLengthArray;
//            
//            NSNumber *routeDurationArray = [routeDictionaryArray[0] objectForKey:@"duration"];
//            route.routeDurationInSeconds = routeDurationArray;
//            
//            [routes addObject:route];
//        }
//    }
//    @catch (NSException *exception) {
//        return nil;
//    }
//    
//    return routes;
//}

-(NSArray *)mapRouteLegsFromArray:(NSArray *)arrayResponse{
    NSMutableArray *legsArray = [[NSMutableArray alloc] init];
    int legOrder = 0;
    for (NSDictionary *legDict in [arrayResponse objectAtIndex:0]) {
        RouteLegE *leg = [[RouteLegE alloc] initFromDictionary:legDict];
        leg.legOrder = legOrder;
        [legsArray addObject:leg];
        legOrder++;
    }
    
    return legsArray;
}

#pragma mark - Stop searching
- (void)fetchStopForCode:(NSString *)code withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock{
    
    if (!optionsDict) {
        optionsDict = [@{} mutableCopy];
    }
    
    [optionsDict setValue:@"stop" forKey:@"request"];
    [optionsDict setValue:@"4326" forKey:@"epsg_in"];
    [optionsDict setValue:@"4326" forKey:@"epsg_out"];
    [optionsDict setValue:@"json" forKey:@"format"];
    [optionsDict setValue:@"20" forKey:@"dep_limit"];
    [optionsDict setValue:@"360" forKey:@"time_limit"];
    
    [optionsDict setValue:code forKey:@"code"];
    
    NSDictionary *mappingDict = @{
                                  @"code" : @"code",
                                  @"code_short" : @"code_short",
                                  @"name_fi" : @"name_fi",
                                  @"city_fi" : @"city_fi",
                                  @"lines" : @"lines",
                                  @"departures" : @"departures",
                                  @"address_fi" : @"address_fi",
                                  };
    
    [self.apiClient doJsonApiFetchWithParams:optionsDict mappingDictionary:mappingDict mapToClass:[BusStopE class] mapKeyPath:@"" andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error && responseArray && responseArray.count > 0) {
            completionBlock(responseArray[0], nil);
        }else{
            completionBlock(nil, @"Stop fetch failed");
        }
    }];
}

@end
