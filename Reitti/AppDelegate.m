//
//  AppDelegate.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchController.h"
#import "AppManager.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSLog(@"%@", [UIFont fontNamesForFamilyName:@"Aspergit"]);
//    NSLog(@"%@", [ReittiStringFormatter formatHSLAPITimeWithColon:@"0000"]);
//    NSLog(@"%@", [ReittiStringFormatter formatHSLAPITimeWithColon:@"ante"]);
//    NSLog(@"%@", [ReittiStringFormatter formatHSLAPITimeWithColon:@"000"]);
//    NSLog(@"%@", [ReittiStringFormatter formatHSLAPITimeWithColon:@"1234"]);
//    NSLog(@"%@", [ReittiStringFormatter parseBusNumFromLineCode:@"1041T 0"]);
//    NSLog(@"%@", [ReittiStringFormatter parseBusNumFromLineCode:@"1234 R"]);
//    NSLog(@"%@", [ReittiStringFormatter parseBusNumFromLineCode:@"1034 2"]);
    // Override point for customization after application launch.
    
//        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ewketApps.commuterDepartures"];
//    
////        NSDictionary *defaults = @{@"StopCodes" : @"2222222",};
//    
//        [sharedDefaults setObject:@"222222" forKey:@"StopCodes"];
//    
//        NSLog(@"%@",[sharedDefaults dictionaryRepresentation]);
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    [[UITabBar appearance] setTintColor:[AppManager systemGreenColor]];
    
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    
    tabBarItem1.title = @"Search";
    tabBarItem2.title = @"Route";
    tabBarItem3.title = @"Bookmarks";
    tabBarItem4.title = @"Settings";
//    tabBarItem4.title = @"Settings";
    
    UIImage *image1 = [UIImage imageNamed:@"search-icon-100.png"];
    tabBarItem1.image = [self imageWithImage:image1 scaledToSize:CGSizeMake(26, 26)];
    
    UIImage *image2 = [UIImage imageNamed:@"Bus Filled-green-100.png"];
//    UIImage *image2_unselected = [UIImage imageNamed:@"Bus-unselected-100.png"];
    tabBarItem2.image = [self imageWithImage:image2 scaledToSize:CGSizeMake(25, 24)];
//    tabBarItem2.image = [[self imageWithImage:image2_unselected scaledToSize:CGSizeMake(26, 26)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *image3 = [UIImage imageNamed:@"bookmark-green-filled-100.png"];
//    UIImage *image3_unselected = [UIImage imageNamed:@"Bookmark-unselected-100.png"];
    tabBarItem3.image = [self imageWithImage:image3 scaledToSize:CGSizeMake(28, 28)];
//    tabBarItem3.image = [[self imageWithImage:image3_unselected scaledToSize:CGSizeMake(28, 28)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *image4 = [UIImage imageNamed:@"Settings-Filled-2-100.png"];
//    UIImage *image4_unselected = [UIImage imageNamed:@"Settings-unselected-100.png"];
    tabBarItem4.image = [self imageWithImage:image4 scaledToSize:CGSizeMake(24, 24)];
//    tabBarItem4.selectedImage = [self imageWithImage:image4 scaledToSize:CGSizeMake(26, 26)];
//    tabBarItem4.image = [[self imageWithImage:image4_unselected scaledToSize:CGSizeMake(26, 26)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    tabBarItem1.image = [UIImage imageNamed:@"Home-green-100.png"];
//    tabBarItem2.image = [UIImage imageNamed:@"bookmark-green-filled-100.png"];
//    tabBarItem3.image = [UIImage imageNamed:@"settings-green-100.png"];
    
//    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"home_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home.png"]];
//    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"maps_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"maps.png"]];
//    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"myplan_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"myplan.png"]];
//    [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:@"settings_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"settings.png"]];
    
    return YES;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main.storyboard" bundle: nil];
    
    SearchController *controller = (SearchController *)[[navigationController viewControllers] lastObject];
    [controller initDataComponentsAndModulesWithManagedObjectCOntext:self.managedObjectContext];
    if ([MKDirectionsRequest isDirectionsRequestURL:url]) {
        MKDirectionsRequest* directionsInfo = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
        // TO DO: Plot and display the route using the
        //   source and destination properties of directionsInfo.
        [controller dismissViewControllerAnimated:YES completion:nil];
        [controller openRouteViewForFromLocation:directionsInfo];
        
        return YES;
    }
    else {
        NSLog(@"Search controller is : %@",controller);
        [controller dismissViewControllerAnimated:YES completion:nil];
        if ([[url query] isEqualToString:@"bookmarks"]) {
            [controller openBookmarksView];
        }
        
        if ([[url query] isEqualToString:@"routeSearch"]) {
            [controller openRouteSearchView];
        }
        
        if ([[url query] containsString:@"openStop"]) {
            NSArray *parts = [[url query] componentsSeparatedByString:@"-"];
            if (parts.count == 2) {
                [controller openStopViewForCode:parts[1]];
            }
        }
        
        if ([[url query] isEqualToString:@"widgetSettings"]) {
            [controller openWidgetSettingsView];
        }
        
        //    [self.window.rootViewController presentViewController: controller animated:YES completion:nil];
        
        return YES;
    }
    
    return NO;
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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
