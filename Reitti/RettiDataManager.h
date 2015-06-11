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
#import "LiveTrafficManager.h"
#import "CacheManager.h"

@class StopEntity;
@class HistoryEntity;
@class RouteEntity;
@class RouteHistoryEntity;
@class CookieEntity;
@class NamedBookmark;
@class FailedGeoCodeFetch;
@class SettingsEntity;
@class LiveTrafficManager;

@protocol RettiDataManagerDelegate <NSObject>
- (void)stopFetchDidComplete:(NSArray *)stopList;
- (void)stopFetchDidFail:(NSString *)error;
- (void)nearByStopFetchDidComplete:(NSArray *)nearByStopList;
- (void)nearByStopFetchDidFail:(NSString *)error;
@end

@protocol RettiGeocodeSearchDelegate <NSObject>
- (void)geocodeSearchDidComplete:(NSArray *)geocodeList isFinalResult:(BOOL)isFinalResult;
- (void)geocodeSearchAddedResults:(NSArray *)geocodeList  isFinalResult:(BOOL)isFinalResult;
- (void)geocodeSearchDidFail:(NSString *)error forRequest:(NSString *)requestedKey;
@end

@protocol RettiReverseGeocodeSearchDelegate <NSObject>
- (void)reverseGeocodeSearchDidComplete:(GeoCode *)geoCode;
- (void)reverseGeocodeSearchDidFail:(NSString *)error;
@end

@protocol RettiRouteSearchDelegate <NSObject>
- (void)routeSearchDidComplete:(NSArray *)routeList;
- (void)routeSearchDidFail:(NSString *)error;
@end

@protocol ReittiDisruptionFetchDelegate <NSObject>
- (void)disruptionFetchDidComplete:(NSArray *)disList;
- (void)disruptionFetchDidFail:(NSString *)error;
@end

@protocol ReittiLiveVehicleFetchDelegate <NSObject>
- (void)vehiclesFetchCompleteFromHSlLive:(NSArray *)vehicleList;
- (void)vehiclesFetchFromHSLFailedWithError:(NSError *)error;
- (void)vehiclesFetchCompleteFromPubTrans:(NSArray *)vehicleList;
- (void)vehiclesFetchFromPubTransFailedWithError:(NSError *)error;
@end

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

@interface RettiDataManager : NSObject <HSLCommunicationDelegate,TRECommunicationDelegate, PubTransCommunicatorDelegate, LiveTraficManagerDelegate>{
    int nextObjectLID;
    
    Region stopInAreaRequestedFor;
    Region stopInfoRequestedFor;
    Region geoCodeRequestPrioritizedFor;
    Region geoCodeRequestedFor;
    Region lineInfoRequestedFor;
    
    int stopFetchFailedCount;
    int geocodeFetchResponseCount;
    int geocodeFetchFailedCount;
    
    NSMutableArray *HSLGeocodeResposeQueue;
    NSMutableArray *TREGeocodeResponseQueue;
    
    int numberOfApis;
}

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context;
-(void)setUserLocationToCoords:(CLLocationCoordinate2D)coords;
-(Region)getRegionForCoords:(CLLocationCoordinate2D)coords;
-(void)setUserLocationToRegion:(Region)region;
-(NSString *)getNameOfRegion:(Region)region;
-(void)resetResponseQueues;
+(CLLocationCoordinate2D)getCoordinateForRegion:(Region)region;

-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords time:(NSString *)time andDate:(NSString *)date andTimeType:(NSString *)timeType andSearchOption:(RouteSearchOption)searchOption;
-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords;
-(void)getFirstRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords;
-(void)searchAddressesForKey:(NSString *)key;
-(void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords;
-(void)fetchStopsForCode:(NSString *)code andCoords:(CLLocationCoordinate2D)coords;
-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion;
-(void)fetchLineInfoForCodeList:(NSString *)codeList;
-(void)fetchDisruptions;

-(BOOL)isBusStopSaved:(BusStop *)stop;
-(BOOL)isRouteSaved:(NSString *)fromString andTo:(NSString *)toString;
-(BOOL)doesNamedBookmarkExistWithName:(NSString *)name;

-(void)saveToCoreDataStop:(BusStop *)stop withLines:(NSDictionary *)lines;
-(void)deleteSavedStopForCode:(NSNumber *)code;
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
-(NSArray *)fetchAllSavedRoutesFromCoreData;

-(BOOL)saveRouteHistoryToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation toCoords:(NSString *)toCoords;
-(void)deleteHistoryRouteForCode:(NSString *)code;
-(void)deleteAllHistoryRoutes;
-(NSArray *)fetchAllSavedRouteHistoryFromCoreData;

-(NamedBookmark *)saveNamedBookmarkToCoreData:(NamedBookmark *)namedBookmark;
-(NamedBookmark *)updateNamedBookmarkToCoreDataWithID:(NSNumber *)objectLid withNamedBookmark:(NamedBookmark *)ndBookmark;
-(void)deleteNamedBookmarkForName:(NSString *)name;
-(void)deleteAllNamedBookmarks;
-(NSArray *)fetchAllSavedNamedBookmarksFromCoreData;
-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForCoords:(NSString *)coords;

-(SettingsEntity *)fetchSettings;
-(void)saveSettings;
-(void)resetSettings;

-(int)getAppOpenCountAndIncreament;
-(void)setAppOpenCountValue:(int)value;

+(NSString *)generateUniqueRouteNameFor:(NSString *)fromLoc andToLoc:(NSString *)toLoc;

- (void)fetchAllLiveVehicles;
-(void)stopFetchingLiveVehicles;

+(NSDictionary *)convertStopLinesArrayToDictionary:(NSArray *)lineList;
+(NSDictionary *)parseStopLineNamesToDictionary:(NSArray *)lineList;
-(StopEntity *)castHistoryEntityToStopEntity:(HistoryEntity *)historyEntity;
-(BusStopShort *)castStopGeoCodeToBusStopShort:(GeoCode *)geoCode;
-(BusStopShort *)castStopEntityToBusStopShort:(StopEntity *)stopEntity;

@property (strong, nonatomic) NSDictionary *detailLineInfo;
@property (strong, nonatomic) NSDictionary *stopLinesInfo;
@property (strong, nonatomic) NSMutableArray *allHistoryStopCodes;
@property (strong, nonatomic) NSMutableArray *allSavedStopCodes;
@property (strong, nonatomic) NSMutableArray *allSavedRouteCodes;
@property (strong, nonatomic) NSMutableArray *allRouteHistoryCodes;
@property (strong, nonatomic) NSMutableArray *allNamedBookmarkNames;

@property (strong, nonatomic) HSLCommunication *hslCommunication;
@property (strong, nonatomic) TRECommunication *treCommunication;
@property (strong, nonatomic) PubTransCommunicator *pubTransAPI;

@property (nonatomic, weak) id <RettiDataManagerDelegate> delegate;
@property (nonatomic, weak) id <RettiGeocodeSearchDelegate> geocodeSearchdelegate;
@property (nonatomic, weak) id <RettiReverseGeocodeSearchDelegate> reverseGeocodeSearchdelegate;
@property (nonatomic, weak) id <RettiRouteSearchDelegate> routeSearchdelegate;
@property (nonatomic, weak) id <ReittiDisruptionFetchDelegate> disruptionFetchDelegate;
@property (nonatomic, weak) id <ReittiLiveVehicleFetchDelegate> vehicleFetchDelegate;

@property (strong, nonatomic) StopEntity *stopEntity;
@property (strong, nonatomic) HistoryEntity *historyEntity;
@property (strong, nonatomic) RouteEntity *routeEntity;
@property (strong, nonatomic) RouteHistoryEntity *routeHistoryEntity;
@property (strong, nonatomic) CookieEntity *cookieEntity;
@property (strong, nonatomic) SettingsEntity *settingsEntity;
@property (strong, nonatomic) NamedBookmark *namedBookmark;

@property (nonatomic) RTCoordinateRegion helsinkiRegion;
@property (nonatomic) RTCoordinateRegion tampereRegion;

@property (nonatomic) Region userLocation;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, strong) LiveTrafficManager *liveTrafficManager;
@property(nonatomic, strong) CacheManager *cacheManager;

@end
