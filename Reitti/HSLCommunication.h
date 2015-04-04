//
//  HSLCommunication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 31/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
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
- (void)hslRouteSearchDidComplete:(HSLCommunication *)communicator;
- (void)hslRouteSearchFailed:(int)errorCode;
- (void)hslDisruptionFetchComplete:(HSLCommunication *)communicator;
- (void)hslDisruptionFetchFailed:(int)errorCode;
@end

@interface HSLCommunication : NSObject

-(id)init;
-(void)searchRouteForCoordinates:(NSString *)fromCoordinate andToCoordinate:(NSString *)toCoordinate  time:(NSString *)time andDate:(NSString *)date andTimeType:(NSString *)timeType andOptimize:(NSString *)optimize numberOfResults:(int)numOfResults;
-(void)searchGeocodeForKey:(NSString *)key;
-(void)getStopInfoForCode:(NSString *)code;
-(void)getStopsInArea:(CLLocationCoordinate2D)center forDiameter:(int)diameter;
-(void)getDisruptions;
-(void)getLineInformation:(NSString *)codeList;

@property (nonatomic, strong) NSArray *stopList;
@property (nonatomic, strong) NSArray *nearByStopList;
@property (nonatomic, strong) NSArray *lineInfoList;
@property (nonatomic, strong) NSArray *geoCodeList;
@property (nonatomic, strong) NSArray *routeList;
@property (nonatomic, strong) NSArray *disruptionList;
@property (nonatomic, strong) NSString *requestedKey;

@property (nonatomic, weak) id <HSLCommunicationDelegate> delegate;

@end
