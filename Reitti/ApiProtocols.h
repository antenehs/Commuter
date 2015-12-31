//
//  ApiProtocols.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "RouteSearchOptions.h"

typedef void (^ActionBlock)();

@protocol RouteSearchProtocol <NSObject>
- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol StopsInAreaSearchProtocol <NSObject>
- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol StopDetailFetchProtocol <NSObject>
- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol LineDetailFetchProtocol <NSObject>
- (void)fetchLineForSearchterm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol RouteSearchOptionProtocol <NSObject>
-(NSArray *)allTrasportTypeNames;

-(NSArray *)getTransportTypeOptions;
-(NSArray *)getTicketZoneOptions;
-(NSArray *)getChangeMargineOptions;
-(NSArray *)getWalkingSpeedOptions;

-(NSInteger)getDefaultValueIndexForTicketZoneOptions;
-(NSInteger)getDefaultValueIndexForChangeMargineOptions;
-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;
@end