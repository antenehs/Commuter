//
//  HSLandTRECommonApiClient.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLandTRECommonApiClient.h"
#import "RouteE.h"
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
            NSError *error = nil;
            NSArray *responseArray = [self routeFromJSON:responseData error:&error];
            
            if (responseArray) {
                completionBlock(responseArray, nil);
            }else{
                completionBlock(nil, error);
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
            NSLog(@"route length is %@", route.routeLength);
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
        //NSLog(@"a dictionary %@",legDict);
        RouteLegE *leg = [[RouteLegE alloc] initFromDictionary:legDict];
        leg.legOrder = legOrder;
        [legsArray addObject:leg];
        legOrder++;
    }
    
    return legsArray;
}

@end
