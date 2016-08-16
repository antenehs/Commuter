//
//  MainTabBarController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteSearchParameters.h"
#import "RouteSearchViewController.h"

@interface MainTabBarController : UITabBarController

-(RouteSearchViewController *)routeSearchViewControllerForSearchParameters:(RouteSearchParameters *)searchParameters;
-(RouteSearchViewController *)setupRouteSearchViewWithSearchParameters:(RouteSearchParameters *)searchParameters;
-(void)switchToRouteSearchViewController;

-(void)setupAndSwithToRouteSearchViewWithSearchParameters:(RouteSearchParameters *)searchParameters;

-(void)switchToHomeTab;
-(void)openStopWithCode:(NSString *)stopCode;
//-(void)openWidgetSettingsView;
-(void)switchToBookmarksTab;
-(void)switchToAddBookmarksTab;

-(BOOL)handleDeepLink:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
