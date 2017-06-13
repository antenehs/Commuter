//
//  NamedBookmarkCoreDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/12/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "NamedBookmarkCoreDataManager.h"
#import "AppManager.h"
#import "WatchCommunicationManager.h"
#import "ReittiAppShortcutManager.h"
#import "ReittiSearchManager.h"
#import "RouteEntity.h"
#import "RouteHistoryEntity.h"

NSString *kNamedBookmarkEntityName = @"NamedBookmark";

@interface NamedBookmarkCoreDataManager ()

@property (strong, nonatomic) NSMutableArray *allNamedBookmarkNames;
@property (nonatomic) BOOL doneInitialTasks;

@end

@implementation NamedBookmarkCoreDataManager

+(instancetype)sharedManager {
    static NamedBookmarkCoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [NamedBookmarkCoreDataManager new];
    });
    
    //Do this outside the dispatch
    if (!sharedInstance.doneInitialTasks) {
        sharedInstance.doneInitialTasks = YES;
        
        [sharedInstance fetchAllNamedBookmarkNames];
        [sharedInstance updateNamedBookmarksUserDefaultValue];
        [sharedInstance updatedBookmarksWithNotification:NO];
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

-(NamedBookmark *)createNewNamedBookmark {
    return (NamedBookmark *)[super createNewObjectForEntityNamed:kNamedBookmarkEntityName];
}

#pragma mark - Save methods

-(NamedBookmark *)saveNamedBookmarkToCoreData:(NamedBookmarkData *)namedBookmarkData {
    if (namedBookmarkData == nil) return nil;
    NamedBookmark *bookmarkToSave;
    if (namedBookmarkData.objectLid) {
        bookmarkToSave= [self fetchSavedNamedBookmarkForObjectLid:namedBookmarkData.objectLid];
    }
    
    if(bookmarkToSave) { //Exist already
        [self deleteNamedBookmarksFromICloud:@[bookmarkToSave]];
    }else{
        bookmarkToSave = [self createNewNamedBookmark];
        //TODO: This doesnt work. Has to reset orders of others
        bookmarkToSave.order = [NSNumber numberWithInteger:self.allNamedBookmarkNames.count + 1];
    }
    
    [bookmarkToSave updateValuesFromNamedBookmarkData:namedBookmarkData];
    [super saveReittiManagedObject:bookmarkToSave];
    
    [self updateSavedAndHistoryRoutesForNamedBookmark:bookmarkToSave];
    [self updatedBookmarksWithNotification:YES];
    
    return bookmarkToSave;
}

-(NamedBookmark *)createOrUpdateNamedBookmarkFromICLoudRecord:(CKRecord *)record {
    if (!record)
        return nil;
    
    NSDictionary *dict = [ICloudManager ckrecordAsDictionary:record];
    NamedBookmark *bookmark = [[NamedBookmarkCoreDataManager sharedManager] fetchSavedNamedBookmarkForName:dict[kNamedBookmarkName]];
    
    if(bookmark){
        [bookmark updateValuesFromDictionary:dict];
    }else{
        bookmark = [self createNewNamedBookmark];
        [bookmark updateValuesFromDictionary:dict];
    }
    
    [super saveReittiManagedObject:bookmark];
    
    return bookmark;
}

-(BOOL)doesNamedBookmarkExistWithName:(NSString *)name{
    [self fetchAllNamedBookmarkNames];
    return [self.allNamedBookmarkNames containsObject:name];
}

#pragma mark - Delete methods

-(void)deleteNamedBookmarkForName:(NSString *)name {
    NamedBookmark *bookmarkToDelete = [self fetchSavedNamedBookmarkForName:name];
    
    if (!bookmarkToDelete) return;
    
    [self deleteNamedBookmarksFromICloud:@[bookmarkToDelete]];
    [self deleteSavedAndHistoryRoutesForNamedBookmark:bookmarkToDelete];
    
    [super deleteManagedObject:bookmarkToDelete];
    
    [self updatedBookmarksWithNotification:YES];
}

-(void)deleteAllNamedBookmarks {
    NSArray *bookmarksToDelete = [[NamedBookmarkCoreDataManager sharedManager] fetchAllSavedNamedBookmarks];
    
    [self deleteNamedBookmarksFromICloud:bookmarksToDelete];
    
    for (NamedBookmark *bookmark in bookmarksToDelete) {
        [self deleteSavedAndHistoryRoutesForNamedBookmark:bookmark];
    }
    
    [super deleteManagedObjects:bookmarksToDelete];
    
    [self updatedBookmarksWithNotification:YES];
}

#pragma mark - fetch methods

-(NSArray *)fetchAllSavedNamedBookmarks {
    return [super fetchAllOrderedObjectsForEntityNamed: kNamedBookmarkEntityName];
}

-(NamedBookmark *)fetchSavedNamedBookmarkForName:(NSString *)name {
    NSString *predString = [NSString stringWithFormat:@"name == '%@'", name];
    
    NSArray *savedBookmarks = [super fetchObjectsForEntityNamed:kNamedBookmarkEntityName predicateString:predString];
    return [savedBookmarks firstObject];
}

-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForCoords:(NSString *)coords{
    NSString *predString = [NSString stringWithFormat:@"coords == '%@'", coords];
    
    NSArray *savedBookmarks = [super fetchObjectsForEntityNamed:kNamedBookmarkEntityName predicateString:predString];
    return [savedBookmarks firstObject];
}

-(NamedBookmark *)fetchSavedNamedBookmarkForObjectLid:(NSNumber *)objectLid {
    NSString *predString = [NSString stringWithFormat:@"objectLID == %@", objectLid];
    
    NSArray *savedBookmarks = [super fetchObjectsForEntityNamed:kNamedBookmarkEntityName predicateString:predString];
    return [savedBookmarks firstObject];
}

-(void)fetchAllNamedBookmarkNames {
    NSArray *names = [super fetchObjectsForEntityNamed:kNamedBookmarkEntityName predicateString:nil sortWithPropertyNamed:@"name" assending:NO propertiesToFetch:@[@"name"]];
    
    self.allNamedBookmarkNames = names ? names : [@[] mutableCopy];
}

#pragma mark - Update to remotes

- (void)updatedBookmarksWithNotification:(BOOL)notify {
    NSArray *bookmarks = [self fetchAllSavedNamedBookmarks];
    
    [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
    
    [self updateSavedNamedBookmarksToICloud:bookmarks];
    [self updateNamedBookmarksUserDefaultValue:bookmarks];
    [self updateNamedBookmarksToWatch:bookmarks];
    
    [self fetchAllNamedBookmarkNames];
    
    if (notify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBookmarksWithAnnotationUpdated object:nil];
    }
}

- (void)updateNamedBookmarksUserDefaultValue:(NSArray *)namedBookmarks {
    if (![AppManager isProVersion]) return;
    
    NSMutableArray *namedBookmarkDictionaries = [@[] mutableCopy];
    
    for (NamedBookmark *nmdBookmark in namedBookmarks) {
        [namedBookmarkDictionaries addObject:[nmdBookmark dictionaryRepresentation]];
    }
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsRoutesExtensionSuitName]];
    
    [sharedDefaults setObject:namedBookmarkDictionaries forKey:kUserDefaultsNamedBookmarksKey];
    [sharedDefaults synchronize];
}

- (void)updateNamedBookmarksUserDefaultValue {
    NSArray *namedBookmarks = [self fetchAllSavedNamedBookmarks];
    
    [self updateNamedBookmarksUserDefaultValue: namedBookmarks];
}

- (void)updateNamedBookmarksToWatch {
    NSArray *namedBookmarks = [self fetchAllSavedNamedBookmarks];
    [self updateNamedBookmarksToWatch:namedBookmarks];
}
- (void)updateNamedBookmarksToWatch:(NSArray *)namedBookmarks {
    NSMutableArray *namedBookmarkDictionaries = [@[] mutableCopy];
    
    for (NamedBookmark *nmdBookmark in namedBookmarks) {
        [namedBookmarkDictionaries addObject:[nmdBookmark dictionaryRepresentation]];
    }
    
    [[WatchCommunicationManager sharedManager] transferNamedBookmarks:namedBookmarkDictionaries];
}

- (void)updateSavedNamedBookmarksToICloud:(NSArray *)namedBookmarks {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    [[ICloudManager sharedManager] saveNamedBookmarksToICloud:namedBookmarks];
}
- (void)updateSavedNamedBookmarksToICloud {
    [self updateNamedBookmarksToWatch:[self fetchAllSavedNamedBookmarks]];
}

- (void)deleteNamedBookmarksFromICloud:(NSArray *)namedBookmarks {
    if (![ICloudManager isICloudContainerAvailable]) return;
    
    [[ICloudManager sharedManager] deleteNamedBookmarksFromICloud:namedBookmarks];
}

-(void)updateSavedAndHistoryRoutesForNamedBookmark:(NamedBookmark *)bookmark {
    //TODO
    /*
    NSArray *savedRoutes = [self fetchSavedRouteFromCoreDataForNamedBookmarkName:bookmark.name];
    
    for (RouteEntity *entity in savedRoutes) {
        if ([entity.toLocationName isEqualToString:bookmark.name]) {
            entity.toLocationCoordsString = bookmark.coords;
        }
        
        if ([entity.fromLocationName isEqualToString:bookmark.name]) {
            entity.fromLocationCoordsString = bookmark.coords;
        }
        
        [self saveManagedObject:entity];
    }
    
    NSArray *historyRoutes = [self fetchRouteHistoryFromCoreDataForNamedBookmarkName:bookmark.name];
    
    for (RouteHistoryEntity *entity in historyRoutes) {
        if ([entity.toLocationName isEqualToString:bookmark.name]) {
            entity.toLocationCoordsString = bookmark.coords;
        }
        
        if ([entity.fromLocationName isEqualToString:bookmark.name]) {
            entity.fromLocationCoordsString = bookmark.coords;
        }
        
        [self saveManagedObject:entity];
    }
    
    [[ReittiRemindersManager sharedManger] updateRoutineForDeletedBookmarkNamed:bookmark.name];
     */
}

-(void)deleteSavedAndHistoryRoutesForNamedBookmark:(NamedBookmark *)bookmark {
    //TODO
    /*
    NSArray *savedRoutes = [self fetchSavedRouteFromCoreDataForNamedBookmarkName:bookmark.name];
    
    for (RouteEntity *entity in savedRoutes) {
        [self deleteSavedRouteForCode:entity.routeUniqueName];
    }
    
    NSArray *historyRoutes = [self fetchRouteHistoryFromCoreDataForNamedBookmarkName:bookmark.name];
    
    for (RouteHistoryEntity *entity in historyRoutes) {
        [self deleteHistoryRouteForCode:entity.routeUniqueName];
    }
    
    [[ReittiRemindersManager sharedManger] updateRoutineForDeletedBookmarkNamed:bookmark.name];
     */
}

#pragma mark - Order
-(void)updateNamedBookmarkOrderTo:(NSArray *)orderedObjects {
    [self updateOrderedManagedObjectOrderTo:orderedObjects];
    
    [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
    [self updateNamedBookmarksUserDefaultValue];
    [self updateNamedBookmarksToWatch];
}

#pragma mark - Migration
-(void)doMigrations {
    [self doVersion16CoreDataMigration];
}

-(void)doVersion16CoreDataMigration {
    //Migration due to addition orders
    NSArray *namedBookmarks = [self fetchAllSavedNamedBookmarks];
    
    [self updateOrderedManagedObjectOrderTo:namedBookmarks];
}


@end
