//
//  WatchCommunicationManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "WatchCommunicationManager.h"
#import "AppManagerBase.h"

@interface WatchCommunicationManager ()

@property (nonatomic, strong)WCSession *session;

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

//Requires watch app to be running
-(void)sendMessage:(NSDictionary *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    [self.session sendMessage:message replyHandler:replyHandler errorHandler:^(NSError *error){
        NSLog(@"Error occured: %@", error);
    }];
}

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    
}

//Userinfo will be queed until watch app is available
-(void)transferUserInfo:(NSDictionary *)userInfo {
    [self.session transferUserInfo:userInfo];
}

-(void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    if (!userInfo) return;
    NSArray *namedBookmarkArray = [userInfo objectForKey:kUserDefaultsNamedBookmarksKey];
    if (namedBookmarkArray) {
        [self.delegate receivedNamedBookmarksArray:namedBookmarkArray];
    }
    
}
@end
