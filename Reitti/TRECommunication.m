//
//  TRECommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "TRECommunication.h"

@implementation TRECommunication

@synthesize delegate;

-(id)init{
    super.apiBaseUrl = @"http://api.publictransport.tampere.fi/1_0_3/";
    return self;
}

#pragma mark - overriden methods
- (void)StopFetchDidComplete{
    [delegate treStopFetchDidComplete:self];
}
- (void)StopFetchFailed:(int)errorCode{
    [self.delegate treStopFetchFailed:errorCode];
}
- (void)StopInAreaFetchDidComplete{
    [delegate treStopInAreaFetchDidComplete:self];
}
- (void)StopInAreaFetchFailed:(int)errorCode{
    [self.delegate treStopInAreaFetchFailed:errorCode];
}
- (void)LineInfoFetchDidComplete{
    [delegate treLineInfoFetchDidComplete:self];
}
- (void)LineInfoFetchFailed{
    [delegate treLineInfoFetchFailed:self];
}
- (void)GeocodeSearchDidComplete{
    [delegate treGeocodeSearchDidComplete:self];
}
- (void)GeocodeSearchFailed:(int)errorCode{
    [self.delegate treGeocodeSearchFailed:errorCode];
}
- (void)ReverseGeocodeSearchDidComplete{
    [self.delegate treReverseGeocodeSearchDidComplete:self];
}
- (void)ReverseGeocodeSearchFailed:(int)errorCode{
    [self.delegate treReverseGeocodeSearchFailed:errorCode];
}
- (void)RouteSearchDidComplete{
    [delegate treRouteSearchDidComplete:self];
}
- (void)RouteSearchFailed:(int)errorCode{
    [self.delegate treRouteSearchFailed:errorCode];
}
- (void)DisruptionFetchComplete{
    [delegate treDisruptionFetchComplete:self];
}
- (void)DisruptionFetchFailed:(int)errorCode{
    [self.delegate treDisruptionFetchFailed:errorCode];
}

@end
