//
//  DigiTransitCommunicator.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DigiTransitCommunicator.h"
#import "DigiDataModels.h"

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
    if (!stopName) completionBlock(nil, @"No Stop Name");
    
    [super doGraphQlQuery:[self stopGraphQlQueryForName:stopName] responseDiscriptor:[DigiStop responseDiscriptorForPath:@"data.stops"] andCompletionBlock:^(NSArray *stops, NSError *error){
        if (!error) {
            completionBlock(stops, nil);
        } else {
            completionBlock(nil, @"Stop fetch failed");//Proper error message here. 
        }
    }];
}

-(NSString *)stopGraphQlQueryForName:(NSString *)name {
    return [NSString stringWithFormat:@"{ stops(name: \"%@\") { name,code,gtfsId,url,platformCode,lat,lon,routes {shortName,longName,type},stoptimesWithoutPatterns (numberOfDepartures: 20){scheduledDeparture,realtimeDeparture,realtimeState,realtime,serviceDay,trip {route {shortName,longName, type},tripHeadsign}}}}", name];
}


#pragma mark - Response descriptors

@end
