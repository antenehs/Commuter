//
//  SettingsManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EnumManager.h"

#ifndef APPLE_WATCH
//#import "RettiDataManager.h"
#import "ReittiRegionManager.h"
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
#endif

@interface SettingsManager : NSObject

#ifndef APPLE_WATCH
+(id)sharedManager;

-(NSDate *)settingsStartDate;
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
#endif

//NSUserDefaults settings
+(NSString *)uniqueDeviceIdentifier;
+(BOOL)isAnalyticsEnabled;
+(void)enableAnalytics:(BOOL)enable;
+(NSInteger)getStartingIndexTab;
+(void)setStartingIndexTab:(NSInteger)index;

+(BOOL)showBookmarkRoutes;
+(void)setShowBookmarkRoutes:(BOOL)show;
+(BOOL)showBookmarkDepartures;
+(void)setShowBookmarkDepartures:(BOOL)show;
+(BOOL)isAnnotationTypeEnabled:(AnnotationType)type;
+(void)saveAnnotationTypeEnabled:(BOOL)enabled type:(AnnotationType)type;
+(BOOL)askedContactsPermission;
+(void)setAskedContactPermission:(BOOL)asked;
+(NSInteger)getSkippedcontactsRequestTrials;
+(void)setSkippedcontactsRequestTrials:(NSInteger)index;
+(NSInteger)showGoProInStopViewRequestCount;

+(BOOL)useDigiTransit;
+(void)setUseDigiTrnsit:(BOOL)use;

#if APPLE_WATCH
+(BOOL)watchRegionSupportsLocalSearching;
+(void)setWatchRegionSupportsLocalSearching:(BOOL)supports;
#endif

#ifndef APPLE_WATCH
//@property(nonatomic, strong)RettiDataManager *reittiDataManager;

//@property(nonatomic, strong)SettingsEntity *settingsEntity;
#endif

//Temoporarily make user location to apple watch
@property(nonatomic, readonly)BOOL isHSLRegion;

@end
