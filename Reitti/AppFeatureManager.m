//
//  AppFeatureManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/20/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "AppFeatureManager.h"
#import "AppManagerBase.h"

@interface AppFeatureManager ()

@property (nonatomic, strong)NSArray *proOnlyFeatures;
@property (nonatomic)BOOL areProFeaturesAvailable;

@end

@implementation AppFeatureManager

+(instancetype)sharedManager {
    static AppFeatureManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [AppFeatureManager new];
    });
    
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

+(BOOL)proFeaturesAvailable {
    return [AppManagerBase isProVersion];
}

-(NSArray *)proOnlyFeatures {
    
    BOOL proFeaturesAvailable = self.areProFeaturesAvailable;
    
    return @[[AppFeature featureWithName:AppFeatureNearbyDepartures isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureAppleWatchApp isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureRealtimeDepartures isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureRoutesWidget isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureNearbyDepartureWidget isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureCityBikes isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureLiveLines isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureIcloudBookmarks isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureRouteDisruptions isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureStopFilter isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureRemindersManager isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureTicketSales isAvailable:proFeaturesAvailable],
             [AppFeature featureWithName:AppFeatureFavouriteLines isAvailable:proFeaturesAvailable],];
    
}

-(BOOL)areProFeaturesAvailable {
    return [AppFeatureManager proFeaturesAvailable];
}

@end
