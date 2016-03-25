//
//  HSLandTRECommonApiClient.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLandTRECommonApiClient.h"
#import "RouteE.h"
#import "ReittiStringFormatterE.h"

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
    
    [optionsDict setValue:[WidgetHelpers convert2DCoordToString:fromCoords] forKey:@"from"];
    [optionsDict setValue:[WidgetHelpers convert2DCoordToString:toCoords] forKey:@"to"];
    
    [self.apiClient doApiFetchWithParams:optionsDict andCompletionBlock:^(NSData *responseData, NSError *error){
        if (!error) {
            NSError *localError = nil;
            NSArray *responseArray = [self routeFromJSON:responseData error:&localError];
            
            if (responseArray) {
                @try {
                    for (RouteE *route in responseArray) {
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
                }
                @catch (NSException *exception) {}
                completionBlock(responseArray, nil);
            }else{
                completionBlock(nil, localError);
            }
        }else{
            completionBlock(nil, error);
        }
    }];
}

-(NSArray *)routeFromJSON:(NSData *)data error:(NSError **)error{
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *routes = [[NSMutableArray alloc] init];
    @try {
        for (NSArray *routeDictionaryArray in parsedObject) {
            RouteE *route = [[RouteE alloc] init];
            
            NSArray *legsArray = [routeDictionaryArray[0] objectForKey:@"legs"];
            route.routeLegs = [self mapRouteLegsFromArray:legsArray];
            
            NSNumber *routeLengthArray = [routeDictionaryArray[0] objectForKey:@"length"];
            route.routeLength = routeLengthArray;
            
            NSNumber *routeDurationArray = [routeDictionaryArray[0] objectForKey:@"duration"];
            route.routeDurationInSeconds = routeDurationArray;
            
            [routes addObject:route];
        }
    }
    @catch (NSException *exception) {
        return nil;
    }
    
    return routes;
}

-(NSArray *)mapRouteLegsFromArray:(NSArray *)arrayResponse{
    NSMutableArray *legsArray = [[NSMutableArray alloc] init];
    int legOrder = 0;
    for (NSDictionary *legDict in arrayResponse) {
        RouteLegE *leg = [[RouteLegE alloc] initFromDictionary:legDict];
        leg.legOrder = legOrder;
        [legsArray addObject:leg];
        legOrder++;
    }
    
    return legsArray;
}

@end
