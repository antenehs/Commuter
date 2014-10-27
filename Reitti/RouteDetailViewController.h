//
//  RouteDetailViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Route.h"
#import "AMBlurView.h"
#import "RouteLocation.h"

@interface RouteDetailViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    IBOutlet MKMapView *routeMapView;
    IBOutlet AMBlurView *topBarView;
    IBOutlet AMBlurView *routeListView;
    IBOutlet UIButton *toggleListButton;
    IBOutlet UILabel *toLabel;
    IBOutlet UILabel *fromLabel;
    IBOutlet UIView *separatorView;
    
    IBOutlet UITableView *routeListTableView;
    
    //local vars
    CLLocationCoordinate2D upperBound;
    CLLocationCoordinate2D lowerBound;
    CLLocationCoordinate2D leftBound;
    CLLocationCoordinate2D rightBound;
    
    CLLocationManager *locationManager;
    MKMapRect previousRegion;
}

@property (strong, nonatomic) Route *route;
@property (strong, nonatomic) RouteLeg *currentLeg;
@property (strong, nonatomic) NSMutableArray *routeLocationList;
@property (strong, nonatomic) MKPolylineRenderer *currentpolyLine;
@property (strong, nonatomic) NSString *toLocation;
@property (strong, nonatomic) NSString *fromLocation;
@property (strong, nonatomic)CLLocation * currentUserLocation;

@property (nonatomic) bool darkMode;

@end
