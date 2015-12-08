//
//  HSLAndTRECommon.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLAndTRECommon.h"
#import "ReittiStringFormatter.h"

@implementation HSLAndTRECommon

-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptionsDictionary:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock{
    
    [optionsDict setValue:@"route" forKey:@"request"];
    [optionsDict setValue:@"4326" forKey:@"epsg_in"];
    [optionsDict setValue:@"4326" forKey:@"epsg_out"];
    [optionsDict setValue:@"json" forKey:@"format"];
    
    //TODO: Select from list
    [optionsDict setValue:@"asacommuterstops" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [optionsDict setValue:[ReittiStringFormatter convert2DCoordToString:fromCoords] forKey:@"from"];
    [optionsDict setValue:[ReittiStringFormatter convert2DCoordToString:toCoords] forKey:@"to"];
    
    NSDictionary *mappingDict = @{
                                  @"length" : @"unMappedRouteLength",
                                  @"duration" : @"unMappedRouteDurationInSeconds",
                                  @"legs" : @"unMappedRouteLegs"
                                  };
    
    [super doApiFetchWithParams:optionsDict mappingDictionary:mappingDict andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error) {
            for (Route *route in responseArray) {
                route.routeLegs = [self mapRouteLegsFromArray:route.unMappedRouteLegs];
                NSLog(@"route length is %@", route.routeLength);
                route.routeLength = [route.unMappedRouteLength objectAtIndex:0];
                route.routeDurationInSeconds = [route.unMappedRouteDurationInSeconds objectAtIndex:0];
            }
            
            
        }
        completionBlock(responseArray, error);
    }];
}

-(NSArray *)mapRouteLegsFromArray:(NSArray *)arrayResponse{
    NSMutableArray *legsArray = [[NSMutableArray alloc] init];
    int legOrder = 0;
    for (NSDictionary *legDict in [arrayResponse objectAtIndex:0]) {
        //NSLog(@"a dictionary %@",legDict);
        RouteLeg *leg = [[RouteLeg alloc] initFromDictionary:legDict];
        leg.legOrder = legOrder;
        [legsArray addObject:leg];
        legOrder++;
    }
    
    return legsArray;
}

@end
