//
//  MainTabBarController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MainTabBarController.h"
#import "AppManager.h"
#import "BookmarksViewController.h"
#import "SearchController.h"
#import <MapKit/MapKit.h>

@interface MainTabBarController ()

@property (nonatomic, strong)SearchController *searchController;
@property (nonatomic, strong)RouteSearchViewController *pendingRouteSearchController;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBar appearance] setTintColor:[AppManager systemGreenColor]];
    
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    
    tabBarItem1.title = @"Map";
    tabBarItem2.title = @"Route";
    tabBarItem3.title = @"Bookmarks";
    tabBarItem4.title = @"Lines";
    UIImage *image1 = [UIImage imageNamed:@"globe-filled-100.png"];
    tabBarItem1.image = [UIImage asa_imageWithImage:image1 scaledToSize:CGSizeMake(20, 20)];
    
    UIImage *image2 = [UIImage imageNamed:@"Bus Filled-green-100.png"];
    tabBarItem2.image = [UIImage asa_imageWithImage:image2 scaledToSize:CGSizeMake(19, 19)];
    
    UIImage *image3 = [UIImage imageNamed:@"bookmark-green-filled-100.png"];
    tabBarItem3.image = [UIImage asa_imageWithImage:image3 scaledToSize:CGSizeMake(20, 22)];
    
    UIImage *image4 = [UIImage imageNamed:@"transit-line.png"];
    tabBarItem4.image = [UIImage asa_imageWithImage:image4 scaledToSize:CGSizeMake(20, 17)];
    
    UINavigationController * homeViewNavController = (UINavigationController *)[[self viewControllers] objectAtIndex:0];
    
    self.searchController = (SearchController *)[[homeViewNavController viewControllers] firstObject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(RouteSearchViewController *)routeSearchViewControllerForSearchParameters:(RouteSearchParameters *)searchParameters {
    RouteSearchViewController *routeSearchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ASARouteSearchViewController"];
    
    routeSearchViewController.prevToLocation = searchParameters.toLocation;
    routeSearchViewController.prevToCoords = searchParameters.toCoords;
    routeSearchViewController.prevFromLocation = searchParameters.fromLocation;
    routeSearchViewController.prevFromCoords = searchParameters.fromCoords;
    
    routeSearchViewController.modalViewControllerMode = [NSNumber numberWithBool:NO];
    return routeSearchViewController;
}

-(RouteSearchViewController *)setupRouteSearchViewWithSearchParameters:(RouteSearchParameters *)searchParameters {

    self.pendingRouteSearchController = [self routeSearchViewControllerForSearchParameters:searchParameters];
    
    return self.pendingRouteSearchController;
}

-(void)switchToRouteSearchViewController {
    if (self.pendingRouteSearchController) {
        UINavigationController * routeSearchNavController = (UINavigationController *)[[self viewControllers] objectAtIndex:1];
        
        [routeSearchNavController setViewControllers:@[self.pendingRouteSearchController] animated:NO];
        NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
        [viewControllers replaceObjectAtIndex:1 withObject:routeSearchNavController];
        
        self.viewControllers = viewControllers;
    }
    
    if (self.searchController) {
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
    }
    
    self.selectedIndex = 1;
}

-(void)setupAndSwithToRouteSearchViewWithSearchParameters:(RouteSearchParameters *)searchParameters {
    [self setupRouteSearchViewWithSearchParameters:searchParameters];
    [self switchToRouteSearchViewController];
}

-(void)switchToHomeTab {
    [self.searchController initDataComponentsAndModules];
    [self.searchController dismissViewControllerAnimated:YES completion:nil];
    
    self.selectedIndex = 0;
}

-(void)openStopWithCode:(NSString *)stopCode {
    [self switchToHomeTab];
    
    [self.searchController.navigationController popToRootViewControllerAnimated:NO];
    
    [self.searchController openStopViewForCode:stopCode];
}

//-(void)openWidgetSettingsView {
//    [self switchToHomeTab];
//    [self.searchController openWidgetSettingsView];
//}

-(void)switchToBookmarksTab {
    self.selectedIndex = 2;
    
    //TODO: Next version me - Do this with notification to all view controllers
    if (self.searchController) {
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
    }
    
    UINavigationController * bookmarksViewNavController = (UINavigationController *)[[self viewControllers] objectAtIndex:2];
    [bookmarksViewNavController popToRootViewControllerAnimated:NO];
}

-(void)switchToAddBookmarksTab {
    self.selectedIndex = 2;
    
    if (self.searchController) {
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
    }
    
    UINavigationController * bookmarksViewNavController = (UINavigationController *)[[self viewControllers] objectAtIndex:2];
    BookmarksViewController *controller = (BookmarksViewController *)[[bookmarksViewNavController viewControllers] firstObject];
    [bookmarksViewNavController popToRootViewControllerAnimated:NO];
    
    [controller openAddBookmarkController];
}

#pragma mark - handle deeplinks
-(BOOL)handleDeepLink:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    //    NSLog(@"URL scheme:%@", [url scheme]);
    //    NSLog(@"URL query: %@", [url query]);
    
    if ([MKDirectionsRequest isDirectionsRequestURL:url]) {
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromMapsApp label:nil value:nil];
        MKDirectionsRequest* directionsInfo = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
        
        [self handleDirectionRequestFromMaps:directionsInfo];
        
        return YES;
    } else {
        if ([[url query] isEqualToString:@"bookmarks"]) {
            [self switchToBookmarksTab];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromStopsWidget label:@"bookmarks" value:nil];
        }
        
        if ([[url  query] isEqualToString:@"addBookmark"]) {
            
            [self switchToAddBookmarksTab];
            
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromRoutesWidget label:@"addBookmark" value:nil];
        }
        
        //?routeSearch&toaddressname&toaddresscoords
        if ([[url query] containsString:@"routeSearch"]) {
            NSString *queryString = [[url query] stringByRemovingPercentEncoding];
            NSArray *parametes = [queryString componentsSeparatedByString:@"&"];
            self.selectedIndex = 1;
            if (parametes.count == 3 && [parametes[0] isEqualToString:@"routeSearch"]) {
                NSString *name = parametes[1];
                NSString *coords = parametes[2];
                
                if (name == nil || coords == nil)
                    return NO;
                
                RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:name toCoords:coords fromLocation:nil fromCoords:nil];
                [self setupAndSwithToRouteSearchViewWithSearchParameters:searchParms];
                [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromRoutesWidget label:@"routeSearch" value:nil];
            }
        }
        
        if ([[url query] containsString:@"openStop"]) {
            NSArray *parts = [[url query] componentsSeparatedByString:@"-"];
            if (parts.count == 2) {
                if (self.selectedIndex != 0) {
                    self.selectedIndex = 0;
                }
                
                [self openStopWithCode:parts[1]];
                
                [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromStopsWidget label:@"openStop" value:nil];
            }
        }
        
//        if ([[url query] isEqualToString:@"widgetSettings"]) {
//            [self openWidgetSettingsView];
//            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionLaunchAppFromStopsWidget label:@"widgetSettings" value:nil];
//        }
        
        return YES;
    }
    
    return NO;
}

-(void)handleDirectionRequestFromMaps:(MKDirectionsRequest *)directionsInfo {
    MKMapItem *source = directionsInfo.source;
    NSString *fromLocation, *fromCoords, *toLocation, *toCoords;
    if (source.isCurrentLocation) {
        fromLocation = @"Current location";
    }else{
        fromCoords = [NSString stringWithFormat:@"%f,%f",source.placemark.location.coordinate.longitude, source.placemark.location.coordinate.latitude];
        fromLocation = [NSString stringWithFormat:@"%@",
                        [[source.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "]
                        ];
    }
    
    MKMapItem *destination = directionsInfo.destination;
    if (destination.isCurrentLocation) {
        toLocation = @"Current location";
    }else{
        toCoords = [NSString stringWithFormat:@"%f,%f",destination.placemark.location.coordinate.longitude, destination.placemark.location.coordinate.latitude];
        //        NSLog(@"Address of placemark: %@", ABCreateStringWithAddressDictionary(destination.placemark.addressDictionary, NO));
        //        NSLog(@"Address Dictionary: %@",destination.placemark.addressDictionary);
        if ([destination.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] != nil) {
            toLocation = [NSString stringWithFormat:@"%@",
                          [[destination.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "]
                          ];
        }else{
            toLocation = [NSString stringWithFormat:@"%@, %@",
                          [destination.placemark.addressDictionary objectForKey:@"Street"],
                          [destination.placemark.addressDictionary objectForKey:@"City"]
                          ];
        }
    }
    
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:toLocation toCoords:toCoords fromLocation:fromLocation fromCoords:fromCoords];
    [self setupAndSwithToRouteSearchViewWithSearchParameters:searchParms];
}


@end
