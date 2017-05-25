//
//  DigiTransitCommunicator.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DigiTransitCommunicator.h"
#import "DigiDataModels.h"
#import "ReittiStringFormatter.h"
#import "ReittiMapkitHelper.h"
#import "ReittiDateHelper.h"
#import "GraphQLQuery.h"
#import "ReittiModels.h"
#import "BikeStation.h"
#import "DigiAlert.h"
#import "AnnotationFilter.h"
#import "ASA_Helpers.h"
#import "DigiRouteOptionManager.h"

#if MAIN_APP
#import "ReittiAnalyticsManager.h"
#import "StopDeparture.h"
#import "Line.h"
#endif

NSString *kHslDigiTransitGraphQlUrl = @"https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql";
NSString *kFinlandDigiTransitGraphQlUrl = @"https://api.digitransit.fi/routing/v1/routers/finland/index/graphql";

NSString *kDigiLineCodesKey = @"lineCodes";

typedef enum : NSUInteger {
    HslApi,
    TreApi,
    FinlandApi,
} DigiTransitSource;

@interface DigiTransitCommunicator ()

@property (nonatomic)DigiTransitSource source;

@property (nonatomic, strong) APIClient *addressSearchClient;
@property (nonatomic, strong) APIClient *addressReverseClient;
@property (nonatomic, strong) APIClient *liveVehicleFetchClient;

@property (nonatomic, strong) NSDictionary *searchFilterBoundary;

@property (nonatomic) ActionBlock bikeFetchingCompletionHandler;
@property (nonatomic, strong)NSTimer *bikeFetchUpdateTimer;

@property (nonatomic) ActionBlock vehicleFetchingCompletionHandler;
@property (nonatomic, strong)NSTimer *vehicleFetchUpdateTimer;

@end

@implementation DigiTransitCommunicator

+(id)hslDigiTransitCommunicator {
    DigiTransitCommunicator *communicator = [DigiTransitCommunicator new];
    communicator.apiBaseUrl = kHslDigiTransitGraphQlUrl;
    communicator.source = HslApi;
    
    communicator.searchFilterBoundary = @{@"boundary.rect.min_lon" : @"24.332469",
                                          @"boundary.rect.min_lat" : @"59.917154",
                                          @"boundary.rect.max_lon" : @"25.507191",
                                          @"boundary.rect.max_lat" : @"60.456700"};
    
    communicator.liveVehicleFetchClient = [[APIClient alloc] init];
    communicator.liveVehicleFetchClient.apiBaseUrl = @"https://api.digitransit.fi/realtime/vehicle-positions/v1/siriaccess/vm/json";
    
    return communicator;
}

+(id)treDigiTransitCommunicator {
    DigiTransitCommunicator *communicator = [DigiTransitCommunicator new];
    communicator.apiBaseUrl = kFinlandDigiTransitGraphQlUrl;
    communicator.source = TreApi;
    return communicator;
}

+(id)finlandDigiTransitCommunicator {
    DigiTransitCommunicator *communicator = [DigiTransitCommunicator new];
    communicator.apiBaseUrl = kFinlandDigiTransitGraphQlUrl;
    communicator.source = FinlandApi;
    return communicator;
}

-(id)init {
    self = [super init];
    if (self) {
        self.addressSearchClient = [[APIClient alloc] init];
        self.addressSearchClient.apiBaseUrl = @"https://api.digitransit.fi/geocoding/v1/search";
        
        self.addressReverseClient = [[APIClient alloc] init];
        self.addressReverseClient.apiBaseUrl = @"https://api.digitransit.fi/geocoding/v1/reverse";
    }
    
    return self;
}

#pragma mark - Stop in area fetching methods
- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock {
    
    [super doGraphQlQuery:[self stopInAreadGraphQlQueryForRegionCenterCoords:regionCenter andDiameter:diameter] mappingDiscriptor:[DigiStopAtDistance mappingDescriptorForPath:@"data.stopsByRadius.edges"] andCompletionBlock:^(NSArray *stops, NSError *error){
        if (!error && stops.count > 0) {
            NSMutableArray *allStops = [@[] mutableCopy];
            for (DigiStopAtDistance *stopAtDist in stops) {
                [allStops addObject:stopAtDist.stop.reittiBusStop];
            }
            completionBlock(allStops, nil);
        } else {
            completionBlock(nil, [self formattedNearbyStopSearchErrorMessageForError:error]);//Proper error message here.
        }
    }];
    
}

-(NSString *)stopInAreadGraphQlQueryForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter {
    
    return [GraphQLQuery stopInAreaQueryStringWithArguments:@{@"lat" : [NSNumber numberWithDouble:regionCenter.latitude],
                                                              @"lon" : [NSNumber numberWithDouble:regionCenter.longitude],
                                                              @"radius": [NSNumber numberWithInteger:diameter/2]}];
}

-(NSString *)formattedNearbyStopSearchErrorMessageForError:(NSError *)error{
    if(!error) return nil;
    
    NSString *errorString = [self formatCommonCaseErrorMessageForError:error];
    
    switch (error.code) {
        case -1011:
            errorString = @"Nearby stops service not available in this area.";
            break;
        case -1016:
            errorString = @"No stops information available for the selected region.";
            break;
        default:
            break;
    }
    
    return errorString ? errorString : @"Unknown Error Occured.";
}

#pragma mark - Stop detail fetching
- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock {
    if (!stopCode)  {
        completionBlock(nil, @"No stopCode");
        return;
    }
    
    [self fetchStopsForIds:@[stopCode] withCompletionBlock:^(NSArray *stops, NSString *error){
        if (!error && stops.count > 0) {
            completionBlock(stops.firstObject, nil);
        } else {
            completionBlock(nil, error);
        }
    }];
}

-(void)fetchStopsForIds:(NSArray *)stopIds withCompletionBlock:(ActionBlock)completionBlock {
    if (!stopIds || stopIds.count < 1){
        completionBlock(nil, @"No Stop Ids");
        return;
    }
    
    [super doGraphQlQuery:[self stopGraphQlQueryForArguments:@{@"ids" : stopIds }] mappingDiscriptor:[DigiStop mappingDescriptorForPath:@"data.stops"] andCompletionBlock:^(NSArray *stops, NSError *error){
        if (!error && stops.count > 0) {
            NSMutableArray *allStops = [@[] mutableCopy];
            for (DigiStop *digiStop in stops) {
                [allStops addObject:digiStop.reittiBusStop];
            }
            completionBlock(allStops, nil);
        } else {
            completionBlock(nil, [self formattedStopDetailFetchErrorMessageForError:error]);
        }
    }];
}

-(void)fetchStopsForName:(NSString *)stopName withCompletionBlock:(ActionBlock)completionBlock {
    if (!stopName){
        completionBlock(nil, @"No Stop Name");
        return;
    }
    
    [super doGraphQlQuery:[self stopGraphQlQueryForArguments:@{@"name" : stopName}] mappingDiscriptor:[DigiStop mappingDescriptorForPath:@"data.stops"] andCompletionBlock:^(NSArray *stops, NSError *error){
        if (!error) {
            completionBlock(stops, nil);
        } else {
            completionBlock(nil, [self formattedStopDetailFetchErrorMessageForError:error]);
        }
    }];
}

-(NSString *)stopGraphQlQueryForArguments:(NSDictionary *)arguments {
    return [GraphQLQuery stopQueryStringWithArguments:arguments];
}

-(NSString *)formattedStopDetailFetchErrorMessageForError:(NSError *)error{
    if(!error) return nil;
    
    NSString *errorString = [self formatCommonCaseErrorMessageForError:error];
    if(errorString) return errorString;
    
    return @"Unknown Error Occured. Please try again.";
}

#pragma mark - Realtime departure fetching methods
#if MAIN_APP
-(void)fetchRealtimeDeparturesForStopName:(NSString *)name andShortCode:(NSString *)code withCompletionHandler:(ActionBlock)completionBlock {
    //Use code as name in case of HSL region
    [self fetchDeparturesForStopName:code withCompletionHandler:completionBlock];
}

-(void)fetchDeparturesForStopName:(NSString *)name withCompletionHandler:(ActionBlock)completionBlock {
    [self fetchStopsForName:name withCompletionBlock:^(NSArray *stops, NSString *errorString){
        //Filter applicable stops
        if (!errorString && stops.count > 0) {
            NSMutableArray *allDepartures = [@[] mutableCopy];
            for (DigiStop *digiStop in stops) {
                for (DigiStoptime *stopTime in digiStop.stoptimes) {
                    [allDepartures addObject:stopTime.reittiStopDeparture];
                }
            }
            
            completionBlock(allDepartures, nil);
        } else {
            completionBlock(nil, errorString);
        }
    }];
    
#if MAIN_APP
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedRealtimeDepartureFromApi label:@"DIGITRANSIT" value:nil];
#endif
}
#endif 

#pragma mark - Route search
-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock {
    
    NSString *queryString = [self routeGraphQlQueryForFromCoords:fromCoords andToCoords:toCoords withOptions:options];
    
    if (!queryString) {
        completionBlock(nil, @"No Coords");
        return;
    }
    
    [super doGraphQlQuery:queryString mappingDiscriptor:[DigiPlan mappingDescriptorForPath:@"data.plan.itineraries"] andCompletionBlock:^(NSArray *digiRoutes, NSError *error){
        if (!error && digiRoutes) {
            NSMutableArray *allRoutes = [@[] mutableCopy];
            for (DigiPlan *plan in digiRoutes) {
                Route *route = [Route routeFromDigiPlan:plan];
                if (route) {
                    [allRoutes addObject:route];
                }
            }
            completionBlock(allRoutes, nil);
        } else {
            completionBlock(nil, [self routeSearchErrorMessageForError:error]);
        }
    }];
    
    
}

-(NSString *)routeGraphQlQueryForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options {
    if (![ReittiMapkitHelper isValidCoordinate:fromCoords] || ![ReittiMapkitHelper isValidCoordinate:toCoords])
        return nil;
    
    NSMutableDictionary *arguments = [@{@"from" : @{@"lat": [NSNumber numberWithDouble:fromCoords.latitude], @"lon": [NSNumber numberWithDouble:fromCoords.longitude]},
                                @"to" : @{@"lat": [NSNumber numberWithDouble:toCoords.latitude], @"lon": [NSNumber numberWithDouble:toCoords.longitude]}} mutableCopy];
    [arguments addEntriesFromDictionary:[self apiRequestParametersDictionaryForRouteOptions:options]];
    return [GraphQLQuery planQueryStringWithArguments:arguments];
}

-(NSString *)routeSearchErrorMessageForError:(NSError *)error{
    if (!error) return nil;
    
    NSString *errorString = [self formatCommonCaseErrorMessageForError:error];
    
    if (error.code == -1016) {
        errorString = @"No route information available for the selected addresses.";
    }
    
    return errorString ? errorString : @"Unknown Error Occured.";
}

#pragma mark - Geocode methods
#if MAIN_APP
- (void)searchGeocodeForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    __block NSInteger requestCalls = 2;
    __block NSMutableArray *allResults = [@[] mutableCopy];
    __block NSArray *addressResults = @[];
    __block NSArray *stopResults = @[];
    
    [self fetchStopsForName:searchTerm withCompletionBlock:^(NSArray *responseArray, NSError *error){
        requestCalls--;
        if (!error && responseArray) {
            
            NSMutableArray *results = [@[] mutableCopy];
            for (DigiStop *digiStop in responseArray) {
                if (!digiStop.code && !digiStop.desc && digiStop.patterns.count == 0) continue;
                [results addObject:[GeoCode geocodeForDigiStop:digiStop]];
            }
            
            stopResults = results;
            
            if (requestCalls == 0){
                allResults = [@[] mutableCopy];
                [allResults addObjectsFromArray:addressResults];
                [allResults addObjectsFromArray:stopResults];
                completionBlock([self sortGeoCodes:allResults forSearchTerm:searchTerm], nil);
            }
        }
    }];
    
    [optionsDict setValue:searchTerm forKey:@"text"];
//    [optionsDict setValue:@"venue,street,locality" forKey:@"layers"];
//    [optionsDict setValue:@"20" forKey:@"size"];
    
    if (self.searchFilterBoundary)
        [optionsDict addEntriesFromDictionary:self.searchFilterBoundary];
    
    [self.addressSearchClient doJsonApiFetchWithParams:optionsDict mappingDescriptor:[DigiGeoCode mappingDescriptorForPath:@"features"] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        requestCalls--;
        if (!error && responseArray) {
            
            NSMutableArray *results = [@[] mutableCopy];
            for (DigiGeoCode *digiGeocode in responseArray) {
                if (digiGeocode.properties.confidence < 0.5 ) continue;
                //Ignore stops since there is no detail and separate search is done
                if (digiGeocode.locationType == LocationTypeStop) continue;
                
                [results addObject:[GeoCode geocodeForDigiGeocode:digiGeocode]];
            }
            
            addressResults = results;
            
            if (requestCalls == 0){
                allResults = [@[] mutableCopy];
                [allResults addObjectsFromArray:addressResults];
                [allResults addObjectsFromArray:stopResults];
                completionBlock([self sortGeoCodes:allResults forSearchTerm:searchTerm], nil);
            }
        }
    }];
    
#if MAIN_APP
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedAddressFromApi label:@"HSL:DIGI" value:nil];
#endif
}

-(NSArray *)sortGeoCodes:(NSArray *)addressList forSearchTerm:(NSString *)searchTerm {
    if (!addressList || !searchTerm) return addressList;
    return [addressList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [searchTerm scoreAgainst:[(GeoCode *)obj1 name]  fuzziness:@1] < [searchTerm scoreAgainst:[(GeoCode *)obj2 name]  fuzziness:@1];
    }];
}
#endif

#pragma mark - Reverese geocode methods
#if MAIN_APP
- (void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *latString = [NSString stringWithFormat:@"%f", coords.latitude];
    NSString *lonString = [NSString stringWithFormat:@"%f", coords.longitude];
    
    [optionsDict setValue:latString forKey:@"point.lat"];
    [optionsDict setValue:lonString forKey:@"point.lon"];
    [optionsDict setValue:@"address" forKey:@"layers"];
    [optionsDict setValue:@"1" forKey:@"size"];
    
    [self.addressReverseClient doJsonApiFetchWithParams:optionsDict mappingDescriptor:[DigiGeoCode mappingDescriptorForPath:@"features"] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error && responseArray && responseArray.count > 0) {
            
            completionBlock([GeoCode geocodeForDigiGeocode:responseArray[0]], nil);
        }else{
            completionBlock(nil, [self formattedReverseGeocodeFetchErrorMessageForError:error]);
        }
    }];
    
#if MAIN_APP
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedReverseGeoCodeFromApi label:@"HSL:DIGI" value:nil];
#endif
}

-(NSString *)formattedReverseGeocodeFetchErrorMessageForError:(NSError *)error{
    if(!error) return nil;
    
    NSString *errorString = [self formatCommonCaseErrorMessageForError:error];
    
    if (error.code == -1016) {
        errorString = @"No address was found for the coordinates";
    }
    
    return errorString ? errorString :  @"No address was found for the coordinates";
}
#endif

#pragma mark - Line fetch methods
- (void)fetchLinesForSearchterm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock {
    [self fetchLinesWithArguments:@{@"name" : searchTerm} withCompletionBlock:completionBlock];
}

- (void)fetchLinesForCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock {
    [self fetchLinesWithArguments:@{@"ids" : lineCodes} withCompletionBlock:completionBlock];
}

-(void)fetchLinesWithArguments:(NSDictionary *)arguments withCompletionBlock:(ActionBlock)completionBlock {
    [super doGraphQlQuery:[GraphQLQuery routeQueryStringWithArguments:arguments] mappingDiscriptor:[DigiRoute mappingDescriptorForPath:@"data.routes"] andCompletionBlock:^(NSArray *routes, NSError *error){
        //TODO: When lines not found returns empty. So filter them here. 
        if (!error) {
            NSMutableArray *allLines = [@[] mutableCopy];
            for (DigiRoute *digiRoute in routes) {
                if (digiRoute.patterns) {
                    for (DigiPattern *pattern in digiRoute.patterns) {
                        [allLines addObject:[digiRoute reittiLineForPattern:pattern]];
                    }
                } else {
                    [allLines addObject:digiRoute.reittiLine];
                }
            }
            completionBlock(allLines, nil);
        } else {
            completionBlock(nil, [self formattedLineDetailFetchErrorMessageForError:error]);//Proper error message here.
        }
    }];
}

-(NSString *)formattedLineDetailFetchErrorMessageForError:(NSError *)error{
    if(!error) return nil;
    
    NSString *errorString = [self formatCommonCaseErrorMessageForError:error];
    if (errorString) return errorString;
    
    return @"Unknown Error Occured. Please try again.";
}

#pragma mark - Bike station fetch
#if MAIN_APP
-(void)startFetchBikeStationsWithCompletionHandler:(ActionBlock)completion {
    if (self.source != HslApi) {
        completion(nil, @"City bike not available in area.");
        self.bikeFetchingCompletionHandler = nil;
        return;
    }
    [self fetchBikeStationsWithCompletionHandler:completion];
    self.bikeFetchingCompletionHandler = completion;
    self.bikeFetchUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateBikeStations) userInfo:nil repeats:YES];
}

-(void)fetchBikeStationsWithCompletionHandler:(ActionBlock)completion {
    [super doGraphQlQuery:[GraphQLQuery bikeStationsQueryString] mappingDiscriptor:[DigiBikeRentalStation mappingDescriptorForPath:@"data.bikeRentalStations"] andCompletionBlock:^(NSArray *responseArray, NSError *error) {
        if (!error && responseArray) {
            NSMutableArray *bikeStations = [@[] mutableCopy];
            for (DigiBikeRentalStation *station in responseArray) {
                [bikeStations addObject:station.bikeStation];
            }
            completion(bikeStations, nil);
        } else {
            completion(responseArray, [self formattedBikeStationFetchErrorMessageForError:error]);
        }
    }];
}

-(void)updateBikeStations {
    if (self.bikeFetchingCompletionHandler && self.source == HslApi) {
        [self fetchBikeStationsWithCompletionHandler:self.bikeFetchingCompletionHandler];
    }
}

-(void)stopFetchingBikeStations {
    self.bikeFetchingCompletionHandler = nil;
    [self.bikeFetchUpdateTimer invalidate];
}

-(NSString *)formattedBikeStationFetchErrorMessageForError:(NSError *)error{
    if(!error) return nil;
    
    NSString *errorString = [self formatCommonCaseErrorMessageForError:error];
    if (errorString) return errorString;
    
    return @"Unknown Error Occured.";
}
#endif

#pragma mark - disruption info fetch
#if MAIN_APP
-(void)fetchTrafficDisruptionsWithCompletionBlock:(ActionBlock)completionBlock {
    //Digi transit gives disruptions for whole country when there are disruptions only in HSL region
    if (self.source != HslApi) {
        completionBlock(nil, @"Service not available in the current region.");
        return;
    }
    
    [super doGraphQlQuery:[GraphQLQuery alertsQueryString] mappingDiscriptor:[DigiAlert mappingDescriptorForPath:@"data.alerts"] andCompletionBlock:^(NSArray *responseArray, NSError *error) {
        if (!error && responseArray) {
            NSMutableArray *disruptions = [@[] mutableCopy];
            for (DigiAlert *digiAlert in responseArray) {
                [disruptions addObject:[Disruption disruptionFromDigiAlert:digiAlert]];
            }
            
            completionBlock(disruptions, nil);
        } else {
            completionBlock(nil, error.localizedDescription);
        }
    }];
}
#endif

#pragma mark - LiveVehicle fetching
#if MAIN_APP
- (void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler {
    [self startFetchingAllLiveVehiclesWithCodes:nil andTrainCodes:nil withCompletionHandler:completionHandler];
}

- (void)startFetchingAllLiveVehiclesWithCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler {
    
    NSMutableArray *allVehicleCodes = [@[] mutableCopy];
    if (lineCodes) [allVehicleCodes addObjectsFromArray:lineCodes];
    if (trainCodes) [allVehicleCodes addObjectsFromArray:trainCodes];
    allVehicleCodes = allVehicleCodes ? allVehicleCodes : nil;
    
    @try {
        self.vehicleFetchingCompletionHandler = completionHandler;
        [self fetchAllLiveVehiclesWithCodes:allVehicleCodes withCompletionHandler:completionHandler];
        
        NSDictionary *userInfo = @{kDigiLineCodesKey : allVehicleCodes ? allVehicleCodes : @[]};
        self.vehicleFetchUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateLiveVehicles:) userInfo:userInfo repeats:YES];
    }
    @catch (NSException *exception) {
        completionHandler(nil, exception.reason);
    }
}

- (void)fetchAllLiveVehiclesWithCodes:(NSArray *)lineCodes withCompletionHandler:(ActionBlock)completionHandler {
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    NSArray *shortLineCodes = [self formatLineStrings:lineCodes];
    
    //Other cases will be filtered after fetched because multiple codes is not supported.
    if (lineCodes.count == 1) {
        [optionsDict setValue:shortLineCodes[0] forKey:@"lineRef"];
    }
    
    [self.liveVehicleFetchClient doJsonApiFetchWithParams:optionsDict mappingDescriptor:[DigiVehicleActivityContainer mappingDescriptorForPath:@"Siri.ServiceDelivery.VehicleMonitoringDelivery"] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        
        if (!error && responseArray.count > 0 && [[(DigiVehicleActivityContainer *)responseArray[0] vehicles] count] > 0) {
            NSArray *vehicles = [(DigiVehicleActivityContainer *)responseArray[0] vehicles];
            vehicles = vehicles ? vehicles : @[];
            vehicles = [self filterInvalidVehicles:vehicles allowBusses:lineCodes.count > 0];
            if (lineCodes.count > 1)
                vehicles = [self filterVehicles:vehicles forGtfsLineCodes:shortLineCodes];
            
            NSMutableArray *reittiVehicles = [@[] mutableCopy];
            for (DigiVehicle *vehicle in vehicles) {
                [reittiVehicles addObject:[vehicle reittiVehicle]];
            }
            
            completionHandler(reittiVehicles, nil);
        } else {
            if (lineCodes.count > 1)
                [self stopFetchingVehicles];
            
            completionHandler(nil, @"Vehicle fetching failed");
        }
        
    }];
}

-(NSArray *)filterVehicles:(NSArray *)digiVehicles forGtfsLineCodes:(NSArray *)codes {
    if (!codes || codes.count == 0) return digiVehicles;
    
    return [digiVehicles filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [codes containsObject:[(DigiVehicle *)evaluatedObject lineId]];
    }]];
}

-(NSArray *)filterInvalidVehicles:(NSArray *)digiVehicles allowBusses:(BOOL )allowBusses{
    if (!digiVehicles) return digiVehicles;
    
    return [digiVehicles filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        BOOL isMonitored = [(DigiVehicle *)evaluatedObject monitored];
        BOOL hasName = [(DigiVehicle *)evaluatedObject vehicleName];
        BOOL hasCode = [(DigiVehicle *)evaluatedObject vehicleId] && [(DigiVehicle *)evaluatedObject lineId];
        BOOL isBus = [(DigiVehicle *)evaluatedObject vehicleType] == VehicleTypeBus;
        BOOL busTypeAllowed = !allowBusses && isBus ? NO : YES;
        //Add more
        return isMonitored && hasName && hasCode && busTypeAllowed;
    }]];
}

-(void)updateLiveVehicles:(NSTimer *)timer {
    if (!self.vehicleFetchingCompletionHandler) {
        [timer invalidate];
        return;
    }
    
    NSDictionary *userInfo = [timer userInfo] ? [timer userInfo] : @{};
    [self fetchAllLiveVehiclesWithCodes:userInfo[kDigiLineCodesKey] withCompletionHandler:self.vehicleFetchingCompletionHandler];
}

-(void)stopFetchingVehicles {
    [self.vehicleFetchUpdateTimer invalidate];
    
    self.vehicleFetchingCompletionHandler = nil;
}

#pragma mark - Live vehicle fetch helpers
-(NSArray *)formatLineStrings:(NSArray *)lineCodes {
    if (!lineCodes) return lineCodes;
    
    NSMutableArray *codes = [@[] mutableCopy];
    for (NSString *lineCode in lineCodes) {
        //Expecting gtfsid
        NSArray *parts = [lineCode componentsSeparatedByString:@":"];
        if (parts.count < 2)
            continue;
        
        NSString *code = parts[1];
        [codes addObject:code];
    }
    
    return codes;
}

#endif

#pragma mark - Annotation filer protocol methods.
#if MAIN_APP

-(NSArray *)annotationFilterOptions {
    if (self.source == HslApi) {
        return @[[AnnotationFilterOption optionForBusStop],
                 [AnnotationFilterOption optionForTramStop],
                 [AnnotationFilterOption optionForTrainStop],
                 [AnnotationFilterOption optionForMetroStop],
                 [AnnotationFilterOption optionForBikeStation]];
    } else {
        return @[[AnnotationFilterOption optionForBusStop]];
    }
}

#endif

#pragma mark - RouteSearchOptions protocol methods

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions{
    NSMutableDictionary *parametersDict = [[DigiRouteOptionManager apiRequestParametersDictionaryForRouteOptions:[searchOptions dictionaryRepresentation]] mutableCopy];
    
    return parametersDict;
}

-(NSArray *)allTrasportTypeNames {
    return [DigiRouteOptionManager allTrasportTypeNames];
}

-(NSArray *)getTransportTypeOptions {
    return [DigiRouteOptionManager getTransportTypeOptionsForDisplay];
}

-(NSArray *)getDefaultTransportTypeNames {
    return [DigiRouteOptionManager getDefaultTransportTypeNames];
}

-(NSArray *)getTicketZoneOptions {
    return nil;
}

-(NSInteger)getDefaultValueIndexForTicketZoneOptions {
    return 0;
}

-(NSArray *)getChangeMargineOptions {
    return [DigiRouteOptionManager getChangeMargineOptionsForDisplay];
}

-(NSInteger)getDefaultValueIndexForChangeMargineOptions {
    return [DigiRouteOptionManager getDefaultValueIndexForChangeMargineOptions];
}

-(NSArray *)getWalkingSpeedOptions {
    return [DigiRouteOptionManager getWalkingSpeedOptionsForDisplay];
}

-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions {
    return [DigiRouteOptionManager getDefaultValueIndexForWalkingSpeedOptions];
}

#pragma mark - Helpers

-(NSString *)formatCommonCaseErrorMessageForError:(NSError *)error{
    NSString *errorString = nil;
    switch (error.code) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        case -1001:
            errorString = @"Connection to the data provider could not be established. Please try again later.";
            break;
        case -1016:
            errorString = @"The remote server returned nothing. Try again.";
            break;
        default:
            errorString = nil;
    }
    
    return errorString;
}

@end


