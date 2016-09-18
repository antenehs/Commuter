//
//  WatchCommunicationManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@protocol WCManagerDelegate <NSObject>

@optional

-(void)receivedNamedBookmarksArray:(NSArray * _Nonnull)bookmarksArray;
-(void)receivedSavedStopsArray:(NSArray * _Nonnull)stopsArray;
-(void)receivedRoutesArray:(NSArray * _Nonnull)routesArray;
-(void)receivedRoutesSearchOptions:(NSDictionary * _Nonnull)routeSearchOptions;

@end

@interface WatchCommunicationManager : NSObject<WCSessionDelegate>

+(instancetype _Nonnull)sharedManager;

-(void)sendUsedComplicationTypeMessage:(NSString * _Nullable)complicationType;
-(void)sendWatchAppEventWithAction:(NSString * _Nullable)action andLabel:(NSString * _Nullable)label;

#ifndef APPLE_WATCH
-(void)transferNamedBookmarks:(NSArray * _Nullable)bookmarksDictionary;
-(void)transferSavedStops:(NSArray * _Nullable)stopsDictionaries;
-(void)transferRoutes:(NSArray * _Nullable)routesDictionary;
-(void)transferRouteSearchOptions:(NSDictionary * _Nullable)optionsDictionary;
-(void)updateWatchLocalSearchSupported:(BOOL)supported;
#endif

@property (nonatomic, weak)NSObject<WCManagerDelegate> * _Nullable delegate;

#if APPLE_WATCH
@property (nonatomic)BOOL userRegionSupportLocalSearch;

#endif

@end
