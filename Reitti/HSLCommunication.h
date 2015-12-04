//
//  HSLCommunication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"
#import "RouteSearchOptions.h"

@class HSLCommunication;

@protocol HSLCommunicationDelegate <NSObject>
- (void)hslStopFetchDidComplete:(HSLCommunication *)communicator;
- (void)hslStopFetchFailed:(int)errorCode;
- (void)hslStopInAreaFetchDidComplete:(HSLCommunication *)communicator;
- (void)hslStopInAreaFetchFailed:(int)errorCode;
- (void)hslLineInfoFetchDidComplete:(NSArray *)lines;
- (void)hslLineInfoFetchFailed:(NSError *)erro;
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

+(NSArray *)allTrasportTypeNames;

+(NSArray *)getTransportTypeOptions;
+(NSArray *)getTicketZoneOptions;
+(NSArray *)getChangeMargineOptions;
+(NSArray *)getWalkingSpeedOptions;

+(NSInteger)getDefaultValueIndexForTicketZoneOptions;
+(NSInteger)getDefaultValueIndexForChangeMargineOptions;
+(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions;

@property (nonatomic, weak) id <HSLCommunicationDelegate> delegate;

@end
