//
//  ReittiAnalyticsManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

//Categories
extern NSString *kEventCategoryAppInstallation;
extern NSString *kEventCategoryFeatureUse;
extern NSString *kEventCategoryApiUse;
extern NSString *kEventCategoryError;

//Feature Actions
//0. Generic features
extern NSString *kActionUsed3DTouch;
extern NSString *kActionLaunchAppFromAppShortcut;
extern NSString *kActionLaunchAppFromSpotlightSearch;
extern NSString *kActionLaunchAppFromMapsApp;
extern NSString *kActionLaunchAppFromStopsWidget;
extern NSString *kActionLaunchAppFromRoutesWidget;
extern NSString *kActionLaunchAppFromNotification;
extern NSString *kActionNewAppInstallation;


//1. Home View Controller
extern NSString *kActionListNearByStops;
extern NSString *kActionOpenGeoLocationFromDroppedPin;
extern NSString *kActionFilteredStops;

//2. Route Search View Controller
extern NSString *kActionSearchedRoute;
extern NSString *kActionSearchedRouteFromSavedLocation;
extern NSString *kActionSearchedRouteFromSavedHistory;
extern NSString *kActionBookmarkedARoute;

//2.1 Route Detail View Controller
extern NSString *kActionSetRouteReminder;

//3. Stop View Controller
extern NSString *kActionViewedAStop;
extern NSString *kActionSetDepartureReminder;
extern NSString *kActionViewedFullTimeTable;
extern NSString *kActionOpenRouteFromStop;
extern NSString *kActionBookmarkedStop;

//4. Bookmarks View Controller
extern NSString *kActionViewedNamedBookmarks;
extern NSString *kActionOpenedRouteFromNamedBookmark;
extern NSString *kActionOpenedRouteFromSavedRoute;
extern NSString *kActionViewedSavedStop;
extern NSString *kActionInteractWithHistoryObject;
extern NSString *kActionOpenedWidgetSettingsFromBookmarks;
extern NSString *kActionEditedNamedBookmark;
extern NSString *kActionReorderedBookmarks;

//4.1 Edit Address TableView Controller
extern NSString *kActionCreatedNewNamedBookmark;
extern NSString *kActionSelectedCurrentAddressForNamedBookmark;

//4.2 ICloud Sync View Controller
extern NSString *kActionDownloadedICloudBookmark;
extern NSString *kActionResetICloudBookmarks;

//5. Lines View Controller
extern NSString *kActionViewedLine;

//6. Routine View Controller
extern NSString *kActionSavedRoutine;

//7. More View Controller
extern NSString *kActionViewedTicketSalesPoints;
extern NSString *kActionSelectedMatkakorttiMonitor;
extern NSString *kActionViewedDisruptions;
extern NSString *kActionViewedNewInThisVersion;
extern NSString *kActionViewedGoProDetail;
extern NSString *kActionGoToProVersionAppStore;
extern NSString *kActionTappedRateButton;
extern NSString *kActionTappedShareButton;
extern NSString *kActionTappedTranslateCell;

//8. Settings View Controller
extern NSString *kActionChangedRouteSearchOption;
extern NSString *kActionChangedReminderTone;
extern NSString *kActionChangedLiveVehicleOption;
extern NSString *kActionOpenedDepartureSettingsFromSettings;
extern NSString *kActionChangedUserLocation;
extern NSString *kActionChangedMapMode;
extern NSString *kActionChangedHistoryCleaningDay;
extern NSString *kActionChangedAnalyticsOption;
extern NSString *kActionChangedStartingTabOption;

//9. Address Search View Controller
extern NSString *kActionSelectedContactAddress;

//10. Stop Migration
extern NSString *kEventNoStopMigrationNeeded;
extern NSString *kEventSuccessfulStopMigration;
extern NSString *kEventPartialFailStopMigration;
extern NSString *kEventTotalFailStopMigration;

//User properties
extern NSString *kUserPropertyIsProUser;
extern NSString *kUserPropertyHasAppleWatchPaired;
extern NSString *kUserUsedComplicationType;
extern NSString *kUserNumberOfNamedBookmarks;
extern NSString *kUserNumberOfSavedStops;
extern NSString *kUserNumberOfSavedRoutes;
extern NSString *kUserNumberOfAddressesInContact;
extern NSString *kUserAllowedContactSearching;
extern NSString *kUserAllowedReminders;

//Api use Actions
extern NSString *kActionSearchedRouteFromApi;
extern NSString *kActionSearchedStopFromApi;
extern NSString *kActionSearchedLineFromApi;
extern NSString *kActionSearchedNearbyStopsFromApi;
extern NSString *kActionSearchedAddressFromApi;
extern NSString *kActionSearchedReverseGeoCodeFromApi;
extern NSString *kActionSearchedRealtimeDepartureFromApi;

//Error case Actions
extern NSString *kActionApiSearchFailed;

@interface ReittiAnalyticsManager : NSObject

+(id)sharedManager;

//Tracking
-(void)trackUserProperty:(NSString *)userProperty value:(NSString *)value;
-(void)trackScreenViewForScreenName:(NSString *)screenName;
-(void)trackFeatureUseEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
-(void)trackApiUseEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
-(void)trackErrorEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
-(void)trackEventForEventName:(NSString *)name category:(NSString *)category value:(NSNumber *)value;

@property (nonatomic, readonly)BOOL isEnabled;

@end
