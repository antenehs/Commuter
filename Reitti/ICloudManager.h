//
//  ICloudManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASA_Helpers.h"
#import "ICloudBookmarks.h"
#import <CloudKit/CloudKit.h>

extern NSString *NamedBookmarkType;
extern NSString *SavedStopType;

@interface ICloudManager : NSObject

+(id)sharedManager;

//Fetch, save and delete methods
- (void)fetchAllBookmarksWithCompletionHandler:(ActionBlock)completionHandler ;
- (void)saveNamedBookmarksToICloud:(NSArray *)namedBookmarks;
- (void)deleteNamedBookmarksFromICloud:(NSArray *)namedBookmarks;

- (void)fetchAllStopsWithCompletionHandler:(ActionBlock)completionHandler;
- (void)saveStopsToICloud:(NSArray *)stops;
- (void)deleteSavedStopFromICloud:(NSArray *)savedStops;

//Helpers
+(NSDictionary *)ckrecordAsDictionary:(CKRecord *)record;

@end
