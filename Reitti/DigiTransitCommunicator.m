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
#import "ReittiDateFormatter.h"

NSString *kHslDigiTransitGraphQlUrl = @"http://api.digitransit.fi/routing/v1/routers/hsl/index/graphql";
NSString *kFinlandDigiTransitGraphQlUrl = @"http://api.digitransit.fi/routing/v1/routers/finland/index/graphql";

typedef enum : NSUInteger {
    HslApi,
    TreApi,
    FinlandApi,
} DigiTransitSource;

@interface DigiTransitCommunicator ()

@property (nonatomic)DigiTransitSource source;

@end

@implementation DigiTransitCommunicator

+(id)hslDigiTransitCommunicator {
    DigiTransitCommunicator *communicator = [DigiTransitCommunicator new];
    communicator.apiBaseUrl = kHslDigiTransitGraphQlUrl;
    communicator.source = HslApi;
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

#pragma mark - Stop detail fetching
-(void)fetchStopsForName:(NSString *)stopName withCompletionBlock:(ActionBlock)completionBlock {
    if (!stopName){
        completionBlock(nil, @"No Stop Name");
        return;
    }
    
    [super doGraphQlQuery:[self stopGraphQlQueryForName:stopName] responseDiscriptor:[DigiStop responseDiscriptorForPath:@"data.stops"] andCompletionBlock:^(NSArray *stops, NSError *error){
        if (!error) {
            completionBlock(stops, nil);
        } else {
            completionBlock(nil, @"Stop fetch failed");//Proper error message here. 
        }
    }];
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
}

-(NSString *)stopGraphQlQueryForName:(NSString *)name {
    return [NSString stringWithFormat:@"{ stops(name: \"%@\") { name,code,gtfsId,url,platformCode,lat,lon,routes {shortName,longName,type},stoptimesWithoutPatterns (numberOfDepartures: 20){scheduledDeparture,realtimeDeparture,realtimeState,realtime,serviceDay,trip {route {shortName,longName, type},tripHeadsign}}}}", name];
}

#pragma mark - Route search
-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock {
    
    NSString *queryString = [self routeGraphQlQueryForFromCoords:fromCoords andToCoords:toCoords withOptions:options];
    
    if (!queryString) {
        completionBlock(nil, @"No Coords");
        return;
    }
    
    [super doGraphQlQuery:queryString responseDiscriptor:[DigiPlan responseDiscriptorForPath:@"data.plan.itineraries"] andCompletionBlock:^(NSArray *routes, NSError *error){
        if (!error) {
            completionBlock(routes, nil);
        } else {
            completionBlock(nil, @"Route fetch failed");//Proper error message here.
        }
    }];
    
    
}

-(NSString *)routeGraphQlQueryForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options {
    if (![ReittiMapkitHelper isValidCoordinate:fromCoords] || ![ReittiMapkitHelper isValidCoordinate:toCoords])
        return nil;
    
    NSString *fromCoordLat = [NSString stringWithFormat:@"%f", fromCoords.latitude];
    NSString *fromCoordLon = [NSString stringWithFormat:@"%f", fromCoords.longitude];
    NSString *toCoordLat = [NSString stringWithFormat:@"%f", toCoords.latitude];
    NSString *toCoordLon = [NSString stringWithFormat:@"%f", toCoords.longitude];
    
    NSString *date = [[ReittiDateFormatter sharedFormatter] digitransitQueryDateStringFromDate:options.date];
    NSString *time = [[ReittiDateFormatter sharedFormatter] digitransitQueryTimeStringFromDate:options.date];
    
    return [NSString stringWithFormat:@"{plan(from: {lat: %@, lon: %@}, to: {lat: %@, lon: %@}, numItineraries: 5, modes: \"BICYCLE_RENT,BUS,TRAM,SUBWAY,RAIL,FERRY,WALK\", allowBikeRental: true, date: \"%@\", time: \"%@\") { itineraries{ startTime, endTime, walkDistance, walkTime, waitingTime, duration, legs { mode, startTime, endTime, duration, distance, rentedBike, transitLeg, realTime, from { lat, lon, name, bikeRentalStation { stationId, name, bikesAvailable, spacesAvailable, realtime }, stop { name, gtfsId, code } }, to { lat, lon, name, bikeRentalStation { stationId, name, bikesAvailable, spacesAvailable, realtime}, stop { name, gtfsId, code } }, intermediateStops { gtfsId, code, name, lat, lon, }, trip { tripHeadsign, route {longName,shortName, type, gtfsId}, pattern { geometry { lat, lon, } } } } }}}", fromCoordLat, fromCoordLon, toCoordLat, toCoordLon, date, time];
}

@end
