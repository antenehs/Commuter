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

#if MAIN_APP
#import "ReittiAnalyticsManager.h"
#import "StopDeparture.h"
#import "Line.h"
#endif

NSString *kHslDigiTransitGraphQlUrl = @"https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql";
NSString *kFinlandDigiTransitGraphQlUrl = @"https://api.digitransit.fi/routing/v1/routers/finland/index/graphql";

typedef enum : NSUInteger {
    HslApi,
    TreApi,
    FinlandApi,
} DigiTransitSource;

@interface DigiTransitCommunicator ()

@property (nonatomic)DigiTransitSource source;

@property (nonatomic, strong) APIClient *addressSearchClient;
@property (nonatomic, strong) APIClient *addressReverseClient;

@property (nonatomic, strong) NSDictionary *searchFilterBoundary;

@end

@implementation DigiTransitCommunicator

+(id)hslDigiTransitCommunicator {
    DigiTransitCommunicator *communicator = [DigiTransitCommunicator new];
    communicator.apiBaseUrl = kHslDigiTransitGraphQlUrl;
    communicator.source = HslApi;
    
    communicator.searchFilterBoundary = @{@"boundary.rect.min_lon" : @"25.332469",
                                          @"boundary.rect.min_lat" : @"60.017154",
                                          @"boundary.rect.max_lon" : @"24.507191",
                                          @"boundary.rect.max_lat" : @"60.256700"};
    
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
    
    [super doGraphQlQuery:[self stopInAreadGraphQlQueryForRegionCenterCoords:regionCenter andDiameter:diameter] responseDiscriptor:[DigiStopAtDistance responseDiscriptorForPath:@"data.stopsByRadius.edges"] andCompletionBlock:^(NSArray *stops, NSError *error){
        if (!error && stops.count > 0) {
            NSMutableArray *allStops = [@[] mutableCopy];
            for (DigiStopAtDistance *stopAtDist in stops) {
                [allStops addObject:[[BusStop alloc] initFromDigiStop:stopAtDist.stop]];
            }
            completionBlock(allStops, nil);
        } else {
            completionBlock(nil, @"Stop fetch failed");//Proper error message here.
        }
    }];
    
}

-(NSString *)stopInAreadGraphQlQueryForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter {
    
    return [GraphQLQuery stopInAreaQueryStringWithArguments:@{@"lat" : [NSNumber numberWithDouble:regionCenter.latitude],
                                                              @"lon" : [NSNumber numberWithDouble:regionCenter.longitude],
                                                              @"radius": [NSNumber numberWithInteger:diameter/2]}];
}

#pragma mark - Stop detail fetching
- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock {
    if (!stopCode)  {
        completionBlock(nil, @"No stopCode");
        return;
    }
    
    [self fetchStopsForIds:@[stopCode] withCompletionBlock:^(NSArray *stops, NSError *error){
        if (!error && stops.count > 0) {
            completionBlock(stops.firstObject, nil);
        } else {
            completionBlock(nil, @"Stop fetch failed");//Proper error message here.
        }
    }];
}


-(void)fetchStopsForIds:(NSArray *)stopIds withCompletionBlock:(ActionBlock)completionBlock {
    if (!stopIds || stopIds.count < 1){
        completionBlock(nil, @"No Stop Ids");
        return;
    }
    
    [super doGraphQlQuery:[self stopGraphQlQueryForArguments:@{@"ids" : stopIds }] responseDiscriptor:[DigiStop responseDiscriptorForPath:@"data.stops"] andCompletionBlock:^(NSArray *stops, NSError *error){
        if (!error && stops.count > 0) {
            NSMutableArray *allStops = [@[] mutableCopy];
            for (DigiStop *digiStop in stops) {
                [allStops addObject:[[BusStop alloc] initFromDigiStop:digiStop]];
            }
            completionBlock(allStops, nil);
        } else {
            completionBlock(nil, @"Stop fetch failed");//Proper error message here.
        }
    }];
}


-(void)fetchStopsForName:(NSString *)stopName withCompletionBlock:(ActionBlock)completionBlock {
    if (!stopName){
        completionBlock(nil, @"No Stop Name");
        return;
    }
    
    [super doGraphQlQuery:[self stopGraphQlQueryForArguments:@{@"name" : stopName}] responseDiscriptor:[DigiStop responseDiscriptorForPath:@"data.stops"] andCompletionBlock:^(NSArray *stops, NSError *error){
        if (!error) {
            completionBlock(stops, nil);
        } else {
            completionBlock(nil, @"Stop fetch failed");//Proper error message here. 
        }
    }];
}

-(NSString *)stopGraphQlQueryForArguments:(NSDictionary *)arguments {
    return [GraphQLQuery stopQueryStringWithArguments:arguments];
}

#pragma mark - Realtime departure fetching methods
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
                    StopDeparture *dep = [StopDeparture departureForDigiStopTime:stopTime];
                    if (dep)
                        [allDepartures addObject:dep];
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

#pragma mark - Route search
-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock {
    
    NSString *queryString = [self routeGraphQlQueryForFromCoords:fromCoords andToCoords:toCoords withOptions:options];
    
    if (!queryString) {
        completionBlock(nil, @"No Coords");
        return;
    }
    
    [super doGraphQlQuery:queryString responseDiscriptor:[DigiPlan responseDiscriptorForPath:@"data.plan.itineraries"] andCompletionBlock:^(NSArray *digiRoutes, NSError *error){
        if (!error && digiRoutes && digiRoutes.count > 0) {
            NSMutableArray *allRoutes = [@[] mutableCopy];
            for (DigiPlan *plan in digiRoutes) {
                Route *route = [Route routeFromDigiPlan:plan];
                if (route) {
                    [allRoutes addObject:route];
                }
            }
            completionBlock(allRoutes, nil);
        } else {
            completionBlock(nil, @"Route fetch failed");//Proper error message here.
        }
    }];
    
    
}

-(NSString *)routeGraphQlQueryForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options {
    if (![ReittiMapkitHelper isValidCoordinate:fromCoords] || ![ReittiMapkitHelper isValidCoordinate:toCoords])
        return nil;
    
    NSString *date = [[ReittiDateHelper sharedFormatter] digitransitQueryDateStringFromDate:options.date];
    NSString *time = [[ReittiDateHelper sharedFormatter] digitransitQueryTimeStringFromDate:options.date];
    
    NSDictionary *arguments = @{@"from" : @{@"lat": [NSNumber numberWithDouble:fromCoords.latitude], @"lon": [NSNumber numberWithDouble:fromCoords.longitude]},
                                @"to" : @{@"lat": [NSNumber numberWithDouble:toCoords.latitude], @"lon": [NSNumber numberWithDouble:toCoords.longitude]},
                                @"numItineraries" : @5,
                                @"modes" : @"BICYCLE_RENT,BUS,TRAM,SUBWAY,RAIL,FERRY,WALK",
                                @"allowBikeRental" : [NSNumber numberWithBool:YES],
                                @"date" : date,
                                @"time" : time
                                };
    
    return [GraphQLQuery planQueryStringWithArguments:arguments];
}

#pragma mark - Geocode methods
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
                [results addObject:[GeoCode geocodeForDigiStop:digiStop]];
            }
            
            stopResults = results;
            
            if (requestCalls == 0){
                allResults = [@[] mutableCopy];
                [allResults addObjectsFromArray:addressResults];
                [allResults addObjectsFromArray:stopResults];
                completionBlock(allResults, nil);
            }
        }
    }];
    
    [optionsDict setValue:searchTerm forKey:@"text"];
    [optionsDict setValue:@"venue,street,locality" forKey:@"layers"];
    [optionsDict setValue:@"50" forKey:@"size"];
    
//    if (self.searchFilterBoundary)
//        [optionsDict addEntriesFromDictionary:self.searchFilterBoundary];
    
    [self.addressSearchClient doJsonApiFetchWithParams:optionsDict responseDescriptor:[DigiGeoCode responseDiscriptorForPath:@"features"] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        requestCalls--;
        if (!error && responseArray) {
            
            NSMutableArray *results = [@[] mutableCopy];
            for (DigiGeoCode *digiGeocode in responseArray) {
                [results addObject:[GeoCode geocodeForDigiGeocode:digiGeocode]];
            }
            
            addressResults = results;
            
            if (requestCalls == 0){
                allResults = [@[] mutableCopy];
                [allResults addObjectsFromArray:addressResults];
                [allResults addObjectsFromArray:stopResults];
                completionBlock(allResults, nil);
            }
        }
    }];
    
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedAddressFromApi label:@"HSL:DIGI" value:nil];
}

#pragma mark - Reverese geocode methods
- (void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *latString = [NSString stringWithFormat:@"%f", coords.latitude];
    NSString *lonString = [NSString stringWithFormat:@"%f", coords.longitude];
    
    [optionsDict setValue:latString forKey:@"point.lat"];
    [optionsDict setValue:lonString forKey:@"point.lon"];
    [optionsDict setValue:@"address" forKey:@"layers"];
    [optionsDict setValue:@"1" forKey:@"size"];
    
    [self.addressReverseClient doJsonApiFetchWithParams:optionsDict responseDescriptor:[DigiGeoCode responseDiscriptorForPath:@"features"] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error && responseArray && responseArray.count > 0) {
            
            completionBlock([GeoCode geocodeForDigiGeocode:responseArray[0]], nil);
        }else{
            completionBlock(nil, [self formattedReverseGeocodeFetchErrorMessageForError:error]);
        }
    }];
    
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedReverseGeoCodeFromApi label:@"HSL:DIGI" value:nil];
    
}

-(NSString *)formattedReverseGeocodeFetchErrorMessageForError:(NSError *)error{
    NSString *errorString = @"";
    switch (error.code) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        default:
            errorString = @"No address was found for the coordinates";
            break;
    }
    
    return errorString;
}

#pragma mark - Line fetch methods
- (void)fetchLinesForSearchterm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock {
    [self fetchLinesWithArguments:@{@"name" : searchTerm} withCompletionBlock:completionBlock];
}

- (void)fetchLinesForCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock {
    [self fetchLinesWithArguments:@{@"ids" : lineCodes} withCompletionBlock:completionBlock];
}

-(void)fetchLinesWithArguments:(NSDictionary *)arguments withCompletionBlock:(ActionBlock)completionBlock {
    [super doGraphQlQuery:[GraphQLQuery routeQueryStringWithArguments:arguments] responseDiscriptor:[DigiRoute responseDiscriptorForPath:@"data.routes"] andCompletionBlock:^(NSArray *routes, NSError *error){
        if (!error) {
            NSMutableArray *allLines = [@[] mutableCopy];
            for (DigiRoute *digiRoute in routes) {
                Line *line = [Line lineFromDigiLine:digiRoute];
                if(line) [allLines addObject:line];
            }
            completionBlock(allLines, nil);
        } else {
            completionBlock(nil, @"Route(Line) fetch failed");//Proper error message here.
        }
    }];
}

@end
