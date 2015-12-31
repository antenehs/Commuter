//
//  ReittiAnalyticsManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiAnalyticsManager.h"
#import "SettingsManager.h"
#import <Google/Analytics.h>

//Categories
NSString *kEventCategoryAppInstallation = @"CategoryAppInstallation";
NSString *kEventCategoryFeatureUse = @"CategoryFeatureUse";
NSString *kEventCategoryApiUse = @"CategoryApiUse";
NSString *kEventCategoryError = @"CategoryError";

//Feature Actions
//0. Generic features
NSString *kActionUsed3DTouch = @"Used3DTouch";
NSString *kActionLaunchAppFromAppShortcut = @"LaunchAppFromAppShortcut";
NSString *kActionLaunchAppFromSpotlightSearch = @"LaunchAppFromSpotlightSearch";
NSString *kActionLaunchAppFromMapsApp = @"LaunchAppFromMapsApp";
NSString *kActionLaunchAppFromStopsWidget = @"LaunchAppFromStopsWidget";
NSString *kActionLaunchAppFromRoutesWidget = @"LaunchAppFromRoutesWidget";
NSString *kActionLaunchAppFromNotification = @"LaunchAppFromNotification";
NSString *kActionNewAppInstallation = @"NewAppInstallation";

//1. Home View Controller
NSString *kActionListNearByStops = @"ListNearByStops";
NSString *kActionOpenGeoLocationFromDroppedPin = @"OpenGeoLocationFromDroppedPin";

//2. Route Search View Controller
NSString *kActionSearchedRoute = @"SearchedRoute";
NSString *kActionSearchedRouteFromSavedLocation = @"SearchedRouteFromSavedLocation";
NSString *kActionSearchedRouteFromSavedHistory = @"SearchedRouteFromSavedHistory";
NSString *kActionBookmarkedARoute = @"BookmarkedARoute";

//2.1 Route Detail View Controller
NSString *kActionSetRouteReminder = @"SetRouteReminder";

//3. Stop View Controller
NSString *kActionViewedAStop = @"ViewedAStop";
NSString *kActionSetDepartureReminder = @"SetDepartureReminder";
NSString *kActionViewedFullTimeTable = @"ViewedFullTimeTable";
NSString *kActionOpenRouteFromStop = @"OpenRouteFromStop";
NSString *kActionBookmarkedStop = @"BookmarkedStop";

//4. Bookmarks View Controller
NSString *kActionViewedNamedBookmarks = @"ViewedNamedBookmarks";
NSString *kActionOpenedRouteFromNamedBookmark = @"OpenedRouteFromNamedBookmark";
NSString *kActionOpenedRouteFromSavedRoute = @"OpenedRouteFromSavedRoute";
NSString *kActionViewedSavedStop = @"ViewedSavedStop";
NSString *kActionInteractWithHistoryObject = @"InteractWithHistoryObject";
NSString *kActionOpenedWidgetSettingsFromBookmarks = @"OpenedWidgetSettingsFromBookmarks";
NSString *kActionEditedNamedBookmark = @"EditedNamedBookmark";

//4.1 Edit Address TableView Controller
NSString *kActionCreatedNewNamedBookmark = @"CreatedNewNamedBookmark";
NSString *kActionSelectedCurrentAddressForNamedBookmark = @"SelectedCurrentAddressForNamedBookmark";

//5. Lines View Controller
NSString *kActionViewedLine = @"ViewedLine";

//6. Routine View Controller
NSString *kActionSavedRoutine = @"SavedRoutine";

//7. Settings View Controller
NSString *kActionChangedRouteSearchOption = @"ChangedRouteSearchOption";
NSString *kActionChangedReminderTone = @"ChangedReminderTone";
NSString *kActionChangedLiveVehicleOption = @"ChangedLiveVehicleOption";
NSString *kActionOpenedDepartureSettingsFromSettings = @"OpenedDepartureSettingsFromSettings";
NSString *kActionChangedUserLocation = @"ChangedUserLocation";
NSString *kActionChangedMapMode = @"ChangedMapMode";
NSString *kActionChangedHistoryCleaningDay = @"ChangedHistoryCleaningDay";
NSString *kActionChangedAnalyticsOption = @"ChangedAnalyticsOption";

//Api use Actions
NSString *kActionSearchedRouteFromApi = @"SearchedRouteFromApi";
NSString *kActionSearchedStopFromApi = @"SearchedStopFromApi";
NSString *kActionSearchedLineFromApi = @"SearchedLineFromApi";
NSString *kActionSearchedNearbyStopsFromApi = @"SearchedNearbyStopsFromApi";
NSString *kActionSearchedAddressFromApi = @"SearchedAddressFromApi";
NSString *kActionSearchedReverseGeoCodeFromApi = @"SearchedReverseGeoCodeFromApi";

//Error case Actions
NSString *kActionApiSearchFailed = @"ApiSearchFailed";

@implementation ReittiAnalyticsManager

@synthesize isEnabled;

+(id)sharedManager{
    static ReittiAnalyticsManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[ReittiAnalyticsManager alloc] init];
    });
    
    return manager;
}

-(id)init{
    self = [super init];
    
    if (self) {
        @try {
            // Configure tracker from GoogleService-Info.plist.
            NSError *configureError;
            [[GGLContext sharedInstance] configureWithError:&configureError];
            if (configureError) {
                NSLog(@"Error configuring Google services: %@", configureError);
                self.isEnabled = NO;
            }
            
            // Optional: configure GAI options.
            GAI *gai = [GAI sharedInstance];
            gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
        }
        @catch (NSException *exception) {
            self.isEnabled = NO;
        }
    }
    
    return self;
}

-(BOOL)isEnabled{
    return [SettingsManager isAnalyticsEnabled];
}

-(void)setIsEnabled:(BOOL)enabled{
    [SettingsManager enableAnalytics:enabled];
}

-(void)trackScreenViewForScreenName:(NSString *)screenName{
    if (self.isEnabled) {
        @try {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker set:kGAIScreenName value:screenName];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        }
        @catch (NSException *exception) {}
    }
}

-(void)trackAppInstallationWithDevice:(NSString *)device osversion:(NSString *)version value:(NSNumber *)value{
    [self trackEventForEventCategory:kEventCategoryAppInstallation action:device label:version value:value];
}

-(void)trackFeatureUseEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    [self trackEventForEventCategory:kEventCategoryFeatureUse action:action label:label value:value];
}

-(void)trackApiUseEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    [self trackEventForEventCategory:kEventCategoryApiUse action:action label:label value:value];
}

-(void)trackErrorEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    [self trackEventForEventCategory:kEventCategoryError action:action label:label value:value];
}

-(void)trackEventForEventCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    if (self.isEnabled) {
        @try {
            // May return nil if a tracker has not already been initialized with a property
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            if (!tracker)
                return;
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category       // Event category (required)
                                                                  action:action         // Event action (required)
                                                                   label:label          // Event label
                                                                   value:value] build]];// Event value
        }
        @catch (NSException *exception) {}
    }
}

@end
