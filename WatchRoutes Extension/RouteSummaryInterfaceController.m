//
//  RouteSummaryInterfaceController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RouteSummaryInterfaceController.h"
#import "RouteSummaryRowController.h"
#import "WatchCommunicationManager.h"
#import "RouteHeaderRowController.h"

@interface RouteSummaryInterfaceController ()

@property (strong, nonatomic) IBOutlet WKInterfaceTable *routesTable;
@property (strong, nonatomic) NSArray *routes;

@end

@implementation RouteSummaryInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    if ([context isKindOfClass:[NSArray class]]) {
        NSArray *routes = (NSArray *)context;
        if (routes) {
            [self setUpViewForRoutes:routes];
            self.routes = routes;
        } else [self dismissController];
    }
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)setUpViewForRoutes:(NSArray *)routes {
    NSMutableArray *rowTypes = [@[] mutableCopy];
    [rowTypes addObject:@"RouteHeaderRow"];
    
    for (int i = 0; i < routes.count; i++) {
        [rowTypes addObject:@"RouteSummaryRow"];
    }
    
    [self.routesTable setRowTypes:rowTypes];
    
    for (int i = 0; i < self.routesTable.numberOfRows; i++) {
        if (i == 0) {
            RouteHeaderRowController *controller = (RouteHeaderRowController *)[self.routesTable rowControllerAtIndex:i];
            [controller setupWithRoute:routes[0]];
        } else {
            RouteSummaryRowController *controller = (RouteSummaryRowController *)[self.routesTable rowControllerAtIndex:i];
            [controller setupWithRoute:routes[i-1]];
        }
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    id rowController = [self.routesTable rowControllerAtIndex:rowIndex];
    if ([rowController isKindOfClass:[RouteSummaryRowController class]]) {
        
        [self showRoute:((RouteSummaryRowController *)rowController).route];
        
        [[WatchCommunicationManager sharedManager] sendWatchAppEventWithAction:@"Watch_selected_route" andLabel:@""];
    }
}

-(void)showRoute:(Route *)route {
    if (!route) return;
    [self pushControllerWithName:@"RouteView" context:route];
}


@end



