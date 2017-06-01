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
#import "RouteLegLocation.h"
#import "WatchDataManager.h"
#import "ComplicationDataManager.h"
#import "MapInterfaceController.h"

@interface RouteInterfaceController ()

@property (strong, nonatomic) IBOutlet WKInterfaceTable *routeTable;
@property (strong, nonatomic) Route *route;

@end

@implementation RouteInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    if ([context isKindOfClass:[Route class]]) {
         Route *route = (Route *)context;
        if (route) {
            [self setUpViewForRoute:route];
            self.route = route;
        } else [self dismissController];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    if (self.route) {
        [self updateComplicationDataForRoute:self.route];
    }
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
//    [[ComplicationDataManager sharedManager] setRoute:nil];
    [super didDeactivate];
}

-(void)handleUserActivity:(NSDictionary *)userInfo {
    
}

-(void)setUpViewForRoute:(Route *)route {
    
    [self.routeTable setNumberOfRows:route.routeLegs.count + 1 withRowType:@"RouteLegRow"];
    
    for (int i = 0; i < self.routeTable.numberOfRows; i++) {
        RouteLegRowController *controller = (RouteLegRowController *)[self.routeTable rowControllerAtIndex:i];
        if (i < route.routeLegs.count) {
            [controller setUpWithRouteLeg:route.routeLegs[i] inRoute:route];
        } else { //destination row
            RouteLeg *lastLeg = [route.routeLegs lastObject];
            [controller setUpAsDestinationForName:route.toLocationName prevLegType:lastLeg.legType];
        }
    }
    
//    [self setTitle:@"Done     10:45"];
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSString *locationName = nil;
    CLLocationCoordinate2D coords;
    RouteLegRowController *controller = (RouteLegRowController *)[self.routeTable rowControllerAtIndex:rowIndex];
    locationName = controller.locationName;
    
    if (rowIndex < self.route.routeLegs.count) {
        RouteLegLocation *loc = [controller.routeLeg.legLocations firstObject];
        if (!loc) return;
        coords = loc.coords;
    } else {//Destination row
        RouteLeg *lastLeg = [self.route.routeLegs lastObject];
        RouteLegLocation *loc = [lastLeg.legLocations lastObject];
        if (!loc) return;
        coords = loc.coords;
    }
    
    [self pushControllerWithName:@"MapView" context:@{LocationNameContextKey: locationName, LocationCoordsContextKey: [[CLLocation alloc] initWithLatitude:coords.latitude longitude:coords.longitude]}];
}

-(void)updateComplicationDataForRoute:(Route *)route {
    [[ComplicationDataManager sharedManager] setRoute:route];
}

@end



