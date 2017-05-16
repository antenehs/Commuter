//
//  ICloudBookmarks.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

extern NSString *kRecordDeviceName;
extern NSString *kRecordDeviceUniqueId;

//NamedBookmark
extern NSString *kNamedBookmarkUniqueId;
extern NSString *kNamedBookmarkFullAddress;
extern NSString *kNamedBookmarkName;

//Saved stopentity
extern NSString *kStopGtfsId;
extern NSString *kStopNumber;
extern NSString *kStopShortCode;
extern NSString *kStopName;
extern NSString *kStopCity;
extern NSString *kStopType;
extern NSString *kStopCoordinate;
extern NSString *kStopFetchedFrom;

//Saved RouteEntity
extern NSString *kRouteUniqueName;
extern NSString *kRouteFromLocaiton;
extern NSString *kRouteFromCoords;
extern NSString *kRouteToLocation;
extern NSString *kRouteToCoords;

@interface ICloudBookmarks : NSObject

//Returns dictionary<deviceName:sortedArrayOfBookmarks>
-(NSDictionary *)getBookmarksExcludingNamedBookmarks:(NSArray *)namedBookmarks savedStops:(NSArray *)savedStops savedRoutes:(NSArray *)savedRoutes;
-(NSDictionary *)allBookmarksGrouped;
-(NSDictionary *)groupRecordsByDevice:(NSArray *)records;

@property (nonatomic, strong)NSArray *allNamedBookmarks;
@property (nonatomic, strong)NSArray *allSavedStops;
@property (nonatomic, strong)NSArray *allSavedRoutes;
@property (nonatomic, strong, readonly)NSArray *allRecordIds;

@end
