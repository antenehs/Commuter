//
//  StopCoreDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/13/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "StopCoreDataManager.h"
#import "WatchCommunicationManager.h"
#import "AppManager.h"
#import "ICloudManager.h"
#import "ReittiSearchManager.h"
#import "HistoryEntity.h"
#import "SettingsManager.h"

@interface StopCoreDataManager ()

@property (strong, nonatomic) NSMutableArray *allSavedStopCodes;
@property (strong, nonatomic) NSMutableArray *allHistoryStopCodes;
@property (nonatomic) BOOL doneInitialTasks;

@end

@implementation StopCoreDataManager

@synthesize allSavedStopCodes, allHistoryStopCodes;

+(instancetype)sharedManager {
    static StopCoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [StopCoreDataManager new];
    });
    
    //Do this outside the dispatch
    if (!sharedInstance.doneInitialTasks) {
        [sharedInstance doMigrations];
        
        [sharedInstance stopsUpdated: NO];
        [sharedInstance fetchAllSavedStopCodesFromCoreData];
        [sharedInstance updateSavedStopsToICloud];
        [sharedInstance clearOldHistory];
        sharedInstance.doneInitialTasks = YES;
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

#pragma mark - Saved Stop fetch methods
-(NSArray *)fetchAllSavedStopsFromCoreData {
    return [self fetchAllSavedStopsFromCoreData:NO];
}

-(StopEntity *)fetchSavedStopFromCoreDataForCode:(NSString *)code {
    return [self fetchSavedStopFromCoreDataForCode:code isHistory:NO];
}

-(void)fetchAllSavedStopCodesFromCoreData {
    NSArray *codes = [self fetchAllSavedStopCodesFromCoreData:NO];
    allSavedStopCodes = codes ? [codes mutableCopy] : [@[] mutableCopy];
}

#pragma mark - Stop history fetch methods
-(NSArray *)fetchAllSavedStopHistoryFromCoreData {
    return [self fetchAllSavedStopsFromCoreData:YES];
}

-(StopEntity *)fetchStopHistoryFromCoreDataForCode:(NSString *)code {
    return [self fetchSavedStopFromCoreDataForCode:code isHistory:YES];
}

-(void)fetchAllHistoryStopCodesFromCoreData {
    NSArray *codes = [self fetchAllSavedStopCodesFromCoreData:YES];
    allHistoryStopCodes = codes ? [codes mutableCopy] : [@[] mutableCopy];
}

#pragma mark - Common fetch
-(NSArray *)fetchAllSavedStopsFromCoreData:(BOOL)isHistory {
    NSString *predString = [NSString stringWithFormat:@"isHistory == %@", isHistory ? @"true" : @"false"];
    
    return [super fetchObjectsForEntityNamed: @"StopEntity" predicateString:predString sortWithPropertyNamed:@"objectLID" assending:YES];
}

-(StopEntity *)fetchSavedStopFromCoreDataForCode:(NSString *)code isHistory:(BOOL)isHistory {
    NSString *predString = [NSString stringWithFormat:@"stopGtfsId == '%@' && isHistory == %@", code, isHistory ? @"true" : @"false"];
    
    NSArray *savedStops = [super fetchObjectsForEntityNamed:@"StopEntity" predicateString:predString];
    
    if ([savedStops count] != 0) {
        return [savedStops objectAtIndex:0];
    }
    
    return nil;
}

-(NSArray *)fetchAllSavedStopCodesFromCoreData:(BOOL)isHistory {
    NSString *predString = [NSString stringWithFormat:@"isHistory == %@", isHistory ? @"true" : @"false"];
    
    return [super fetchObjectsForEntityNamed:@"StopEntity" predicateString:predString sortWithPropertyNamed:@"stopGtfsId" assending:YES propertiesToFetch:@[@"stopGtfsId"]];
}

#pragma mark - save methods

-(void)saveToCoreDataStop:(BusStop *)stop {
    [self saveToCoreDataStop:stop isHistory:NO];
}

-(void)saveHistoryToCoreDataStop:(BusStop *)stop {
    [self saveToCoreDataStop:stop isHistory:YES];
}

-(void)saveToCoreDataStop:(BusStop *)stop isHistory:(BOOL)isHistory{
    if (!stop)
        return;
    
    StopEntity *stopEntity = nil;
    if (isHistory) {
        stopEntity = [self fetchStopHistoryFromCoreDataForCode:stop.gtfsId];
    } else {
        stopEntity = [self fetchSavedStopFromCoreDataForCode:stop.gtfsId];
    }
    
    if (!stopEntity) {
        stopEntity= (StopEntity *)[self createNewObjectForEntityNamed:@"StopEntity"];
        if (!isHistory) stopEntity.order = [NSNumber numberWithInteger:allSavedStopCodes.count + 1];
    }
    
    //set default values
    [stopEntity setBusStopCode:stop.code];
    [stopEntity setBusStopShortCode:stop.codeShort];
    [stopEntity setBusStopName:stop.nameFi];
    [stopEntity setBusStopCity:stop.cityFi];
    [stopEntity setBusStopURL:stop.timetableLink];
    [stopEntity setBusStopCoords:stop.coords];
    [stopEntity setBusStopWgsCoords:stop.wgsCoords];
    [stopEntity setStopLines:stop.lines];
    [stopEntity setFetchedFrom:[NSNumber numberWithInt:(int)stop.fetchedFromApi]];
    [stopEntity setIsHistory:[NSNumber numberWithBool:isHistory]];
    [stopEntity setStopGtfsId:stop.gtfsId];
    [stopEntity setStopTypeNumber:[NSNumber numberWithInt:stop.stopType]];
    
    [super saveReittiManagedObject:stopEntity];
    
    if (isHistory) {
        [allHistoryStopCodes addObject:stop.code];
    } else {
        [allSavedStopCodes addObject:stop.code];
    }
    
    if (!isHistory) [self updateSavedStopsToICloud];
    if (!isHistory) [self stopsUpdated];
}

-(BOOL)isBusStopSaved:(BusStop *)stop{
    return [self isBusStopSavedWithCode:stop.gtfsId];
}

-(BOOL)isBusStopSavedWithCode:(NSString *)stopCode{
    [self fetchAllSavedStopCodesFromCoreData];
    return [allSavedStopCodes containsObject:stopCode];
}

#pragma mark - delete methods

-(void)deleteSavedStopForCode:(NSString *)code{
    if (!code) return;
    
    StopEntity *stopToDelete = [self fetchSavedStopFromCoreDataForCode:code];
    
    [self deleteSavedStop:stopToDelete];
}

-(void)deleteAllSavedStop {
    [self deleteStops:[self fetchAllSavedStopsFromCoreData]];
}

-(void)deleteSavedStop:(StopEntity *)stop {
    if (!stop) return;
    [self deleteStops:@[stop]];
}

-(void)deleteStops:(NSArray *)stops {
    if (!stops || stops.count < 1) return;
    
    [self deleteStopsFromICloud:stops];
    [super deleteManagedObjects:stops];
    
    NSMutableArray *deletedCodes = [@[] mutableCopy];
    for (StopEntity *stop in stops) { [deletedCodes addObject:stop.stopGtfsId]; }
    
    [allSavedStopCodes removeObjectsInArray:deletedCodes];
    [self stopsUpdated];
}


-(void)deleteHistoryStopForCode:(NSString *)code {
    if (!code) return;
    
    StopEntity *stopToDelete = [self fetchStopHistoryFromCoreDataForCode:code];
    [super deleteManagedObject:stopToDelete];

    [allHistoryStopCodes removeObject:code];
}

-(void)deleteAllHistoryStop {
    NSArray *historyToDelete = [self fetchAllSavedStopHistoryFromCoreData];
    [super deleteManagedObjects:historyToDelete];
    
    [allHistoryStopCodes removeAllObjects];
}

-(void)clearOldHistory {
    SettingsManager *settingsManager = [SettingsManager sharedManager];
    if ([settingsManager isClearingHistoryEnabled]) {
        int numOfDays = [settingsManager numberOfDaysToKeepHistory];
        
        NSMutableArray *stopsToDelete = [@[] mutableCopy];
        NSArray *allStopHistory = [self fetchAllSavedStopHistoryFromCoreData];
        for (HistoryEntity *stop in allStopHistory) {
            if (stop.dateModified != nil) {
                if ([stop.dateModified timeIntervalSinceNow] < -(numOfDays * 24 * 60 * 60)) {
                    [stopsToDelete addObject:stop];
                    [allHistoryStopCodes removeObject:stop.busStopCode];
                }
            }
        }
        
        if (stopsToDelete.count > 0) {
            [super deleteManagedObjects:stopsToDelete];
        }
    }
}

#pragma mark - Update order
-(void)updateStopsOrderTo:(NSArray *)orderedObjects {
    [self updateOrderedManagedObjectOrderTo:orderedObjects];
    
    [self updateSavedStopsDefaultValueForStops:[self fetchAllSavedStopsFromCoreData]];
}

#pragma mark - update to remote
-(void)stopsUpdated {
    [self stopsUpdated:YES];
}

-(void)stopsUpdated:(BOOL)withNotification {
    NSArray *savedStops = [self fetchAllSavedStopsFromCoreData];
    
    [self updateSavedStopsDefaultValueForStops:savedStops];
    [self updateSavedStopsToWatch:savedStops];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
    
    if (withNotification)
        [[NSNotificationCenter defaultCenter] postNotificationName:kBookmarksWithAnnotationUpdated object:nil];
}

-(void)updateSourceApiForStops:(NSArray *)savedStops {
    if (!savedStops || savedStops.count == 0) { return; }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (StopEntity *stop in savedStops) {
        if (!stop.stopGtfsId) continue;
        
        dict[stop.stopGtfsId] = stop.fetchedFrom;
    }
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsStopsWidgetSuitName]];
    
    [sharedDefaults setObject:dict forKey:kUserDefaultsStopSourceApiKey];
    [sharedDefaults synchronize];
}

-(void)updateSavedStopsToWatch:(NSArray *)savedStops {
    NSMutableArray *stopsDictionaries = [@[] mutableCopy];
    
    for (StopEntity *stop in savedStops) {
        [stopsDictionaries addObject:[stop dictionaryRepresentation]];
    }
    
    [[WatchCommunicationManager sharedManager] transferSavedStops:stopsDictionaries];
}

-(void)updateSavedStopsDefaultValueForStops:(NSArray *)savedStops {
    if (!savedStops){
        savedStops = [self fetchAllSavedStopsFromCoreData];
    }
    
    NSString *codes = [[NSString alloc] init];
    
    BOOL firstElement = YES;
    for (StopEntity *stop in savedStops) {
        if (!stop.stopGtfsId) continue;
        if (firstElement) {
            codes = stop.stopGtfsId;
            firstElement = NO;
        }else{
            codes = [NSString stringWithFormat:@"%@,%@",codes, stop.stopGtfsId];
        }
    }
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsStopsWidgetSuitName]];
    
    [sharedDefaults setObject:codes forKey:kUserDefaultsSavedStopsKey];
    [sharedDefaults synchronize];
    
    [self updateSourceApiForStops:savedStops];
}

-(void)updateSavedStopsDefaultValueForStops {
    [self updateSavedStopsDefaultValueForStops:nil];
}

- (void)updateSavedStopsToICloud {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    NSArray *stops = [self fetchAllSavedStopsFromCoreData];
    [[ICloudManager sharedManager] saveStopsToICloud:stops];
}

- (void)deleteStopsFromICloud:(NSArray *)stops {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    [[ICloudManager sharedManager] deleteSavedStopsFromICloud:stops
     ];
}

#pragma mark - migration
-(void)doMigrations {
    //TODO: Do checkup - if migration is not done
    [self doVersion4_1CoreDataMigration];
    [self doVersion16CoreDataMigration];
    [self doVersion17CoreDataMigration];
    [self migratePreGtfsIdStops];
}

-(void)migratePreGtfsIdStops {
    NSArray *allStops = [self fetchAllSavedStopsFromCoreData];
    NSMutableArray *updated = [@[] mutableCopy];
    
    for (StopEntity *stop in allStops) {
        if (!stop.stopGtfsId) {
            stop.stopGtfsId = @"NONE";
            [updated addObject:stop];
        }
    }
    
    [super saveState];
}

-(BOOL)doVersion4_1CoreDataMigration {
    
    //migration due to stopLines array format change
    NSArray *savedStops = [self fetchAllSavedStopsFromCoreData];
    for (StopEntity *stop in savedStops) {
        if (stop.stopLines && stop.stopLines.count > 0 && [stop.stopLines isKindOfClass:[NSDictionary class]]) {
            //Stops lines were just the dictionary and there were not used anywhere anyways. So just remove them
            stop.stopLines = @[];
            [self saveReittiManagedObject:stop];
        }
    }
    
    return YES;
}

-(void)doVersion16CoreDataMigration {
    //Migration due to addition orders
    NSArray *savedStops = [self fetchAllSavedStopsFromCoreData];
    
    [self updateOrderedManagedObjectOrderTo:savedStops];
}

-(void)doVersion17CoreDataMigration {
    //Get all history and convert them to stop entity
    NSArray *oldHistory = [super fetchAllObjectsForEntityNamed:@"HistoryEntity"];
    if (oldHistory && oldHistory.count > 0) {
        [super deleteManagedObjects:oldHistory];
    }
    
    NSArray *oldSavedStops = [super fetchAllObjectsForEntityNamed:@"StopEntity"];
    if (oldSavedStops && oldSavedStops.count > 0) {
        for (StopEntity *stop in oldSavedStops) {
            if (stop.isHistory) continue;
            
            stop.isHistory = @NO;
        }
        
        [super saveState];
    }
    
}

@end
