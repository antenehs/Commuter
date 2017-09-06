//
//  RettiDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RettiDataManager.h"
#import <MapKit/MapKit.h>
#import "ApiProtocols.h"
#import "ASA_Helpers.h"
#import "AppManager.h"
#import "ReittiRemindersManager.h"
#import "DigiTransitCommunicator.h"
#import "MatkaTransportTypeManager.h"
#import "ReittiModels.h"
#import "SettingsManager.h"
#import "AppFeatureManager.h"

@interface RettiDataManager ()

@property (strong, nonatomic)HSLCommunication *hslCommunication;
@property (strong, nonatomic)TRECommunication *treCommunication;

@property (nonatomic, strong)DigiTransitCommunicator *hslDigitransitCommunicator;
@property (nonatomic, strong)DigiTransitCommunicator *finlandDigitransitCommunicator;

@property(nonatomic, strong) HSLLiveTrafficManager *hslLiveTrafficManager;
@property(nonatomic, strong) TRELiveTrafficManager *treLiveTrafficManager;
@property(nonatomic, strong) CacheManager *cacheManager;

@property (nonatomic, strong)SettingsManager *settingsManager;
@property (nonatomic, strong)ReittiRegionManager *reittiRegionManager;

@end

@implementation RettiDataManager

@synthesize hslCommunication, treCommunication;
@synthesize userLocationRegion;
@synthesize hslLiveTrafficManager, treLiveTrafficManager, cacheManager, reittiRegionManager;

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
        [self initElements];
    }
    
    return self;
}

-(void)initElements {
    
    self.hslCommunication = [[HSLCommunication alloc] init];
    self.treCommunication = [[TRECommunication alloc] init];;
    
    self.hslDigitransitCommunicator = [DigiTransitCommunicator hslDigiTransitCommunicator];
    self.finlandDigitransitCommunicator = [DigiTransitCommunicator finlandDigiTransitCommunicator];
    
    self.hslLiveTrafficManager = [[HSLLiveTrafficManager alloc] init];
    self.treLiveTrafficManager = [[TRELiveTrafficManager alloc] init];
    
    self.settingsManager = [SettingsManager sharedManager];
    self.userLocationRegion = [self.settingsManager userLocation];
    
    self.reittiRegionManager = [ReittiRegionManager sharedManager];
    
    self.cacheManager = [CacheManager sharedManager];
    
    HSLGeocodeResposeQueue = [@[] mutableCopy];
    TREGeocodeResponseQueue = [@[] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userlocationChangedNotificationName object:nil];
}

-(void)userLocationSettingsValueChanged:(NSNotificationCenter *)notification{
    self.userLocationRegion = [self.settingsManager userLocation];
}

-(void)resetResponseQueues{
    [HSLGeocodeResposeQueue removeAllObjects];
    [TREGeocodeResponseQueue removeAllObjects];
}

#pragma mark - regional datasource
-(ReittiApi)getApiForRegion:(Region)region {
    if ([SettingsManager useDigiTransit]) {
        if (region == HSLRegion) {
            return ReittiDigiTransitHslApi;
        } else {
            return ReittiDigiTransitApi;
        }
    } else {
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
}

-(id)getDataSourceForApi:(ReittiApi)api {
    if (api == ReittiHSLApi) {
        return self.hslCommunication;
    } else if (api == ReittiTREApi) {
        return self.treCommunication;
    } else if (api == ReittiDigiTransitHslApi) {
        return self.hslDigitransitCommunicator;
    } else {
        return self.finlandDigitransitCommunicator;
    }
}

-(id)getDataSourceForCurrentRegion{
    return [self getDataSourceForRegion:userLocationRegion];
}

-(id)getDataSourceForRegion:(Region)region{
    return [self getDataSourceForApi:[self getApiForRegion:region]];
}

-(id)getLiveTrafficManagerForCurrentRegion{
    return [self getLiveTrafficManagerForRegion:userLocationRegion];
}

-(id)getLiveTrafficManagerForRegion:(Region)region{
    if ([SettingsManager useDigiTransit]) {
        if (region == TRERegion) {
            return self.treLiveTrafficManager;
        }else if(region == HSLRegion){
            return self.hslDigitransitCommunicator;
        }else{
            return nil;
        }
    } else {
        if (region == TRERegion) {
            return self.treLiveTrafficManager;
        }else if(region == HSLRegion){
            return self.hslLiveTrafficManager;
        }else{
            return nil;
        }
    }
}

#pragma mark - Annotation filter options
-(NSArray *)annotationFilterOptions {
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(AnnotationFilterOptionProtocol)]) {
        return [(NSObject<AnnotationFilterOptionProtocol> *)dataSourceManager annotationFilterOptions];
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

-(NSArray *)getDefaultTransportTypeNames {
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchOptionProtocol)]) {
        return [(NSObject<RouteSearchOptionProtocol> *)dataSourceManager getDefaultTransportTypeNames];
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
-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andSearchOption:(RouteSearchOptions *)searchOptions andNumberOfResult:(NSNumber *)numberOfResult andCompletionBlock:(ActionBlock)completionBlock{
    
    CLLocationCoordinate2D fromCoordinates = [ReittiStringFormatter convertStringTo2DCoord:fromCoords];
    CLLocationCoordinate2D toCoordinates = [ReittiStringFormatter convertStringTo2DCoord:toCoords];
    
    if ([reittiRegionManager areCoordinatesInTheSameRegion:fromCoordinates andCoordinate:toCoordinates]) {
        Region fromRegion = [reittiRegionManager identifyRegionOfCoordinate:fromCoordinates];
        
        id dataSourceManager = [self getDataSourceForRegion:fromRegion];
        
        if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchProtocol)]) {
            if (numberOfResult)
                searchOptions.numberOfResults = [numberOfResult integerValue];
            else
                searchOptions.numberOfResults = kDefaultNumberOfResults;
            
            [(NSObject<RouteSearchProtocol> *)dataSourceManager searchRouteForFromCoords:fromCoordinates andToCoords:toCoordinates withOptions:searchOptions andCompletionBlock:^(NSArray * response, NSString *error){
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
        
        id dataSourceManager = [self getDataSourceForRegion:FINRegion];
        ReittiApi usedApi = [self getApiForRegion:FINRegion];
        
        [(NSObject<RouteSearchProtocol> *)dataSourceManager searchRouteForFromCoords:fromCoordinates andToCoords:toCoordinates withOptions:searchOptions andCompletionBlock:^(NSArray * response, NSString *error){
            if (!error) {
                completionBlock(response, nil, usedApi);
            }else{
                completionBlock(nil, error, usedApi);
            }
        }];
    }
}

-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andCompletionBlock:(ActionBlock)completionBlock{
    
    RouteSearchOptions *options = [self.settingsManager globalRouteOptions];
    options.date = [NSDate date];
    
    [self searchRouteForFromCoords:fromCoords andToCoords:toCoords andSearchOption:options andNumberOfResult:nil andCompletionBlock:completionBlock];
}

//Needed to avoid making default search that returns 3 results and hence slower
-(void)getFirstRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords andCompletionBlock:(ActionBlock)completionBlock{
    
    RouteSearchOptions *options = [self.settingsManager globalRouteOptions];
    options.date = [NSDate date];
    
    [self searchRouteForFromCoords:fromCoords andToCoords:toCoords andSearchOption:options andNumberOfResult:@1 andCompletionBlock:completionBlock];
}


#pragma mark - stop in area search methods
-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion withCompletionBlock:(ActionBlock)completionBlock {
    [self fetchStopsInAreaForRegion:mapRegion fetchFromApi:ReittiAutomaticApi withCompletionBlock:completionBlock];
}

-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock{
    id dataSourceManager = nil;
    ReittiApi usedApi = api;
    if (api == ReittiAutomaticApi) {
        Region centerRegion = [reittiRegionManager identifyRegionOfCoordinate:mapRegion.center];
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

#pragma mark - stop detail search methods
-(void)fetchStopsForSearchParams:(RTStopSearchParam *)searchParams andCoords:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock {
    Region region = [reittiRegionManager identifyRegionOfCoordinate:coords];
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
                
//                __block BusStop *fetchedStop = response;
//                if (searchParams.stopName && searchParams.shortCode) {
//                    [self fetchRealtimeDeparturesForStopName:searchParams.stopName andShortCode:searchParams.shortCode fetchFromApi:usedApi withCompletionHandler:^(NSArray *realDepartures, NSString *errorString){
//                        if (!realDepartures || realDepartures.count == 0 || errorString) return;
//                        [fetchedStop updateDeparturesFromRealtimeDepartures:realDepartures];
//                        completionBlock(fetchedStop, nil, usedApi);
//                    }];
//                }
                
            } else {
                completionBlock(nil, error, usedApi);
            }
        }];
        
    }else{
        [self.finlandDigitransitCommunicator fetchStopDetailForCode:searchParams.longCode withCompletionBlock:^(BusStop * response, NSString *error){
            if (!error) {
                response.fetchedFromApi = ReittiDigiTransitApi;
                completionBlock(response, nil, ReittiDigiTransitApi);
                
//                __block BusStop *fetchedStop = response;
//                if (searchParams.stopName && searchParams.shortCode) {
//                    [self fetchRealtimeDeparturesForStopName:searchParams.stopName andShortCode:searchParams.shortCode fetchFromApi:usedApi withCompletionHandler:^(NSArray *realDepartures, NSString *errorString){
//                        if (!realDepartures || realDepartures.count == 0 || errorString) return;
//                        [fetchedStop updateDeparturesFromRealtimeDepartures:realDepartures];
//                        completionBlock(fetchedStop, nil, usedApi);
//                    }];
//                }
            }else{
                completionBlock(nil, @"Fetching stop detail failed. Please try again later.", ReittiDigiTransitApi);
            }
        }];
    }

}

#pragma mark - Line search methods
//This method should return a short line without patterns
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
    Region region = [reittiRegionManager identifyRegionOfCoordinate:coords];
    id dataSourceManager = [self getDataSourceForRegion:region];
    
    if ([dataSourceManager conformsToProtocol:@protocol(ReverseGeocodeProtocol)]) {
        [(NSObject<ReverseGeocodeProtocol> *)dataSourceManager searchAddresseForCoordinate:coords withCompletionBlock:completionBlock];
    }else{
        completionBlock(nil, @"Service not available in the current region.");
    }
}

#pragma mark - Address fetch methods
-(void)searchAddressesForKey:(NSString *)key withCompletionBlock:(ActionBlock)completionBlock {
    id dataSourceManager = [self getDataSourceForCurrentRegion];
    
    if ([dataSourceManager conformsToProtocol:@protocol(GeocodeProtocol)]) {
        ArrayFetchBlock reittiFetchBlock = ^(FetchedArrayBlock completed) {
            [(NSObject<GeocodeProtocol> *)dataSourceManager searchGeocodeForSearchTerm:key withCompletionBlock:^(NSArray * response, NSString *error){
                completed(response);
            }];
        };
        
        ArrayFetchBlock appleFetchBlock = ^(FetchedArrayBlock completed) {
            [self searchAddressFromAppleForKey:key withCompletionBlock:^(NSArray *response, NSString *searchKey){
                completed(response);
            }];
        };
        
        [self asa_ExecuteFetchObjectBlocksWithFetchers:@[reittiFetchBlock,appleFetchBlock] withCompletion:^(NSArray *result) {
            completionBlock(result, key, nil);
        }];
    }else{
        [self.finlandDigitransitCommunicator searchGeocodeForSearchTerm:key withCompletionBlock:^(NSArray * response, NSString *error){
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

#pragma mark - Disruption fetch methods
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

#pragma mark - Bike search methods
-(void)startFetchingBikeStationsWithCompletionBlock:(ActionBlock)completionBlock {
    if (![AppFeatureManager proFeaturesAvailable]) return;
    
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
    [self.hslDigitransitCommunicator stopFetchingVehicles];
}

@end
