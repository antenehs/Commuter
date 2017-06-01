//
//  WatchDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "WatchHslApi.h"
#import "RoutableLocation.h"
#import "RouteSearchOptions.h"

@interface WatchDataManager : NSObject

-(void)saveRouteSearchOptions:(RouteSearchOptions *)searchOptions;
-(RouteSearchOptions *)getRouteSearchOptions;

-(void)saveStops:(NSArray *)stops;
-(NSArray *)getSavedStopsDictionaries;


-(void)saveStopsWithDepartures:(NSArray *)stops;
-(NSArray *)getSavedStopsWithDeparturesDictionaries;

-(void)saveBookmarks:(NSArray *)bookmarks;
-(NSArray *)getSavedNamedBookmarkDictionaries;

-(void)saveOtherRecentLocation:(RoutableLocation *)location;
-(void)saveOtherRecentLocations:(NSArray *)locations;
-(NSArray *)getOtherRecentLocations;

-(NSArray *)namedBookmarksFromBookmarksDictionaries:(NSArray *)bookmarkdictionaries;

-(void)getRouteToLocation:(RoutableLocation *)toLocation fromCoordLocation:(CLLocation *)fromLocation routeOptions:(RouteSearchOptions *)searchOptions andCompletionBlock:(ActionBlock)completionBlock;
- (void)fetchStopForCode:(NSString *)code andCompletionBlock:(ActionBlock)completionBlock;

@end
