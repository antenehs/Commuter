//
//  NamedBookmarkCoreDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/12/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "CoreDataManager.h"
#import "NamedBookmark.h"
#import "GeoCode.h"
#import "ICloudManager.h"

@interface NamedBookmarkCoreDataManager : CoreDataManager

+(id)sharedManager;

-(NamedBookmark *)createNewNamedBookmark;

-(BOOL)doesNamedBookmarkExistWithName:(NSString *)name;

//Save
-(NamedBookmark *)saveNamedBookmarkToCoreData:(NamedBookmarkData *)namedBookmarkData;
-(NamedBookmark *)createOrUpdateNamedBookmarkFromICLoudRecord:(CKRecord *)record;

//Delete
-(void)deleteNamedBookmarkForName:(NSString *)name;
-(void)deleteAllNamedBookmarks;

//Fetch
-(NSArray *)fetchAllSavedNamedBookmarks;
-(NamedBookmark *)fetchSavedNamedBookmarkForName:(NSString *)name;
-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForCoords:(NSString *)coords;
-(NamedBookmark *)fetchSavedNamedBookmarkForObjectLid:(NSNumber *)objectLid;

//Order
-(void)updateNamedBookmarkOrderTo:(NSArray *)orderedObjects;

@end
