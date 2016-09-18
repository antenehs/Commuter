//
//  ReittiConfigManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiConfigManager.h"

@import Firebase;

NSString *kAppTranslationLinkConfigKey = @"AppTranslationLinkConfigKey";
NSString *kIntervalBetweenGoProShowsInStopView = @"IntervalBetweenGoProShowsInStopView";
NSString *kDefaultConfigValueString = @"DefaultText";

@interface ReittiConfigManager ()

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
        [self.remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
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
    FIRRemoteConfigValue *value = [self.remoteConfig configValueForKey:kAppTranslationLinkConfigKey];
    NSString *stringVal = [value stringValue];
    if (!stringVal ||
        [[stringVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ||
        [stringVal isEqualToString:kDefaultConfigValueString])
            return nil;
    
    return stringVal;
}

-(NSInteger)intervalBetweenGoProShowsInStopView {
    FIRRemoteConfigValue *value = [self.remoteConfig configValueForKey:kIntervalBetweenGoProShowsInStopView];
    NSNumber *interval = [value numberValue];
    
    if (!interval) return 2;
    else return [interval integerValue];
}

@end
