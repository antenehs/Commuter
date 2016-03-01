//
//  SettingsManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "SettingsManager.h"

NSString * const mapModeChangedNotificationName = @"SettingsManagerMapModeChangedNotification";
NSString * const userlocationChangedNotificationName = @"SettingsManagerUserLocationChangedNotification";
NSString * const shouldShowVehiclesNotificationName = @"SettingsManagerShowVehiclesChangedNotification";
NSString * const routeSearchOptionsChangedNotificationName = @"SettingsManagerRouteSearchOptionsChangedNotification";

NSString * const kAnalyticsSettingsNsDefaultsKey = @"IsAnalyticsSettingEnabled";
NSString * const kStartingTabNsDefaultsKey = @"startingTabNsDefaultsKey";

@implementation SettingsManager

@synthesize reittiDataManager, settingsEntity;

-(id)initWithDataManager:(RettiDataManager *)dataManager{
    self.reittiDataManager = dataManager;
    
    [self.reittiDataManager fetchSettings];
    
    [self.reittiDataManager updateRouteSearchOptionsToUserDefaultValue];
    
    return self;
}

-(MapMode)getMapMode{
    [self.reittiDataManager fetchSettings];
    return (MapMode)[self.reittiDataManager.settingsEntity.mapMode  intValue];
}
-(Region)userLocation{
    [self.reittiDataManager fetchSettings];
    return (Region)[self.reittiDataManager.settingsEntity.userLocation intValue];
}

-(BOOL)shouldShowLiveVehicles{
    [self.reittiDataManager fetchSettings];
    return [self.reittiDataManager.settingsEntity.showLiveVehicle boolValue];
}

-(BOOL)isClearingHistoryEnabled{
    [self.reittiDataManager fetchSettings];
    return [self.reittiDataManager.settingsEntity.clearOldHistory boolValue];
}
-(int)numberOfDaysToKeepHistory{
    [self.reittiDataManager fetchSettings];
    return [self.reittiDataManager.settingsEntity.numberOfDaysToKeepHistory intValue];
}

-(NSString *)toneName{
    [self.reittiDataManager fetchSettings];
    return self.reittiDataManager.settingsEntity.toneName;
}

-(RouteSearchOptions *)globalRouteOptions{
    [self.reittiDataManager fetchSettings];
    return self.reittiDataManager.settingsEntity.globalRouteOptions;
}

-(void)setMapMode:(MapMode)mapMode{
    [self.reittiDataManager.settingsEntity setMapMode:[NSNumber numberWithInt:mapMode]];
    [self.reittiDataManager saveSettings];
    
    [self postNotificationWithName:mapModeChangedNotificationName];
}
-(void)setUserLocation:(Region)userLocation{
    [self.reittiDataManager.settingsEntity setUserLocation:[NSNumber numberWithInt:userLocation]];
    [self.reittiDataManager saveSettings];
    self.reittiDataManager.userLocationRegion = userLocation;
    
    [self postNotificationWithName:userlocationChangedNotificationName];
}

-(void)showLiveVehicle:(BOOL)show{
    [self.reittiDataManager.settingsEntity setShowLiveVehicle:[NSNumber numberWithBool:show]];
    [self.reittiDataManager saveSettings];
    
    [self postNotificationWithName:shouldShowVehiclesNotificationName];
}

-(void)enableClearingOldHistory:(BOOL)clear{
    [self.reittiDataManager.settingsEntity setClearOldHistory:[NSNumber numberWithBool:clear]];
    [self.reittiDataManager saveSettings];
}
-(void)setNumberOfDaysToKeepHistory:(int)days{
    [self.reittiDataManager.settingsEntity setNumberOfDaysToKeepHistory:[NSNumber numberWithInt:days]];
    [self.reittiDataManager saveSettings];
}

-(void)setToneName:(NSString *)toneName{
    [self.reittiDataManager.settingsEntity setToneName:toneName];
    [self.reittiDataManager saveSettings];
}

-(void)setGlobalRouteOptions:(RouteSearchOptions *)globalRouteOptions{
    [self.reittiDataManager.settingsEntity setGlobalRouteOptions:globalRouteOptions];
    [self.reittiDataManager saveSettings];
    
    [self postNotificationWithName:routeSearchOptionsChangedNotificationName];
}

#pragma mark - Settings in NSUserDefaults
+(BOOL)isAnalyticsEnabled{
    NSNumber *savedValue = [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsSettingsNsDefaultsKey];
    
    if (!savedValue || ![savedValue isKindOfClass:[NSNumber class]])
        return YES;
    
    return [savedValue boolValue];
}

+(void)enableAnalytics:(BOOL)enable{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithBool:enable] forKey:kAnalyticsSettingsNsDefaultsKey];
        [standardUserDefaults synchronize];
    }
}

+(NSInteger)getStartingIndexTab{
    NSNumber *savedValue = [[NSUserDefaults standardUserDefaults] objectForKey:kStartingTabNsDefaultsKey];
    
    if (!savedValue || ![savedValue isKindOfClass:[NSNumber class]])
        return 0;
    
    return [savedValue integerValue];
}

+(void)setStartingIndexTab:(NSInteger)index{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithInteger:index] forKey:kStartingTabNsDefaultsKey];
        [standardUserDefaults synchronize];
    }
}

#pragma mark - Helpers
-(void)postNotificationWithName:(NSString *)name{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self];
}

@end
