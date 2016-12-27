//
//  SettingsManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "SettingsManager.h"
#import "AppManager.h"

NSString * const kSettingsEntityName = @"SettingsEntity";

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
NSString * const kUseDigiTransitApi = @"UseDigiTransitApi";
NSString * const kStartingTabNsDefaultsKey = @"startingTabNsDefaultsKey";
NSString * const kShowGoProInStopViewRequestCount = @"showGoProInStopViewRequestCount";
NSString * const kWatchRegionSupportsLocalSearching = @"watchRegionSupportsLocalSearching";

#ifndef APPLE_WATCH

#import "CoreDataManager.h"
#import "WatchCommunicationManager.h"

@interface SettingsManager ()

@property (strong, nonatomic) SettingsEntity *settingsEntity;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (nonatomic, strong) WatchCommunicationManager *communicationManager;

@end

#endif

@implementation SettingsManager

#ifndef APPLE_WATCH

@synthesize settingsEntity;

-(id)initWithDataManager:(id)dataManager{
//    self.reittiDataManager = dataManager;
    
//    [self.reittiDataManager fetchSettings];
    
//    [self.reittiDataManager updateRouteSearchOptionsToUserDefaultValue];
    
    return [self init];
}

+(instancetype)sharedManager {
    static SettingsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [SettingsManager new];
    });
    
    return sharedInstance;
}

-(id)init {
    self = [super init];
    if (self) {
        self.coreDataManager = [CoreDataManager sharedManager];
        [self fetchCoreDataSettings];
        
        self.communicationManager = [WatchCommunicationManager sharedManager];
        
        [self updateRouteSearchOptionsToUserDefaultValue];
    }
    
    return self;
}


-(void)fetchCoreDataSettings {
    NSArray *systemSettings = [self.coreDataManager fetchAllObjectsForEntityNamed:kSettingsEntityName];
    
    if (systemSettings.count > 0) {
        self.settingsEntity = [systemSettings objectAtIndex:0];
        
        //Migration to datamodel version 7
        if (settingsEntity.showLiveVehicle == nil) {
            [settingsEntity setShowLiveVehicle:[NSNumber numberWithBool:YES]];
        }
        
        //Migration to datamodel version 14
        if (settingsEntity.toneName == nil) {
            [settingsEntity setToneName:[AppManager defailtToneName]];
        }
    }
    else {
        [self resetSettings];
    }
}

-(void)resetSettings{
    if (settingsEntity == nil) {
        settingsEntity = (SettingsEntity *)[self.coreDataManager createNewObjectForEntityNamed:kSettingsEntityName];
    }
    
    //set default values
    [settingsEntity setMapMode:[NSNumber numberWithInt:0]];
    [settingsEntity setUserLocation:[NSNumber numberWithInt:0]];
    [settingsEntity setShowLiveVehicle:[NSNumber numberWithBool:YES]];
    [settingsEntity setClearOldHistory:[NSNumber numberWithBool:YES]];
    [settingsEntity setNumberOfDaysToKeepHistory:[NSNumber numberWithInt:90]];
    [settingsEntity setToneName:[AppManager defailtToneName]];
    [settingsEntity setSettingsStartDate:[NSDate date]];
    [settingsEntity setGlobalRouteOptions:[RouteSearchOptions defaultOptions]];
    
    [self saveSettings];
}

-(void)saveSettings {
    [self.coreDataManager saveState];
}

-(void)updateRouteSearchOptionsToUserDefaultValue {
    
    [self fetchCoreDataSettings];
    NSDictionary *routeOptions = [self.settingsEntity.globalRouteOptions dictionaryRepresentation];
    
    if (routeOptions) {
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsRoutesExtensionSuitName]];
        
        [sharedDefaults setObject:routeOptions forKey:kUserDefaultsRouteSearchOptionsKey];
        [sharedDefaults synchronize];
    }
    
    [self.communicationManager transferRouteSearchOptions:routeOptions];
}


//Temp hack/helper
-(BOOL)isHSLRegion {
    return [self userLocation] == HSLRegion;
}

-(NSDate *)settingsStartDate{
    [self fetchCoreDataSettings];
    
    return self.settingsEntity.settingsStartDate;
}

-(MapMode)getMapMode{
//    [self.reittiDataManager fetchSettings];
    [self fetchCoreDataSettings];
    
    return (MapMode)[self.settingsEntity.mapMode  intValue];
}

-(Region)userLocation{
//    [self.reittiDataManager fetchSettings];
    [self fetchCoreDataSettings];
    
    return (Region)[self.settingsEntity.userLocation intValue];
}

-(BOOL)shouldShowLiveVehicles{
//    [self.reittiDataManager fetchSettings];
    [self fetchCoreDataSettings];
    
    return [self.settingsEntity.showLiveVehicle boolValue];
}

-(BOOL)isClearingHistoryEnabled{
//    [self.reittiDataManager fetchSettings];
    [self fetchCoreDataSettings];
    
    return [self.settingsEntity.clearOldHistory boolValue];
}
-(int)numberOfDaysToKeepHistory{
//    [self.reittiDataManager fetchSettings];
    [self fetchCoreDataSettings];
    
    return [self.settingsEntity.numberOfDaysToKeepHistory intValue];
}

-(NSString *)toneName{
//    [self.reittiDataManager fetchSettings];
    [self fetchCoreDataSettings];
    
    return self.settingsEntity.toneName;
}

-(RouteSearchOptions *)globalRouteOptions{
//    [self.reittiDataManager fetchSettings];
    [self fetchCoreDataSettings];
    
    return self.settingsEntity.globalRouteOptions;
}

-(void)setMapMode:(MapMode)mapMode{
    [self.settingsEntity setMapMode:[NSNumber numberWithInt:mapMode]];
    [self saveSettings];
    
    [self postNotificationWithName:mapModeChangedNotificationName];
}
-(void)setUserLocation:(Region)userLocation{
    [self.settingsEntity setUserLocation:[NSNumber numberWithInt:userLocation]];
    [self saveSettings];
    
    //TODO: DAta manager should subscribe to the notification or fetch it everytime.
//    self.reittiDataManager.userLocationRegion = userLocation;
    
    [self postNotificationWithName:userlocationChangedNotificationName];
}

-(void)showLiveVehicle:(BOOL)show{
    [self.settingsEntity setShowLiveVehicle:[NSNumber numberWithBool:show]];
    [self saveSettings];
    
    [self postNotificationWithName:shouldShowVehiclesNotificationName];
}

-(void)enableClearingOldHistory:(BOOL)clear{
    [self.settingsEntity setClearOldHistory:[NSNumber numberWithBool:clear]];
    [self saveSettings];
}
-(void)setNumberOfDaysToKeepHistory:(int)days{
    [self.settingsEntity setNumberOfDaysToKeepHistory:[NSNumber numberWithInt:days]];
    [self saveSettings];
}

-(void)setToneName:(NSString *)toneName{
    [self.settingsEntity setToneName:toneName];
    [self saveSettings];
}

-(void)setGlobalRouteOptions:(RouteSearchOptions *)globalRouteOptions{
    [self.settingsEntity setGlobalRouteOptions:globalRouteOptions];
    [self saveSettings];
    
    [self updateRouteSearchOptionsToUserDefaultValue];
    
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
    [self saveIntegerForKey:kShowGoProInStopViewRequestCount integerValue:saved < 200 ? saved + 1 : 0];
    
    return saved;
}

+(BOOL)isAnalyticsEnabled {
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

+(BOOL)useDigiTransit {
    return [self readBoolForKey:kUseDigiTransitApi withDefault:YES];
}

+(void)setUseDigiTrnsit:(BOOL)use {
    [self saveBoolForKey:kUseDigiTransitApi boolVal:use];
}

#if APPLE_WATCH
+(BOOL)watchRegionSupportsLocalSearching {
    return [self readBoolForKey:kWatchRegionSupportsLocalSearching withDefault:YES];
}

+(void)setWatchRegionSupportsLocalSearching:(BOOL)supports {
    [self saveBoolForKey:kWatchRegionSupportsLocalSearching boolVal:supports];
}
#endif

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
