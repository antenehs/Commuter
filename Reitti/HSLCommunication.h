//
//  HSLCommunication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "RouteSearchOptions.h"
#import "ApiProtocols.h"
#import "HSLAndTRECommon.h"

@class HSLCommunication;

@interface HSLCommunication : HSLAndTRECommon <RouteSearchProtocol, RouteSearchOptionProtocol, StopsInAreaSearchProtocol, StopDetailFetchProtocol, LineDetailFetchProtocol, GeocodeProtocol, ReverseGeocodeProtocol, DisruptionFetchProtocol, BikeStationFetchProtocol>{
    
    NSArray *hslApiUserNames;
    NSInteger nextApiUsernameIndex;
}

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions;

+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode;

@end
