//
//  WatchCommunicationManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "WatchCommunicationManager.h"
#import "AppManagerBase.h"

NSString *kRoutesContextKey = @"kRoutesContextKey";
NSString *kNamedBookmarksContextKey = @"kNamedBookmarksContextKey";
NSString *kSavedStopsContextKey = @"kSavedStopsContextKey";
NSString *kRouteSearchOptionsContextKey = @"kRouteSearchOptionsContextKey";

@interface WatchCommunicationManager ()

@property (nonatomic, strong)WCSession *session;
@property (nonatomic, strong)NSArray *namedBookmarks;
@property (nonatomic, strong)NSArray *savedStops;
@property (nonatomic, strong)NSDictionary *searchOptions;

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
    }
    
    return self;
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
    
}

#ifndef APPLE_WATCH
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
    if (!self.session.isPaired) return;
    
    NSMutableDictionary *context = [@{} mutableCopy];
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
        [self.delegate receivedRoutesArray:routesArray];
    }
}

-(void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    if (!applicationContext) return;
    
    NSArray *namedBookmarkArray = [applicationContext objectForKey:kNamedBookmarksContextKey];
    if (namedBookmarkArray) {
        [self.delegate receivedNamedBookmarksArray:namedBookmarkArray];
    }
    
    NSDictionary *routeSearchOptions = [applicationContext objectForKey:kRouteSearchOptionsContextKey];
    if (routeSearchOptions) {
        [self.delegate receivedRoutesSearchOptions:routeSearchOptions];
    }
    
    NSArray *savedStopsArray = [applicationContext objectForKey:kSavedStopsContextKey];
    if (savedStopsArray) {
        [self.delegate receivedSavedStopsArray:savedStopsArray];
    }
}
@end
