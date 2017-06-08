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

#if MAIN_APP
@interface DigiTransitCommunicator : APIClient <RouteSearchProtocol, StopsInAreaSearchProtocol, StopDetailFetchProtocol, RealtimeDeparturesFetchProtocol, GeocodeProtocol, ReverseGeocodeProtocol, LineDetailFetchProtocol, BikeStationFetchProtocol, DisruptionFetchProtocol, AnnotationFilterOptionProtocol, LiveTrafficFetchProtocol, RouteSearchOptionProtocol>
#else 
@interface DigiTransitCommunicator : APIClient <RouteSearchProtocol, StopsInAreaSearchProtocol, StopDetailFetchProtocol, LineDetailFetchProtocol, RouteSearchOptionProtocol>
#endif


+(id)hslDigiTransitCommunicator;
+(id)treDigiTransitCommunicator;
+(id)finlandDigiTransitCommunicator;

#if MAIN_APP
-(void)fetchDeparturesForStopName:(NSString *)name withCompletionHandler:(ActionBlock)completionBlock;
#endif

-(void)fetchStopsForName:(NSString *)stopName withCompletionBlock:(ActionBlock)completionBlock;
@end
