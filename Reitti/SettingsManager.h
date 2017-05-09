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

//Properties
@property(nonatomic)MapMode mapMode;

@property(nonatomic)Region userLocation;

@property(nonatomic)BOOL showLiveVehicles;

@property(nonatomic)BOOL isClearingHistoryEnabled;

@property(nonatomic)int numberOfDaysToKeepHistory;

@property(nonatomic, strong)NSString *toneName;

@property(nonatomic, strong)RouteSearchOptions *globalRouteOptions;

#endif

#pragma mark - NSUserDefaults settings

//Methods
+(NSString *)uniqueDeviceIdentifier;
+(BOOL)isAnnotationTypeEnabled:(AnnotationType)type;
+(void)saveAnnotationTypeEnabled:(BOOL)enabled type:(AnnotationType)type;

@property(nonatomic, class)BOOL isAnalyticsEnabled;

@property(nonatomic, class)NSInteger startingIndexTab;

@property(nonatomic, class)BOOL showBookmarkRoutes;

@property(nonatomic, class)BOOL showBookmarkDepartures;

@property(nonatomic, class)BOOL askedContactsPermission;

@property(nonatomic, class)NSInteger skippedcontactsRequestTrials;

@property(nonatomic, readonly, class)NSInteger showGoProInStopViewRequestCount;

@property(nonatomic, class)BOOL useDigiTransit;

@property(nonatomic, readonly)BOOL isHSLRegion;

#if APPLE_WATCH
@property(nonatomic, class)BOOL watchRegionSupportsLocalSearching;

//+(BOOL)watchRegionSupportsLocalSearching;
//+(void)setWatchRegionSupportsLocalSearching:(BOOL)supports;
#endif


@end
