//
//  HSLCommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLCommunication.h"

@implementation HSLCommunication

@synthesize delegate;

-(id)init{
    super.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    return self;
}

#pragma mark - overriden methods
- (void)StopFetchDidComplete{
    [delegate hslStopFetchDidComplete:self];
}
- (void)StopFetchFailed:(int)errorCode{
    [self.delegate hslStopFetchFailed:errorCode];
}
- (void)StopInAreaFetchDidComplete{
    [delegate hslStopInAreaFetchDidComplete:self];
}
- (void)StopInAreaFetchFailed:(int)errorCode{
    [self.delegate hslStopInAreaFetchFailed:errorCode];
}
- (void)LineInfoFetchDidComplete{
    [delegate hslLineInfoFetchDidComplete:self];
}
- (void)LineInfoFetchFailed{
    [delegate hslLineInfoFetchFailed:self];
}
- (void)GeocodeSearchDidComplete{
    [delegate hslGeocodeSearchDidComplete:self];
}
- (void)GeocodeSearchFailed:(int)errorCode{
    [self.delegate hslGeocodeSearchFailed:errorCode];
}
- (void)ReverseGeocodeSearchDidComplete{
    [self.delegate hslReverseGeocodeSearchDidComplete:self];
}
- (void)ReverseGeocodeSearchFailed:(int)errorCode{
    [self.delegate hslReverseGeocodeSearchFailed:errorCode];
}
- (void)RouteSearchDidComplete{
    [delegate hslRouteSearchDidComplete:self];
}
- (void)RouteSearchFailed:(int)errorCode{
    [self.delegate hslRouteSearchFailed:errorCode];
}
- (void)DisruptionFetchComplete{
    [delegate hslDisruptionFetchComplete:self];
}
- (void)DisruptionFetchFailed:(int)errorCode{
    [self.delegate hslDisruptionFetchFailed:errorCode];
}

@end
