//
//  RouteInterfaceController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 2/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RouteInterfaceController.h"
#import "RouteLegRowController.h"
#import "Route.h"
#import "NamedBookmarkE.h"
#import "WatchDataManager.h"

@interface RouteInterfaceController ()

@property (strong, nonatomic) IBOutlet WKInterfaceTable *routeTable;

@end

@implementation RouteInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    //TODO: Check if Route or namedbookmark
    
    if ([context isKindOfClass:[NamedBookmarkE class]]) {
        NamedBookmarkE *bookmark = (NamedBookmarkE *)context;
        
        
        CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:60.215413888458 longitude:24.866182201828];
        
        //    [self presentControllerWithName:@"ActivityView" context:@"Loading Routes..."];
        WatchDataManager *manager = [WatchDataManager new];
        [manager getRouteForNamedBookmark:bookmark fromLocation:fromLocation routeOptions:nil andCompletionBlock:^(NSArray *routes, NSString *errorString){
            //        [self dismissController];
            //        [self presentControllerWithNames:@[@"RouteView", @"RouteView", @"RouteView"] contexts:@[@"RouteView", @"RouteView", @"RouteView"]];
            [WKInterfaceController reloadRootControllersWithNames:@[@"RouteView", @"RouteView", @"RouteView", @"RouteView"] contexts:@[@"RouteView", @"RouteView", @"RouteView", @"RouteView"]];
        }];
    } else if ([context isKindOfClass:[Route class]]) {
         Route *route = (Route *)context;
         if (route) [self setUpViewForRoute:route];
         else [self dismissController];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)setUpViewForRoute:(Route *)route {
    
    [self.routeTable setNumberOfRows:route.routeLegs.count + 1 withRowType:@"RouteLegRow"];
    
    for (int i = 0; i < self.routeTable.numberOfRows; i++) {
        RouteLegRowController *controller = (RouteLegRowController *)[self.routeTable rowControllerAtIndex:i];
        if (i < route.routeLegs.count) {
            [controller setUpWithRouteLeg:route.routeLegs[i] inRoute:route];
        } else { //destination row
            [controller setUpAsDestinationForName:route.toLocationName];
        }
    }
}

@end



