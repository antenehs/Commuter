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

//NamedBookmark
extern NSString *kNamedBookmarkUniqueId;
extern NSString *kNamedBookmarkFullAddress;
extern NSString *kNamedBookmarkName;

//Saved stopentity
extern NSString *kStopNumber;
extern NSString *kStopShortCode;
extern NSString *kStopName;
extern NSString *kStopCity;
extern NSString *kStopType;

@interface ICloudBookmarks : NSObject

//Returns dictionary<deviceName:sortedArrayOfBookmarks>
-(NSDictionary *)getBookmarksExcludingNamedBookmarks:(NSArray *)namedBookmarks savedStops:(NSArray *)savedStops savedRoutes:(NSArray *)savedRoutes;

@property (nonatomic, strong)NSArray *allNamedBookmarks;
@property (nonatomic, strong)NSArray *allSavedStops;
@property (nonatomic, strong)NSArray *allSavedRoutes;

@end
