//
//  DigiTransitCommunicator.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiProtocols.h"
#import "APIClient.h"

@interface DigiTransitCommunicator : APIClient <RouteSearchProtocol, StopsInAreaSearchProtocol, StopDetailFetchProtocol, RealtimeDeparturesFetchProtocol, GeocodeProtocol, ReverseGeocodeProtocol, LineDetailFetchProtocol, BikeStationFetchProtocol, DisruptionFetchProtocol>

+(id)hslDigiTransitCommunicator;
+(id)treDigiTransitCommunicator;
+(id)finlandDigiTransitCommunicator;

-(void)fetchDeparturesForStopName:(NSString *)name withCompletionHandler:(ActionBlock)completionBlock;
-(void)fetchStopsForName:(NSString *)stopName withCompletionBlock:(ActionBlock)completionBlock;
@end
