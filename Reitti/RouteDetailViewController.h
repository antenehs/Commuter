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
#import "RettiDataManager.h"
#import "ReittiRemindersManager.h"
#import "SettingsManager.h"
#import "StopViewController.h"
#import "MapViewManager.h"

typedef enum{
    RouteListViewLoactionBottom = 1,
    RouteListViewLoactionMiddle = 2,
    RouteListViewLoactionTop = 3
} RouteListViewLoaction;

typedef enum{
    MapViewCenterLocationShiftedUp = 1,
    MapViewCenterLocationCenter = 2,
} MapViewCenterLocation;

@interface RouteDetailViewController : UIViewController<MapViewManagerDelegate, CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate, UIViewControllerPreviewingDelegate>{
    
    IBOutlet MKMapView *routeMapView;
    IBOutlet AMBlurView *topBarView;
    IBOutlet AMBlurView *routeListView;
    IBOutlet UIButton *toggleListButton;
    IBOutlet UIButton *toggleListBigButton;
    IBOutlet UIButton *toggleListArrowButton;
    IBOutlet UILabel *timeIntervalLabel;
    IBOutlet UILabel *arrivalTimeLabel;
    IBOutlet UILabel *fromLabel;
    IBOutlet UIView *separatorView;
    IBOutlet UIScrollView *routeView;
    IBOutlet UIView *topViewBackView;
    
    IBOutlet UIButton *currentLocationButton;
    
    IBOutlet UIButton *previousRouteButton;
    IBOutlet UIButton *nextRouteButton;
    
    IBOutlet UITableView *routeListTableView;
    
    UIPanGestureRecognizer *detailViewDragGestureRecognizer;
    
    //local vars
    CLLocationCoordinate2D upperBound;
    CLLocationCoordinate2D lowerBound;
    CLLocationCoordinate2D leftBound;
    CLLocationCoordinate2D rightBound;
    
    CLLocation *previousCenteredLocation;
    
    CLLocationManager *locationManager;
//    MKMapRect previousRegion;
    
    ReittiRemindersManager *reittiRemindersManager;
    
    IBOutlet NSLayoutConstraint *routeLIstViewVerticalSpacing;
    IBOutlet NSLayoutConstraint *mapViewVerticalSpacing;
    
    BOOL isShowingStopView;
//    BOOL isShowingBikeAnnotations;
    NSString *selectedAnnotionStopShortCode, *selectedAnnotionStopName;
    NSString *selectedAnnotionStopCode;
    CLLocationCoordinate2D selectedAnnotationStopCoords;
    
    BOOL ignoreMapRegionChangeForCurrentLocationButtonStatus;
    
    BOOL tableViewIsDecelerating;
    BOOL routeListViewIsGoingUp;
    RouteListViewLoaction currentRouteListViewLocation;
    MapViewCenterLocation mapViewCenterLocation;
}

@property (strong, nonatomic) Route *route;
@property (strong, nonatomic) NSMutableDictionary *lineDetailMap;
@property (nonatomic) int selectedRouteIndex;
@property (strong, nonatomic) NSArray *routeList;
@property (strong, nonatomic) RouteLeg *currentLeg;
@property (strong, nonatomic) NSMutableArray *routeLocationList;
@property (strong, nonatomic) MKPolylineRenderer *currentpolyLine;
@property (strong, nonatomic) NSString *toLocation;
@property (strong, nonatomic) NSString *fromLocation;
@property (strong, nonatomic) CLLocation * currentUserLocation;

@property (nonatomic)ReittiApi useApi;

@property (nonatomic) bool darkMode;

@property (strong, nonatomic) SettingsManager *settingsManager;

@end
