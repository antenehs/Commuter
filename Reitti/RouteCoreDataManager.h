//
//  RouteCoreDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/13/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"
#import "RouteEntity.h"

@interface RouteCoreDataManager : CoreDataManager

+(id)sharedManager;

//Save
-(void)saveRouteToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation andToCoords:(NSString *)toCoords;
-(void)deleteSavedRouteForCode:(NSString *)code;
-(void)deleteAllSavedroutes;

-(void)saveRouteHistoryToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation toCoords:(NSString *)toCoords;
-(void)deleteHistoryRouteForCode:(NSString *)code;
-(void)deleteAllHistoryRoutes;

-(void)updateRoutesOrderTo:(NSArray *)orderedObjects;
-(void)updateSavedAndHistoryRoutesWithLocation:(NSString *)locationName withNewLocationName:(NSString *)newLocationName withNewCoord:(NSString *)newCoordString;
-(void)deleteSavedAndHistoryRoutesForLocationName:(NSString *)locationName;

-(BOOL)isRouteSaved:(NSString *)fromString andTo:(NSString *)toString;

-(RouteEntity *)fetchSavedRouteFromCoreDataForCode:(NSString *)code;
-(NSArray *)fetchAllSavedRoutesFromCoreData;

-(NSArray *)fetchAllSavedRouteHistoryFromCoreData;

@end

