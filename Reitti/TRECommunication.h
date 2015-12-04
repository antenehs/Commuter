//
//  TRECommunication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"
#import "RouteSearchOptions.h"

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
- (void)treReverseGeocodeSearchDidComplete:(TRECommunication *)communicator;
- (void)treReverseGeocodeSearchFailed:(int)errorCode;
- (void)treRouteSearchDidComplete:(TRECommunication *)communicator;
- (void)treRouteSearchFailed:(int)errorCode;
- (void)treDisruptionFetchComplete:(TRECommunication *)communicator;
- (void)treDisruptionFetchFailed:(int)errorCode;
@end

@interface TRECommunication : APIClient

+(NSArray *)allTrasportTypeNames;

+(NSArray *)getTransportTypeOptions;
+(NSArray *)getTicketZoneOptions;
+(NSArray *)getChangeMargineOptions;
+(NSArray *)getWalkingSpeedOptions;

+(NSInteger)getDefaultValueIndexForTicketZoneOptions;
+(NSInteger)getDefaultValueIndexForChangeMargineOptions;
+(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions;

@property (nonatomic, weak) id <TRECommunicationDelegate> delegate;

@end
