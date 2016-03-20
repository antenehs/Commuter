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
NSString *kStopCoordinate = @"StopCoordinate";

//Route
NSString *kRouteUniqueName = @"RouteUniqueName";
NSString *kRouteFromLocaiton = @"kRouteFromLocaiton";
NSString *kRouteFromCoords = @"kRouteFromCoords";
NSString *kRouteToLocation = @"kRouteToLocation";
NSString *kRouteToCoords = @"kRouteToCoords";


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
        [ids addObject:stop.busStopCode];
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
