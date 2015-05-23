//
//  HslLiveCommunicator.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HslLiveCommunicator.h"

@implementation HslLiveCommunicator

- (void)VehiclesFetchFromHslLiveComplete:(NSData *)objectNotation{
    [self.delegate receivedVehiclesCSV:objectNotation];
}
- (void)VehiclesFetchFromHslLiveFailed:(NSError *)error{
    [self.delegate fetchingVehiclesFromHSLLiveFailedWithError:error];
}

- (void)dealloc
{
    NSLog(@"Communication:This bitchass ARC deleted my HSL Live API.");
}

@end
