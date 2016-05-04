//
//  ApiProtocols.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "RouteSearchOptions.h"
//#import "Route.h"

typedef void (^ActionBlock)();

typedef enum
{
    ReittiAutomaticApi = 0, //Api calculated based on request property
    ReittiCurrentRegionApi = 1, //Api favored for the current user location
    ReittiHSLApi = 100,
    ReittiTREApi = 200,
    ReittiMatkaApi = 300
} ReittiApi;

@protocol RouteSearchProtocol <NSObject>
- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol StopsInAreaSearchProtocol <NSObject>
- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol StopDetailFetchProtocol <NSObject>
- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol LineDetailFetchProtocol <NSObject>
- (void)fetchLinesForSearchterm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock;
- (void)fetchLinesForCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol GeocodeProtocol <NSObject>
- (void)searchGeocodeForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol ReverseGeocodeProtocol <NSObject>
- (void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol DisruptionFetchProtocol <NSObject>
- (void)fetchTrafficDisruptionsWithCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol RouteSearchOptionProtocol <NSObject>
-(NSArray *)allTrasportTypeNames;

-(NSArray *)getTransportTypeOptions;
-(NSArray *)getTicketZoneOptions;
-(NSArray *)getChangeMargineOptions;
-(NSArray *)getWalkingSpeedOptions;

-(NSInteger)getDefaultValueIndexForTicketZoneOptions;
-(NSInteger)getDefaultValueIndexForChangeMargineOptions;
-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;
@end

@protocol LiveTrafficFetchProtocol <NSObject>
- (void)startFetchingAllLiveVehiclesWithCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler;
- (void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler;
- (void)stopFetchingVehicles;
@end

