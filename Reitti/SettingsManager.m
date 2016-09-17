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

NSString * const kDeviceIdNsDefaultsKey = @"DeviceIdNsDefaultsKey";
NSString * const kAnalyticsSettingsNsDefaultsKey = @"IsAnalyticsSettingEnabled";
NSString * const kShowRoutesFromBookmarksKey = @"ShowRoutesFromBookmarks";
NSString * const kAnnotationTypesEnableStateKey = @"AnnotationTypesEnableStateKey";
NSString * const kShowDeparturesFromBookmarksKey = @"ShowDeparturesFromBookmarks";
NSString * const kAskedContactsPermission = @"AskedContactsPermission";
NSString * const kSkippedContactsPermissionTrial = @"SkippedContactsPermissionTrial";
NSString * const kStartingTabNsDefaultsKey = @"startingTabNsDefaultsKey";
NSString * const kShowGoProInStopViewRequestCount = @"showGoProInStopViewRequestCount";

@implementation SettingsManager

#ifndef APPLE_WATCH
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

#endif

#pragma mark - Settings in NSUserDefaults
+(NSString *)uniqueDeviceIdentifier {
    NSString *uniqueId = [self readStringForKey:kDeviceIdNsDefaultsKey];
    
    if (!uniqueId) {
        uniqueId = [[NSUUID UUID] UUIDString];
        [self saveStringForKey:kDeviceIdNsDefaultsKey stringVal:uniqueId];
    }
    
    return uniqueId;
}

+(BOOL)showBookmarkRoutes {
    return [self readBoolForKey:kShowRoutesFromBookmarksKey withDefault:NO];
}

+(void)setShowBookmarkRoutes:(BOOL)show {
    [self saveBoolForKey:kShowRoutesFromBookmarksKey boolVal:show];
}

+(BOOL)showBookmarkDepartures {
    return [self readBoolForKey:kShowDeparturesFromBookmarksKey withDefault:YES];
}

+(void)setShowBookmarkDepartures:(BOOL)show {
    [self saveBoolForKey:kShowDeparturesFromBookmarksKey boolVal:show];
}

+(BOOL)isAnnotationTypeEnabled:(AnnotationType)type {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *statusDic = [standardUserDefaults dictionaryForKey:kAnnotationTypesEnableStateKey];
    
    if (!statusDic) return YES;
    NSString *typeString = [NSString stringWithFormat:@"%d", type];
    
    NSNumber *statusNumber = statusDic[typeString];
    if (!statusNumber && ![statusNumber isKindOfClass:[NSNumber class]]) return true;
    
    return [statusNumber boolValue];
}

+(void)saveAnnotationTypeEnabled:(BOOL)enabled type:(AnnotationType)type {
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *statusDic = [[standardUserDefaults dictionaryForKey:kAnnotationTypesEnableStateKey] mutableCopy];
    if (!statusDic) statusDic = [@{} mutableCopy];
    
    NSString *typeString = [NSString stringWithFormat:@"%d", type];
    statusDic[typeString] = [NSNumber numberWithBool:enabled];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:statusDic forKey:kAnnotationTypesEnableStateKey];
        [standardUserDefaults synchronize];
    }
}

+(BOOL)askedContactsPermission {
    return [self readBoolForKey:kAskedContactsPermission withDefault:NO];
}

+(void)setAskedContactPermission:(BOOL)asked {
    [self saveBoolForKey:kAskedContactsPermission boolVal:asked];
}

+(NSInteger)getSkippedcontactsRequestTrials {
    return [self readIntegerForKey:kSkippedContactsPermissionTrial withDefault:0];
}

+(void)setSkippedcontactsRequestTrials:(NSInteger)index {
    [self saveIntegerForKey:kSkippedContactsPermissionTrial integerValue:index];
}

+(NSInteger)showGoProInStopViewRequestCount {
    NSInteger saved = [self readIntegerForKey:kShowGoProInStopViewRequestCount withDefault:0];
    [self saveIntegerForKey:kShowGoProInStopViewRequestCount integerValue:saved < NSIntegerMax ? saved + 1 : 0];
    
    return saved;
}

+(BOOL)isAnalyticsEnabled{
    return [self readBoolForKey:kAnalyticsSettingsNsDefaultsKey withDefault:YES];
}

+(void)enableAnalytics:(BOOL)enable{
    [self saveBoolForKey:kAnalyticsSettingsNsDefaultsKey boolVal:enable];
}

+(NSInteger)getStartingIndexTab{
    return [self readIntegerForKey:kStartingTabNsDefaultsKey withDefault:0];
}

+(void)setStartingIndexTab:(NSInteger)index{
    [self saveIntegerForKey:kStartingTabNsDefaultsKey integerValue:index];
}

#pragma mark - Helpers

+(NSString *)readStringForKey:(NSString *)defaultsKey {
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:defaultsKey];
    
    if (![savedValue isKindOfClass:[NSString class]]) return nil;
    
    return savedValue;
}

+(void)saveStringForKey:(NSString *)defaultsKey stringVal:(NSString *)stringVal {
    if (!stringVal) return;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:stringVal forKey:defaultsKey];
        [standardUserDefaults synchronize];
    }
}

+(BOOL)readBoolForKey:(NSString *)defaultsKey withDefault:(BOOL)defaultValue {
    NSNumber *savedValue = [[NSUserDefaults standardUserDefaults] objectForKey:defaultsKey];
    
    if (!savedValue || ![savedValue isKindOfClass:[NSNumber class]])
        return defaultValue;
    
    return [savedValue boolValue];
}

+(void)saveBoolForKey:(NSString *)defaultsKey boolVal:(BOOL)boolVal {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithBool:boolVal] forKey:defaultsKey];
        [standardUserDefaults synchronize];
    }
}

+(NSInteger)readIntegerForKey:(NSString *)defaultsKey withDefault:(NSInteger)defaultValue {
    NSNumber *savedValue = [[NSUserDefaults standardUserDefaults] objectForKey:defaultsKey];
    
    if (!savedValue || ![savedValue isKindOfClass:[NSNumber class]])
        return defaultValue;
    
    return [savedValue integerValue];
}

+(void)saveIntegerForKey:(NSString *)defaultsKey integerValue:(NSInteger)integerValue {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithInteger:integerValue] forKey:defaultsKey];
        [standardUserDefaults synchronize];
    }
}

-(void)postNotificationWithName:(NSString *)name{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self];
}

@end
