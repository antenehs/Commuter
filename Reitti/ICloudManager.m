//
//  ICloudManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ICloudManager.h"
#import "ReittiModels.h"
#import "AppManager.h"
#import "ASA_Helpers.h"

NSString *NamedBookmarkType = @"NamedBookmark";
NSString *SavedStopType = @"SavedStop";
NSString *SavedRouteType = @"SavedRoute";

@interface NamedBookmark (ICloud)

-(CKRecord *)iCloudRecord;
+(CKRecordID *)recordIdForNamedBookmark:(NamedBookmark *)namedBookmark;

@end

@implementation NamedBookmark (ICloud)

-(CKRecord *)iCloudRecord{
    NSDictionary *dict = [self dictionaryRepresentation];
    
    if (!dict)
        return nil;
    
    CKRecordID *recordId = [NamedBookmark recordIdForNamedBookmark:self];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:NamedBookmarkType recordID:recordId];
    for (NSString *key in dict.allKeys) {
        record[key] = dict[key];
    }
    
    record[kNamedBookmarkUniqueId] = [self getUniqueIdentifier];
    record[kNamedBookmarkFullAddress] = [self getFullAddress];
    
    return record;
}

+(CKRecordID *)recordIdForNamedBookmark:(NamedBookmark *)namedBookmark {
    NSString *uniqueName = [NSString stringWithFormat:@"%@ - %@", [namedBookmark getUniqueIdentifier], [AppManager iosDeviceUniqueIdentifier]];
    return [[CKRecordID alloc] initWithRecordName:uniqueName];
}

@end

@interface StopEntity (ICloud)

-(CKRecord *)iCloudRecord;
+(CKRecordID *)recordIdForStopEntity:(StopEntity *)stop;

@end

@implementation StopEntity (ICloud)

-(CKRecord *)iCloudRecord{
    
    CKRecordID *recordId = [StopEntity recordIdForStopEntity:self];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:SavedStopType recordID:recordId];
    record[kStopNumber] = self.busStopCode;
    record[kStopShortCode] = self.busStopShortCode;
    record[kStopName] = self.busStopName;
    record[kStopCity] = self.busStopCity;
    record[kStopType] = [NSNumber numberWithInt: (int)self.stopType];
    
    CLLocationCoordinate2D coordinates = [ReittiStringFormatter convertStringTo2DCoord:self.busStopCoords];
    record[kStopCoordinate] = [[CLLocation alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
    
    record[kStopFetchedFrom] = self.fetchedFrom;
    
    return record;
}

+(CKRecordID *)recordIdForStopEntity:(StopEntity *)stop {
    NSString *uniqueName = [NSString stringWithFormat:@"%ld - %@", (long)stop.busStopCode.integerValue , [AppManager iosDeviceUniqueIdentifier]];
    return [[CKRecordID alloc] initWithRecordName:uniqueName];
}

@end

@interface RouteEntity (ICloud)

-(CKRecord *)iCloudRecord;
+(CKRecordID *)recordIdForRouteEntity:(RouteEntity *)route;

@end

@implementation RouteEntity (ICloud)

-(CKRecord *)iCloudRecord{
    
    CKRecordID *recordId = [RouteEntity recordIdForRouteEntity:self];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:SavedRouteType recordID:recordId];
    record[kRouteUniqueName] = self.routeUniqueName;
    record[kRouteFromLocaiton] = self.fromLocationName;
    record[kRouteFromCoords] = self.fromLocationCoordsString;
    record[kRouteToLocation] = self.toLocationName;
    record[kRouteToCoords] = self.toLocationCoordsString;
    
    return record;
}

+(CKRecordID *)recordIdForRouteEntity:(RouteEntity *)route {
    NSString *uniqueName = [NSString stringWithFormat:@"%@ - %@", route.routeUniqueName , [AppManager iosDeviceUniqueIdentifier]];
    return [[CKRecordID alloc] initWithRecordName:uniqueName];
}

@end

@interface ICloudManager ()

@property (nonatomic, strong)CKDatabase *privateDB;

@end

@implementation ICloudManager

+(id)sharedManager {
    static ICloudManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[ICloudManager alloc] init];
    });
    
    return sharedManager;
}

-(id)init {
    self = [super init];
    
    if (self) {
        self.privateDB = [[CKContainer defaultContainer] privateCloudDatabase];
    }
    
    return self;
}

+(BOOL)isICloudContainerAvailable {
    id currentToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    if (currentToken){
        return YES;
    } else {
        return NO;
    }
}

-(void)fetchAllBookmarksWithCompletionHandler:(ActionBlock)completionHandler {
    ICloudBookmarks *bookmarks = [ICloudBookmarks new];
    
    __block int totalCount = 3;
    __block int failedCount = 0;
//    __block NSString *errorString = nil;
    
    [self fetchAllNamedBookmarksWithCompletionHandler:^(NSArray *results, NSString *error){
        totalCount--;
        if(error) {
//            errorString = error;
            failedCount++;
        } else {
            bookmarks.allNamedBookmarks = results;
        }
        
        if (totalCount == 0) {
            completionHandler(bookmarks, failedCount == 3 ? error : nil);
        }
    }];
    
    [self fetchAllStopsWithCompletionHandler:^(NSArray *results, NSString *error){
        totalCount--;
        if(error) {
//            errorString = error;
            failedCount++;
        } else {
            bookmarks.allSavedStops = results;
        }
        
        if (totalCount == 0) {
            completionHandler(bookmarks, failedCount == 3 ? error : nil);
        }
    }];
    
    [self fetchAllRoutesWithCompletionHandler:^(NSArray *results, NSString *error){
        totalCount--;
        if(error) {
//            errorString = error;
            failedCount++;
        } else {
            bookmarks.allSavedRoutes = results;
        }
        
        if (totalCount == 0) {
            completionHandler(bookmarks, failedCount == 3 ? error : nil);
        }
    }];
}

#pragma mark - Named Bookmark Methods
-(void)fetchAllNamedBookmarksWithCompletionHandler:(ActionBlock)completionHandler {
    [self fetchAllBookmarksWithType:NamedBookmarkType completionHandler:^(NSArray *results, NSString *error){
        if(error) {
            completionHandler(nil, error);
        } else {
            completionHandler(results, nil);
        }
    }];
}

- (void)saveNamedBookmarksToICloud:(NSArray *)namedBookmarks {
    NSMutableArray *records = [@[] mutableCopy];
    
    for (NamedBookmark *bookamrk in namedBookmarks) {
        CKRecord *record = bookamrk.iCloudRecord;
        if (record)
            [records addObject:record];
    }
    
    if (records.count > 0)
        [self saveRecordsToICloud:records];
}

- (void)deleteNamedBookmarksFromICloud:(NSArray *)namedBookmarks {
    if (!namedBookmarks || namedBookmarks.count < 1)
        return;
    
    NSMutableArray *recordIds = [@[] mutableCopy];
    for (NamedBookmark *bookmark in namedBookmarks)
        [recordIds addObject: [NamedBookmark recordIdForNamedBookmark:bookmark]];
    
    [self deleteRecordsWithId:recordIds];
}

#pragma mark - Stop methods
-(void)fetchAllStopsWithCompletionHandler:(ActionBlock)completionHandler {
    [self fetchAllBookmarksWithType:SavedStopType completionHandler:^(NSArray *results, NSString *error){
        if(error) {
            completionHandler(nil, error);
        } else {
            completionHandler(results, nil);
        }
    }];
}

-(void)saveStopsToICloud:(NSArray *)stops {
    NSMutableArray *records = [@[] mutableCopy];
    
    for (StopEntity *stop in stops) {
        CKRecord *record = stop.iCloudRecord;
        if (record)
            [records addObject:record];
    }
    
    if (records.count > 0)
        [self saveRecordsToICloud:records];
}

-(void)deleteSavedStopsFromICloud:(NSArray *)savedStops {
    if (!savedStops || savedStops.count < 1)
        return;
    
    NSMutableArray *recordIds = [@[] mutableCopy];
    for (StopEntity *stop in savedStops)
        [recordIds addObject: [StopEntity recordIdForStopEntity:stop]];
    
    [self deleteRecordsWithId:recordIds];
}

#pragma mark -Route methods
- (void)fetchAllRoutesWithCompletionHandler:(ActionBlock)completionHandler {
    [self fetchAllBookmarksWithType:SavedRouteType completionHandler:^(NSArray *results, NSString *error){
        if(error) {
            completionHandler(nil, error);
        } else {
            completionHandler(results, nil);
        }
    }];
}

- (void)saveRoutesToICloud:(NSArray *)routes {
    NSMutableArray *records = [@[] mutableCopy];
    
    for (RouteEntity *route in routes) {
        CKRecord *record = route.iCloudRecord;
        if (record)
            [records addObject:record];
    }
    
    if (records.count > 0)
        [self saveRecordsToICloud:records];
}

- (void)deleteSavedRoutesFromICloud:(NSArray *)savedRoutes {
    if (!savedRoutes || savedRoutes.count < 1)
        return;
    
    NSMutableArray *recordIds = [@[] mutableCopy];
    for (RouteEntity *route in savedRoutes)
        [recordIds addObject: [RouteEntity recordIdForRouteEntity:route]];
    
    [self deleteRecordsWithId:recordIds];
}

#pragma mark - Generic iCloud methods
-(void)fetchAllBookmarksWithType:(NSString *)type completionHandler:(ActionBlock)completionHandler {
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DeviceUniqueId != %@", [AppManagerBase iosDeviceUniqueIdentifier]];
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:type predicate:predicate];
    [self.privateDB performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error){
        if(error) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self asa_ExecuteBlockInUIThread:^{
                completionHandler(nil, [self errorStringForICloudError:error]);
            }];
        } else {
            [self asa_ExecuteBlockInUIThread:^{
                completionHandler(results, nil);
            }];
        }
    }];
}

- (void)saveRecordsToICloud:(NSArray *)records {
    if (!records || records.count < 1)
        return;
    
    for (CKRecord *record in records) {
        record[kRecordDeviceName] = [AppManager iosDeviceName];
        record[kRecordDeviceUniqueId] = [AppManager iosDeviceUniqueIdentifier];
    }
    
    CKModifyRecordsOperation *modifOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:records recordIDsToDelete: nil];
    
    modifOperation.savePolicy = CKRecordSaveAllKeys;
    modifOperation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * savedRecords, NSArray<CKRecordID *> * deletedRecordIDs, NSError * error){
        if(error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    };
    
    [self.privateDB addOperation:modifOperation];
}

- (void)deleteRecordsWithId:(NSArray *)recordIds {
    CKModifyRecordsOperation *modifOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:recordIds];
    
    modifOperation.savePolicy = CKRecordSaveAllKeys;
    modifOperation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * savedRecords, NSArray<CKRecordID *> * deletedRecordIDs, NSError * error){
        if(error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    };
    
    [self.privateDB addOperation:modifOperation];
}

- (NSString *)errorStringForICloudError:(NSError *)error{
    if ([error.debugDescription containsString:@"-1009"]) {
        return @"The internet connection appears to be offline.";
    }
    
    return @"Unknown error occured. Please try again and report a bug if the problem persists.";
}


#pragma mark - helpers
+(NSDictionary *)ckrecordAsDictionary:(CKRecord *)record{
    if (!record)
        return @{};
    
    NSMutableDictionary *dict = [@{} mutableCopy];
    for (NSString *key in record.allKeys) {
        [dict setValue:record[key] forKey:key];
    }
    
    return dict;
}

@end
