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
NSString *kRecordDeviceUniqueId = @"DeviceUniqueId";

//Named bookmar
NSString *kNamedBookmarkUniqueId = @"BookmarkUniqueId";
NSString *kNamedBookmarkFullAddress = @"FullAddress";
NSString *kNamedBookmarkName = @"name";

//Stop
NSString *kStopGtfsId = @"StopGtfsId";
NSString *kStopNumber = @"StopNumber";
NSString *kStopShortCode = @"StopShortCode";
NSString *kStopName = @"StopName";
NSString *kStopCity = @"StopCity";
NSString *kStopType = @"StopType";
NSString *kStopCoordinate = @"StopCoordinate";
NSString *kStopFetchedFrom = @"StopFetchedFrom";

//Route
NSString *kRouteUniqueName = @"RouteUniqueName";
NSString *kRouteFromLocaiton = @"kRouteFromLocaiton";
NSString *kRouteFromCoords = @"kRouteFromCoords";
NSString *kRouteToLocation = @"kRouteToLocation";
NSString *kRouteToCoords = @"kRouteToCoords";


@implementation ICloudBookmarks

//This method also excludes bookmarks from current device. [appmanager iosDeviceUniqueId] changes for each new installation so it
//will still be available to download in re-installation
-(NSDictionary *)getBookmarksExcludingNamedBookmarks:(NSArray *)namedBookmarks savedStops:(NSArray *)savedStops savedRoutes:(NSArray *)savedRoutes {
    
    NSArray *namedBookmarkIds = [self namedBookmarkIds:namedBookmarks];
    
    NSMutableArray *filteredArray = [[self.allNamedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        CKRecord *record = (CKRecord *)object;
        return record ? ![namedBookmarkIds containsObject:record[kNamedBookmarkUniqueId]] : NO;
    }]] mutableCopy];
    
    NSArray *stopIds = [self stopIds:savedStops];
    
    [filteredArray addObjectsFromArray:[self.allSavedStops filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        CKRecord *record = (CKRecord *)object;
        return record ? ![stopIds containsObject:record[kStopGtfsId]] : NO;
    }]]];
    
    NSArray *routeIds = [self routeIds:savedRoutes];
    
    [filteredArray addObjectsFromArray:[self.allSavedRoutes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        CKRecord *record = (CKRecord *)object;
        return record ? ![routeIds containsObject:record[kRouteUniqueName]] : NO;
    }]]];

    return [self groupRecordsByDevice:filteredArray];
}

-(NSDictionary *)allBookmarksGrouped {
    NSMutableArray *allArray = [@[] mutableCopy];
    [allArray addObjectsFromArray:self.allNamedBookmarks ? self.allNamedBookmarks : @[]];
    [allArray addObjectsFromArray:self.allSavedRoutes ? self.allSavedRoutes : @[]];
    [allArray addObjectsFromArray:self.allSavedStops ? self.allSavedStops : @[]];
    
    return [self groupRecordsByDevice:allArray];
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
        [ids addObject:stop.stopGtfsId];
    }
    
    return ids;
}

-(NSArray *)routeIds:(NSArray *)routes {
    if (!routes)
        return @[];
    
    NSMutableArray *ids = [@[] mutableCopy];
    for (RouteEntity *route in routes) {
        [ids addObject:route.routeUniqueName];
    }
    
    return ids;
}



-(NSDictionary *)groupRecordsByDevice:(NSArray *)records {
    NSMutableDictionary *groupedDictionary = [@{} mutableCopy];
    NSMutableArray *deviceIds = [@[] mutableCopy];
    
    for (CKRecord *record in records) {
        if (![deviceIds containsObject:record[kRecordDeviceUniqueId]]) {
            [deviceIds addObject:record[kRecordDeviceUniqueId]];
        }
    }
    
    for (NSString *deviceId in deviceIds) {
        NSArray *filteredArray = [records filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            CKRecord *record = (CKRecord *)object;
            return record ? [(NSString *)record[kRecordDeviceUniqueId] isEqualToString:deviceId] : NO;
        }]];
        
        if (filteredArray && filteredArray.count > 0)
            groupedDictionary[deviceId] = filteredArray;
    }
    
    return groupedDictionary;
}

#pragma mark - convinence methods
-(NSArray *)allRecordIds {
    NSMutableArray *allArray = [@[] mutableCopy];
    [allArray addObjectsFromArray:self.allNamedBookmarks ? self.allNamedBookmarks : @[]];
    [allArray addObjectsFromArray:self.allSavedRoutes ? self.allSavedRoutes : @[]];
    [allArray addObjectsFromArray:self.allSavedStops ? self.allSavedStops : @[]];
    
    NSMutableArray *allRecordIds = [@[] mutableCopy];
    for (CKRecord *record in allArray) {
        [allRecordIds addObject:record.recordID];
    }
    
    return allRecordIds;
}

@end
