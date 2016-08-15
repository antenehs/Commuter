//
//  AppDelegate.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchController.h"
#import "RouteSearchViewController.h"
#import "AppManager.h"
#import "TravelCardManager.h"
#import "ReittiRemindersManager.h"
#import "ReittiAppShortcutManager.h"
#import "ReittiSearchManager.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "ReittiAnalyticsManager.h"
#import "LinesManager.h"
#import "ASA_Helpers.h"
#import "MainTabBarController.h"
#import "RettiDataManager.h"
#import "ReittiRegionManager.h"
#import "WatchCommunicationManager.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Init Singletons
    [ReittiAnalyticsManager sharedManager]; //Google Analytics
    [LinesManager sharedManager];
    [ReittiRegionManager sharedManager];
    [WatchCommunicationManager sharedManager];
    
    //Check if notification is allowed.
    if (![[ReittiRemindersManager sharedManger] isLocalNotificationEnabled]) {
        [[ReittiRemindersManager sharedManger] registerNotification];
    }
    
    if (launchOptions != nil) {
        // Launched from push notification
        UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (locationNotification) {
            [self searchRouteFromRoutineNotification:locationNotification];
        }
    }
    
    if([UIApplicationShortcutItem class]){
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        if(shortcutItem){
            [self handleShortCutItem:shortcutItem];
        }
    }
    
    return YES;
}

//Handle app 3D touch shortcuts
- (BOOL)handleShortCutItem:(UIApplicationShortcutItem *)shortcutItem  {
    if([shortcutItem.type isEqualToString:[ReittiAppShortcutManager shortcutIdentifierStringValue:NamedBookmarkShortcutType]]){
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromAppShortcut label:@"Named bookmark" value:nil];
        
        NSString *name = (NSString *)[shortcutItem.userInfo objectForKey:@"namedBookmarkName"];
        NSString *coords = (NSString *)[shortcutItem.userInfo objectForKey:@"namedBookmarkCoords"];
        
        if (name == nil || coords == nil)
            return NO;
        
        RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:name toCoords:coords fromLocation:nil fromCoords:nil];
        [self switchToRouteSearchViewWithRouteParameter:searchParms];
        
        return YES;
    }else if([shortcutItem.type isEqualToString:[ReittiAppShortcutManager shortcutIdentifierStringValue:MoreBookmarksShortcutType]]){
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromAppShortcut label:@"More bookmarks" value:nil];
        
        [self switchToBookmarksTab];
        
        return YES;
    }else if([shortcutItem.type isEqualToString:[ReittiAppShortcutManager shortcutIdentifierStringValue:AddBookmarkShortcutType]]){
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromAppShortcut label:@"Add bookmark" value:nil];
        
        [self switchToAddBookmarksController];
        
        return YES;
    }
    
    return NO;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    completionHandler([self handleShortCutItem:shortcutItem]);
}

//Handle deeplinks
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    MainTabBarController *tabBarController = (MainTabBarController *)self.window.rootViewController;
    return [tabBarController handleDeepLink:url sourceApplication:sourceApplication annotation:annotation];
}


-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
//    NSLog(@"UserInfo: %@", userActivity.userInfo);
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        NSString *uniqueIdentifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        switch ([ReittiSearchManager spotlightObjectTypeForIdentifier:uniqueIdentifier]) {
            case SearchableNamedBookmarkType:
                [self openRouteForNamedBookmarkNamed:[ReittiSearchManager uniqueObjectNameForIdentifier:uniqueIdentifier]];
                break;
                
            case SearchableSavedStopType:
                [self openStopDetailForStopWithCode:[ReittiSearchManager uniqueObjectNameForIdentifier:uniqueIdentifier]];
                break;
                
            case SearchableSavedRouteType:
                [self openRouteForSavedRouteNamed:[ReittiSearchManager uniqueObjectNameForIdentifier:uniqueIdentifier]];
                break;
                
            default:
                break;
        }
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromSpotlightSearch label:uniqueIdentifier value:nil];
    }
    
    return YES;
}

-(void)openRouteForNamedBookmarkNamed:(NSString *)bookmarkName{
    NamedBookmark *bookmark = [[RettiDataManager sharedManager] fetchSavedNamedBookmarkFromCoreDataForName:bookmarkName];
    if (bookmark) {
        RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:bookmark.name toCoords:bookmark.coords fromLocation:@"Current location" fromCoords:nil];
        [self switchToRouteSearchViewWithRouteParameter:searchParms];
    }
}

-(void)openRouteForSavedRouteNamed:(NSString *)routeUniqueName{
    RouteEntity *route = [[RettiDataManager sharedManager] fetchSavedRouteFromCoreDataForCode:routeUniqueName];
    if (route) {
        RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:route.toLocationName toCoords:route.toLocationCoordsString fromLocation:route.fromLocationName fromCoords:route.fromLocationCoordsString];
        [self switchToRouteSearchViewWithRouteParameter:searchParms];
    }
}

-(void)openStopDetailForStopWithCode:(NSString *)stopCode{
    if (!stopCode)
        return;
    
    [self openStopViewForCode:stopCode];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState applicationState = application.applicationState;
    if (application.applicationState == UIApplicationStateInactive || applicationState == UIApplicationStateBackground) {
        [self searchRouteFromRoutineNotification:notification];
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromNotification label:nil value:nil];
    }else if (application.applicationState == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertTitle
                                                        message:notification.alertBody
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)searchRouteFromRoutineNotification:(UILocalNotification *)locationNotification{
    RouteSearchParameters *searchParams = [[RouteSearchParameters alloc] initWithToLocation:locationNotification.userInfo[kRoutineNotificationToName] toCoords:locationNotification.userInfo[kRoutineNotificationToCoords] fromLocation:locationNotification.userInfo[kRoutineNotificationFromName] fromCoords:locationNotification.userInfo[kRoutineNotificationFromCoords]];
    [self switchToRouteSearchViewWithRouteParameter:searchParams];
}

-(void)switchToHomeTab {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [tabBarController switchToHomeTab];
}

-(void)openStopViewForCode:(NSString *)stopCode {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [tabBarController openStopWithCode:stopCode];
}

-(void)switchToRouteSearchViewWithRouteParameter:(RouteSearchParameters  *)searchParameters {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [tabBarController setupAndSwithToRouteSearchViewWithSearchParameters:searchParameters];
}

-(void)switchToBookmarksTab {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [tabBarController switchToBookmarksTab];
}

-(void)switchToAddBookmarksController {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [tabBarController switchToAddBookmarksTab];
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - CORE DATA
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Reitti" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Reitti.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    NSLog(@"Documents Dir:%@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
