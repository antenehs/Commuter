//
//  HSLCommunication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"

@class HSLCommunication;

@protocol HSLCommunicationDelegate <NSObject>
- (void)hslStopFetchDidComplete:(HSLCommunication *)communicator;
- (void)hslStopFetchFailed:(int)errorCode;
- (void)hslStopInAreaFetchDidComplete:(HSLCommunication *)communicator;
- (void)hslStopInAreaFetchFailed:(int)errorCode;
- (void)hslLineInfoFetchDidComplete:(HSLCommunication *)communicator;
- (void)hslLineInfoFetchFailed:(HSLCommunication *)communicator;
- (void)hslGeocodeSearchDidComplete:(HSLCommunication *)communicator;
- (void)hslGeocodeSearchFailed:(int)errorCode;
- (void)hslReverseGeocodeSearchDidComplete:(HSLCommunication *)communicator;
- (void)hslReverseGeocodeSearchFailed:(int)errorCode;
- (void)hslRouteSearchDidComplete:(HSLCommunication *)communicator;
- (void)hslRouteSearchFailed:(int)errorCode;
- (void)hslDisruptionFetchComplete:(HSLCommunication *)communicator;
- (void)hslDisruptionFetchFailed:(int)errorCode;
@end

@interface HSLCommunication : APIClient

@property (nonatomic, weak) id <HSLCommunicationDelegate> delegate;

@end
