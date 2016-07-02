//
//  RouteInterfaceController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 2/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RouteInterfaceController.h"

@interface RouteInterfaceController ()

@property (strong, nonatomic) IBOutlet WKInterfaceTable *routeTable;

@end

@implementation RouteInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self.routeTable setNumberOfRows:2 withRowType:@"WalkRow"];
    
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

@end



