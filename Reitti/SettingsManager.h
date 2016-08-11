//
//  SettingsManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RettiDataManager.h"
#import "SettingsEntity.h"

typedef enum
{
    StandartMapMode = 0,
    HybridMapMode = 1,
    SateliteMapMode = 2
} MapMode;

extern NSString * const mapModeChangedNotificationName;
extern NSString * const userlocationChangedNotificationName;
extern NSString * const shouldShowVehiclesNotificationName;
extern NSString * const routeSearchOptionsChangedNotificationName;

@interface SettingsManager : NSObject

-(id)initWithDataManager:(RettiDataManager *)dataManager;

-(MapMode)getMapMode;
-(Region)userLocation;
-(BOOL)shouldShowLiveVehicles;
-(BOOL)isClearingHistoryEnabled;
-(int)numberOfDaysToKeepHistory;
-(NSString *)toneName;
-(RouteSearchOptions *)globalRouteOptions;

-(void)setMapMode:(MapMode)mapMode;
-(void)setUserLocation:(Region)userLocation;
-(void)showLiveVehicle:(BOOL)show;
-(void)enableClearingOldHistory:(BOOL)clear;
-(void)setNumberOfDaysToKeepHistory:(int)days;
-(void)setToneName:(NSString *)toneName;
-(void)setGlobalRouteOptions:(RouteSearchOptions *)globalRouteOptions;

//NSUserDefaults settings
+(BOOL)isAnalyticsEnabled;
+(void)enableAnalytics:(BOOL)enable;
+(NSInteger)getStartingIndexTab;
+(void)setStartingIndexTab:(NSInteger)index;

+(BOOL)showBookmarkRoutes;
+(void)setShowBookmarkRoutes:(BOOL)show;
+(BOOL)showBookmarkDepartures;
+(void)setShowBookmarkDepartures:(BOOL)show;

@property(nonatomic, strong)RettiDataManager *reittiDataManager;

@property(nonatomic, strong)SettingsEntity *settingsEntity;


@end
