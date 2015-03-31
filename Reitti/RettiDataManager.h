//
//  RettiDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSLCommunication.h"
#import "ReittiStringFormatter.h"
#import "BusStop.h"
#include "RouteSearchOptions.h"

@class StopEntity;
@class HistoryEntity;
@class RouteEntity;
@class RouteHistoryEntity;
@class CookieEntity;

@protocol RettiDataManagerDelegate <NSObject>
- (void)stopFetchDidComplete:(NSArray *)stopList;
- (void)stopFetchDidFail:(NSString *)error;
- (void)nearByStopFetchDidComplete:(NSArray *)nearByStopList;
- (void)nearByStopFetchDidFail:(NSString *)error;
@end

@protocol RettiGeocodeSearchDelegate <NSObject>
- (void)geocodeSearchDidComplete:(NSArray *)geocodeList forRequest:(NSString *)requestedKey;
- (void)geocodeSearchDidFail:(NSString *)error forRequest:(NSString *)requestedKey;
@end

@protocol RettiRouteSearchDelegate <NSObject>
- (void)routeSearchDidComplete:(NSArray *)routeList;
- (void)routeSearchDidFail:(NSString *)error;
@end

@protocol ReittiDisruptionFetchDelegate <NSObject>
- (void)disruptionFetchDidComplete:(NSArray *)disList;
- (void)disruptionFetchDidFail:(NSString *)error;
@end



@interface RettiDataManager : NSObject<HSLCommunicationDelegate>{
    int nextObjectLID;
}

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords time:(NSString *)time andDate:(NSString *)date andTimeType:(NSString *)timeType andSearchOption:(RouteSearchOption)searchOption;
-(void)searchAddressesForKey:(NSString *)key;
-(void)fetchStopsForCode:(NSString *)code;
-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion;
-(void)fetchLineInfoForCodeList:(NSString *)codeList;
-(void)fetchDisruptions;

-(BOOL)isBusStopSaved:(BusStop *)stop;
-(BOOL)isRouteSaved:(NSString *)fromString andTo:(NSString *)toString;

-(void)saveToCoreDataStop:(BusStop *)stop withLines:(NSDictionary *)lines;
-(void)deleteSavedStopForCode:(NSNumber *)code;
-(void)deleteAllSavedStop;
-(NSArray *)fetchAllSavedStopsFromCoreData;
-(void)updateSavedStopsDefaultValueForStops:(NSArray *)savedStops;

-(BOOL)saveHistoryToCoreDataStop:(BusStop *)stop;
-(void)deleteHistoryStopForCode:(NSNumber *)code;
-(void)deleteAllHistoryStop;
-(NSArray *)fetchAllSavedStopHistoryFromCoreData;

-(void)saveRouteToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation andToCoords:(NSString *)toCoords;
-(void)deleteSavedRouteForCode:(NSString *)code;
-(void)deleteAllSavedroutes;
-(NSArray *)fetchAllSavedRoutesFromCoreData;

-(BOOL)saveRouteHistoryToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation toCoords:(NSString *)toCoords;
-(void)deleteHistoryRouteForCode:(NSString *)code;
-(void)deleteAllHistoryRoutes;
-(NSArray *)fetchAllSavedRouteHistoryFromCoreData;

-(int)getAppOpenCountAndIncreament;
-(void)setAppOpenCountValue:(int)value;

+(NSString *)generateUniqueRouteNameFor:(NSString *)fromLoc andToLoc:(NSString *)toLoc;
+(NSDictionary *)convertStopLinesArrayToDictionary:(NSArray *)lineList;
-(StopEntity *)castHistoryEntityToStopEntity:(HistoryEntity *)historyEntity;
-(BusStopShort *)castStopGeoCodeToBusStopShort:(GeoCode *)geoCode;
-(BusStopShort *)castStopEntityToBusStopShort:(StopEntity *)stopEntity;

@property (strong, nonatomic) NSDictionary *detailLineInfo;
@property (strong, nonatomic) NSDictionary *stopLinesInfo;
@property (strong, nonatomic) NSMutableArray *allHistoryStopCodes;
@property (strong, nonatomic) NSMutableArray *allSavedStopCodes;
@property (strong, nonatomic) NSMutableArray *allSavedRouteCodes;
@property (strong, nonatomic) NSMutableArray *allRouteHistoryCodes;

@property (strong, nonatomic) HSLCommunication *hslCommunication;

@property (nonatomic, weak) id <RettiDataManagerDelegate> delegate;
@property (nonatomic, weak) id <RettiGeocodeSearchDelegate> geocodeSearchdelegate;
@property (nonatomic, weak) id <RettiRouteSearchDelegate> routeSearchdelegate;
@property (nonatomic, weak) id <ReittiDisruptionFetchDelegate> disruptionFetchDelegate;

@property (strong, nonatomic) StopEntity *stopEntity;
@property (strong, nonatomic) HistoryEntity *historyEntity;
@property (strong, nonatomic) RouteEntity *routeEntity;
@property (strong, nonatomic) RouteHistoryEntity *routeHistoryEntity;
@property (strong, nonatomic) CookieEntity *cookieEntity;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
