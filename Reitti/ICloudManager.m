//
//  ICloudManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ICloudManager.h"
#import "NamedBookmark.h"
#import "StopEntity.h"
#import "AppManager.h"
#import "ASA_Helpers.h"

NSString *NamedBookmarkType = @"NamedBookmark";
NSString *SavedStopType = @"SavedStop";

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
    NSString *uniqueName = [NSString stringWithFormat:@"%@ - %@", [namedBookmark getUniqueIdentifier], [AppManagerBase iosDeviceName]];
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
    
    return record;
}

+(CKRecordID *)recordIdForStopEntity:(StopEntity *)stop {
    NSString *uniqueName = [NSString stringWithFormat:@"%ld - %@", (long)stop.busStopCode.integerValue , [AppManagerBase iosDeviceName]];
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

-(void)fetchAllBookmarksWithCompletionHandler:(ActionBlock)completionHandler {
    ICloudBookmarks *bookmarks = [ICloudBookmarks new];
    
    __block int totalCount = 2;
    __block NSString *errorString = nil;
    
    [self fetchAllNamedBookmarksWithCompletionHandler:^(NSArray *results, NSString *error){
        totalCount--;
        if(error) {
            errorString = error;
        } else {
            bookmarks.allNamedBookmarks = results;
        }
        
        if (totalCount == 0) {
            completionHandler(bookmarks, errorString);
        }
    }];
    
    [self fetchAllStopsWithCompletionHandler:^(NSArray *results, NSString *error){
        totalCount--;
        if(error) {
            errorString = error;
        } else {
            bookmarks.allSavedStops = results;
        }
        
        if (totalCount == 0) {
            completionHandler(bookmarks, errorString);
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

-(void)deleteSavedStopFromICloud:(NSArray *)savedStops {
    if (!savedStops || savedStops.count < 1)
        return;
    
    NSMutableArray *recordIds = [@[] mutableCopy];
    for (StopEntity *stop in savedStops)
        [recordIds addObject: [StopEntity recordIdForStopEntity:stop]];
    
    [self deleteRecordsWithId:recordIds];
}

#pragma mark - Generic iCloud methods
-(void)fetchAllBookmarksWithType:(NSString *)type completionHandler:(ActionBlock)completionHandler {
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:type predicate:predicate];
    [self.privateDB performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error){
        if(error) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self asa_ExecuteBlockInUIThread:^{
                completionHandler(nil, error.localizedDescription);
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
    
    for (CKRecord *record in records)
        record[kRecordDeviceName] = [AppManagerBase iosDeviceName];
    
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
