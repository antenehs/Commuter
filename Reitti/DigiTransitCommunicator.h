//
//  DigiTransitCommunicator.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIClient.h"

@interface DigiTransitCommunicator : APIClient

+(id)hslDigiTransitCommunicator;
+(id)treDigiTransitCommunicator;
+(id)finlandDigiTransitCommunicator;

-(void)fetchStopsForName:(NSString *)stopName withCompletionBlock:(ActionBlock)completionBlock;
-(void)fetchDeparturesForStopName:(NSString *)name withCompletionHandler:(ActionBlock)completionBlock;
-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlockl;

@end
