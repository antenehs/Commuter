//
//  ReittiConfigManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiConfigManager.h"
#import "ASA_Helpers.h"

@implementation RemoteMessage

+(instancetype)messageWithMessage:(NSString *)message
                       actionName:(NSString *)actionName
                   actionDeepLink:(NSString *)actionDeepLink {
    RemoteMessage *remoteMessage = [self new];
    remoteMessage.message = message;
    remoteMessage.actionName = actionName;
    remoteMessage.actionDeeplink = actionDeepLink;
    
    return remoteMessage;
}

-(BOOL)isActionable {
    return ![NSString isNilOrEmpty:self.actionName] && ![NSString isNilOrEmpty:self.actionDeeplink];
}

@end


@import Firebase;

NSString *kAppTranslationLinkConfigKey = @"AppTranslationLinkConfigKey";
NSString *kIntervalBetweenGoProShowsInStopView = @"IntervalBetweenGoProShowsInStopView";
NSString *kMoreTabMessage = @"MoreTabMessage";
NSString *kMoreTabMessageActionName = @"MoreTabMessageActionName";
NSString *kMoreTabMessageActionDeeplink = @"MoreTabMessageActionDeeplink";
NSString *kDefaultConfigValueString = @"DefaultText";

@interface ReittiConfigManager ()

@property(nonatomic, strong)NSString *appTranslationLink;
@property(nonatomic)NSInteger intervalBetweenGoProShowsInStopView;
@property(nonatomic, strong)RemoteMessage *moreTabMessage;

@property (nonatomic, strong)FIRRemoteConfig *remoteConfig;

@end

@implementation ReittiConfigManager

+(instancetype)sharedManager {
    static ReittiConfigManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [ReittiConfigManager new];
    });
    
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
//        if (![FIRApp defaultApp])
//            [FIRApp configure];
        
        self.remoteConfig = [FIRRemoteConfig remoteConfig];
        [self.remoteConfig setDefaults:[self defaultConfigValues]];
        
        [self appTranslationLink];
        [self.remoteConfig fetchWithExpirationDuration:0 completionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
            if (status == FIRRemoteConfigFetchStatusSuccess && !error) {
                [self.remoteConfig activateFetched];
            }
        }];
    }
    
    return self;
}

-(NSDictionary *)defaultConfigValues {
    return @{kAppTranslationLinkConfigKey : kDefaultConfigValueString,
             kIntervalBetweenGoProShowsInStopView: [NSNumber numberWithInteger:2]};
}

-(NSString *)appTranslationLink {
    if (!_appTranslationLink) {
        FIRRemoteConfigValue *value = [self.remoteConfig configValueForKey:kAppTranslationLinkConfigKey];
        NSString *stringVal = [value stringValue];
        if ([NSString isNilOrEmpty:stringVal] ||
            [stringVal isEqualToString:kDefaultConfigValueString])
            _appTranslationLink = nil;
        else
            _appTranslationLink = stringVal;
    }
    
    return _appTranslationLink;
}

-(NSInteger)intervalBetweenGoProShowsInStopView {
    if (!_intervalBetweenGoProShowsInStopView) {
        FIRRemoteConfigValue *value = [self.remoteConfig configValueForKey:kIntervalBetweenGoProShowsInStopView];
        NSNumber *interval = [value numberValue];
        
        if (!interval) _intervalBetweenGoProShowsInStopView = 2;
        else _intervalBetweenGoProShowsInStopView = [interval integerValue];
    }
    
    return _intervalBetweenGoProShowsInStopView;
}

-(RemoteMessage *)moreTabMessage {
    if (!_moreTabMessage) {
        NSString *message = [[self.remoteConfig configValueForKey:kMoreTabMessage] stringValue];
        NSString *messageActionName = [[self.remoteConfig configValueForKey:kMoreTabMessageActionName] stringValue];
        NSString *messageActionDeeplink = [[self.remoteConfig configValueForKey:kMoreTabMessageActionDeeplink] stringValue];
        
        if (![NSString isNilOrEmpty:message]) {
            _moreTabMessage = [RemoteMessage messageWithMessage:message
                                                     actionName:messageActionName
                                                 actionDeepLink:messageActionDeeplink];
        }
    }
    
    return _moreTabMessage;
}



@end
