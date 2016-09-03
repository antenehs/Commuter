//
//  RettiDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RettiDataManager.h"
#import <MapKit/MapKit.h>
#import "StopEntity.h"
#import "HistoryEntity.h"
#import "RouteEntity.h"
#import "RouteHistoryEntity.h"
#import "CookieEntity.h"
#import "SettingsEntity.h"
#import "ReittiManagedObjectBase.h"
#import "CoreDataManager.h"
#import "ReittiAppShortcutManager.h"
#import "ReittiSearchManager.h"
#import "ApiProtocols.h"
#import "ASA_Helpers.h"
#import "AppManager.h"
#import "ReittiRemindersManager.h"
#import "DigiTransitCommunicator.h"
#import "MatkaTransportTypeManager.h"

CLLocationCoordinate2D kHslRegionCenter = {.latitude =  60.170163, .longitude =  24.941352};
CLLocationCoordinate2D kTreRegionCenter = {.latitude =  61.4981508, .longitude =  23.7610254};

@implementation RettiDataManager

@synthesize managedObjectContext;
@synthesize hslCommunication, treCommunication;
@synthesize allHistoryStopCodes;
@synthesize allSavedStopCodes;
@synthesize allRouteHistoryCodes, allSavedRouteCodes;
@synthesize stopEntity;
@synthesize historyEntity;
@synthesize routeEntity;
@synthesize routeHistoryEntity;
@synthesize cookieEntity;
@synthesize settingsEntity;
@synthesize allNamedBookmarkNames;
@synthesize namedBookmark;
@synthesize userLocationRegion;

@synthesize hslLiveTrafficManager, treLiveTrafficManager, cacheManager;

//@synthesize vehicleFetchDelegate;

+(id)sharedManager {
    static RettiDataManager *sharedManager = nil;
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        sharedManager = [[RettiDataManager alloc] init];
    });
    
    return sharedManager;
}

-(id)init{
    self = [super init];
    if (self) {
        self.managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
        
        [self initElements];
        [self initAndFetchCoreData];
        [self updateIcloudRecords];
    }
    
    return self;
}

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context{
    self = [super init];
    if (self) {
        self.managedObjectContext = context;
        
        [self initElements];
        [self initAndFetchCoreData];
        [self updateIcloudRecords];
    }
    
    return self;
}

- (void)initElements {
    HSLCommunication *hCommunicator = [[HSLCommunication alloc] init];
    
    self.hslCommunication = hCommunicator;
    
    self.treCommunication = [[TRECommunication alloc] init];;
    self.matkaCommunicator = [[MatkaCommunicator alloc] init];
    [MatkaTransportTypeManager sharedManager]; //Init singleton

    self.hslLiveTrafficManager = [[HSLLiveTrafficManager alloc] init];
    self.treLiveTrafficManager = [[TRELiveTrafficManager alloc] init];
    
    self.cacheManager = [CacheManager sharedManager];
    
    self.communicationManager = [WatchCommunicationManager sharedManager];
    
    HSLGeocodeResposeQueue = [@[] mutableCopy];
    TREGeocodeResponseQueue = [@[] mutableCopy];
    
//    [self initRegionCoordinates];
    
    userLocationRegion = HSLandTRERegion;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:@"SettingsManagerUserLocationChangedNotification" object:nil];
}

- (void)initAndFetchCoreData {
    [self fetchSystemCookie];
    nextObjectLID = [cookieEntity.objectLID intValue];
    
    [self fetchAllHistoryStopCodesFromCoreData];
    [self fetchAllSavedStopCodesFromCoreData];
    [self fetchAllSavedRouteCodesFromCoreData];
    [self fetchAllRouteHistoryCodesFromCoreData];
    [self fetchAllNamedBookmarkNamesFromCoreData];
    
    //Update widget ns user default values
    [self updateNamedBookmarksUserDefaultValue];
}

- (void)updateIcloudRecords {
    [self updateSavedNamedBookmarksToICloud];
    [self updateSavedStopsToICloud];
    [self updateSavedRoutesToICloud];
}

-(void)setUserLocationToCoords:(CLLocationCoordinate2D)coords{
    userLocationRegion = [self identifyRegionOfCoordinate:coords];
}

-(void)userLocationSettingsValueChanged:(NSNotificationCenter *)notification{
    [self fetchSettings];
    userLocationRegion = (Region)[self.settingsEntity.userLocation intValue];
}

-(Region)getRegionForCoords:(CLLocationCoordinate2D)coords{
    return [self identifyRegionOfCoordinate:coords];
}

//-(BOOL)isCoordinateInCurrentRegion:(CLLocationCoordinate2D)coords{
//    Region region = [self getRegionForCoords:coords];
//    return region == userLocationRegion;
//}

-(void)setUserLocationToRegion:(Region)region{
    userLocationRegion = region;
}

-(NSString *)getNameOfRegion:(Region)region{
    if (region == HSLRegion) {
        return @"Helsinki region";
    }else if (region == TRERegion) {
        return @"Tampere region";
    }else{
        return @"Whole finland";
    }
}

-(void)resetResponseQueues{
    [HSLGeocodeResposeQueue removeAllObjects];
    [TREGeocodeResponseQueue removeAllObjects];
}

+(CLLocationCoordinate2D)getCoordinateForRegion:(Region)region{
    if (region == TRERegion) {
        //lat="61.4981508" lon="23.7610254"
        CLLocationCoordinate2D coord = {.latitude = 61.4981508 , .longitude = 23.7610254 };
        return coord;
    }else{
        //lat="60.168959" lon="24.924714"
        CLLocationCoordinate2D coord = {.latitude = 60.168959 , .longitude = 24.924714 };
        return coord;
    }
}

//- (void)initRegionCoordinates {
//    CLLocationCoordinate2D coord1 = {.latitude = 60.409784 , .longitude = 24.392395 };
//    CLLocationCoordinate2D coord2 = {.latitude = 59.908222 , .longitude = 25.304260};
//    RTCoordinateRegion helsinkiRegionCoords = { coord1,coord2 };
//    self.helsinkiRegion = helsinkiRegionCoords;
//    
//    CLLocationCoordinate2D coord3 = {.latitude = 61.892057 , .longitude = 22.781625 };
//    CLLocationCoordinate2D coord4 = {.latitude = 61.092114 , .longitude = 24.716342};
//    RTCoordinateRegion tampereRegionCoords = { coord3,coord4 };
//    self.tampereRegion = tampereRegionCoords;
//}

#pragma mark - regional datasource
-(ReittiApi)getApiForRegion:(Region)region {
    if (region == HSLRegion) {
        return ReittiHSLApi;
    }else if(region == TRERegion){
        return ReittiTREApi;
    }else if(region == FINRegion){
        return ReittiMatkaApi;
    }else{
        return ReittiCurrentRegionApi;
    }
}

-(id)getDataSourceForApi:(ReittiApi)api {
    if (api == ReittiHSLApi) {
        return self.hslCommunication;
    } else if (api == ReittiTREApi) {
        return self.treCommunication;
    } else if (api == ReittiMatkaApi) {
        return self.matkaCommunicator;
    } else {
        return self.matkaCommunicator;
    }
}

-(id)getDataSourceForCurrentRegion{
    return [self getDataSourceForRegion:userLocationRegion];
}

-(id)getDataSourceForRegion:(Region)region{
    return [self getDataSourceForApi:[self getApiForRegion:region]];
//    if (region == TRERegion) {
//        return self.treCommunication;
//    }else if(region == HSLRegion){
//        return self.hslCommunication;
//    }else{
//        return self.matkaCommunicator;
//    }
}

-(id)getLiveTrafficManagerForCurrentRegion{
    return [self getLiveTrafficManagerForRegion:userLocationRegion];
}

-(id)getLiveTrafficManagerForRegion:(Region)region{
    if (region == TRERegion) {
        return self.treLiveTrafficManager;
    }else if(region == HSLRegion){
        return self.hslLiveTrafficManager;
    }else{
        return nil;
    }
}

#pragma mark - Route search option methods
-(NSArray *)allTrasportTypeNames{
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchOptionProtocol)]) {
        return [(NSObject<RouteSearchOptionProtocol> *)dataSourceManager allTrasportTypeNames];
    }else{
        return nil;
    }
}

-(NSArray *)getTransportTypeOptions{
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchOptionProtocol)]) {
        return [(NSObject<RouteSearchOptionProtocol> *)dataSourceManager getTransportTypeOptions];
    }else{
        return nil;
    }
}
-(NSArray *)getTicketZoneOptions{
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchOptionProtocol)]) {
        return [(NSObject<RouteSearchOptionProtocol> *)dataSourceManager getTicketZoneOptions];
    }else{
        return nil;
    }
}
-(NSArray *)getChangeMargineOptions{
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchOptionProtocol)]) {
        return [(NSObject<RouteSearchOptionProtocol> *)dataSourceManager getChangeMargineOptions];
    }else{
        return nil;
    }
}
-(NSArray *)getWalkingSpeedOptions{
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchOptionProtocol)]) {
        return [(NSObject<RouteSearchOptionProtocol> *)dataSourceManager getWalkingSpeedOptions];
    }else{
        return nil;
    }
}

-(NSInteger)getDefaultValueIndexForTicketZoneOptions{
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchOptionProtocol)]) {
        return [(NSObject<RouteSearchOptionProtocol> *)dataSourceManager getDefaultValueIndexForTicketZoneOptions];
    }else{
        return 0;
    }
}
-(NSInteger)getDefaultValueIndexForChangeMargineOptions{
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchOptionProtocol)]) {
        return [(NSObject<RouteSearchOptionProtocol> *)dataSourceManager getDefaultValueIndexForChangeMargineOptions];
    }else{
        return 0;
    }
}
-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions{
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchOptionProtocol)]) {
        return [(NSObject<RouteSearchOptionProtocol> *)dataSourceManager getDefaultValueIndexForWalkingSpeedOptions];
    }else{
        return 0;
    }
}

#pragma mark - Route Search methods

-(BOOL)areCoordinatesInTheSameRegion:(CLLocationCoordinate2D)firstcoord andCoordinate:(CLLocationCoordinate2D)secondCoord{
    Region firstRegion = [self identifyRegionOfCoordinate:firstcoord];
    Region secondRegion = [self identifyRegionOfCoordinate:secondCoord];
    
    return firstRegion == secondRegion;
}

-(BOOL)areCoordStringsInTheSameRegion:(NSString *)firstcoord andCoordinate:(NSString *)secondCoord{
    return [self areCoordinatesInTheSameRegion:[ReittiStringFormatter convertStringTo2DCoord:firstcoord] andCoordinate:[ReittiStringFormatter convertStringTo2DCoord:secondCoord]];
}

-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andSearchOption:(RouteSearchOptions *)searchOptions andNumberOfResult:(NSNumber *)numberOfResult andCompletionBlock:(ActionBlock)completionBlock{
    
    if ([self areCoordStringsInTheSameRegion:fromCoords andCoordinate:toCoords]) {
        Region fromRegion = [self identifyRegionOfCoordinate:[ReittiStringFormatter convertStringTo2DCoord:fromCoords]];
        
        id dataSourceManager = [self getDataSourceForRegion:fromRegion];
        
        if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchProtocol)]) {
            if (numberOfResult)
                searchOptions.numberOfResults = [numberOfResult integerValue];
            else
                searchOptions.numberOfResults = kDefaultNumberOfResults;
            
            [(NSObject<RouteSearchProtocol> *)dataSourceManager searchRouteForFromCoords:[ReittiStringFormatter convertStringTo2DCoord:fromCoords] andToCoords:[ReittiStringFormatter convertStringTo2DCoord:toCoords] withOptions:searchOptions andCompletionBlock:^(NSArray * response, NSString *error){
                if (!error) {
                    completionBlock(response, nil, [self getApiForRegion:fromRegion]);
                }else{
                    completionBlock(nil, error, [self getApiForRegion:fromRegion]);
                }
            }];
            
        }else{
            completionBlock(nil, @"Service not available in this area.", [self getApiForRegion:fromRegion]);
        }
        
    }else{
        if (numberOfResult)
            searchOptions.numberOfResults = [numberOfResult integerValue];
        else
            searchOptions.numberOfResults = kDefaultNumberOfResults;
        
        [self.matkaCommunicator searchRouteForFromCoords:[ReittiStringFormatter convertStringTo2DCoord:fromCoords] andToCoords:[ReittiStringFormatter convertStringTo2DCoord:toCoords] withOptions:searchOptions andCompletionBlock:^(NSArray * response, NSString *error){
            if (!error) {
                completionBlock(response, nil, ReittiMatkaApi);
            }else{
                completionBlock(nil, error, ReittiMatkaApi);
            }
        }];
    }
}

-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andCompletionBlock:(ActionBlock)completionBlock{
    
    RouteSearchOptions *options = [settingsEntity globalRouteOptions];
    options.date = [NSDate date];
    
    [self searchRouteForFromCoords:fromCoords andToCoords:toCoords andSearchOption:options andNumberOfResult:nil andCompletionBlock:completionBlock];
}

//Needed to avoid making default search that returns 3 results and hence slower
-(void)getFirstRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andCompletionBlock:(ActionBlock)completionBlock{
    
    RouteSearchOptions *options = [settingsEntity globalRouteOptions];
    options.date = [NSDate date];
    
    [self searchRouteForFromCoords:fromCoords andToCoords:toCoords andSearchOption:options andNumberOfResult:@1 andCompletionBlock:completionBlock];
}


#pragma mark - stop search methods

//TODO: Needs to support specifiying api
//TODO: Needs to support responding used API

-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion withCompletionBlock:(ActionBlock)completionBlock {
    [self fetchStopsInAreaForRegion:mapRegion fetchFromApi:ReittiAutomaticApi withCompletionBlock:completionBlock];
}

-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock{
    id dataSourceManager = nil;
    ReittiApi usedApi = api;
    if (api == ReittiAutomaticApi) {
        Region centerRegion = [self identifyRegionOfCoordinate:mapRegion.center];
        dataSourceManager = [self getDataSourceForRegion:centerRegion];
        usedApi = [self getApiForRegion:centerRegion];
    } else if (api == ReittiCurrentRegionApi) {
        dataSourceManager = [self getDataSourceForCurrentRegion];
        usedApi = [self getApiForRegion:userLocationRegion];
    } else {
        dataSourceManager = [self getDataSourceForApi:api];
    }
    
    if ([dataSourceManager conformsToProtocol:@protocol(StopsInAreaSearchProtocol)]) {
        [(NSObject<StopsInAreaSearchProtocol> *)dataSourceManager fetchStopsInAreaForRegionCenterCoords:mapRegion.center andDiameter:(mapRegion.span.longitudeDelta * 111000) withCompletionBlock:^(NSArray *responseArray, NSError *error){
            completionBlock(responseArray, error, usedApi);
        }];
    }else{
        completionBlock(nil, @"Service not available in this area.", usedApi);
    }
}

-(void)fetchStopsForSearchParams:(RTStopSearchParam *)searchParams andCoords:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock {
    Region region = [self identifyRegionOfCoordinate:coords];
    ReittiApi api = [self getApiForRegion:region];
    [self fetchStopsForSearchParams:searchParams fetchFromApi:api withCompletionBlock:completionBlock];
}

-(void)fetchStopsForSearchParams:(RTStopSearchParam *)searchParams fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock {
    
    id dataSourceManager = nil;
    ReittiApi usedApi = api;
    if (api == ReittiCurrentRegionApi) {
        dataSourceManager = [self getDataSourceForCurrentRegion];
        usedApi = [self getApiForRegion:userLocationRegion];
    } else {
        dataSourceManager = [self getDataSourceForApi:api];
    }
    
    if ([dataSourceManager conformsToProtocol:@protocol(StopDetailFetchProtocol)]) {
        [(NSObject<StopDetailFetchProtocol> *)dataSourceManager fetchStopDetailForCode:searchParams.longCode withCompletionBlock:^(BusStop * response, NSString *error){
            if (!error && response) {
                response.fetchedFromApi = usedApi;
                completionBlock(response, error, usedApi);
                
                __block BusStop *fetchedStop = response;
                if (searchParams.stopName && searchParams.shortCode) {
                    [self fetchRealtimeDeparturesForStopName:searchParams.stopName andShortCode:searchParams.shortCode fetchFromApi:usedApi withCompletionHandler:^(NSArray *realDepartures, NSString *errorString){
                        if (!realDepartures || realDepartures.count == 0 || errorString) return;
                        [fetchedStop updateDeparturesFromRealtimeDepartures:realDepartures];
                        completionBlock(fetchedStop, nil, usedApi);
                    }];
                }
                
            } else {
                completionBlock(nil, @"Fetching stop detail failed. Please try again later.", usedApi);
            }
        }];
        
    }else{
        [self.matkaCommunicator fetchStopDetailForCode:searchParams.longCode withCompletionBlock:^(BusStop * response, NSString *error){
            if (!error) {
                response.fetchedFromApi = ReittiMatkaApi;
                completionBlock(response, nil, ReittiMatkaApi);
                
                __block BusStop *fetchedStop = response;
                if (searchParams.stopName && searchParams.shortCode) {
                    [self fetchRealtimeDeparturesForStopName:searchParams.stopName andShortCode:searchParams.shortCode fetchFromApi:usedApi withCompletionHandler:^(NSArray *realDepartures, NSString *errorString){
                        if (!realDepartures || realDepartures.count == 0 || errorString) return;
                        [fetchedStop updateDeparturesFromRealtimeDepartures:realDepartures];
                        completionBlock(fetchedStop, nil, usedApi);
                    }];
                }
            }else{
                completionBlock(nil, @"Fetching stop detail failed. Please try again later.", ReittiMatkaApi);
            }
        }];
    }

}

-(void)fetchRealtimeDeparturesForStopName:(NSString *)name andShortCode:(NSString *)code fetchFromApi:(ReittiApi)api withCompletionHandler:(ActionBlock)completion {
    id dataSourceManager = nil;
    ReittiApi usedApi = api;
    if (api == ReittiCurrentRegionApi) {
        dataSourceManager = [self getDataSourceForCurrentRegion];
        usedApi = [self getApiForRegion:userLocationRegion];
    } else {
        dataSourceManager = [self getDataSourceForApi:api];
    }
    
    if ([dataSourceManager conformsToProtocol:@protocol(RealtimeDeparturesFetchProtocol)]) {
        [(NSObject<RealtimeDeparturesFetchProtocol> *)dataSourceManager fetchRealtimeDeparturesForStopName:name andShortCode:code withCompletionHandler:completion];
    }else{
        completion(nil, @"Realtime departure fetching not supported in this region.");
    }
}

-(void)fetchLinesForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock {
    [self fetchLinesForSearchTerm:searchTerm fetchFromApi:ReittiCurrentRegionApi withCompletionBlock:completionBlock];
}

-(void)fetchLinesForSearchTerm:(NSString *)searchTerm fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock{
    
    id dataSourceManager = nil;
    ReittiApi usedApi = api;
    if (api == ReittiCurrentRegionApi) {
        dataSourceManager = [self getDataSourceForCurrentRegion];
        usedApi = [self getApiForRegion:userLocationRegion];
    } else {
        dataSourceManager = [self getDataSourceForApi:api];
    }
    
    if ([dataSourceManager conformsToProtocol:@protocol(LineDetailFetchProtocol)]) {
        [(NSObject<LineDetailFetchProtocol> *)dataSourceManager fetchLinesForSearchterm:searchTerm withCompletionBlock:^(NSArray * response, NSString *error){
            completionBlock(response, searchTerm, error, usedApi);
        }];
    }else{
        completionBlock(nil, searchTerm, @"Service not available in the current region.", usedApi);
    }
}

-(void)fetchLinesForLineCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock {
    [self fetchLinesForLineCodes:lineCodes fetchFromApi:ReittiCurrentRegionApi  withCompletionBlock:completionBlock];
}

-(void)fetchLinesForLineCodes:(NSArray *)lineCodes fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock {
    
    id dataSourceManager = nil;
    ReittiApi usedApi = api;
    if (api == ReittiCurrentRegionApi) {
        dataSourceManager = [self getDataSourceForCurrentRegion];
        usedApi = [self getApiForRegion:userLocationRegion];
    } else {
        dataSourceManager = [self getDataSourceForApi:api];
    }
    
    if ([dataSourceManager conformsToProtocol:@protocol(LineDetailFetchProtocol)]) {
        [(NSObject<LineDetailFetchProtocol> *)dataSourceManager fetchLinesForCodes:lineCodes withCompletionBlock:^(NSArray * response, NSString *error){
            completionBlock(response, lineCodes, error, usedApi);
        }];
    }else{
        completionBlock(nil, lineCodes, @"Service not available in the current region.", usedApi);
    }
}

#pragma mark - Reverse geocode methods

-(void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock{
    Region region = [self identifyRegionOfCoordinate:coords];
    
    id dataSourceManager = [self getDataSourceForRegion:region];
    
    if ([dataSourceManager conformsToProtocol:@protocol(ReverseGeocodeProtocol)]) {
        [(NSObject<ReverseGeocodeProtocol> *)dataSourceManager searchAddresseForCoordinate:coords withCompletionBlock:completionBlock];
    }else{
        completionBlock(nil, @"Service not available in the current region.");
    }
}

#pragma mark - Address fetch methods

-(void)searchAddressesForKey:(NSString *)key withCompletionBlock:(ActionBlock)completionBlock{
//    geoCodeRequestedFor = userLocationRegion;
    
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    
    if ([dataSourceManager conformsToProtocol:@protocol(GeocodeProtocol)]) {
        __block NSInteger requestCalls = 2;
        __block NSMutableArray *allResults = [@[] mutableCopy];
        __block NSArray *poiResults = @[];
        __block NSArray *reitiopasResults = @[];
        
        [(NSObject<GeocodeProtocol> *)dataSourceManager searchGeocodeForSearchTerm:key withCompletionBlock:^(NSArray * response, NSString *error){
            requestCalls--;
            
            if (!error) {
                reitiopasResults = response;
            }
            
            if (requestCalls == 0){
                allResults = [@[] mutableCopy];
                [allResults addObjectsFromArray:reitiopasResults];
                [allResults addObjectsFromArray:poiResults];
                completionBlock(allResults, key , error);
            }
        }];
        
        [self searchAddressFromAppleForKey:key withCompletionBlock:^(NSArray *response, NSString *searchKey){
            requestCalls--;
            
            if (response && response.count > 0) {
                poiResults = response;
            }
            
            if (requestCalls == 0){
                allResults = [@[] mutableCopy];
                [allResults addObjectsFromArray:reitiopasResults];
                [allResults addObjectsFromArray:poiResults];
                completionBlock(allResults, searchKey, nil);
            }
        }];
    }else{
        [self.matkaCommunicator searchGeocodeForSearchTerm:key withCompletionBlock:^(NSArray * response, NSString *error){
            if (!error) {
                completionBlock(response, key, nil);
            } else {
                completionBlock(nil, key, error);
            }
        }];
    }
}

//Search addresses from apple in the regions out of the current region. Search pois from all finland
-(void)searchAddressFromAppleForKey:(NSString *)key withCompletionBlock:(ActionBlock)completionBlock{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = key;
//    request.region = [self regionForCurrentUserLocation]; //TODO: Make the region to cover finland.

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         NSMutableArray *geocodes = [NSMutableArray array];
         for (MKMapItem *item in response.mapItems) {
             if (!item.placemark.addressDictionary[@"CountryCode"] ||
                 ![item.placemark.addressDictionary[@"CountryCode"] isEqualToString:@"FI"])
                 continue;
             
             //Dont search for addresses when matka api is in use. it will duplicate addresses.
             if (userLocationRegion == FINRegion && !item.phoneNumber )
                 continue;
             
             GeoCode *geoCode =[[GeoCode alloc] initWithMapItem:item];
             
             if (geoCode)
                 [geocodes addObject:geoCode];
         }
         
         completionBlock(geocodes, key);
     }];
}

-(void)fetchDisruptionsWithCompletionBlock:(ActionBlock)completionBlock{
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    
    if ([dataSourceManager conformsToProtocol:@protocol(DisruptionFetchProtocol)]) {
        [(NSObject<DisruptionFetchProtocol> *)dataSourceManager fetchTrafficDisruptionsWithCompletionBlock:^(NSArray *response, NSString *error){
            
            if (!error) {
                completionBlock(response, nil);
            }else{
                completionBlock(nil, error);
            }
        }];
    }else{
        completionBlock(nil, @"Service not available in the current region.");
    }
}

-(void)startFetchingBikeStationsWithCompletionBlock:(ActionBlock)completionBlock {
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    
    if ([dataSourceManager conformsToProtocol:@protocol(BikeStationFetchProtocol)]) {
        [(NSObject<BikeStationFetchProtocol> *)dataSourceManager startFetchBikeStationsWithCompletionHandler:^(NSArray *response, NSString *error){
            if (!error) {
                completionBlock(response, nil);
            }else{
                completionBlock(nil, error);
            }
        }];
    }else{
        completionBlock(nil, @"Service not available in the current region.");
    }
}

-(void)stopUpdatingBikeStations {
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    
    if ([dataSourceManager conformsToProtocol:@protocol(BikeStationFetchProtocol)]) {
        [(NSObject<BikeStationFetchProtocol> *)dataSourceManager stopFetchingBikeStations];
    }
}

#pragma mark - Live traffic fetch methods
-(void)fetchAllLiveVehiclesWithCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler{
    id liveTrafficManager = [self getLiveTrafficManagerForCurrentRegion];
    
    [self stopFetchingLiveVehicles];
    
    if ([liveTrafficManager conformsToProtocol:@protocol(LiveTrafficFetchProtocol)]) {
        [(NSObject<LiveTrafficFetchProtocol> *)liveTrafficManager startFetchingAllLiveVehiclesWithCodes:lineCodes andTrainCodes:trainCodes withCompletionHandler:completionHandler];
    }else{
        completionHandler(nil, @"Service not available in the current region.");
    }
}

-(void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler{
    id liveTrafficManager = [self getLiveTrafficManagerForCurrentRegion];
    
    [self stopFetchingLiveVehicles];
    
    if ([liveTrafficManager conformsToProtocol:@protocol(LiveTrafficFetchProtocol)]) {
        [(NSObject<LiveTrafficFetchProtocol> *)liveTrafficManager startFetchingAllLiveVehiclesWithCompletionHandler:completionHandler];
    }else{
        completionHandler(nil, @"Service not available in the current region.");
    }
}

-(void)stopFetchingLiveVehicles{
    //Done like this because when region changes, we dont know which manager to stop
    [self.hslLiveTrafficManager stopFetchingVehicles];
    [self.treLiveTrafficManager stopFetchingVehicles];
}

#pragma mark - helper methods
- (void)saveManagedObject:(NSManagedObject *)object {
    ReittiManagedObjectBase *managedObject = (ReittiManagedObjectBase *)object;
    managedObject.objectLID = [NSNumber numberWithInt:nextObjectLID];
    managedObject.dateModified = [NSDate date];
    
    NSError *error = nil;
    
    if (![object.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self increamentObjectLID];
}

-(void)updateOrderedManagedObjectOrderTo:(NSArray *)orderedObjects {
    
    for (int i = 0; i < orderedObjects.count; i++) {
        
        OrderedManagedObject *object = orderedObjects[i];
        if (![object isKindOfClass:[OrderedManagedObject class]]) return;
        
        object.order = [NSNumber numberWithInt:i + 1];
        [self saveManagedObject:object];
    }
    
    if (orderedObjects.count > 0 && [orderedObjects[0] isKindOfClass:[StopEntity class]]) {
        [self updateSavedStopsDefaultValueForStops:[self fetchAllSavedStopsFromCoreData]];
    }
    
    if (orderedObjects.count > 0 && [orderedObjects[0] isKindOfClass:[NamedBookmark class]]) {
        [self updateNamedBookmarksUserDefaultValue];
        [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
    }
}

-(NSDictionary *)convertListInfoArrayToDictionary:(NSArray *)infoListArray{
    
    NSMutableArray *codesList;
    
    for (Line * line in infoListArray) {
        [codesList addObject:[NSString stringWithFormat:@"%@", line.code]];
    }
    
    NSDictionary *convertedSet = [NSDictionary dictionaryWithObjects:infoListArray forKeys:codesList];
    
    return convertedSet;
}

-(NSDictionary *)convertBusStopToDictionary:(BusStop *)stop{
    
    NSMutableDictionary *stopDictionary = [[NSMutableDictionary alloc] init];
    [stopDictionary setObject:stop forKey:stop.code];
    
    return stopDictionary;
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

-(StopEntity *)castHistoryEntityToStopEntity:(HistoryEntity *)historyEntityToCast{
  
    return (StopEntity *)historyEntityToCast;
}

-(BusStopShort *)castStopGeoCodeToBusStopShort:(GeoCode *)geoCode{
    if (geoCode.getLocationType != LocationTypeStop)
        return nil;
    
    BusStopShort *castedBSS = [[BusStopShort alloc] init];
    castedBSS.code = geoCode.getStopCode;
    castedBSS.codeShort = geoCode.getStopShortCode;
    castedBSS.coords = geoCode.coords;
    castedBSS.name = geoCode.name;
    castedBSS.city = geoCode.city;
    castedBSS.address = geoCode.getAddress;
    castedBSS.distance = [NSNumber numberWithInt:0];
    
    return castedBSS;
}

-(BusStopShort *)castStopEntityToBusStopShort:(StopEntity *)stopEntityToCast{
    BusStopShort *castedBSS = [[BusStopShort alloc] init];
    castedBSS.code = stopEntityToCast.busStopCode;
    castedBSS.codeShort = stopEntityToCast.busStopShortCode;
    castedBSS.coords = stopEntityToCast.busStopWgsCoords;
    castedBSS.name = stopEntityToCast.busStopName;
    castedBSS.city = stopEntityToCast.busStopCity;
    castedBSS.address = nil;
    castedBSS.distance = [NSNumber numberWithInt:0];
    
    return castedBSS;
}

-(BOOL)isBusStopSaved:(BusStop *)stop{
    return [self isBusStopSavedWithCode:stop.code];
}

-(BOOL)isBusStopSavedWithCode:(NSNumber *)stopCode{
    [self fetchAllSavedStopCodesFromCoreData];
    return [allSavedStopCodes containsObject:stopCode];
}

-(void)updateNamedBookmarksUserDefaultValue{
    
    NSArray * namedBookmarks = [self fetchAllSavedNamedBookmarksFromCoreData];
    
    NSMutableArray *namedBookmarkDictionaries = [@[] mutableCopy];
    
    for (NamedBookmark *nmdBookmark in namedBookmarks) {
        [namedBookmarkDictionaries addObject:[nmdBookmark dictionaryRepresentation]];
    }
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsRoutesExtensionSuitName]];
    
    [sharedDefaults setObject:namedBookmarkDictionaries forKey:kUserDefaultsNamedBookmarksKey];
    [sharedDefaults synchronize];
    
    //Update bookmarks to watch
    [self.communicationManager transferNamedBookmarks:namedBookmarkDictionaries];
}

-(void)updateSourceApiForStops:(NSArray *)savedStops {
    if (!savedStops || savedStops.count == 0) { return; }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (StopEntity *stop in savedStops) {
        dict[[stop.busStopCode stringValue]] = stop.fetchedFrom;
    }
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsStopsWidgetSuitName]];
    
    [sharedDefaults setObject:dict forKey:kUserDefaultsStopSourceApiKey];
    [sharedDefaults synchronize];
}

-(void)updateSavedStopsToWatch:(NSArray *)savedStops {
    NSMutableArray *stopsDictionaries = [@[] mutableCopy];
    
    for (StopEntity *stop in savedStops) {
        [stopsDictionaries addObject:[stop dictionaryRepresentation]];
    }
    
    [[WatchCommunicationManager sharedManager] transferSavedStops:stopsDictionaries];
}

-(void)updateSavedStopsDefaultValueForStops:(NSArray *)savedStops{

    NSString *codes = [[NSString alloc] init];
    
    BOOL firstElement = YES;
    for (StopEntity *stop in savedStops) {
        if (firstElement) {
            codes = [NSString stringWithFormat:@"%d",[stop.busStopCode intValue]];
            firstElement = NO;
        }else{
            codes = [NSString stringWithFormat:@"%@,%d",codes, [stop.busStopCode intValue]];
        }
    }

    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsStopsWidgetSuitName]];
    
    [sharedDefaults setObject:codes forKey:kUserDefaultsSavedStopsKey];
    [sharedDefaults synchronize];
    
    [self updateSourceApiForStops:savedStops];
    [self updateSavedStopsToWatch:savedStops];
}

//-(void)updateSelectedStopListForDeletedStop:(int)stopCode andAllStops:(NSArray *)allStops{
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsStopsWidgetSuitName]];
//    NSString *selectedCodes = [sharedDefaults objectForKey:kUserDefaultsSelectedSavedStopsKey];
//    
//    if (allStops == nil) {
//        [sharedDefaults setObject:@"" forKey:kUserDefaultsSelectedSavedStopsKey];
//        return;
//    }
//    
//    if (stopCode == 0) {
//        return;
//    }
//    
//    NSRange strRange = [selectedCodes rangeOfString:[NSString stringWithFormat:@"%d", stopCode]];
//    if (strRange.location != NSNotFound) {
//        StopEntity *new;
//        for (StopEntity *stop in allStops) {
//            
//            if ([stop.busStopCode intValue] != stopCode) {
//                NSRange range = [selectedCodes rangeOfString:[NSString stringWithFormat:@"%d", [stop.busStopCode intValue]]];
//                if (range.location == NSNotFound) {
//                    new = stop;
//                }
//            }
//        }
//        
//        if (allStops != nil && new != nil) {
//            
//            NSString *newEntry = [NSString stringWithFormat:@"%@", [new busStopCode]];
//            NSString *newStr = [selectedCodes stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%d", stopCode] withString:newEntry ];
//            [sharedDefaults setObject:newStr forKey:kUserDefaultsSelectedSavedStopsKey];
//            [sharedDefaults synchronize];
//        }else{
//            NSString *newStr = [selectedCodes stringByReplacingCharactersInRange:strRange withString:@""];
//            newStr = [newStr stringByReplacingOccurrencesOfString:@",," withString:@","];
//            newStr = [newStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
//            [sharedDefaults setObject:newStr forKey:kUserDefaultsSelectedSavedStopsKey];
//            [sharedDefaults synchronize];
//        }
//    }
//    
//    [self updateSourceApiForStops:allStops];
//}

-(BOOL)isRouteSaved:(NSString *)fromString andTo:(NSString *)toString{
    [self fetchAllSavedRouteCodesFromCoreData];
    return [allSavedRouteCodes containsObject:[RettiDataManager generateUniqueRouteNameFor:fromString andToLoc:toString]];
}

-(Region)identifyRegionOfCoordinate:(CLLocationCoordinate2D)coords{
    
//    if ([self isCoordinateInRegion:self.helsinkiRegion coordinate:coords]) {
//        return HSLRegion;
//    }
//    
//    if ([self isCoordinateInRegion:self.tampereRegion coordinate:coords]) {
//        return TRERegion;
//    }

    if ([[ReittiRegionManager sharedManager] isCoordinateInHSLRegion:coords]) {
        return HSLRegion;
    }
    
    if ([[ReittiRegionManager sharedManager] isCoordinateInTRERegion:coords]) {
        return TRERegion;
    }
    
    return FINRegion;
}

//-(MKCoordinateRegion)mapRegionForRtCoordinateRegion:(RTCoordinateRegion)coordRegion{
//    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((coordRegion.topLeftCorner.latitude + coordRegion.bottomRightCorner.latitude)/2 , (coordRegion.topLeftCorner.longitude + coordRegion.bottomRightCorner.longitude)/2 );
//    
//    CLLocationDegrees latitudeDelta = coordRegion.topLeftCorner.latitude - coordRegion.bottomRightCorner.latitude;
//    CLLocationDegrees longtudeDelta = coordRegion.bottomRightCorner.longitude - coordRegion.topLeftCorner.longitude;
//    
//    return MKCoordinateRegionMake(center, MKCoordinateSpanMake(latitudeDelta, longtudeDelta));
//}

//-(MKCoordinateRegion)regionForCurrentUserLocation{
//    if ([self userLocationRegion] == HSLRegion) {
//        return [self mapRegionForRtCoordinateRegion:helsinkiRegion];
//    }else if ([self userLocationRegion] == TRERegion){
//        return [self mapRegionForRtCoordinateRegion:tampereRegion];
//    }else{
//        return MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(0, 0));
//    }
//}

#pragma mark - Settings Methods
-(SettingsEntity *)fetchSettings{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"SettingsEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    
    NSError *error = nil;
    
    NSArray *tempSystemSettings = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (tempSystemSettings.count > 0) {
        settingsEntity = [tempSystemSettings objectAtIndex:0];
        
        //Migration to datamodel version 7
        if (settingsEntity.showLiveVehicle == nil) {
            [settingsEntity setShowLiveVehicle:[NSNumber numberWithBool:YES]];
        }
        
        //Migration to datamodel version 14
        if (settingsEntity.toneName == nil) {
            [settingsEntity setToneName:[AppManager defailtToneName]];
        }
    }
    else {
        [self initializeSettings];
    }
    
    return settingsEntity;
    
}

-(void)initializeSettings{
    settingsEntity = (SettingsEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"SettingsEntity" inManagedObjectContext:self.managedObjectContext];
    //set default values
    [settingsEntity setMapMode:[NSNumber numberWithInt:0]];
    [settingsEntity setUserLocation:[NSNumber numberWithInt:0]];
    [settingsEntity setShowLiveVehicle:[NSNumber numberWithBool:YES]];
    [settingsEntity setClearOldHistory:[NSNumber numberWithBool:YES]];
    [settingsEntity setNumberOfDaysToKeepHistory:[NSNumber numberWithInt:90]];
    [settingsEntity setToneName:[AppManager defailtToneName]];
    [settingsEntity setSettingsStartDate:[NSDate date]];
    [settingsEntity setGlobalRouteOptions:[RouteSearchOptions defaultOptions]];
    
    NSError *error = nil;
    
    if (![settingsEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed settings!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

-(void)resetSettings{
    if (settingsEntity == nil) {
        settingsEntity = (SettingsEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"SettingsEntity" inManagedObjectContext:self.managedObjectContext];
    }
    
    //set default values
    [settingsEntity setMapMode:[NSNumber numberWithInt:0]];
    [settingsEntity setUserLocation:[NSNumber numberWithInt:0]];
    [settingsEntity setShowLiveVehicle:[NSNumber numberWithBool:YES]];
    [settingsEntity setClearOldHistory:[NSNumber numberWithBool:YES]];
    [settingsEntity setNumberOfDaysToKeepHistory:[NSNumber numberWithInt:90]];
    [settingsEntity setToneName:[AppManager defailtToneName]];
    [settingsEntity setSettingsStartDate:[NSDate date]];
    [settingsEntity setGlobalRouteOptions:[RouteSearchOptions defaultOptions]];
    
    [self saveSettings];
}

-(void)saveSettings{
    NSError *error = nil;
    
    if (![settingsEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed settings!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self updateRouteSearchOptionsToUserDefaultValue];
}

-(void)updateRouteSearchOptionsToUserDefaultValue{
    
    [self fetchSettings];
    NSDictionary *routeOptions = [self.settingsEntity.globalRouteOptions dictionaryRepresentation];
    
    if (routeOptions) {
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsRoutesExtensionSuitName]];
        
        [sharedDefaults setObject:routeOptions forKey:kUserDefaultsRouteSearchOptionsKey];
        [sharedDefaults synchronize];
    }
    
    [self.communicationManager transferRouteSearchOptions:routeOptions];
}

#pragma mark - Core data methods
-(CookieEntity *)fetchSystemCookie{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"CookieEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    
    NSError *error = nil;
    
    NSArray *tempSystemCookie = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (tempSystemCookie.count > 0) {
        cookieEntity = [tempSystemCookie objectAtIndex:0];
    }
    else {
        [self initializeSystemCookie];
    }
    
    return cookieEntity;
    
}

-(void)initializeSystemCookie{
    cookieEntity = (CookieEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"CookieEntity" inManagedObjectContext:self.managedObjectContext];
    //set default values
    [cookieEntity setObjectLID:[NSNumber numberWithInt:100]];
    [cookieEntity setAppOpenCount:[NSNumber numberWithInt:0]];
    
    NSError *error = nil;
    
    if (![cookieEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed systemCookie!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

-(int)getAppOpenCountAndIncreament{
    
    if ([cookieEntity.appOpenCount intValue] < 15) {
        [self increamentAppOpenCounter];
    }
    
    return [cookieEntity.appOpenCount intValue];
    
}

-(void)setAppOpenCountValue:(int)value{
    [cookieEntity setAppOpenCount:[NSNumber numberWithInt:value]];
    NSError *error = nil;
    
    if (![cookieEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:!!", error, [error userInfo]);
        exit(-1);  // Fail
    }

}

-(void)increamentObjectLID{
    [self fetchSystemCookie];
    
    [cookieEntity setObjectLID:[NSNumber numberWithInt:(nextObjectLID + 1)]];
    nextObjectLID++;
    NSError *error = nil;
    
    if (![cookieEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

-(void)increamentAppOpenCounter{
    [cookieEntity setAppOpenCount:[NSNumber numberWithInt:([cookieEntity.appOpenCount intValue] + 1)]];
    NSError *error = nil;
    
    if (![cookieEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

#pragma mark - stop core data methods
//@ Updates a saved stop if it exists or insert a new one.
-(void)saveToCoreDataStop:(BusStop *)stop{
    if (!stop)
        return;
    
    self.stopEntity = [self fetchSavedStopFromCoreDataForCode:stop.code];
    
    if (!self.stopEntity) {
        self.stopEntity= (StopEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"StopEntity" inManagedObjectContext:self.managedObjectContext];
        self.stopEntity.order = [NSNumber numberWithInteger:allSavedStopCodes.count + 1];
    }
    
    //set default values
    [self.stopEntity setBusStopCode:stop.code];
    [self.stopEntity setBusStopShortCode:stop.code_short];
    [self.stopEntity setBusStopName:stop.name_fi];
    [self.stopEntity setBusStopCity:stop.city_fi];
    [self.stopEntity setBusStopURL:stop.timetable_link];
    [self.stopEntity setBusStopCoords:stop.coords];
    [self.stopEntity setBusStopWgsCoords:stop.wgs_coords];
    [self.stopEntity setStopLines:stop.lines];
    [self.stopEntity setFetchedFrom:[NSNumber numberWithInt:(int)stop.fetchedFromApi]];
    
    [self saveManagedObject:stopEntity];
    
    [allSavedStopCodes addObject:stop.code];
    [self updateSavedStopsDefaultValueForStops:[self fetchAllSavedStopsFromCoreData]];
    [self updateSavedStopsToICloud];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
}

-(void)updateSavedStopIfItExists:(BusStop *)stop{
    if ([self isBusStopSavedWithCode:stop.code]) {
        [self saveToCoreDataStop:stop];
    }
}

-(void)deleteSavedStopForCode:(NSNumber *)code{
    if (!code) return;
    
    StopEntity *stopToDelete = [self fetchSavedStopFromCoreDataForCode:code];
    
    [self deleteSavedStop:stopToDelete];
}

-(void)deleteSavedStop:(StopEntity *)savedStop{
    if (!savedStop)
        return;
    
    [self deleteStopsFromICloud:@[savedStop]];
    
    [self.managedObjectContext deleteObject:savedStop];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedStopCodes removeObject:savedStop.busStopCode];
    NSArray *savedSt = [self fetchAllSavedStopsFromCoreData];
    [self updateSavedStopsDefaultValueForStops:savedSt];
//    [self updateSelectedStopListForDeletedStop:[savedStop.busStopCode intValue] andAllStops:savedSt];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
}

-(void)deleteAllSavedStop{
    NSArray *stopsToDelete = [self fetchAllSavedStopsFromCoreData];
    [self deleteStopsFromICloud:stopsToDelete];
    
    for (StopEntity *stop in stopsToDelete) {
        [self.managedObjectContext deleteObject:stop];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedStopCodes removeAllObjects];
    NSArray *savedSt = [self fetchAllSavedStopsFromCoreData];
    [self updateSavedStopsDefaultValueForStops:savedSt];
//    [self updateSelectedStopListForDeletedStop:0 andAllStops:savedSt];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
}

//Return array of set dictionaries
-(NSArray *)fetchAllSavedStopsFromCoreData{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"StopEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    //[request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    //[request setPropertiesToFetch :[NSArray arrayWithObjects: @"set_id",  @"title",  @"subject",  @"url",  @"score",  @"views",  @"created",  @"last_modified",  @"card_count",  @"access", nil]];
    
    NSError *error = nil;
    
    NSArray *savedStops = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedStops count] != 0) {
        return savedStops;
    }
    
    return nil;
}

-(void)fetchAllSavedStopCodesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"StopEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"busStopCode"]];
    
    NSError *error = nil;
    
    NSArray *recentStopsCodes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentStopsCodes count] != 0) {
        allSavedStopCodes = [self simplifyCoreDataDictionaryArray:recentStopsCodes withKey:@"busStopCode"] ;
    }
    else {
        allSavedStopCodes = [[NSMutableArray alloc] init];
    }
}

-(StopEntity *)fetchSavedStopFromCoreDataForCode:(NSNumber *)code{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"StopEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"busStopCode == %@", code];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedStops = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedStops count] != 0) {
        return [savedStops objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark - Stop history core data methods
-(BOOL)saveHistoryToCoreDataStop:(BusStop *)stop{
    if (!stop)
        return NO;
    
    //Check for existence here first
    if(![allHistoryStopCodes containsObject:stop.code] && stop != nil){
        self.historyEntity= (HistoryEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"HistoryEntity" inManagedObjectContext:self.managedObjectContext];
        //set default values
        [self.historyEntity setBusStopCode:stop.code];
        [self.historyEntity setBusStopShortCode:stop.code_short];
        [self.historyEntity setBusStopName:stop.name_fi];
        [self.historyEntity setBusStopCity:stop.city_fi];
        [self.historyEntity setBusStopURL:stop.timetable_link];
        [self.historyEntity setBusStopCoords:stop.coords];
        [self.historyEntity setBusStopWgsCoords:stop.wgs_coords];
        [self.historyEntity setFetchedFrom:[NSNumber numberWithInt:(int)stop.fetchedFromApi]];
        
        [self saveManagedObject:historyEntity];
        
        [allHistoryStopCodes addObject:stop.code];
        return YES;
    }else if (stop == nil){
        return NO;
    }else{
        self.historyEntity = [self fetchStopHistoryFromCoreDataForCode:stop.code];
        
        [self saveManagedObject:historyEntity];
        
        return YES;
    }
}

-(void)deleteHistoryStopForCode:(NSNumber *)code{
    HistoryEntity *historyToDelete = [self fetchStopHistoryFromCoreDataForCode:code];
    
    [self.managedObjectContext deleteObject:historyToDelete];
    
    NSError *error = nil;
    if (![historyToDelete.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allHistoryStopCodes removeObject:code];
}

-(void)deleteAllHistoryStop{
    NSArray *historyToDelete = [self fetchAllSavedStopHistoryFromCoreData];
    
    for (HistoryEntity *stop in historyToDelete) {
        [self.managedObjectContext deleteObject:stop];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allHistoryStopCodes removeAllObjects];
}

-(void)clearHistoryOlderThanDays:(int)numOfDays{
//    numOfDays = 1;
    BOOL modified = NO;
    NSArray *allStopHistory = [self fetchAllSavedStopHistoryFromCoreData];
    for (HistoryEntity *stop in allStopHistory) {
        if (stop.dateModified != nil) {
            if ([stop.dateModified timeIntervalSinceNow] < -(numOfDays * 24 * 60 * 60)) {
                [self.managedObjectContext deleteObject:stop];
                modified = YES;
                [allHistoryStopCodes removeObject:stop.busStopCode];
            }
        }else{
            if ([settingsEntity.settingsStartDate timeIntervalSinceNow] > (numOfDays * 24 * 60 * 60)) {
                [self.managedObjectContext deleteObject:stop];
                modified = YES;
                [allHistoryStopCodes removeObject:stop.busStopCode];
            }
        }
    }
    
    NSArray *allRouteHistory = [self fetchAllSavedRouteHistoryFromCoreData];
    for (RouteHistoryEntity *route in allRouteHistory) {
        if (route.dateModified != nil) {
            if ([route.dateModified timeIntervalSinceNow] < -(numOfDays * 24 * 60 * 60)) {
                [self.managedObjectContext deleteObject:route];
                modified = YES;
                [allRouteHistoryCodes removeObject:route.routeUniqueName];
            }
        }else{
            if ([settingsEntity.settingsStartDate timeIntervalSinceNow] > (numOfDays * 24 * 60 * 60)) {
                [self.managedObjectContext deleteObject:route];
                modified = YES;
                [allRouteHistoryCodes removeObject:route.routeUniqueName];
            }
        }
    }
    
    if (modified) {
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
            exit(-1);  // Fail
        }
    }
}

-(NSArray *)fetchAllSavedStopHistoryFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"objectLID" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    [request setReturnsDistinctResults:YES];
    
    NSError *error = nil;
    
    NSArray *recentStops = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentStops count] != 0) {
        return recentStops;
    }
    
    return nil;
}

-(HistoryEntity *)fetchStopHistoryFromCoreDataForCode:(NSNumber *)code{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"busStopCode == %@", code];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *recentStops = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentStops count] != 0) {
        return [recentStops objectAtIndex:0];
    }
    
    return nil;
}

-(void)fetchAllHistoryStopCodesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"objectLID" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"busStopCode"]];
    
    NSError *error = nil;
    
    NSArray *recentStopsCodes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentStopsCodes count] != 0) {
        allHistoryStopCodes = [self simplifyCoreDataDictionaryArray:recentStopsCodes withKey:@"busStopCode"] ;
    }
    else {
        allHistoryStopCodes = [[NSMutableArray alloc] init];
    }
}

#pragma mark - route core data methods
+(NSString *)generateUniqueRouteNameFor:(NSString *)fromLoc andToLoc:(NSString *)toLoc{
    return [NSString stringWithFormat:@"%@ - %@",fromLoc, toLoc];
}

-(void)saveRouteToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation andToCoords:(NSString *)toCoords{
    
    if (fromLocation == nil || fromCoords == nil || toLocation == nil || toCoords == nil ||
        fromLocation.length == 0 || fromCoords.length == 0 || toLocation.length == 0 || toCoords.length == 0) {
        return;
    }
    
    self.routeEntity= (RouteEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"RouteEntity" inManagedObjectContext:self.managedObjectContext];
    //set default values
    [self.routeEntity setOrder:[NSNumber numberWithInteger:allSavedRouteCodes.count + 1]];
    [self.routeEntity setFromLocationName:fromLocation];
    [self.routeEntity setFromLocationCoordsString:fromCoords];
    [self.routeEntity setToLocationName:toLocation];
    [self.routeEntity setToLocationCoordsString:toCoords];
    [self.routeEntity setRouteUniqueName:[RettiDataManager generateUniqueRouteNameFor:fromLocation andToLoc:toLocation]];
    
    [self saveManagedObject:self.routeEntity];
    
    [self updateSavedRoutesToICloud];
    [allSavedRouteCodes addObject:self.routeEntity.routeUniqueName];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
}

-(void)deleteSavedRouteForCode:(NSString *)code{
    RouteEntity *routeToDelete = [self fetchSavedRouteFromCoreDataForCode:code];
    if (!routeToDelete)
        return;
    
    [self deleteRoutesFromICloud:@[routeToDelete]];
    
    [self.managedObjectContext deleteObject:routeToDelete];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedRouteCodes removeObject:code];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
}

-(void)deleteAllSavedroutes{
    NSArray *routesToDelete = [self fetchAllSavedRoutesFromCoreData];
    if (!routesToDelete || routesToDelete.count < 1)
        return;
    
    [self deleteRoutesFromICloud:routesToDelete];
    
    for (RouteEntity *route in routesToDelete) {
        [self.managedObjectContext deleteObject:route];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedRouteCodes removeAllObjects];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
}

-(NSArray *)fetchAllSavedRoutesFromCoreData{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    //[request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    //[request setPropertiesToFetch :[NSArray arrayWithObjects: @"set_id",  @"title",  @"subject",  @"url",  @"score",  @"views",  @"created",  @"last_modified",  @"card_count",  @"access", nil]];
    
    NSError *error = nil;
    
    NSArray *savedRoutes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedRoutes count] != 0) {
        return savedRoutes;
    }
    
    return nil;
}

-(void)fetchAllSavedRouteCodesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"routeUniqueName"]];
    
    NSError *error = nil;
    
    NSArray *savedRouteCodes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedRouteCodes count] != 0) {
        allSavedRouteCodes = [self simplifyCoreDataDictionaryArray:savedRouteCodes withKey:@"routeUniqueName"] ;
    } else {
        allSavedRouteCodes = [[NSMutableArray alloc] init];
    }
}

-(RouteEntity *)fetchSavedRouteFromCoreDataForCode:(NSString *)code{
    
    NSString *predString = [NSString stringWithFormat:
                            @"routeUniqueName == '%@'", code];
    
    NSArray *savedRoutes = [self fetchSavedRouteFromCoreDataForPredicateString:predString];
    
    if (savedRoutes && savedRoutes.count > 0)
        return savedRoutes[0];

    return nil;
}

-(NSArray *)fetchSavedRouteFromCoreDataForNamedBookmarkName:(NSString *)bookmarkName{
    NSString *predString = [NSString stringWithFormat:
                            @"fromLocationName == '%@' || toLocationName == '%@'", bookmarkName, bookmarkName];
    
    return [self fetchSavedRouteFromCoreDataForPredicateString:predString];
}

-(NSArray *)fetchSavedRouteFromCoreDataForPredicateString:(NSString *)predString{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedRoutes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return savedRoutes;
}

#pragma mark - named bookmark methods
-(NamedBookmark *)saveNamedBookmarkToCoreData:(NamedBookmark *)ndBookmark{
    if (ndBookmark == nil)
        return nil;
    
    //Check for existence here first
    if(![self doesNamedBookmarkExistWithName:ndBookmark.name]){
        self.namedBookmark = (NamedBookmark *)[NSEntityDescription insertNewObjectForEntityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
        self.namedBookmark.order = [NSNumber numberWithInteger:allNamedBookmarkNames.count + 1];
        
        [allNamedBookmarkNames addObject:ndBookmark.name];
    }else{
        self.namedBookmark = [self fetchSavedNamedBookmarkFromCoreDataForName:ndBookmark.name];
        
        //Delete the existing one from iCloud
        [self deleteNamedBookmarksFromICloud:@[self.namedBookmark]];
    }
    
    [self.namedBookmark setName:ndBookmark.name];
    [self.namedBookmark setStreetAddress:ndBookmark.streetAddress];
    [self.namedBookmark setCity:ndBookmark.city];
    [self.namedBookmark setSearchedName:ndBookmark.searchedName];
    [self.namedBookmark setCoords:ndBookmark.coords];
    [self.namedBookmark setIconPictureName:ndBookmark.iconPictureName];
    [self.namedBookmark setMonochromeIconName:ndBookmark.monochromeIconName];
    
    [self saveManagedObject:namedBookmark];
    
    [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
    [self updateSavedNamedBookmarksToICloud];
    [self updateNamedBookmarksUserDefaultValue];
    [self updateSavedAndHistoryRoutesForNamedBookmark:self.namedBookmark];
    
    return self.namedBookmark;
}

-(NamedBookmark *)createOrUpdateNamedBookmarkFromICLoudRecord:(CKRecord *)record {
    if (!record)
        return nil;
    
    NSDictionary *dict = [ICloudManager ckrecordAsDictionary:record];
    NamedBookmark *bookmark;
    
    if(![self doesNamedBookmarkExistWithName:dict[kNamedBookmarkName]]){
        bookmark = [[NamedBookmark alloc] initWithDictionary:dict andManagedObjectContext:self.managedObjectContext];
        self.namedBookmark.order = [NSNumber numberWithInteger:allNamedBookmarkNames.count + 1];
        
        [allNamedBookmarkNames addObject:bookmark.name];
    }else{
        bookmark = [self fetchSavedNamedBookmarkFromCoreDataForName:dict[kNamedBookmarkName]];
        
        //Delete the existing one from iCloud
        [self deleteNamedBookmarksFromICloud:@[bookmark]];
        
        [bookmark updateValuesFromDictionary:dict];
    }
    
    [self saveManagedObject:bookmark];
    
    [allNamedBookmarkNames addObject:bookmark.name];
    
    [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
    [self updateNamedBookmarksUserDefaultValue];
    [self updateSavedAndHistoryRoutesForNamedBookmark:bookmark];
    
    return bookmark;
}

-(NamedBookmark *)updateNamedBookmarkToCoreDataWithID:(NSNumber *)objectLid withNamedBookmark:(NamedBookmark *)ndBookmark{
    //Check for existence here first
    if (ndBookmark == nil)
        return nil;
    
    self.namedBookmark = [self fetchSavedNamedBookmarkFromCoreDataForObjectLid:objectLid];
    
    if(self.namedBookmark != nil){
        [self deleteNamedBookmarksFromICloud:@[self.namedBookmark]];
        
        [self.namedBookmark setName:ndBookmark.name];
        [self.namedBookmark setStreetAddress:ndBookmark.streetAddress];
        [self.namedBookmark setCity:ndBookmark.city];
        [self.namedBookmark setSearchedName:ndBookmark.searchedName];
        [self.namedBookmark setCoords:ndBookmark.coords];
        [self.namedBookmark setIconPictureName:ndBookmark.iconPictureName];
        [self.namedBookmark setMonochromeIconName:ndBookmark.monochromeIconName];
        
        NSError *error = nil;
        
        if (![namedBookmark.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
        [[ReittiSearchManager sharedManager] updateSearchableIndexes];
        [self updateSavedNamedBookmarksToICloud];
        [self updateNamedBookmarksUserDefaultValue];
        [self updateSavedAndHistoryRoutesForNamedBookmark:self.namedBookmark];
        
        return self.namedBookmark;
    }else{
        return nil;
    }
}


-(void)deleteNamedBookmarkForName:(NSString *)name{
    NamedBookmark *bookmarkToDelete = [self fetchSavedNamedBookmarkFromCoreDataForName:name];
    
    if (!bookmarkToDelete)
        return;
    
    [self deleteNamedBookmarksFromICloud:@[bookmarkToDelete]];
    [self deleteSavedAndHistoryRoutesForNamedBookmark:bookmarkToDelete];
    
    [self.managedObjectContext deleteObject:bookmarkToDelete];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    //Update orders
    [allNamedBookmarkNames removeObject:name];
    
    [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
    [self updateNamedBookmarksUserDefaultValue];
}

-(void)deleteAllNamedBookmarks{
    NSArray *bookmarksToDelete = [self fetchAllSavedNamedBookmarksFromCoreData];
    
    [self deleteNamedBookmarksFromICloud:bookmarksToDelete];
    for (NamedBookmark *bookmark in bookmarksToDelete) {
        [self deleteSavedAndHistoryRoutesForNamedBookmark:bookmark];
        
        [self.managedObjectContext deleteObject:bookmark];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object.", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allNamedBookmarkNames removeAllObjects];
    
    [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
    [self updateNamedBookmarksUserDefaultValue];
}

-(void)deleteSavedAndHistoryRoutesForNamedBookmark:(NamedBookmark *)bookmark{
    NSArray *savedRoutes = [self fetchSavedRouteFromCoreDataForNamedBookmarkName:bookmark.name];
    
    for (RouteEntity *entity in savedRoutes) {
        [self deleteSavedRouteForCode:entity.routeUniqueName];
    }
    
    NSArray *historyRoutes = [self fetchRouteHistoryFromCoreDataForNamedBookmarkName:bookmark.name];
    
    for (RouteHistoryEntity *entity in historyRoutes) {
        [self deleteHistoryRouteForCode:entity.routeUniqueName];
    }
    
    [[ReittiRemindersManager sharedManger] updateRoutineForDeletedBookmarkNamed:bookmark.name];
}

-(void)updateSavedAndHistoryRoutesForNamedBookmark:(NamedBookmark *)bookmark{
    NSArray *savedRoutes = [self fetchSavedRouteFromCoreDataForNamedBookmarkName:bookmark.name];
    
    for (RouteEntity *entity in savedRoutes) {
        if ([entity.toLocationName isEqualToString:bookmark.name]) {
            entity.toLocationCoordsString = bookmark.coords;
        }
        
        if ([entity.fromLocationName isEqualToString:bookmark.name]) {
            entity.fromLocationCoordsString = bookmark.coords;
        }
        
        [self saveManagedObject:entity];
    }
    
    NSArray *historyRoutes = [self fetchRouteHistoryFromCoreDataForNamedBookmarkName:bookmark.name];
    
    for (RouteHistoryEntity *entity in historyRoutes) {
        if ([entity.toLocationName isEqualToString:bookmark.name]) {
            entity.toLocationCoordsString = bookmark.coords;
        }
        
        if ([entity.fromLocationName isEqualToString:bookmark.name]) {
            entity.fromLocationCoordsString = bookmark.coords;
        }
        
        [self saveManagedObject:entity];
    }
    
    [[ReittiRemindersManager sharedManger] updateRoutineForDeletedBookmarkNamed:bookmark.name];
}

-(void)updateRoutinesForChangeInNamedBookmarkNamed:(NSString *)bookmarkName{
    
}

-(NSArray *)fetchAllSavedNamedBookmarksFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    [request setReturnsDistinctResults:YES];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    
    NSArray *savedBookmarks = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedBookmarks count] != 0) {
        return savedBookmarks;
    }
    
    return nil;
}

-(BOOL)doesNamedBookmarkExistWithName:(NSString *)name{
    return [allNamedBookmarkNames containsObject:name];
}

-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForName:(NSString *)name{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"name == '%@'", name];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedBookmarks = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedBookmarks count] != 0) {
        return [savedBookmarks objectAtIndex:0];
    }
    
    return nil;
}

-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForCoords:(NSString *)coords{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"coords == '%@'", coords];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedBookmarks = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedBookmarks count] != 0) {
        return [savedBookmarks objectAtIndex:0];
    }
    
    return nil;
}

-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForObjectLid:(NSNumber *)objectLid{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"objectLID == %@", objectLid];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedBookmarks = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedBookmarks count] != 0) {
        return [savedBookmarks objectAtIndex:0];
    }
    
    return nil;
}

-(void)fetchAllNamedBookmarkNamesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"name"]];
    
    NSError *error = nil;
    
    NSArray *bookmarkNames = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([bookmarkNames count] != 0) {
        allNamedBookmarkNames = [self simplifyCoreDataDictionaryArray:bookmarkNames withKey:@"name"] ;
    }
    else {
        allNamedBookmarkNames = [[NSMutableArray alloc] init];
    }
}

#pragma mark - route history core data methods
-(BOOL)saveRouteHistoryToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation toCoords:(NSString *)toCoords{
    //Check for existence here first
    
    if (fromLocation == nil || fromCoords == nil || toLocation == nil || toCoords == nil ||
        fromLocation.length == 0 || fromCoords.length == 0 || toLocation.length == 0 || toCoords.length == 0) {
        return NO;
    }
    
    NSString *uniqueCode = [RettiDataManager generateUniqueRouteNameFor:fromLocation andToLoc:toLocation];
    if(![allRouteHistoryCodes containsObject:uniqueCode] && uniqueCode != nil){
        self.routeHistoryEntity= (RouteHistoryEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"RouteHistoryEntity" inManagedObjectContext:self.managedObjectContext];
        //set default values
        [self.routeHistoryEntity setRouteUniqueName:uniqueCode];
        [self.routeHistoryEntity setFromLocationName:fromLocation];
        [self.routeHistoryEntity setFromLocationCoordsString:fromCoords];
        [self.routeHistoryEntity setToLocationName:toLocation];
        [self.routeHistoryEntity setToLocationCoordsString:toCoords];
        
        [self saveManagedObject:routeHistoryEntity];
        
        [allRouteHistoryCodes addObject:uniqueCode];
        return YES;
    }else if (uniqueCode == nil){
        return NO;
    }else{
        self.routeHistoryEntity = [self fetchRouteHistoryFromCoreDataForCode:uniqueCode];
        
        [self saveManagedObject:routeHistoryEntity];
        
        return YES;
    }
}

-(void)deleteHistoryRouteForCode:(NSString *)code{
    RouteHistoryEntity *historyToDelete = [self fetchRouteHistoryFromCoreDataForCode:code];
    
    [self.managedObjectContext deleteObject:historyToDelete];
    
    NSError *error = nil;
    if (![historyToDelete.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allRouteHistoryCodes removeObject:code];
}

-(void)deleteAllHistoryRoutes{
    NSArray *historyToDelete = [self fetchAllSavedRouteHistoryFromCoreData];
    
    for (RouteHistoryEntity *route in historyToDelete) {
        [self.managedObjectContext deleteObject:route];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allRouteHistoryCodes removeAllObjects];
}

-(NSArray *)fetchAllSavedRouteHistoryFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteHistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"objectLID" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    [request setReturnsDistinctResults:YES];
    
    NSError *error = nil;
    
    NSArray *recentRoutes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentRoutes count] != 0) {
        return recentRoutes;
    }
    
    return nil;
}

-(RouteHistoryEntity *)fetchRouteHistoryFromCoreDataForCode:(NSString *)code{
    
    NSString *predString = [NSString stringWithFormat:
                            @"routeUniqueName == '%@'", code];
    
    NSArray *routesEntities = [self fetchRouteHistoryFromCoreDataForPredicateString:predString];
    
    if (routesEntities && routesEntities.count > 0)
        return routesEntities[0];
    
    return nil;
}

-(NSArray *)fetchRouteHistoryFromCoreDataForNamedBookmarkName:(NSString *)bookmarkName{
    NSString *predString = [NSString stringWithFormat:
                            @"fromLocationName == '%@' || toLocationName == '%@'", bookmarkName, bookmarkName];
    
    return [self fetchRouteHistoryFromCoreDataForPredicateString:predString];
}

-(NSArray *)fetchRouteHistoryFromCoreDataForPredicateString:(NSString *)predString{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteHistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *recentRoutes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return recentRoutes;
}

-(void)fetchAllRouteHistoryCodesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteHistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"objectLID" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"routeUniqueName"]];
    
    NSError *error = nil;
    
    NSArray *recentRouteCodes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentRouteCodes count] != 0) {
        allRouteHistoryCodes = [self simplifyCoreDataDictionaryArray:recentRouteCodes withKey:@"routeUniqueName"] ;
    }
    else {
        allRouteHistoryCodes = [[NSMutableArray alloc] init];
    }
}

-(NSMutableArray *)simplifyCoreDataDictionaryArray:(NSArray *)array withKey:(NSString *)key{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NSDictionary * dict in array) {
        [retArray addObject:[dict objectForKey:key]];
    }
    return retArray;
}

-(BOOL)doVersion4_1CoreDataMigration{
    
    //Migration due to addition of monochromepicture
    NSArray *namedBookmarks = [self fetchAllSavedNamedBookmarksFromCoreData];
    for (NamedBookmark *ndBookmark in namedBookmarks) {
        if (ndBookmark.monochromeIconName == nil) {
            ndBookmark.monochromeIconName = [NamedBookmark getMonochromePictureNameForColorPicture:ndBookmark.iconPictureName];
            [self saveNamedBookmarkToCoreData:ndBookmark];
        }
    }
    
    //migration due to stopLines array format change
    NSArray *savedStops = [self fetchAllSavedStopsFromCoreData];
    for (StopEntity *stop in savedStops) {
        if (stop.stopLines && stop.stopLines.count > 0 && [stop.stopLines isKindOfClass:[NSDictionary class]]) {
            //Stops lines were just the dictionary and there were not used anywhere anyways. So just remove them
            stop.stopLines = @[];
            [self saveManagedObject:stop];
        }
    }
    
    return YES;
}

-(void)doVersion16CoreDataMigration{
    
    //Migration due to addition orders
    NSArray *namedBookmarks = [self fetchAllSavedNamedBookmarksFromCoreData];
    NSArray *savedStops = [self fetchAllSavedStopsFromCoreData];
    NSArray *savedRoutes = [self fetchAllSavedRoutesFromCoreData];
    
    [self updateOrderedManagedObjectOrderTo:namedBookmarks];
    [self updateOrderedManagedObjectOrderTo:savedStops];
    [self updateOrderedManagedObjectOrderTo:savedRoutes];
}

#pragma mark - ICloud methods
- (void)fetchallBookmarksFromICloudWithCompletionHandler:(ActionBlock)completionHandler {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    [[ICloudManager sharedManager] fetchAllBookmarksWithCompletionHandler:completionHandler];
}

- (void)updateSavedNamedBookmarksToICloud {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    NSArray *namedBookmarks = [self fetchAllSavedNamedBookmarksFromCoreData];
    [[ICloudManager sharedManager] saveNamedBookmarksToICloud:namedBookmarks];
}

- (void)deleteNamedBookmarksFromICloud:(NSArray *)namedBookmarks {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    [[ICloudManager sharedManager] deleteNamedBookmarksFromICloud:namedBookmarks];
}

- (void)updateSavedStopsToICloud {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    NSArray *stops = [self fetchAllSavedStopsFromCoreData];
    [[ICloudManager sharedManager] saveStopsToICloud:stops];
}

- (void)deleteStopsFromICloud:(NSArray *)stops {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    [[ICloudManager sharedManager] deleteSavedStopsFromICloud:stops
     ];
}

- (void)updateSavedRoutesToICloud {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    NSArray *routes = [self fetchAllSavedRoutesFromCoreData];
    [[ICloudManager sharedManager] saveRoutesToICloud:routes];
}

- (void)deleteRoutesFromICloud:(NSArray *)routes {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    [[ICloudManager sharedManager] deleteSavedRoutesFromICloud:routes];
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SettingsManagerUserLocationChangedNotification" object:nil];
}

@end
