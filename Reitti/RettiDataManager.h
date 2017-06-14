//
//  RettiDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "HSLCommunication.h"
#import "TRECommunication.h"
#import "MatkaCommunicator.h"
#import "ReittiStringFormatter.h"
#import "BusStop.h"
#import "RouteSearchOptions.h"
#import "FailedGeoCodeFetch.h"
#import "HSLLiveTrafficManager.h"
#import "TRELiveTrafficManager.h"
#import "CacheManager.h"
#import "ReittiAnalyticsManager.h"
#import "ReittiRegionManager.h"
#import "RTStopSearchParam.h"

@class RouteEntity;
@class RouteHistoryEntity;
@class NamedBookmark;
@class FailedGeoCodeFetch;
@class HSLLiveTrafficManager;

extern NSString * const kBookmarksWithAnnotationUpdated;

@interface RettiDataManager : NSObject {
    NSMutableArray *HSLGeocodeResposeQueue;
    NSMutableArray *TREGeocodeResponseQueue;
}

+(id)sharedManager;
-(id)init;

-(void)resetResponseQueues;

/* Annotation filtering */
-(NSArray *)annotationFilterOptions;

/* Route search options */
-(NSArray *)allTrasportTypeNames;
-(NSArray *)getTransportTypeOptions;
-(NSArray *)getDefaultTransportTypeNames;

-(NSArray *)getTicketZoneOptions;
-(NSInteger)getDefaultValueIndexForTicketZoneOptions;

-(NSArray *)getChangeMargineOptions;
-(NSInteger)getDefaultValueIndexForChangeMargineOptions;

-(NSArray *)getWalkingSpeedOptions;
-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;

/* API fetch methods */
//Fetch routes
-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andSearchOption:(RouteSearchOptions *)searchOptions andNumberOfResult:(NSNumber *)numberOfResult andCompletionBlock:(ActionBlock)completionBlock;
-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andCompletionBlock:(ActionBlock)completionBlock;
-(void)getFirstRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andCompletionBlock:(ActionBlock)completionBlock;

//Fetch stops
-(void)fetchStopsForSearchParams:(RTStopSearchParam *)searchParams andCoords:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchStopsForSearchParams:(RTStopSearchParam *)searchParams fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;

//Fetch Stops in area
-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;

//Search address
-(void)searchAddressesForKey:(NSString *)key withCompletionBlock:(ActionBlock)completionBlock;
-(void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock;

//Fetch lines
-(void)fetchLinesForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchLinesForSearchTerm:(NSString *)searchTerm fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchLinesForLineCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchLinesForLineCodes:(NSArray *)lineCodes fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;

//Fetch disruptions
-(void)fetchDisruptionsWithCompletionBlock:(ActionBlock)completionBlock;

//Fetch bike stations
-(void)startFetchingBikeStationsWithCompletionBlock:(ActionBlock)completionBlock;
-(void)stopUpdatingBikeStations;

//Fetch live vehicles
-(void)fetchAllLiveVehiclesWithCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler;
-(void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler;
-(void)stopFetchingLiveVehicles;

@property (nonatomic) Region userLocationRegion;

@end
