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

- (void)VehiclesFetchComplete:(NSData *)objectNotation{
    [self.delegate receivedGeoJSON:objectNotation];
}
- (void)VehiclesFetchFailed:(NSError *)error{
    [self.delegate fetchingVehiclesFailedWithError:error];
}

- (void)dealloc
{
    NSLog(@"Communication:This bitchass ARC deleted my PubTransAPI.");
}

@end
