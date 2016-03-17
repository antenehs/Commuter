//
//  ICloudBookmarks.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ICloudBookmarks.h"
#import "NamedBookmark.h"
#import "StopEntity.h"
#import "RouteEntity.h"

NSString *kRecordDeviceName = @"DeviceName";

//Named bookmar
NSString *kNamedBookmarkUniqueId = @"BookmarkUniqueId";
NSString *kNamedBookmarkFullAddress = @"FullAddress";
NSString *kNamedBookmarkName = @"name";

//Stop
NSString *kStopNumber = @"StopNumber";
NSString *kStopShortCode = @"StopShortCode";
NSString *kStopName = @"StopName";
NSString *kStopCity = @"StopCity";
NSString *kStopType = @"StopType";

@implementation ICloudBookmarks

-(NSDictionary *)getBookmarksExcludingNamedBookmarks:(NSArray *)namedBookmarks savedStops:(NSArray *)savedStops savedRoutes:(NSArray *)savedRoutes {
    
    NSArray *namedBookmarkIds = [self namedBookmarkIds:namedBookmarks];
    
    NSMutableArray *filteredArray = [[self.allNamedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        CKRecord *record = (CKRecord *)object;
        return record ? ![namedBookmarkIds containsObject:record[kNamedBookmarkUniqueId]] : NO;
    }]] mutableCopy];
    
    NSArray *stopIds = [self stopIds:savedStops];
    
    [filteredArray addObjectsFromArray:[self.allSavedStops filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        CKRecord *record = (CKRecord *)object;
        return record ? ![stopIds containsObject:record[kStopNumber]] : NO;
    }]]];

    return [self groupRecordsByDevice:filteredArray];
}

-(NSArray *)namedBookmarkIds:(NSArray *)namedBookmarks {
    if (!namedBookmarks)
        return @[];
    
    NSMutableArray *ids = [@[] mutableCopy];
    for (NamedBookmark *bookmark in namedBookmarks) {
        [ids addObject:[bookmark getUniqueIdentifier]];
    }
    
    return ids;
}

-(NSArray *)stopIds:(NSArray *)stops {
    if (!stops)
        return @[];
    
    NSMutableArray *ids = [@[] mutableCopy];
    for (StopEntity *stop in stops) {
        [ids addObject:stop.busStopCode];
    }
    
    return ids;
}

-(NSDictionary *)groupRecordsByDevice:(NSArray *)records {
    NSMutableDictionary *groupedDictionary = [@{} mutableCopy];
    NSMutableArray *deviceNames = [@[] mutableCopy];
    
    for (CKRecord *record in records) {
        if (![deviceNames containsObject:record[kRecordDeviceName]]) {
            [deviceNames addObject:record[kRecordDeviceName]];
        }
    }
    
    for (NSString *deviceName in deviceNames) {
        NSArray *filteredArray = [records filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            CKRecord *record = (CKRecord *)object;
            return record ? [(NSString *)record[kRecordDeviceName] isEqualToString:deviceName] : NO;
        }]];
        
        if (filteredArray)
            groupedDictionary[deviceName] = filteredArray;
    }
    
    return groupedDictionary;
}

@end
