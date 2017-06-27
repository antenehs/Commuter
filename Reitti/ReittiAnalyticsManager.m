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

@import Firebase;

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
NSString *kActionFilteredStops = @"kActionFilteredStops";

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
NSString *kActionReorderedBookmarks = @"ReorderedBookmarks";

//4.1 Edit Address TableView Controller
NSString *kActionCreatedNewNamedBookmark = @"CreatedNewNamedBookmark";
NSString *kActionSelectedCurrentAddressForNamedBookmark = @"SelectedCurrentAddressForNamedBookmark";

//4.2 ICloud Sync View Controller
NSString *kActionDownloadedICloudBookmark = @"DownloadedICloudBookmark";
NSString *kActionResetICloudBookmarks = @"ResetICloudBookmarks";

//5. Lines View Controller
NSString *kActionViewedLine = @"ViewedLine";

//6. Routine View Controller
NSString *kActionSavedRoutine = @"SavedRoutine";

//7. More View Controller
NSString *kActionViewedTicketSalesPoints = @"ViewedTicketSalesPoints";
NSString *kActionSelectedMatkakorttiMonitor = @"SelectedMatkakorttiMonitor";
NSString *kActionViewedDisruptions = @"ViewedDisruptions";
NSString *kActionViewedNewInThisVersion = @"ViewedNewInThisVersion";
NSString *kActionViewedGoProDetail = @"ViewedGoProDetail";
NSString *kActionGoToProVersionAppStore = @"GoToProVersionAppStore";
NSString *kActionTappedRateButton = @"TappedRateButton";
NSString *kActionTappedShareButton = @"TappedShareButton";
NSString *kActionTappedTranslateCell = @"TappedTranslateCell";

//8. Settings View Controller
NSString *kActionChangedRouteSearchOption = @"ChangedRouteSearchOption";
NSString *kActionChangedReminderTone = @"ChangedReminderTone";
NSString *kActionChangedLiveVehicleOption = @"ChangedLiveVehicleOption";
NSString *kActionOpenedDepartureSettingsFromSettings = @"OpenedDepartureSettingsFromSettings";
NSString *kActionChangedUserLocation = @"ChangedUserLocation";
NSString *kActionChangedMapMode = @"ChangedMapMode";
NSString *kActionChangedHistoryCleaningDay = @"ChangedHistoryCleaningDay";
NSString *kActionChangedAnalyticsOption = @"ChangedAnalyticsOption";
NSString *kActionChangedStartingTabOption = @"ChangedStartingTabOption";

//9. Address Search View Controller
NSString *kActionSelectedContactAddress = @"SelectedContactAddress";

//10. Stop Migration
NSString *kEventNoStopMigrationNeeded = @"EventNoStopMigrationNeeded";
NSString *kEventSuccessfulStopMigration = @"EventSuccessfulStopMigration";
NSString *kEventPartialFailStopMigration = @"EventPartialFailStopMigration";
NSString *kEventTotalFailStopMigration = @"EventTotalFailStopMigration";

//User properties
NSString *kUserPropertyIsProUser = @"is_pro_user";
NSString *kUserPropertyHasAppleWatchPaired = @"has_apple_watch_paired";
NSString *kUserUsedComplicationType = @"used_complication_type";
NSString *kUserNumberOfNamedBookmarks = @"number_of_namedBookmarks";
NSString *kUserNumberOfSavedStops = @"number_of_savedStops";
NSString *kUserNumberOfSavedRoutes = @"number_of_savedRoutes";
NSString *kUserNumberOfAddressesInContact = @"number_of_contact";
NSString *kUserAllowedContactSearching = @"allowed_contacts";
NSString *kUserAllowedReminders = @"allowed_reminders";

//Api use Actions
NSString *kActionSearchedRouteFromApi = @"SearchedRouteFromApi";
NSString *kActionSearchedStopFromApi = @"SearchedStopFromApi";
NSString *kActionSearchedLineFromApi = @"SearchedLineFromApi";
NSString *kActionSearchedNearbyStopsFromApi = @"SearchedNearbyStopsFromApi";
NSString *kActionSearchedAddressFromApi = @"SearchedAddressFromApi";
NSString *kActionSearchedReverseGeoCodeFromApi = @"SearchedReverseGeoCodeFromApi";
NSString *kActionSearchedRealtimeDepartureFromApi = @"SearchedRealtimeDepartureFromApi";

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
            
            self.googleAnalyticsEnabled = YES;
        }
        @catch (NSException *exception) {
            self.googleAnalyticsEnabled = NO;
        }
    }
    
    return self;
}

-(BOOL)isEnabled{
    return [SettingsManager isAnalyticsEnabled];
}

-(void)setIsEnabled:(BOOL)enabled {
    SettingsManager.isAnalyticsEnabled = enabled;
}

-(void)trackUserProperty:(NSString *)userProperty value:(NSString *)value {
    [FIRAnalytics setUserPropertyString:value forName:userProperty];
}

#pragma mark - Firebase tracking
-(void)trackScreenViewForScreenName:(NSString *)screenName{
    if (self.isEnabled) {
        @try {
            [FIRAnalytics logEventWithName:[NSString stringWithFormat:@"screen_view_%@", screenName]
                                parameters:@{ kFIRParameterItemName: screenName }];
        }
        @catch (NSException *exception) {}
    }
    
    [self trackScreenViewWithGAForScreenName:screenName];
}

-(void)trackFeatureUseEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    [self trackEventForEventName:action category:label value:value];
    [self trackFeatureUseEventWithGAForAction:action label:label value:value];
}

-(void)trackApiUseEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    [self trackEventForEventName:action category:label value:value];
    [self trackApiUseEventWithGAForAction:action label:label value:value];
}

-(void)trackErrorEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    [self trackEventForEventName:action category:label value:value];
    [self trackErrorEventWithGAForAction:action label:label value:value];
}

-(void)trackEventForEventName:(NSString *)name category:(NSString *)category value:(NSNumber *)value {
    if (self.isEnabled) {
        @try {
            [FIRAnalytics logEventWithName:name
                                parameters:@{
                                             kFIRParameterItemCategory: category ? category : @"",
                                             kFIRParameterValue: value ? value : @1
                                             }];
            
        }
        @catch (NSException *exception) {}
    }
    
    
}

#pragma mark - Google analytics tracking
-(void)trackScreenViewWithGAForScreenName:(NSString *)screenName{
    if (self.isEnabled && self.googleAnalyticsEnabled) {
        @try {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker set:kGAIScreenName value:screenName];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        }
        @catch (NSException *exception) {}
    }
}

-(void)trackFeatureUseEventWithGAForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    [self trackEventWithGAForEventCategory:kEventCategoryFeatureUse action:action label:label value:value];
}

-(void)trackApiUseEventWithGAForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    [self trackEventWithGAForEventCategory:kEventCategoryApiUse action:action label:label value:value];
}

-(void)trackErrorEventWithGAForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    [self trackEventWithGAForEventCategory:kEventCategoryError action:action label:label value:value];
}

-(void)trackEventWithGAForEventCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    if (self.isEnabled && self.googleAnalyticsEnabled) {
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
