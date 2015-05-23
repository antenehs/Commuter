//
//  PubTransAPI.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "PubTransCommunicator.h"

@implementation PubTransCommunicator

@synthesize delegate;

- (id)init {
    return  self;
}

- (void)VehiclesFetchFromPubtransComplete:(NSData *)objectNotation{
    [self.delegate receivedGeoJSON:objectNotation];
}
- (void)VehiclesFetchFromPubtransFailed:(NSError *)error{
    [self.delegate fetchingVehiclesFromPubTransFailedWithError:error];
}

- (void)dealloc
{
    NSLog(@"Communication:This bitchass ARC deleted my PubTransAPI.");
}

@end
