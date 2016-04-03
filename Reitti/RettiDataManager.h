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

@class StopEntity;
@class HistoryEntity;
@class RouteEntity;
@class RouteHistoryEntity;
@class CookieEntity;
@class NamedBookmark;
@class FailedGeoCodeFetch;
@class SettingsEntity;
@class HSLLiveTrafficManager;

typedef enum
{
    HSLRegion = 0,
    TRERegion = 1,
    HSLandTRERegion = 2,
    OtherRegion = 3
} Region;

typedef struct {
    CLLocationCoordinate2D topLeftCorner;
    CLLocationCoordinate2D bottomRightCorner;
} RTCoordinateRegion;

@interface RettiDataManager : NSObject {
    int nextObjectLID;
    
    Region geoCodeRequestPrioritizedFor;
    
    NSMutableArray *HSLGeocodeResposeQueue;
    NSMutableArray *TREGeocodeResponseQueue;
}

+(id)sharedManager;
-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context;
-(void)setUserLocationToCoords:(CLLocationCoordinate2D)coords;
-(Region)getRegionForCoords:(CLLocationCoordinate2D)coords;
-(BOOL)isCoordinateInCurrentRegion:(CLLocationCoordinate2D)coords;
-(void)setUserLocationToRegion:(Region)region;
-(NSString *)getNameOfRegion:(Region)region;
-(void)resetResponseQueues;
+(CLLocationCoordinate2D)getCoordinateForRegion:(Region)region;

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
-(BOOL)canRouteBeSearchedBetweenStringCoordinates:(NSString *)firstcoord andCoordinate:(NSString *)secondCoord;
-(BOOL)canRouteBeSearchedBetweenCoordinates:(CLLocationCoordinate2D)firstcoord andCoordinate:(CLLocationCoordinate2D)secondCoord;

-(void)fetchStopsForCode:(NSString *)code andCoords:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion withCompletionBlock:(ActionBlock)completionBlock;

-(void)searchAddressesForKey:(NSString *)key withCompletionBlock:(ActionBlock)completionBlock;
-(void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock;

-(void)fetchLinesForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchDisruptionsWithCompletionBlock:(ActionBlock)completionBlock;

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

- (void)fetchallBookmarksFromICloudWithCompletionHandler:(ActionBlock)completionHandler;

-(SettingsEntity *)fetchSettings;
-(void)saveSettings;
-(void)resetSettings;
-(void)updateRouteSearchOptionsToUserDefaultValue;

-(int)getAppOpenCountAndIncreament;
-(void)setAppOpenCountValue:(int)value;

+(NSString *)generateUniqueRouteNameFor:(NSString *)fromLoc andToLoc:(NSString *)toLoc;

-(void)fetchAllLiveVehiclesWithCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler;
-(void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler;
-(void)stopFetchingLiveVehicles;

-(StopEntity *)castHistoryEntityToStopEntity:(HistoryEntity *)historyEntity;
-(BusStopShort *)castStopGeoCodeToBusStopShort:(GeoCode *)geoCode;
-(BusStopShort *)castStopEntityToBusStopShort:(StopEntity *)stopEntity;

+(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

-(BOOL)doVersion4_1CoreDataMigration;

@property (strong, nonatomic) NSMutableArray *allHistoryStopCodes;
@property (strong, nonatomic) NSMutableArray *allSavedStopCodes;
@property (strong, nonatomic) NSMutableArray *allSavedRouteCodes;
@property (strong, nonatomic) NSMutableArray *allRouteHistoryCodes;
@property (strong, nonatomic) NSMutableArray *allNamedBookmarkNames;

@property (strong, nonatomic) HSLCommunication *hslCommunication;
@property (strong, nonatomic) TRECommunication *treCommunication;

//@property (nonatomic, weak) id <RettiDataManagerDelegate> delegate;
//@property (nonatomic, weak) id <RettiGeocodeSearchDelegate> geocodeSearchdelegate;
//@property (nonatomic, weak) id <RettiReverseGeocodeSearchDelegate> reverseGeocodeSearchdelegate;
////@property (nonatomic, weak) id <RettiRouteSearchDelegate> routeSearchdelegate;
//@property (nonatomic, weak) id <RettiLineInfoSearchDelegate> lineSearchdelegate;
//@property (nonatomic, weak) id <ReittiDisruptionFetchDelegate> disruptionFetchDelegate;
//@property (nonatomic, weak) id <ReittiLiveVehicleFetchDelegate> vehicleFetchDelegate;

@property (strong, nonatomic) StopEntity *stopEntity;
@property (strong, nonatomic) HistoryEntity *historyEntity;
@property (strong, nonatomic) RouteEntity *routeEntity;
@property (strong, nonatomic) RouteHistoryEntity *routeHistoryEntity;
@property (strong, nonatomic) CookieEntity *cookieEntity;
@property (strong, nonatomic) SettingsEntity *settingsEntity;
@property (strong, nonatomic) NamedBookmark *namedBookmark;

@property (nonatomic) RTCoordinateRegion helsinkiRegion;
@property (nonatomic) RTCoordinateRegion tampereRegion;

@property (nonatomic) Region userLocationRegion;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, strong) HSLLiveTrafficManager *hslLiveTrafficManager;
@property(nonatomic, strong) TRELiveTrafficManager *treLiveTrafficManager;
@property(nonatomic, strong) CacheManager *cacheManager;

@end
