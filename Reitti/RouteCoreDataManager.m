//
//  RouteCoreDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/13/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "RouteCoreDataManager.h"
#import "ReittiSearchManager.h"
#import "ICloudManager.h"
#import "SettingsManager.h"

#import "RouteHistoryEntity.h"

NSString *kRouteEntityName = @"RouteEntity";
NSString *kRouteHistoryEntityName = @"RouteHistoryEntity";

@interface RouteCoreDataManager ()

@property (strong, nonatomic) NSMutableArray *allSavedRouteCodes;
@property (strong, nonatomic) NSMutableArray *allRouteHistoryCodes;
@property (nonatomic) BOOL doneInitialTasks;

@end

@implementation RouteCoreDataManager

+(instancetype)sharedManager {
    static RouteCoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [RouteCoreDataManager new];
    });
    
    //Do this outside the dispatch
    if (!sharedInstance.doneInitialTasks) {
        sharedInstance.doneInitialTasks = YES;
        
        [sharedInstance doMigrations];
        
        [sharedInstance clearOldHistory];
        [sharedInstance savedRoutesUpdated];
        [sharedInstance fetchAllCodes];
    }
    
    return sharedInstance;
}

-(id)init {
    self = [super init];
    
    if (self) {
        self.doneInitialTasks = NO;
    }
    
    return self;
}

-(void)fetchAllCodes {
    [self fetchAllSavedRouteCodesFromCoreData];
    [self fetchAllRouteHistoryCodesFromCoreData];
}

#pragma mark - Save

-(void)saveRouteToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation andToCoords:(NSString *)toCoords {
    [self saveRouteToCoreData:fromLocation
                   fromCoords:fromCoords
                andToLocation:toLocation
                  andToCoords:toCoords
                    isHistory:NO];
}

-(void)saveRouteHistoryToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation toCoords:(NSString *)toCoords {
    [self saveRouteToCoreData:fromLocation
                   fromCoords:fromCoords
                andToLocation:toLocation
                  andToCoords:toCoords
                    isHistory:YES];
}

-(void)saveRouteToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation andToCoords:(NSString *)toCoords isHistory:(BOOL)isHistory {
    
    if (fromLocation == nil || fromCoords == nil || toLocation == nil || toCoords == nil ||
        fromLocation.length == 0 || fromCoords.length == 0 || toLocation.length == 0 || toCoords.length == 0) {
        return;
    }
    
    NSString *uniqueCode = [RouteEntity uniqueRouteNameFor:fromLocation andToLoc:toLocation];
    BOOL bookmarkExists = isHistory
                            ? [self.allRouteHistoryCodes containsObject:uniqueCode]
                            : [self.allSavedRouteCodes containsObject:uniqueCode];
    
    if( bookmarkExists ){
        RouteEntity *routeEntity = isHistory
                                     ? [self fetchRouteHistoryFromCoreDataForCode:uniqueCode]
                                     : [self fetchSavedRouteFromCoreDataForCode:uniqueCode];
        //Save it again to update the objectLID
        [self saveReittiManagedObject:routeEntity];
    } else {
        RouteEntity *routeEntity = (RouteEntity *)[super createNewObjectForEntityNamed:kRouteEntityName];
        
        if (isHistory)
            [routeEntity setOrder:[NSNumber numberWithInteger:self.allRouteHistoryCodes.count + 1]];
        else
            [routeEntity setOrder:[NSNumber numberWithInteger:self.allSavedRouteCodes.count + 1]];
        [routeEntity setFromLocationName:fromLocation];
        [routeEntity setFromLocationCoordsString:fromCoords];
        [routeEntity setToLocationName:toLocation];
        [routeEntity setToLocationCoordsString:toCoords];
        [routeEntity setRouteUniqueName:uniqueCode];
        [routeEntity setIsHistory:[NSNumber numberWithBool:isHistory]];
        
        [self saveReittiManagedObject:routeEntity];
    }
    
    [self savedRoutesUpdated];
}

-(BOOL)isRouteSaved:(NSString *)fromString andTo:(NSString *)toString{
    [self fetchAllSavedRouteCodesFromCoreData];
    return [self.allSavedRouteCodes containsObject:[RouteEntity uniqueRouteNameFor:fromString andToLoc:toString]];
}

#pragma mark - Delete

-(void)deleteSavedRouteForCode:(NSString *)code {
    [self deleteSavedRouteForCode:code isHistory:NO];
}

-(void)deleteHistoryRouteForCode:(NSString *)code {
    [self deleteSavedRouteForCode:code isHistory:YES];
}

-(void)deleteSavedRouteForCode:(NSString *)code isHistory:(BOOL)isHistory{
    RouteEntity *routeToDelete = [self fetchSavedRouteFromCoreDataForCode:code isHistory:isHistory];
    if (!routeToDelete)
        return;
    
    [self deleteRoutesFromICloud:@[routeToDelete]];
    
    [super deleteManagedObject:routeToDelete];
    
    [self savedRoutesUpdated];
}

-(void)deleteAllSavedroutes {
    [self deleteAllSavedroutes:NO];
}

-(void)deleteAllHistoryRoutes {
    [self deleteAllSavedroutes:YES];
}

-(void)deleteAllSavedroutes:(BOOL)isHistory {
    NSArray *routesToDelete = isHistory
                                ? [self fetchAllSavedRouteHistoryFromCoreData]
                                : [self fetchAllSavedRoutesFromCoreData];
    if (!routesToDelete || routesToDelete.count < 1)
        return;
    
    [self deleteRoutesFromICloud:routesToDelete];
    
    [super deleteManagedObjects:routesToDelete];
    
    [self savedRoutesUpdated];
}

-(void)clearOldHistory {
    SettingsManager *settingsManager = [SettingsManager sharedManager];
    if ([settingsManager isClearingHistoryEnabled]) {
        int numOfDays = [settingsManager numberOfDaysToKeepHistory];
        
        NSMutableArray *routesToDelete = [@[] mutableCopy];
        NSArray *allRouteHistory = [self fetchAllSavedRouteHistoryFromCoreData];
        for (RouteEntity *route in allRouteHistory) {
            if (route.dateModified != nil) {
                if ([route.dateModified timeIntervalSinceNow] < -(numOfDays * 24 * 60 * 60)) {
                    [routesToDelete addObject:route];
                }
            }
        }
        
        if (routesToDelete.count > 0) {
            [super deleteManagedObjects:routesToDelete];
        }
    }
}

#pragma mark - Fetch All

-(NSArray *)fetchAllSavedRoutesFromCoreData {
    NSString *predString = @"isHistory == false";
    
    return [super fetchObjectsForEntityNamed: kRouteEntityName predicateString:predString sortWithPropertyNamed:@"order" assending:YES];
}

-(NSArray *)fetchAllSavedRouteHistoryFromCoreData {
    NSString *predString = @"isHistory == true";
    
    return [super fetchObjectsForEntityNamed: kRouteEntityName predicateString:predString sortWithPropertyNamed:@"objectLID" assending:YES];
}

-(void)fetchAllSavedRouteCodesFromCoreData {
    NSString *predString = @"isHistory == false";
    
    NSArray *codes = [super fetchObjectsForEntityNamed:kRouteEntityName predicateString:predString sortWithPropertyNamed:@"order" assending:YES propertiesToFetch:@[@"routeUniqueName"]];
    
    self.allSavedRouteCodes = codes ? [codes mutableCopy] : [@[] mutableCopy];
}

-(void)fetchAllRouteHistoryCodesFromCoreData {
    NSString *predString = @"isHistory == true";
    
    NSArray *codes = [super fetchObjectsForEntityNamed:kRouteEntityName predicateString:predString sortWithPropertyNamed:@"objectLID" assending:YES propertiesToFetch:@[@"routeUniqueName"]];
    
    self.allRouteHistoryCodes = codes ? [codes mutableCopy] : [@[] mutableCopy];
}

#pragma mark - fetch for code

-(RouteEntity *)fetchSavedRouteFromCoreDataForCode:(NSString *)code{
    return [self fetchSavedRouteFromCoreDataForCode:code isHistory:NO];
}

-(RouteEntity *)fetchRouteHistoryFromCoreDataForCode:(NSString *)code {
    return [self fetchSavedRouteFromCoreDataForCode:code isHistory:YES];
}

-(RouteEntity *)fetchSavedRouteFromCoreDataForCode:(NSString *)code isHistory:(BOOL)isHistory {
    NSString *predString = [NSString stringWithFormat:@"routeUniqueName == '%@' && isHistory == %@", code, isHistory ? @"true" : @"false"];
    
    NSArray *savedStops = [super fetchObjectsForEntityNamed:kRouteEntityName predicateString:predString];
    
    if ([savedStops count] != 0)
        return [savedStops firstObject];
    
    return nil;
}

#pragma mark - fetch for location name

-(NSArray *)fetchSavedRouteFromCoreDataForLocationName:(NSString *)locationName {
    return [self fetchSavedRouteFromCoreDataForLocationName:locationName isHistory:NO];
}

-(NSArray *)fetchRouteHistoryFromCoreDataForLocationName:(NSString *)locationName {
    return [self fetchSavedRouteFromCoreDataForLocationName:locationName isHistory:YES];
}

-(NSArray *)fetchSavedRouteFromCoreDataForLocationName:(NSString *)locationName isHistory:(BOOL)isHistory {
    NSString *predString = [NSString stringWithFormat:@"fromLocationName == '%@' || toLocationName == '%@' && isHistory == %@", locationName, locationName, isHistory ? @"true" : @"false"];
    
    return [super fetchObjectsForEntityNamed:kRouteEntityName predicateString:predString];
}

-(NSArray *)fetchAllRoutesForLocationName:(NSString *)locationName {
    NSString *predString = [NSString stringWithFormat:@"fromLocationName == '%@' || toLocationName == '%@'", locationName, locationName];
    
    return [super fetchObjectsForEntityNamed:kRouteEntityName predicateString:predString];
}

#pragma mark - Update for other change
-(void)updateRoutesOrderTo:(NSArray *)orderedObjects {
    [self updateOrderedManagedObjectOrderTo:orderedObjects];
}

-(void)updateSavedAndHistoryRoutesWithLocation:(NSString *)locationName withNewLocationName:(NSString *)newLocationName withNewCoord:(NSString *)newCoordString {
     NSArray *savedRoutes = [self fetchAllRoutesForLocationName:locationName];
     
     for (RouteEntity *entity in savedRoutes) {
         if ([entity.toLocationName isEqualToString:locationName]) {
             entity.toLocationName = newLocationName;
             entity.toLocationCoordsString = newCoordString;
         }
     
         if ([entity.fromLocationName isEqualToString:locationName]) {
             entity.fromLocationName = newLocationName;
             entity.fromLocationCoordsString = newCoordString;
         }
     
         [super saveState];
     }
}

-(void)deleteSavedAndHistoryRoutesForLocationName:(NSString *)locationName {
    NSArray *savedRoutes = [self fetchAllRoutesForLocationName:locationName];
    [super deleteManagedObjects:savedRoutes];
}

#pragma mark - Update to remote

- (void)savedRoutesUpdated {
    [self fetchAllCodes];
    
    [self updateSavedRoutesToICloud];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
}

- (void)updateSavedRoutesToICloud {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    NSArray *routes = [self fetchAllSavedRoutesFromCoreData];
    [[ICloudManager sharedManager] saveRoutesToICloud:routes];
}

- (void)deleteRoutesFromICloud:(NSArray *)routes {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    [[ICloudManager sharedManager] deleteSavedRoutesFromICloud:routes];
}


#pragma mark - migration

-(void)doMigrations {
    [self doVersion18CoreDataMigration];
    [self doVersion16CoreDataMigration];
}

-(void)doVersion16CoreDataMigration {
    //Migration due to addition orders
    NSArray *savedRoutes = [self fetchAllSavedRoutesFromCoreData];
    
    [self updateOrderedManagedObjectOrderTo:savedRoutes];
}


//Addition of isHistory
-(void)doVersion18CoreDataMigration {
    NSArray *oldSavedRouteHistories = [super fetchAllObjectsForEntityNamed:kRouteHistoryEntityName];
    if (oldSavedRouteHistories && oldSavedRouteHistories.count > 0) {
        for (RouteHistoryEntity *routeHistory in oldSavedRouteHistories) {
            [self saveRouteHistoryToCoreData:routeHistory.fromLocationName
                           fromCoords:routeHistory.fromLocationCoordsString
                        andToLocation:routeHistory.toLocationName
                          toCoords:routeHistory.toLocationCoordsString];
            
            [self deleteManagedObject:routeHistory];
        }
    }
    
    NSArray *oldSavedRoutes = [super fetchAllObjectsForEntityNamed:kRouteEntityName];
    if (oldSavedRoutes && oldSavedRoutes.count > 0) {
        for (RouteEntity *route in oldSavedRoutes) {
            if (route.isHistory) continue;
            
            route.isHistory = @NO;
        }
        
        [super saveState];
    }
    
}


@end
