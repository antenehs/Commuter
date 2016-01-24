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

//4.1 Edit Address TableView Controller
extern NSString *kActionCreatedNewNamedBookmark;
extern NSString *kActionSelectedCurrentAddressForNamedBookmark;

//5. Lines View Controller
extern NSString *kActionViewedLine;

//6. Routine View Controller
extern NSString *kActionSavedRoutine;

//7. Settings View Controller
extern NSString *kActionChangedRouteSearchOption;
extern NSString *kActionChangedReminderTone;
extern NSString *kActionChangedLiveVehicleOption;
extern NSString *kActionOpenedDepartureSettingsFromSettings;
extern NSString *kActionChangedUserLocation;
extern NSString *kActionChangedMapMode;
extern NSString *kActionChangedHistoryCleaningDay;
extern NSString *kActionChangedAnalyticsOption;
extern NSString *kActionChangedStartingTabOption;

//Api use Actions
extern NSString *kActionSearchedRouteFromApi;
extern NSString *kActionSearchedStopFromApi;
extern NSString *kActionSearchedLineFromApi;
extern NSString *kActionSearchedNearbyStopsFromApi;
extern NSString *kActionSearchedAddressFromApi;
extern NSString *kActionSearchedReverseGeoCodeFromApi;

//Error case Actions
extern NSString *kActionApiSearchFailed;

@interface ReittiAnalyticsManager : NSObject

+(id)sharedManager;
-(id)init;

//Tracking
-(void)trackScreenViewForScreenName:(NSString *)screenName;
-(void)trackAppInstallationWithDevice:(NSString *)device osversion:(NSString *)version value:(NSNumber *)value;
-(void)trackFeatureUseEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
-(void)trackApiUseEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
-(void)trackErrorEventForAction:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

@property (nonatomic, readonly)BOOL isEnabled;

@end
