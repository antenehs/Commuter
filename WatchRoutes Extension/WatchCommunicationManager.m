//
//  WatchCommunicationManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "WatchCommunicationManager.h"
#import "AppManagerBase.h"
#import "ASA_Helpers.h"
#import "SettingsManager.h"

#ifndef APPLE_WATCH
#import "AppFeatureManager.h"
#import "ReittiAnalyticsManager.h"
#endif

NSString *kRoutesContextKey = @"kRoutesContextKey";
NSString *kNamedBookmarksContextKey = @"kNamedBookmarksContextKey";
NSString *kWatchLocalSearchSupported = @"kWatchLocalSearchSupported";
NSString *kSavedStopsContextKey = @"kSavedStopsContextKey";
NSString *kRouteSearchOptionsContextKey = @"kRouteSearchOptionsContextKey";

NSString *kUsedComplicationTypeKey = @"kUsedComplicationTypeKey";
NSString *kWatchEventActionKey = @"kWatchEventActionKey";
NSString *kWatchEventLabelKey = @"kWatchEventLabelKey";

@interface WatchCommunicationManager ()

@property (nonatomic, strong)WCSession *session;
@property (nonatomic, strong)NSArray *namedBookmarks;
@property (nonatomic, strong)NSArray *savedStops;
@property (nonatomic, strong)NSDictionary *searchOptions;

@property (nonatomic, strong)NSNumber * watchLocalSearchSupported;

@end

@implementation WatchCommunicationManager

+(instancetype)sharedManager {
    static WatchCommunicationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[WatchCommunicationManager alloc] init];
    });
    
    return sharedManager;
}

-(instancetype)init {
    self = [super init];
    
    if (![WCSession isSupported])
        return nil;
    
    if (self) {
        self.session = [WCSession defaultSession];
        self.session.delegate = self;
        [self.session activateSession];
#ifndef APPLE_WATCH
        if (!self.session.isPaired) {
            [[ReittiAnalyticsManager sharedManager] trackUserProperty:kUserPropertyHasAppleWatchPaired value:@"true"];
        } else {
            [[ReittiAnalyticsManager sharedManager] trackUserProperty:kUserPropertyHasAppleWatchPaired value:@"false"];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLocationSet:) name:userlocationChangedNotificationName object:nil];
#endif
        
#if APPLE_WATCH
        self.userRegionSupportLocalSearch = [SettingsManager watchRegionSupportsLocalSearching];
#endif
    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    NSLog(@"Error Occured when activating communication session: %@", error);
}

//Requires watch app to be running
-(void)sendMessage:(NSDictionary *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    [self.session sendMessage:message replyHandler:replyHandler errorHandler:^(NSError *error){
        NSLog(@"Error occured: %@", error);
    }];
}

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    if (!message) return;
#ifndef APPLE_WATCH
    if (message[kUsedComplicationTypeKey]) {
        [[ReittiAnalyticsManager sharedManager] trackUserProperty:kUserUsedComplicationType value:message[kUsedComplicationTypeKey]];
    }
    
    if (message[kWatchEventActionKey]) {
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:message[kWatchEventActionKey] label:message[kWatchEventLabelKey] value:nil];
    }
#endif
}

-(void)sessionDidDeactivate:(WCSession *)session {}
-(void)sessionDidBecomeInactive:(WCSession *)session {}

-(void)sendUsedComplicationTypeMessage:(NSString * _Nullable)complicationType {
    if (!complicationType) return;
    
    [self.session sendMessage:@{kUsedComplicationTypeKey : complicationType} replyHandler:^(NSDictionary *reply){} errorHandler:^(NSError *error) {}];
}

-(void)sendWatchAppEventWithAction:(NSString * _Nullable)action andLabel:(NSString * _Nullable)label {
    if (!action) return;
    
    if (!label) label = @"";
    
    [self.session sendMessage:@{kWatchEventActionKey : action, kWatchEventLabelKey : label} replyHandler:^(NSDictionary *reply){} errorHandler:^(NSError *error) {}];
}

#ifndef APPLE_WATCH
-(void)updateWatchLocalSearchSupported:(BOOL)supported {
    self.watchLocalSearchSupported = [NSNumber numberWithBool:supported];
    [self updateContext];
}

-(void)userLocationSet:(NSNotification *)notification {
    if (notification.object && [notification.object isKindOfClass:[SettingsManager class]]) {
//        BOOL isHSLRegion = [((SettingsManager *)notification.object) isHSLRegion];
        [self updateWatchLocalSearchSupported:YES];
    }
}
-(void)transferNamedBookmarks:(NSArray *)bookmarksDictionary {
    if (!bookmarksDictionary)
        bookmarksDictionary = @[];
    
    self.namedBookmarks = bookmarksDictionary;
    [self updateContext];
}

-(void)transferRoutes:(NSArray *)routesDictionary {
    if (routesDictionary && routesDictionary.count > 0) [self transferUserInfoForComplication:@{kRoutesContextKey : routesDictionary}];
}

-(void)transferRouteSearchOptions:(NSDictionary *)optionsDictionary {
    if (!optionsDictionary)
        optionsDictionary = @{};
    
    self.searchOptions = optionsDictionary;
    [self updateContext];
}

-(void)transferSavedStops:(NSArray *)stopsDictionaries {
    if (!stopsDictionaries)
        stopsDictionaries = @[];
    
    self.savedStops = stopsDictionaries;
    [self updateContext];
}
#endif

//Not available for watch becuse session.ispaired is not available.
#ifndef APPLE_WATCH
//Userinfo will be queed until watch app is available
-(void)transferUserInfo:(NSDictionary *)userInfo {
    if (!self.session.isPaired) return;
    
    [self.session transferUserInfo:userInfo];
}

-(void)updateContext {
    //Only do this when pro version is enabled.
    if (!self.session.isPaired || ![AppFeatureManager proFeaturesAvailable]) return;
    
    NSMutableDictionary *context = [@{} mutableCopy];
    if (self.watchLocalSearchSupported)
        context[kWatchLocalSearchSupported] = self.watchLocalSearchSupported;
    
    if (self.namedBookmarks)
        context[kNamedBookmarksContextKey] = self.namedBookmarks;
    
    if (self.savedStops)
        context[kSavedStopsContextKey] = self.savedStops;
    
    if (self.searchOptions)
        context[kRouteSearchOptionsContextKey] = self.searchOptions;

    [self.session updateApplicationContext:context error:nil];
}

-(void)transferUserInfoForComplication:(NSDictionary *)userInfo {
    if (!self.session.isPaired) return;
    //Clear outstanding transfers
    for (WCSessionUserInfoTransfer *transfer in self.session.outstandingUserInfoTransfers) {
        [transfer cancel];
    }
    [self.session transferCurrentComplicationUserInfo:userInfo];
}
#endif

-(void)session:(WCSession *)session didFinishUserInfoTransfer:(WCSessionUserInfoTransfer *)userInfoTransfer error:(NSError *)error {
#ifndef APPLE_WATCH
    for (WCSessionUserInfoTransfer *transfer in self.session.outstandingUserInfoTransfers) {
        if(!transfer.isCurrentComplicationInfo) {
            if (transfer.userInfo[kRoutesContextKey]) {
                [transfer cancel];
            }
        }
    }
#endif
}

-(void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    if (!userInfo) return;
    NSArray *routesArray = [userInfo objectForKey:kRoutesContextKey];
    if (routesArray) {
        [self asa_ExecuteBlockInUIThread:^{
            [self.delegate receivedRoutesArray:routesArray];
        }];
    }
}

-(void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    if (!applicationContext) return;
    
    #if APPLE_WATCH
    NSNumber *localSearchSupportInRegion = applicationContext[kWatchLocalSearchSupported];
    BOOL localSearchSupported = localSearchSupportInRegion ? [localSearchSupportInRegion boolValue] : self.userRegionSupportLocalSearch;
    
    self.userRegionSupportLocalSearch = localSearchSupported;
    [SettingsManager setWatchRegionSupportsLocalSearching: localSearchSupported];
    
    if (localSearchSupported) {
        NSArray *namedBookmarkArray = [applicationContext objectForKey:kNamedBookmarksContextKey];
        if (namedBookmarkArray) {
            [self asa_ExecuteBlockInUIThread:^{
                [self.delegate receivedNamedBookmarksArray:namedBookmarkArray];
            }];
        }
        
        NSDictionary *routeSearchOptions = [applicationContext objectForKey:kRouteSearchOptionsContextKey];
        if (routeSearchOptions) {
            [self asa_ExecuteBlockInUIThread:^{
                [self.delegate receivedRoutesSearchOptions:routeSearchOptions];
            }];
        }
        
        NSArray *savedStopsArray = [applicationContext objectForKey:kSavedStopsContextKey];
        if (savedStopsArray) {
            [self asa_ExecuteBlockInUIThread:^{
                [self.delegate receivedSavedStopsArray:savedStopsArray];
            }];
        }
    } else {
        //Hack to refresh the view in case location changed. This is rare in reallife
        [self asa_ExecuteBlockInUIThread:^{
            [self.delegate receivedNamedBookmarksArray:@[]];
        }];
    }
    
    #endif
}

@end
