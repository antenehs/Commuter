//
//  WatchDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NamedBookmarkE.h"
#import <MapKit/MapKit.h>
#import "WatchHslApi.h"
#import "RoutableLocation.h"

@interface WatchDataManager : NSObject

-(void)saveBookmarks:(NSArray *)bookmarks;
-(NSArray *)getSavedNamedBookmarkDictionaries;

-(void)saveOtherRecentLocation:(RoutableLocation *)location;
-(void)saveOtherRecentLocations:(NSArray *)locations;
-(NSArray *)getOtherRecentLocations;

-(void)getRouteToLocation:(RoutableLocation *)toLocation fromCoordLocation:(CLLocation *)fromLocation routeOptions:(NSDictionary *)options andCompletionBlock:(ActionBlock)completionBlock;

@end
