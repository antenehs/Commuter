//
//  TRECommunication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "RouteSearchOptions.h"
#import "HSLAndTRECommon.h"
#import "ApiProtocols.h"

@class TRECommunication;

@interface TRECommunication : HSLAndTRECommon <RouteSearchProtocol, RouteSearchOptionProtocol, StopsInAreaSearchProtocol, StopDetailFetchProtocol, RealtimeDeparturesFetchProtocol, LineDetailFetchProtocol, GeocodeProtocol, ReverseGeocodeProtocol, AnnotationFilterOptionProtocol> {
    
    NSArray *treApiUserNames;
    NSInteger nextApiUsernameIndex;
}

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions;

+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode;

@end
