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
#import "NamedBookmark.h"
#import "RouteSearchOptions.h"
#import "FailedGeoCodeFetch.h"
#import "HSLLiveTrafficManager.h"
#import "TRELiveTrafficManager.h"
#import "CacheManager.h"
#import "ReittiAnalyticsManager.h"
#import "ICloudManager.h"
#import "ReittiRegionManager.h"
#import "RTStopSearchParam.h"
#import "WatchCommunicationManager.h"

@class StopEntity;
@class HistoryEntity;
@class RouteEntity;
@class RouteHistoryEntity;
@class CookieEntity;
@class NamedBookmark;
@class FailedGeoCodeFetch;
@class HSLLiveTrafficManager;

//extern CLLocationCoordinate2D kHslRegionCenter;
//extern CLLocationCoordinate2D kTreRegionCenter;

extern NSString * const kBookmarksWithAnnotationUpdated;

@interface RettiDataManager : NSObject {
    int nextObjectLID;
    
    NSMutableArray *HSLGeocodeResposeQueue;
    NSMutableArray *TREGeocodeResponseQueue;
}

+(id)sharedManager;
-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

-(void)resetResponseQueues;

//+(CLLocationCoordinate2D)getCoordinateForRegion:(Region)region;

/* Annotation filtering */
-(NSArray *)annotationFilterOptions;

/* Route search options */
-(NSArray *)allTrasportTypeNames;

-(NSArray *)getTransportTypeOptions;
-(NSArray *)getTicketZoneOptions;
-(NSArray *)getChangeMargineOptions;
-(NSArray *)getWalkingSpeedOptions;

-(NSInteger)getDefaultValueIndexForTicketZoneOptions;
-(NSInteger)getDefaultValueIndexForChangeMargineOptions;
-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;

/* API fetch methods */
-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andSearchOption:(RouteSearchOptions *)searchOptions andNumberOfResult:(NSNumber *)numberOfResult andCompletionBlock:(ActionBlock)completionBlock;
-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andCompletionBlock:(ActionBlock)completionBlock;
-(void)getFirstRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andCompletionBlock:(ActionBlock)completionBlock;



-(void)fetchStopsForSearchParams:(RTStopSearchParam *)searchParams andCoords:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchStopsForSearchParams:(RTStopSearchParam *)searchParams fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;



-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;



-(void)searchAddressesForKey:(NSString *)key withCompletionBlock:(ActionBlock)completionBlock;
-(void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock;



-(void)fetchLinesForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchLinesForSearchTerm:(NSString *)searchTerm fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchLinesForLineCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchLinesForLineCodes:(NSArray *)lineCodes fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;



-(void)fetchDisruptionsWithCompletionBlock:(ActionBlock)completionBlock;


-(void)startFetchingBikeStationsWithCompletionBlock:(ActionBlock)completionBlock;
-(void)stopUpdatingBikeStations;


-(void)updateOrderedManagedObjectOrderTo:(NSArray *)orderedObjects;

-(BOOL)isBusStopSaved:(BusStop *)stop;
-(BOOL)isBusStopSavedWithCode:(NSNumber *)stopCode;
-(BOOL)isRouteSaved:(NSString *)fromString andTo:(NSString *)toString;
-(BOOL)doesNamedBookmarkExistWithName:(NSString *)name;

-(void)saveToCoreDataStop:(BusStop *)stop;
-(void)deleteSavedStopForCode:(NSNumber *)code;
-(void)deleteSavedStop:(StopEntity *)savedStop;
-(void)deleteAllSavedStop;
-(NSArray *)fetchAllSavedStopsFromCoreData;
-(StopEntity *)fetchSavedStopFromCoreDataForCode:(NSNumber *)code;
-(void)updateSavedStopsDefaultValueForStops:(NSArray *)savedStops;

-(BOOL)saveHistoryToCoreDataStop:(BusStop *)stop;
-(void)deleteHistoryStopForCode:(NSNumber *)code;
-(void)deleteAllHistoryStop;
-(NSArray *)fetchAllSavedStopHistoryFromCoreData;

-(void)clearHistoryOlderThanDays:(int)numOfDays;

-(void)saveRouteToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation andToCoords:(NSString *)toCoords;
-(void)deleteSavedRouteForCode:(NSString *)code;
-(void)deleteAllSavedroutes;
-(RouteEntity *)fetchSavedRouteFromCoreDataForCode:(NSString *)code;
-(NSArray *)fetchAllSavedRoutesFromCoreData;

-(BOOL)saveRouteHistoryToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation toCoords:(NSString *)toCoords;
-(void)deleteHistoryRouteForCode:(NSString *)code;
-(void)deleteAllHistoryRoutes;
-(NSArray *)fetchAllSavedRouteHistoryFromCoreData;

-(NamedBookmark *)saveNamedBookmarkToCoreData:(NamedBookmark *)namedBookmark;
-(NamedBookmark *)createOrUpdateNamedBookmarkFromICLoudRecord:(CKRecord *)record;
-(NamedBookmark *)updateNamedBookmarkToCoreDataWithID:(NSNumber *)objectLid withNamedBookmark:(NamedBookmark *)ndBookmark;
-(void)deleteNamedBookmarkForName:(NSString *)name;
-(void)deleteAllNamedBookmarks;
-(NSArray *)fetchAllSavedNamedBookmarksFromCoreData;
-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForName:(NSString *)name;
-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForCoords:(NSString *)coords;



-(void)fetchallBookmarksFromICloudWithCompletionHandler:(ActionBlock)completionHandler;
-(void)deleteAllBookmarksFromICloudWithCompletionHandler:(ActionBlock)completionHandler;

+(NSString *)generateUniqueRouteNameFor:(NSString *)fromLoc andToLoc:(NSString *)toLoc;

-(void)fetchAllLiveVehiclesWithCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler;
-(void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler;
-(void)stopFetchingLiveVehicles;

-(BOOL)doVersion4_1CoreDataMigration;
-(void)doVersion16CoreDataMigration;

@property (strong, nonatomic) NSMutableArray *allHistoryStopCodes;
@property (strong, nonatomic) NSMutableArray *allSavedStopCodes;
@property (strong, nonatomic) NSMutableArray *allSavedRouteCodes;
@property (strong, nonatomic) NSMutableArray *allRouteHistoryCodes;
@property (strong, nonatomic) NSMutableArray *allNamedBookmarkNames;

@property (strong, nonatomic) HSLCommunication *hslCommunication;
@property (strong, nonatomic) TRECommunication *treCommunication;
@property (strong, nonatomic) MatkaCommunicator *matkaCommunicator;

@property (strong, nonatomic) StopEntity *stopEntity;
@property (strong, nonatomic) HistoryEntity *historyEntity;
@property (strong, nonatomic) RouteEntity *routeEntity;
@property (strong, nonatomic) RouteHistoryEntity *routeHistoryEntity;
@property (strong, nonatomic) CookieEntity *cookieEntity;
@property (strong, nonatomic) NamedBookmark *namedBookmark;

@property (nonatomic) Region userLocationRegion;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, strong) HSLLiveTrafficManager *hslLiveTrafficManager;
@property(nonatomic, strong) TRELiveTrafficManager *treLiveTrafficManager;
@property(nonatomic, strong) CacheManager *cacheManager;
@property(nonatomic, strong) WatchCommunicationManager *communicationManager;

@end
