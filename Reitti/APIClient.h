//
//  Communication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 31/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "BusStop.h"
#import "BusStopShort.h"
#import "Line.h"
#import "GeoCode.h"
#import "Route.h"
#import "RouteLegs.h"
#import "RouteLeg.h"
#import "RouteLegLocation.h"
#import "Disruption.h"

typedef void (^ActionBlock)();

@interface APIClient : NSObject

-(id)init;

-(void)doApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass andCompletionBlock:(ActionBlock)completionBlock;
-(void)doApiFetchWithOutMappingWithParams:(NSDictionary *)params andCompletionBlock:(ActionBlock)completionBlock;

-(void)searchRouteForCoordinates:(NSString *)fromCoordinate andToCoordinate:(NSString *)toCoordinate andParams:(NSDictionary *)params;
-(void)searchGeocodeForKey:(NSString *)key;
-(void)searchAddressForCoordinate:(NSString *)coords;
-(void)getStopInfoForCode:(NSString *)code;
-(void)getStopsInArea:(CLLocationCoordinate2D)center forDiameter:(int)diameter;
-(void)getStopsFromPubTransInArea:(CLLocationCoordinate2D)center forDiameter:(int)diameter;
-(void)getDisruptions;
-(void)getLineInformation:(NSString *)codeList;

- (void)getAllLiveVehiclesFromPubTrans:(NSString *)lineCodes;
- (void)getAllLiveVehiclesFromHSLLive:(NSString *)lineCodes;


- (void)StopFetchDidComplete;
- (void)StopFetchFailed:(int)errorCode;
- (void)StopInAreaFetchDidComplete;
- (void)StopInAreaFetchFailed:(int)errorCode;
- (void)LineInfoFetchDidComplete:(NSData *)objectNotation;
- (void)LineInfoFetchFailed:(NSError *)error;
- (void)GeocodeSearchDidComplete;
- (void)GeocodeSearchFailed:(int)errorCode;
- (void)ReverseGeocodeSearchDidComplete;
- (void)ReverseGeocodeSearchFailed:(int)errorCode;
- (void)RouteSearchDidComplete;
- (void)RouteSearchFailed:(int)errorCode;
- (void)DisruptionFetchComplete;
- (void)DisruptionFetchFailed:(int)errorCode;
- (void)StopInAreaFetchFromPubtransDidComplete:(NSData *)objectNotation;
- (void)StopInAreaFetchFromPubtransFailed:(NSError *)error;
- (void)VehiclesFetchFromPubtransComplete:(NSData *)objectNotation;
- (void)VehiclesFetchFromPubtransFailed:(NSError *)error;
- (void)VehiclesFetchFromHslLiveComplete:(NSData *)objectNotation;
- (void)VehiclesFetchFromHslLiveFailed:(NSError *)error;

@property (nonatomic, strong) NSArray *stopList;
@property (nonatomic, strong) NSArray *nearByStopList;
@property (nonatomic, strong) NSArray *lineInfoList;
@property (nonatomic, strong) NSArray *geoCodeList;
@property (nonatomic, strong) NSArray *reverseGeoCodeList;
@property (nonatomic, strong) NSArray *routeList;
@property (nonatomic, strong) NSArray *disruptionList;
@property (nonatomic, strong) NSString *requestedKey;
@property (nonatomic, strong) NSString *apiBaseUrl;

@end
