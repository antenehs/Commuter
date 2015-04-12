//
//  TRECommunication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "BusStop.h"
#import "BusStopShort.h"
#import "LineInfo.h"
#import "GeoCode.h"
#import "Route.h"
#import "RouteLegs.h"
#import "RouteLeg.h"
#import "RouteLegLocation.h"
#import "Disruption.h"

@class TRECommunication;

@protocol TRECommunicationDelegate <NSObject>
- (void)treStopFetchDidComplete:(TRECommunication *)communicator;
- (void)treStopFetchFailed:(int)errorCode;
- (void)treStopInAreaFetchDidComplete:(TRECommunication *)communicator;
- (void)treStopInAreaFetchFailed:(int)errorCode;
- (void)treLineInfoFetchDidComplete:(TRECommunication *)communicator;
- (void)treLineInfoFetchFailed:(TRECommunication *)communicator;
- (void)treGeocodeSearchDidComplete:(TRECommunication *)communicator;
- (void)treGeocodeSearchFailed:(int)errorCode;
- (void)treRouteSearchDidComplete:(TRECommunication *)communicator;
- (void)treRouteSearchFailed:(int)errorCode;
- (void)treDisruptionFetchComplete:(TRECommunication *)communicator;
- (void)treDisruptionFetchFailed:(int)errorCode;
@end

@interface TRECommunication : NSObject

@end
