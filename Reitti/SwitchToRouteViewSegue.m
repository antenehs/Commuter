//
//  SwitchToRouteViewSegue.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "SwitchToRouteViewSegue.h"

@implementation SwitchToRouteViewSegue

-(void)perform {
    UIViewController *sourceView = [self sourceViewController];
    UITabBarController *tabBarController = (UITabBarController *)sourceView.view.window.rootViewController;
    
    tabBarController.selectedIndex = 1;
}

@end
