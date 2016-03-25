//
//  PubTransAPI.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "PubTransCommunicator.h"
#import "NearByStop.h"

@implementation PubTransCommunicator

//@synthesize delegate;

- (void)StopInAreaFetchFromPubtransDidComplete:(NSData *)objectNotation{
    NSError *error = nil;
    NSArray *stops = [PubTransCommunicator stopsFromJSON:objectNotation error:&error];
    
    if (error != nil) {
//        [self.delegate fetchingStopsFromPubTransFailedWithError:error];
        
    } else {
//        [self.delegate receivedStopsFromPubTrans:stops];
    }
}
- (void)StopInAreaFetchFromPubtransFailed:(NSError *)error{
//    [self.delegate fetchingStopsFromPubTransFailedWithError:error];
}

- (void)VehiclesFetchFromPubtransComplete:(NSData *)objectNotation{
//    [self.delegate receivedGeoJSON:objectNotation];
}
- (void)VehiclesFetchFromPubtransFailed:(NSError *)error{
//    [self.delegate fetchingVehiclesFromPubTransFailedWithError:error];
}

#pragma mark - Helper methods
+ (NSArray *)stopsFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    
    NSArray *results = [parsedObject valueForKey:@"features"];
    
    for (NSDictionary *featureDict in results) {
        NearByStop *stop = [[NearByStop alloc] initWithDictionary:featureDict];
        
        [stops addObject:stop];
    }
    
    return stops;
}

@end
