//
//  RouteDetailViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RouteDetailViewController.h"
#import "ReittiStringFormatter.h"
#import "StopAnnotation.h"
#import "LocationsAnnotation.h"
#import "MyFixedLayoutGuide.h"
#import "ASPolylineRenderer.h"
#import "ASPolylineView.h"
#import "RouteViewManager.h"
#import "AppManager.h"
#import "StaticRoute.h"
#import "CacheManager.h"
#import "CoreDataManager.h"
#import "Vehicle.h"
#import "ASA_Helpers.h"
#import "LVThumbnailAnnotation.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@interface RouteDetailViewController ()

@property (nonatomic) NSArray<id<UIPreviewActionItem>> *previewActions;
@property (nonatomic, strong) id previewingContext;

@end

@implementation RouteDetailViewController

#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];
#define SYSTEM_ORANGE_COLOR [UIColor colorWithRed:230.0/255.0 green:126.0/255.0 blue:34.0/255.0 alpha:1.0];
#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
#define SYSTEM_RED_COLOR [UIColor redColor];
#define SYSTEM_BROWN_COLOR [UIColor brownColor];
#define SYSTEM_CYAN_COLOR [UIColor cyanColor];

@synthesize route = _route, selectedRouteIndex,routeList;
@synthesize currentpolyLine,currentLeg;
@synthesize darkMode;
@synthesize routeLocationList;
@synthesize toLocation, fromLocation, currentUserLocation;
@synthesize reittiDataManager, settingsManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    //init vars
    [self initDataManagerIfNull];
    
    darkMode = YES;
    isShowingStopView = NO;
    
    mapResizedForMiddlePosition = NO;
    lineDetailMap = [@{} mutableCopy];
    
    CLLocationCoordinate2D _upper = {.latitude =  -90.0, .longitude =  0.0};
    upperBound = _upper;
    CLLocationCoordinate2D _lower = {.latitude =  90.0, .longitude =  0.0};
    lowerBound = _lower;
    CLLocationCoordinate2D _left = {.latitude =  0, .longitude =  180.0};
    leftBound = _left;
    CLLocationCoordinate2D _right = {.latitude =  0, .longitude =  -180.0};
    rightBound = _right;
    // Do any additional setup after loading the view.
    
    UISwipeGestureRecognizer *recogRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRightDetected:)];
    recogRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [routeListView addGestureRecognizer:recogRight];
    
    UISwipeGestureRecognizer *recogLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeftDetected:)];
    recogLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    [routeListView addGestureRecognizer:recogLeft];
    
//    _route = [routeList objectAtIndex:selectedRouteIndex];
//    NSLog(@"Number of legs = %lu", (unsigned long)_route.routeLegs.count);
    
    routeLocationList = [self convertRouteToLocationList:self.route];
    
    reittiRemindersManager = [ReittiRemindersManager sharedManger];
    
    detailViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragRouteList:)];
    detailViewDragGestureRecognizer.delegate = self;
    [routeListView addGestureRecognizer:detailViewDragGestureRecognizer];
    
    ignoreMapRegionChangeForCurrentLocationButtonStatus = NO;
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self setUpMainViewForRoute];
    [self initializeMapView];
    [self initMapViewForRoute:_route];
    [self moveRouteViewToLocation:RouteListViewLoactionBottom animated:NO];
    
    /* Register 3D touch for Peek and Pop if available */
    [self registerFor3DTouchIfAvailable];
}

- (void)viewDidAppear:(BOOL)animated{
    if (!isShowingStopView){
        isShowingStopView = NO;
        [self moveRouteViewToLocation:RouteListViewLoactionBottom animated:NO];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self hideNavigationBar:NO animated:NO];
    [self moveRouteViewToLocation:currentRouteListViewLocation animated:NO];
//    [routeListTableView reloadData];
    [self setUpMainViewForRoute];
}

//- (id<UILayoutSupport>)topLayoutGuide {
//    return [[MyFixedLayoutGuide alloc] initWithLength:0];
//}

- (id<UILayoutSupport>)bottomLayoutGuide {
    return [[MyFixedLayoutGuide alloc] initWithLength:70];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (darkMode) {
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
}

#pragma mark - initializations
- (void)initDataManagerIfNull {
    // Do any additional setup after loading the view.
    
    if (self.reittiDataManager == nil) {
        
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:[[CoreDataManager sharedManager] managedObjectContext]];
        
        self.settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        
        [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    }
}

- (void)initMapViewForRoute:(Route *)route{
    [routeMapView removeOverlays:routeMapView.overlays];
    [routeMapView removeAnnotations:routeMapView.annotations];
    for (RouteLeg *leg in route.routeLegs) {
        [self drawLineForLeg:leg];
    }
    
    [self plotLocationsAnnotation:route];
    
    [self centerMapRegionToViewRoute];
    
}

#pragma mark - view methods

-(BOOL)isLandScapeOrientation{
    return self.view.frame.size.height < self.view.frame.size.width;
}

-(void)setUpMainViewForRoute{
    
    //Fetch line details
    [self fetchLineDetailsForRoute:self.route];
    
    [nextRouteButton setImage:[UIImage imageNamed:@"next-lgray-100.png"] forState:UIControlStateDisabled];
    [previousRouteButton setImage:[UIImage imageNamed:@"previous-lgray-100.png"] forState:UIControlStateDisabled];
    
    nextRouteButton.layer.borderColor = [AppManager systemGreenColor].CGColor;
    nextRouteButton.layer.borderWidth = 0.5f;
    nextRouteButton.layer.cornerRadius = 4.0f;
    
    previousRouteButton.layer.borderColor = [AppManager systemGreenColor].CGColor;
    previousRouteButton.layer.borderWidth = 0.5f;
    previousRouteButton.layer.cornerRadius = 4.0f;
    
    [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:NO];
    currentLocationButton.hidden = YES;
    
    [self setNextAndPrevButtonStates];
    
    [self.navigationController setToolbarHidden:YES];
    self.title = @"";
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, [self isLandScapeOrientation] ? 20 : 40)];
    titleView.clipsToBounds = YES;
    
    NSMutableDictionary *fromStringDict = [NSMutableDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-light" size:15] forKey:NSFontAttributeName];
    [fromStringDict setObject:[UIColor colorWithWhite:0.85 alpha:1] forKey:NSForegroundColorAttributeName];
    
    NSMutableDictionary *addressStringDict = [NSMutableDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17] forKey:NSFontAttributeName];
    [addressStringDict setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    NSMutableDictionary *destAddressStringDict = [NSMutableDictionary dictionaryWithObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
    [destAddressStringDict setObject:[UIColor colorWithWhite:0.9 alpha:1] forKey:NSForegroundColorAttributeName];
    
    NSMutableAttributedString *addressString = [[NSMutableAttributedString alloc] initWithString:toLocation attributes:addressStringDict];
    
    NSMutableAttributedString *fromAddressString = [[NSMutableAttributedString alloc] initWithString:@"\nfrom " attributes:fromStringDict];
    
    [addressString appendAttributedString:fromAddressString];
    
    NSMutableAttributedString *destAddressString = [[NSMutableAttributedString alloc] initWithString:fromLocation attributes:destAddressStringDict];
    
    [addressString appendAttributedString:destAddressString];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 40)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = addressString;
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    [routeListView setBlurTintColor:nil];
    //    routeListView.layer.borderWidth = 1;
    //    routeListView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    topViewBackView.layer.borderWidth = 0.5;
    topViewBackView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    routeListTableView.backgroundColor = [UIColor clearColor];
    routeListTableView.separatorColor = [UIColor clearColor];
    
    [self stopFetchingVehicles];
    [self startFetchingVehicles];
    
    for (UIView *view in routeView.subviews) {
        [view removeFromSuperview];
    }
    
    UIView *transportsView = [RouteViewManager viewForRoute:self.route longestDuration:[self.route.routeDurationInSeconds floatValue] width:self.view.frame.size.width - 150 alwaysShowVehicle:NO];
    
    [routeView addSubview:transportsView];
    routeView.contentSize = CGSizeMake(transportsView.frame.size.width, transportsView.frame.size.height);
    
    routeView.userInteractionEnabled = NO;
    [topViewBackView addGestureRecognizer:routeView.panGestureRecognizer];
    
    [timeIntervalLabel setText:[NSString stringWithFormat:@"leave at %@ ",
                                               [ReittiStringFormatter formatHourStringFromDate:self.route.startingTimeOfRoute]]];
    
        [arrivalTimeLabel setText:[NSString stringWithFormat:@"| arrive at %@",
                                   [ReittiStringFormatter formatHourStringFromDate:self.route.endingTimeOfRoute]]];
    
    UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, routeListView.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor lightGrayColor];
    [routeListView addSubview:topLine];
    
    [routeListTableView reloadData];
//    [self addTransportTypePictures];
}

- (void)fetchLineDetailsForRoute:(Route *)aRoute{
    
    if (!aRoute || !aRoute.routeLegs)
        return;
    
    NSMutableArray *lineCodes = [@[] mutableCopy];
    for (RouteLeg *leg in aRoute.routeLegs) {
        if (leg.lineCode && leg.lineCode.length > 0 && ![lineDetailMap objectForKey:leg.lineCode])
            [lineCodes addObject:leg.lineCode];
    }
    
    if (lineCodes.count < 1)
        return;
    
    [self.reittiDataManager fetchLinesForLineCodes:lineCodes withCompletionBlock:^(NSArray *lines, NSString *searchTerm, NSString *errorString){
        if (!errorString) {
            [self populateLineDetailMapFromLines:lines];
            [routeListTableView reloadData];
        }
    }];
}

- (void)populateLineDetailMapFromLines:(NSArray *)lines{
    if (!lines || lines.count < 1)
        return;
    
    @try {
        for (Line *line in lines) {
            [lineDetailMap setValue:line forKey:line.code];
        }
    }
    @catch (NSException *exception) {}
}

- (NSString *)getDestinationForLineCode:(NSString *)code{
    if (!code)
        return nil;
    
    Line *detailLine = [lineDetailMap objectForKey:code];
    
    if (detailLine)
        return detailLine.lineEnd;
    
    return nil;
}

- (void)startFetchingVehicles {
    //Start fetching vehicle locations for route
    NSMutableArray *tempTrainArray = [@[] mutableCopy];
    NSMutableArray *tempOthersArray = [@[] mutableCopy];
    for (RouteLeg *leg in self.route.routeLegs) {
        if (leg.legType == LegTypeTrain) {
            [tempTrainArray addObject:leg.lineCode];
        }
        
        if (leg.legType == LegTypeMetro || leg.legType == LegTypeTram || leg.legType == LegTypeBus || leg.legType == LegTypeTrain ) {
            [tempOthersArray addObject:leg.lineCode];
        }
    }
    
    [self.reittiDataManager fetchAllLiveVehiclesWithCodes:tempOthersArray andTrainCodes:tempTrainArray withCompletionHandler:^(NSArray *vehicleList, NSString *errorString){
        [self plotVehicleAnnotations:vehicleList isTrainVehicles:NO];
    }];
}

- (void)stopFetchingVehicles{
    //Remove all vehicle annotations
    [self.reittiDataManager stopFetchingLiveVehicles];
}

-(void)moveRouteViewToLocation:(RouteListViewLoaction)location animated:(BOOL)animated{
    [UIView transitionWithView:routeListView duration:animated ? 0.2 : 0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self moveRouteViewToLocation:location];
        
    } completion:^(BOOL finished) {}];
}

-(void)moveRouteViewToLocation:(RouteListViewLoaction)location{
    currentRouteListViewLocation = location;
    
//    CGFloat tabBarHeight = self.tabBarController != nil ? self.tabBarController.tabBar.frame.size.height : 0;
    
    if (location == RouteListViewLoactionBottom) {
        [self hideNavigationBar:NO animated:YES];
        routeLIstViewVerticalSpacing.constant = self.view.frame.size.height - routeListTableView.frame.origin.y + 15;
        [toggleListButton setTitle:@"List" forState:UIControlStateNormal];
        [toggleListArrowButton setImage:[UIImage imageNamed:@"expand-arrow-50.png"] forState:UIControlStateNormal];
        [self.view layoutIfNeeded];
        [self centerMapRegionToViewRoute];
        mapResizedForMiddlePosition = NO;
    }else if (location == RouteListViewLoactionMiddle) {
        [self hideNavigationBar:NO animated:YES];
        routeLIstViewVerticalSpacing.constant = self.view.frame.size.height/2;
        [toggleListButton setTitle:@"List" forState:UIControlStateNormal];
        [toggleListArrowButton setImage:[UIImage imageNamed:@"horizontal-line-100.png"] forState:UIControlStateNormal];
        routeListTableView.frame = CGRectMake(routeListTableView.frame.origin.x, routeListTableView.frame.origin.y, routeListTableView.frame.size.width,self.view.bounds.size.height/2 - routeListTableView.frame.origin.y);
        [self.view layoutIfNeeded];
        if (!mapResizedForMiddlePosition) {
            [self centerMapRegionToViewRoute];
            mapResizedForMiddlePosition = YES;
        }
    }else{
        routeLIstViewVerticalSpacing.constant = 0;
        routeListTableView.frame = CGRectMake(routeListTableView.frame.origin.x, routeListTableView.frame.origin.y, routeListTableView.frame.size.width, self.view.bounds.size.height - routeListTableView.frame.origin.y);
        [toggleListButton setTitle:@"Map" forState:UIControlStateNormal];
        [toggleListArrowButton setImage:[UIImage imageNamed:@"collapse-arrow-100.png"] forState:UIControlStateNormal];
        [self.view layoutIfNeeded];
        [self hideNavigationBar:![self isLandScapeOrientation] animated:YES];
    }
    
    [routeListTableView reloadData];
}

-(void)hideNavigationBar:(BOOL)hidded animated:(BOOL)animated{
    if (hidded) {
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
        view.tag = 7654;
        view.backgroundColor=[AppManager systemGreenColor];
        [self.view addSubview:view];
        view.hidden = NO;
    }else{
        while ([self.view viewWithTag:7654]) {
            UIView *view = [self.view viewWithTag:7654];
            [view removeFromSuperview];
                
            view.hidden = YES;
            view = nil;
        }
    }
    
    [self.navigationController setNavigationBarHidden:hidded animated:animated];
}

-(BOOL)isRouteListViewVisible{
    return (routeListView.frame.origin.y <= self.view.bounds.size.height/4);
}

- (void)setNextAndPrevButtonStates {
    if (routeList.count > 1) {
        if (selectedRouteIndex == routeList.count - 1) {
            nextRouteButton.enabled = NO;
            previousRouteButton.enabled = YES;
        }else if (selectedRouteIndex == 0){
            nextRouteButton.enabled = YES;
            previousRouteButton.enabled = NO;
        }else{
            nextRouteButton.enabled = YES;
            previousRouteButton.enabled = YES;
        }
    }else{
        nextRouteButton.enabled = NO;
        previousRouteButton.enabled = NO;
    }
    
    if (nextRouteButton.enabled){
        nextRouteButton.tintColor = [AppManager systemGreenColor];
        nextRouteButton.layer.borderColor = [AppManager systemGreenColor].CGColor;
    }else{
        nextRouteButton.tintColor = [UIColor lightGrayColor];
        nextRouteButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    if (previousRouteButton.enabled){
        previousRouteButton.tintColor = [AppManager systemGreenColor];
        previousRouteButton.layer.borderColor = [AppManager systemGreenColor].CGColor;
    }else{
        previousRouteButton.tintColor = [UIColor lightGrayColor];
        previousRouteButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}

-(BOOL)displayNextRouteAnimated{
    if (selectedRouteIndex < routeList.count - 1) {
        selectedRouteIndex++;
        _route = [routeList objectAtIndex:selectedRouteIndex];
        routeLocationList = [self convertRouteToLocationList:self.route];
        CATransition *transition = [CATransition new];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        
        // Make any view changes
        routeLocationList = [self convertRouteToLocationList:self.route];
        [self setUpMainViewForRoute];
        [self initMapViewForRoute:_route];
        
        // Add the transition
//        [routeListView.layer addAnimation:transition forKey:@"transition"];
        [routeMapView.layer addAnimation:transition forKey:@"transition"];
        
        [self setNextAndPrevButtonStates];
    }
    return YES;
}

-(BOOL)displayPrevRouteAnimated{
    if (selectedRouteIndex > 0) {
        selectedRouteIndex--;
        _route = [routeList objectAtIndex:selectedRouteIndex];
        
        CATransition *transition = [CATransition new];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        
        // Make any view changes
        routeLocationList = [self convertRouteToLocationList:self.route];
        [self setUpMainViewForRoute];
        [self initMapViewForRoute:_route];
        
        // Add the transition
//        [routeListView.layer addAnimation:transition forKey:@"transition"];
        [routeMapView.layer addAnimation:transition forKey:@"transition"];
        
        [self setNextAndPrevButtonStates];
    }

    return YES;
}

#pragma mark - map view methods
- (void)initializeMapView
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    [locationManager requestAlwaysAuthorization];
    
    routeMapView.delegate = self;
    previousRegion = routeMapView.visibleMapRect;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentUserLocation = [locations lastObject];
    
    currentLocationButton.hidden = NO;
    
//    if (previousCenteredLocation == nil) {
//        previousCenteredLocation = self.currentUserLocation;
//    }
//    
//    if (currentRouteListViewLocation == RouteListViewLoactionMiddle) {
//        CLLocationDistance dist = [previousCenteredLocation distanceFromLocation:self.currentUserLocation];
//        if (dist > 30) {
//            [self centerMapToCurrentLocation:self];
//        }
//    }
    
//    [self centerMapRegionToCoordinate:self.currentUserLocation.coordinate];
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coord{
    
    BOOL toReturn = YES;
    
    if (coord.latitude == 0 && coord.longitude == 0) {
        return NO;
    }
    if (currentRouteListViewLocation == RouteListViewLoactionMiddle) {
        coord.latitude =  coord.latitude - 0.002;
    }
    
    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    MKCoordinateRegion region = {coord, span};
    
    [UIView animateWithDuration:0.7 animations:^{
        [routeMapView setRegion:region animated:YES];
    } completion:^(BOOL finished) {
//        if (currentRouteListViewLocation == RouteListViewLoactionMiddle) {
//            CGPoint fakecenter = CGPointMake(self.view.bounds.size.width/2, (self.view.bounds.size.height/1.33) - 70);
//            CLLocationCoordinate2D coordinate = [routeMapView convertPoint:fakecenter toCoordinateFromView:routeMapView];
////            [routeMapView setCenterCoordinate:coordinate animated:YES];
//        }
    }];
    
    return toReturn;
}

-(BOOL)centerMapRegionToViewRoute{
    
    BOOL toReturn = YES;
    
    CLLocationCoordinate2D lowerBoundTemp = lowerBound;
    
    if (currentRouteListViewLocation == RouteListViewLoactionMiddle) {
        float latBoundSpan = upperBound.latitude - lowerBound.latitude;
        lowerBound.latitude =  lowerBound.latitude - (latBoundSpan);
    }
    
    CLLocationCoordinate2D centerCoord = {.latitude =  (upperBound.latitude + lowerBound.latitude)/2, .longitude =  (leftBound.longitude + rightBound.longitude)/2};
    MKCoordinateSpan span = {.latitudeDelta =  upperBound.latitude - lowerBound.latitude, .longitudeDelta =  rightBound.longitude - leftBound.longitude };
    span.latitudeDelta += 0.3 * span.latitudeDelta;
    span.longitudeDelta += 0.3 * span.longitudeDelta;
    MKCoordinateRegion region = {centerCoord, span};
    
    if (region.span.latitudeDelta <= 0.0f || region.span.longitudeDelta <= 0.0f) {
        region.span.latitudeDelta = 1.0f;
        region.span.longitudeDelta = 1.0f;
    }
    
    [routeMapView setRegion:region animated:YES];
    
    lowerBound = lowerBoundTemp;
    
    return toReturn;
}

- (void)drawLineForLeg:(RouteLeg *)leg {
    
    self.currentLeg = leg;
    int shapeCount = (int)leg.legShapeCoorStrings.count;
    // create an array of coordinates from allPins
    CLLocationCoordinate2D coordinates[shapeCount + 2];
    int i = 0;
    CLLocationCoordinate2D lastCoord;
    CLLocationCoordinate2D firstCoord;
    for (NSString *coordString in leg.legShapeCoorStrings) {
        CLLocationCoordinate2D coord = [ReittiStringFormatter convertStringTo2DCoord:coordString];
        
        coordinates[i] = coord;
        if (i==0) {
            firstCoord = coord;
        }
        lastCoord = coord;
        i++;
    }
    
    RouteLegLocation *loc2 = [leg.legLocations lastObject];
    CLLocationCoordinate2D legEndLoc = loc2.coords;
    
    coordinates[i] = legEndLoc;
    [self evaluateBoundsForCoordsArray:coordinates andCount:shapeCount];
    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:shapeCount];
    [routeMapView addOverlay:polyline];
    
    if (leg.legType != LegTypeWalk) {
        [self plotTransferAnnotation:[leg.legLocations objectAtIndex:0]];
        if (leg.legOrder != self.route.routeLegs.count) {
            [self plotTransferAnnotation:[leg.legLocations lastObject]];
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    // create an MKPolylineView and add it to the map view
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        ASPolylineRenderer *polylineRenderer = [[ASPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        polylineRenderer.strokeColor  = [UIColor yellowColor];
        polylineRenderer.borderColor = [UIColor blackColor];
        polylineRenderer.borderMultiplier = 1.1;
        polylineRenderer.lineWidth	  = 7.0f;
        polylineRenderer.lineJoin	  = kCGLineJoinRound;
        polylineRenderer.lineCap	  = kCGLineCapRound;
        
        polylineRenderer.alpha = 1.0;
        if (currentLeg.legType == LegTypeWalk) {
            polylineRenderer.strokeColor = SYSTEM_BROWN_COLOR;
            polylineRenderer.lineDashPattern = @[@4, @10];
        }else{
            polylineRenderer.strokeColor = [AppManager colorForLegType:currentLeg.legType];
        }
        
        return polylineRenderer;
    } else {
        return nil;
    }
}

-(void)plotTransferAnnotation:(RouteLegLocation *)loc{
    
    CLLocationCoordinate2D coordinate = loc.coords;
    
    NSString * name = loc.name;
    NSString * shortCode = loc.shortCode;
    
    if (name == nil || name == (id)[NSNull null]) {
        name = @"";
    }
    
    if (shortCode == nil || shortCode == (id)[NSNull null]) {
        shortCode = @"";
    }
    
    StopAnnotation *newAnnotation = [[StopAnnotation alloc] initWithTitle:name andSubtitle:shortCode
                                                            andCoordinate:coordinate];
    newAnnotation.code = [NSNumber numberWithInteger:[loc.stopCode integerValue]];
    
    if (loc.locationLegType == LegTypeWalk) {
        newAnnotation.imageNameForView = @"";
    }else{
        newAnnotation.imageNameForView = [AppManager stopAnnotationImageNameForStopType:[EnumManager stopTypeFromLegType:loc.locationLegType]];
    }
    
    [routeMapView addAnnotation:newAnnotation];
    
}

-(void)plotLocationsAnnotation:(Route *)route{
    int count = 0;
    for (RouteLeg *leg in route.routeLegs) {
       
        int locCount = 0;
        for (RouteLegLocation *loc in leg.legLocations) {
            CLLocationCoordinate2D coordinate = loc.coords;
            if (loc.name == nil) {
                
            }
            NSString * name = loc.name;
            NSString * shortCode = loc.shortCode;
            
            if (name == nil || name == (id)[NSNull null]) {
                name = @"";
            }
            
            if (shortCode == nil || shortCode == (id)[NSNull null]) {
                shortCode = @"";
            }
            
            if (count == 0 && locCount == 0) {
                //plot start annotation
                LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:shortCode andCoordinate:coordinate andLocationType:StartLocation];
                newAnnotation.imageNameForView = @"white-dot-16.png";
                [routeMapView addAnnotation:newAnnotation];
            }
            
            if (count == route.routeLegs.count - 1 && locCount == leg.legLocations.count - 1) {
                //plot destination annotation
                LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:shortCode andCoordinate:coordinate andLocationType:DestinationLocation];
                newAnnotation.imageNameForView = @"finish_flag-50.png";
                [routeMapView addAnnotation:newAnnotation];
            }
            
            if ([self shouldShowStopAnnotations]) {
                if (leg.legType != LegTypeWalk && locCount != 0 && locCount != leg.legLocations.count - 1) {
                    if (loc.shortCode != nil) {
                        LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:shortCode andCoordinate:coordinate andLocationType:StopLocation];
                        newAnnotation.code = [NSNumber numberWithInteger:[loc.stopCode integerValue]];
                        if (loc.locationLegType == LegTypeWalk) {
                            newAnnotation.imageNameForView = @"";
                        }else{
                            newAnnotation.imageNameForView = [AppManager stopAnnotationImageNameForStopType:[EnumManager stopTypeFromLegType:loc.locationLegType]];
                        }
                        
                        [routeMapView addAnnotation:newAnnotation];
                    }
                }
            }else{
                [self removeAllStopLocationAnnotations];
            }
            
            locCount++;
        }
        count++;
    }
}

- (void)plotOtherStopAnnotationsForStops:(NSArray *)stopList{
    if (![self shouldShowOtherStopAnnotations])
        return;

    @try {
        NSMutableArray *codeList;
        codeList = [self collectStopCodes:stopList];
        
        NSMutableArray *annotToRemove = [[NSMutableArray alloc] init];
        NSMutableArray *newStops = [[NSMutableArray alloc] init];
        
        if (stopList.count > 0) {
            //This is to avoid the flickering effect of removing and adding annotations
            for (id<MKAnnotation> annotation in routeMapView.annotations) {
                if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
                    LocationsAnnotation *annot = (LocationsAnnotation *)annotation;
                    if (annot.locationType != OtherStopLocation)
                        continue;
                    
                    if (![codeList containsObject:annot.code]) {
                        //Remove stop if it doesn't exist in the new list
                        [annotToRemove addObject:annotation];
                    }else{
                        [codeList removeObject:annot.code];
                    }
                }
            }
            newStops = [NSMutableArray arrayWithArray:[self collectStopsForCodes:codeList fromStops:stopList]];
            
            [routeMapView removeAnnotations:annotToRemove];
            
            NSMutableArray *allAnots = [@[] mutableCopy];
            for (BusStopShort *stop in newStops) {
                //Do not plot if stop annotation is one of the onces in the route
                if ([self isOtherStopOneOfTheLocationStops:stop])
                    continue;
                
                CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:stop.coords];
                NSString * name = stop.name;
                NSString * codeShort = stop.codeShort;
                
                LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:codeShort andCoordinate:coordinate andLocationType:OtherStopLocation];
                newAnnotation.code = [NSNumber numberWithInteger:[stop.code integerValue]];
                newAnnotation.imageNameForView = [AppManager stopAnnotationImageNameForStopType:stop.stopType];
                
                [routeMapView addAnnotation:newAnnotation];
            }
            
            if (allAnots.count > 0) {
                @try {
                    [routeMapView addAnnotations:allAnots];
                }
                @catch (NSException *exception) {
                    NSLog(@"Adding annotations failed!!! Exception %@", exception);
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Adding annotations failed!!! Exception %@", exception);
    }

}

- (NSArray *)collectStopsForCodes:(NSArray *)codeList fromStops:(NSArray *)stopList
{
    return [stopList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ containsObject:self.code",codeList ]];
}

- (NSMutableArray *)collectStopCodes:(NSArray *)stopList
{
    
    NSMutableArray *codeList = [[NSMutableArray alloc] init];
    for (BusStopShort *stop in stopList) {
        [codeList addObject:stop.code];
    }
    return codeList;
}

- (BOOL)isOtherStopOneOfTheLocationStops:(BusStopShort *)stop{
    for (RouteLeg *leg in self.route.routeLegs) {
        for (RouteLegLocation *loc in leg.legLocations) {
            if (loc.shortCode == stop.codeShort) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)shouldShowStopAnnotations{
    return [self zoomLevelForMapRect:routeMapView.visibleMapRect withMapViewSizeInPixels:routeMapView.bounds.size] >= 13;
}

- (BOOL)shouldShowOtherStopAnnotations{
    //15 is the level the current user location is displayed. Have to zoom more to view the other stops. 
    return [self zoomLevelForMapRect:routeMapView.visibleMapRect withMapViewSizeInPixels:routeMapView.bounds.size] > 14 && currentRouteListViewLocation == RouteListViewLoactionBottom;
}

- (NSMutableArray *)collectVehicleCodes:(NSArray *)vehicleList
{
    NSMutableArray *codeList = [[NSMutableArray alloc] init];
    for (Vehicle *vehicle in vehicleList) {
        [codeList addObject:vehicle.vehicleId];
    }
    return codeList;
}

- (NSArray *)collectVehiclesForCodes:(NSArray *)codeList fromVehicles:(NSArray *)vehicleList
{
    return [vehicleList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ containsObject:self.vehicleId",codeList ]];
}

- (double)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    double fLat = degreesToRadians(fromLoc.latitude);
    double fLng = degreesToRadians(fromLoc.longitude);
    double tLat = degreesToRadians(toLoc.latitude);
    double tLng = degreesToRadians(toLoc.longitude);
    
    double degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

-(void)plotVehicleAnnotations:(NSArray *)vehicleList isTrainVehicles:(BOOL)isTrain{
    
    NSMutableArray *codeList = [self collectVehicleCodes:vehicleList];
    
    NSMutableArray *annotToRemove = [[NSMutableArray alloc] init];
    
    NSMutableArray *existingVehicles = [[NSMutableArray alloc] init];
    
    for (id<MKAnnotation> annotation in routeMapView.annotations) {
        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            LVThumbnailAnnotation *annot = (LVThumbnailAnnotation *)annotation;
            
//            if (isTrain) {
//                if (annot.vehicleType != VehicleTypeTrain) {
//                    continue;
//                }
//            }else{
//                if (annot.vehicleType == VehicleTypeTrain) {
//                    continue;
//                }
//            }
            
            if (![codeList containsObject:annot.code]) {
                [annotToRemove addObject:annotation];
            }else{
                [codeList removeObject:annot.code];
                [existingVehicles addObject:annotation];
            }
        }
    }
    
    for (id<MKAnnotation> annotation in existingVehicles) {
        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            LVThumbnailAnnotation *annot = (LVThumbnailAnnotation *)annotation;
            @try {
                Vehicle *vehicleToUpdate = [[self collectVehiclesForCodes:@[annot.code] fromVehicles:vehicleList] firstObject];
                
                if (vehicleToUpdate.vehicleType == VehicleTypeBus) {
                    double bearing = [self getHeadingForDirectionFromCoordinate:annot.coordinate toCoordinate:vehicleToUpdate.coords];
                    if (vehicleToUpdate.vehicleType == VehicleTypeBus) {
                        //vehicle didn't move.
                        if (bearing != 0) {
                            vehicleToUpdate.bearing = bearing;
                            [annot updateVehicleImage:[AppManager vehicleImageForVehicleType:vehicleToUpdate.vehicleType]];
                        }else{
                            vehicleToUpdate.bearing = -1; //Do not update
                        }
                    }
                }
                
                annot.coordinate = vehicleToUpdate.coords;
                
                if (vehicleToUpdate.bearing != -1) {
                    [((NSObject<LVThumbnailAnnotationProtocol> *)annot) updateBearing:[NSNumber numberWithDouble:vehicleToUpdate.bearing]];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"Failed to update annotation for vehicle with code: %@", annot.code);
                [annotToRemove addObject:annot];
                [codeList addObject:annot.code];
            }
        }
    }
    
    [routeMapView removeAnnotations:annotToRemove];
    
    NSArray *newVehicles = [self collectVehiclesForCodes:codeList fromVehicles:vehicleList];
    
    for (Vehicle *vehicle in newVehicles) {
        LVThumbnail *vehicleAnT = [[LVThumbnail alloc] init];
//        vehicleAnT.image = [AppManager vehicleImageForVehicleType:vehicle.vehicleType];
        vehicleAnT.bearing = [NSNumber numberWithDouble:vehicle.bearing];
        vehicleAnT.image = [AppManager vehicleImageForVehicleType:vehicle.vehicleType];
        vehicleAnT.bearing = [NSNumber numberWithDouble:vehicle.bearing];
        if (vehicle.bearing != -1 ) {
            vehicleAnT.image = [AppManager vehicleImageForVehicleType:vehicle.vehicleType];
        }else{
            vehicleAnT.image = [AppManager vehicleImageWithNoBearingForVehicleType:vehicle.vehicleType];
        }
        vehicleAnT.code = vehicle.vehicleId;
        vehicleAnT.title = vehicle.vehicleName;
        vehicleAnT.lineId = vehicle.vehicleLineId;
        vehicleAnT.vehicleType = vehicle.vehicleType;
        vehicleAnT.coordinate = vehicle.coords;
        vehicleAnT.reuseIdentifier = [NSString stringWithFormat:@"reusableIdentifierFor%@", vehicle.vehicleId];
        
        [routeMapView addAnnotation:[LVThumbnailAnnotation annotationWithThumbnail:vehicleAnT]];
    }
}


- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *transferIdentifier = @"transferLocation";
    if ([annotation isKindOfClass:[StopAnnotation class]]) {
        StopAnnotation *stopAnnotation = (StopAnnotation *)annotation;
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:transferIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:transferIdentifier];
            annotationView.enabled = YES;
            
            annotationView.canShowCallout = YES;
            if (stopAnnotation.code != nil && stopAnnotation.code != (id)[NSNull null]) {
                annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            }
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.image = [UIImage imageNamed:stopAnnotation.imageNameForView];
        [annotationView setFrame:CGRectMake(0, 0, 28, 42)];
        annotationView.centerOffset = CGPointMake(0,-15);
        
        return annotationView;
    }
    
    static NSString *destinationIdentifier = @"destinationLocation";
    static NSString *startIdentifier = @"startLocation";
    static NSString *locationIdentifier = @"location";
    
    if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
        if (locAnnotation.locationType == DestinationLocation) {
            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:destinationIdentifier];
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:destinationIdentifier];
                annotationView.enabled = YES;
                
                annotationView.canShowCallout = YES;
                
            } else {
                annotationView.annotation = annotation;
            }
            
            annotationView.image = [UIImage imageNamed:locAnnotation.imageNameForView];
            [annotationView setFrame:CGRectMake(0, 0, 30, 30)];
            annotationView.centerOffset = CGPointMake(5,-15);
            
            return annotationView;
        }else if (locAnnotation.locationType == StartLocation){
            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:startIdentifier];
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:startIdentifier];
                annotationView.enabled = YES;
                
                annotationView.canShowCallout = YES;
                
            } else {
                annotationView.annotation = annotation;
            }
            
            annotationView.image = [UIImage imageNamed:locAnnotation.imageNameForView];
            [annotationView setFrame:CGRectMake(0, 0, 16, 16)];
            //                annotationView.centerOffset = CGPointMake(0,-19);
            
            return annotationView;
        }else if (locAnnotation.locationType == StopLocation){
//            MKAnnotationView *annotationView;
            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:locationIdentifier];
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:locationIdentifier];
                annotationView.enabled = YES;
                
                annotationView.canShowCallout = YES;
                if (locAnnotation.code != nil && locAnnotation.code != (id)[NSNull null]) {
                    annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                }
                
            } else {
                annotationView.annotation = annotation;
            }
            
            annotationView.image = [UIImage imageNamed:locAnnotation.imageNameForView];
            [annotationView setFrame:CGRectMake(0, 0, 28, 42)];
            annotationView.centerOffset = CGPointMake(0,-15);
            
            return annotationView;
        }else if (locAnnotation.locationType == OtherStopLocation){
            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:locationIdentifier];
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:locationIdentifier];
                annotationView.enabled = YES;
                
                annotationView.canShowCallout = YES;
                if (locAnnotation.code != nil && locAnnotation.code != (id)[NSNull null]) {
                    annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                }
                
            } else {
                annotationView.annotation = annotation;
            }
            
            annotationView.image = [UIImage imageNamed:locAnnotation.imageNameForView];
            [annotationView setFrame:CGRectMake(0, 0, 16, 25)];
            annotationView.centerOffset = CGPointMake(0,-8);
//            annotationView.alpha = 0.95;
            
            return annotationView;
        }
    }
    
    if ([annotation conformsToProtocol:@protocol(LVThumbnailAnnotationProtocol)]) {
        
        return [((NSObject<LVThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:routeMapView];
    }
    
//    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
//        MKAnnotationView *annotationView = [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:routeMapView];
//        annotationView.alpha = 0.5;
//        annotationView.canShowCallout = YES;
//        return annotationView;
//    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = [view annotation];
    NSNumber *stopCode;
    NSString *stopShortCode, *stopName;
    CLLocationCoordinate2D stopCoords;
    if ([annotation isKindOfClass:[StopAnnotation class]])
    {
        StopAnnotation *stopAnnotation = (StopAnnotation *)annotation;
        stopCode = stopAnnotation.code;
        stopCoords = stopAnnotation.coordinate;
        stopShortCode = stopAnnotation.subtitle;
        stopName = stopAnnotation.title;
        
    }else if ([annotation isKindOfClass:[LocationsAnnotation class]])
    {
        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
        stopCode = locAnnotation.code;
        stopCoords = locAnnotation.coordinate;
        stopShortCode = locAnnotation.subtitle;
        stopName = locAnnotation.title;
    }else{
        return;
    }
    
    if (stopCode != nil && stopCode != (id)[NSNull null]) {
        selectedAnnotionStopCode = stopCode;
        selectedAnnotationStopCoords = stopCoords;
        selectedAnnotionStopShortCode = stopShortCode;
        selectedAnnotionStopName = stopName;
        [self performSegueWithIdentifier:@"showStopFromRoute" sender:self];
    }
    
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    previousRegion = mapView.visibleMapRect;
}

//Stop locations are the stops in legs. Not transfer locations
-(void)removeAllStopLocationAnnotations{
    for (id<MKAnnotation> annotation in routeMapView.annotations) {
        if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
            LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
            if (locAnnotation.locationType == StopLocation) {
                [routeMapView removeAnnotation:annotation];
            }
        }
    }
}

-(void)removeAllOtherStopAnnotations{
    NSMutableArray *array = [@[] mutableCopy];
    for (id<MKAnnotation> annotation in routeMapView.annotations) {
        if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
            LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
            if (locAnnotation.locationType == OtherStopLocation) {
                [array addObject:annotation];
            }
        }
    }
    
    [routeMapView removeAnnotations:array];
}

-(void)removeAnnotationsExceptVehicles{
    NSMutableArray *array = [@[] mutableCopy];
    for (id<MKAnnotation> annotation in routeMapView.annotations) {
        if (![annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            [array addObject:annotation];
        }
    }
    
    [routeMapView removeAnnotations:array];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
//    NSLog(@"Zoom level is: %lu ", (unsigned long)[self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size]);
    
    //Show detailed stop annotations when the zoom level is more than or equal to 14
    if ([self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size] != [self zoomLevelForMapRect:previousRegion withMapViewSizeInPixels:mapView.bounds.size]) {
//        [mapView removeAnnotations:mapView.annotations];
        [self removeAnnotationsExceptVehicles];
        [self plotLocationsAnnotation:self.route];
        
        [mapView removeOverlays:mapView.overlays];
        
        for (RouteLeg *leg in self.route.routeLegs) {
            [self drawLineForLeg:leg];
        }
    }
    
    if ([self shouldShowOtherStopAnnotations]) {
        [self.reittiDataManager fetchStopsInAreaForRegion:routeMapView.region withCompletionBlock:^(NSArray *stops, NSString *error){
            if (!error) {
                [self plotOtherStopAnnotationsForStops:stops];
            }
        }];
    }else{
//        [self removeAllOtherStopAnnotations];
    }
    
    //the third check is because setting usertracking mode changes the region and the tag of the button might not yet be updated at that time.
    if (currentLocationButton.tag == kCenteredCurrentLocationButtonTag && !ignoreMapRegionChangeForCurrentLocationButtonStatus && mapView.userTrackingMode != MKUserTrackingModeFollowWithHeading) {
        [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:YES];
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
    }
    
    if (currentLocationButton.tag == kCompasModeCurrentLocationButtonTag && mapView.userTrackingMode != MKUserTrackingModeFollowWithHeading ) {
        [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:YES];
    }
    
    ignoreMapRegionChangeForCurrentLocationButtonStatus = NO;
}

-(NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels
{
    NSUInteger zoomLevel = 20; // MAXIMUM_ZOOM is 20 with MapKit
    MKZoomScale zoomScale = mRect.size.width / viewSizeInPixels.width; //MKZoomScale is just a CGFloat typedef
    double zoomExponent = log2(zoomScale);
    zoomLevel = (NSUInteger)(20 - ceil(zoomExponent));
    return zoomLevel;
}

#pragma mark - Peek and Pop actions support
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    return self.previewActions;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActions {
    if (_previewActions == nil) {
        UIPreviewAction *remindMeAction = [UIPreviewAction
                                        actionWithTitle:@"Remind Me"
                                        style:UIPreviewActionStyleDefault
                                        handler:^(UIPreviewAction * _Nonnull action,
                                                  UIViewController * _Nonnull previewViewController) {
                                            RouteDetailViewController *viewController = (RouteDetailViewController *)previewViewController;
                                            [viewController reminderButtonPressed:self];
                                        }];
        _previewActions = @[remindMeAction];
    }
    return _previewActions;
}

#pragma mark - IB Actions
- (IBAction)backButtonPressed:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)nextRouteButtonPressed:(id)sender {
    [self displayNextRouteAnimated];
}
- (IBAction)previousButtonPressed:(id)sender {
    [self displayPrevRouteAnimated];
}
- (IBAction)expandLegButtonPressed:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:routeListTableView];
    NSIndexPath *indexPath = [routeListTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        RouteLegLocation *loc = [self.routeLocationList objectAtIndex:indexPath.row];
        
        if (loc.isHeaderLocation) {
            @try {
                RouteLeg *selectedLeg = [self.route.routeLegs objectAtIndex:loc.locationLegOrder];
                if(selectedLeg.showDetailed){
                    selectedLeg.showDetailed = NO;
                }else{
                    selectedLeg.showDetailed = YES;
                }
                
                routeLocationList = [self convertRouteToLocationList:self.route];
                
                [routeListTableView reloadData];
            }
            @catch (NSException *exception) {
                
            }
        }
    }
}

- (IBAction)showOrHideListButtonPressed:(id)sender {
    if ([self isRouteListViewVisible]) {
        [self moveRouteViewToLocation:RouteListViewLoactionBottom animated:YES];
    }else{
        [self moveRouteViewToLocation:RouteListViewLoactionTop animated:YES];
    }
}
- (IBAction)centerMapToCurrentLocation:(id)sender {
    if (self.currentUserLocation) {
        if (currentLocationButton.tag == kNormalCurrentLocationButtonTag) {
            [routeMapView setUserTrackingMode:MKUserTrackingModeNone];
            [self centerMapRegionToCoordinate:self.currentUserLocation.coordinate];
            previousCenteredLocation = self.currentUserLocation;
            [currentLocationButton asa_updateAsCenteredAtCurrentLocationWithBackgroundColor:[AppManager systemGreenColor] animated:YES];
            
            ignoreMapRegionChangeForCurrentLocationButtonStatus = YES;
        }else if (currentLocationButton.tag == kCenteredCurrentLocationButtonTag) {
            [routeMapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
            [currentLocationButton asa_updateAsCompassModeCurrentLocationWithBackgroundColor:[AppManager systemGreenColor] animated:YES];
            ignoreMapRegionChangeForCurrentLocationButtonStatus = YES;
        }else if (currentLocationButton.tag == kCompasModeCurrentLocationButtonTag) {
            [routeMapView setUserTrackingMode:MKUserTrackingModeNone];
            [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:YES];
        }
    }
}

- (IBAction)reminderButtonPressed:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"When do you want to be reminded." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1 min before", @"5 min before",@"10 min before",@"15 min before", @"30 min before", nil];
    actionSheet.tag = 2001;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 2001) {
//        NSString * timeToSetAlarm = [ReittiStringFormatter formatHourStringFromDate:self.route.getStartingTimeOfRoute];
        reittiRemindersManager.reminderMessageFormater = @"Get ready to leave in %d minutes.";
        switch (buttonIndex) {
            case 0:
                reittiRemindersManager.reminderMessageFormater = @"Get ready to leave in %d minute.";
                [self setReminderForOffset:1 andTime:self.route.startingTimeOfRoute];
                break;
            case 1:
                [self setReminderForOffset:5 andTime:self.route.startingTimeOfRoute];
                break;
            case 2:
                [self setReminderForOffset:10 andTime:self.route.startingTimeOfRoute];
                break;
            case 3:
                [self setReminderForOffset:15 andTime:self.route.startingTimeOfRoute];
                break;
            case 4:
                [self setReminderForOffset:30 andTime:self.route.startingTimeOfRoute];
                break;
            default:
                break;
        }
        
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSetRouteReminder label:@"All" value:nil];
    }
}

-(void)setReminderForOffset:(int)offset andTime:(NSDate *)time{
    [[ReittiRemindersManager sharedManger] setNotificationWithMinOffset:offset andTime:time andToneName:[settingsManager toneName]];
}

-(void)swipeToLeftDetected:(id)sender{
    [self displayNextRouteAnimated];
}

-(void)swipeToRightDetected:(id)sender{
    [self displayPrevRouteAnimated];
}

#pragma - mark dragging view methods
-(IBAction)dragRouteList:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    if ((recognizer.view.frame.origin.y + translation.y) > 0  ) {
        //        recognizer.view.center = CGPointMake(recognizer.view.center.x, recognizer.view.center.y + translation.y);
        routeLIstViewVerticalSpacing.constant += translation.y;
        [self.view layoutSubviews];
    }
    if (recognizer.state != UIGestureRecognizerStateEnded){
        routeListViewIsGoingUp = translation.y < 0;
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self snapRouteListView];
    }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma - mark Scroll View delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) {
        if (!tableViewIsDecelerating) {
            routeLIstViewVerticalSpacing.constant += -scrollView.contentOffset.y;
            [self.view layoutSubviews];
            routeListViewIsGoingUp = NO;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        }
        
    }else if(scrollView.contentOffset.y == 0 ){
        
    }else{
        if (routeLIstViewVerticalSpacing.constant > 0 && currentRouteListViewLocation != RouteListViewLoactionMiddle) {
            routeLIstViewVerticalSpacing.constant -= scrollView.contentOffset.y;
            [self.view layoutSubviews];
            routeListViewIsGoingUp = YES;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        }else{
//            stopViewDragedDown = NO;
            //
        }
    }
}

- (void)snapRouteListView {
    CGFloat viewHeight = routeListView.frame.size.height;
    CGFloat curPos = routeLIstViewVerticalSpacing.constant;
 
    if (routeListViewIsGoingUp) {
        if ( curPos > (viewHeight / 1.2)) {
            [self moveRouteViewToLocation:RouteListViewLoactionBottom animated:YES];
        }else if ( ((viewHeight / 1.2) > curPos) && (curPos > (viewHeight / 2.5))) {
            [self moveRouteViewToLocation:RouteListViewLoactionMiddle animated:YES];
        }else{
            [self moveRouteViewToLocation:RouteListViewLoactionTop animated:YES];
        }
    }else{
        if ( curPos > (viewHeight / 1.33)) {
            [self moveRouteViewToLocation:RouteListViewLoactionBottom animated:YES];
        }else if (((viewHeight / 1.33) > curPos) && (curPos > (viewHeight / 6))) {
            [self moveRouteViewToLocation:RouteListViewLoactionMiddle animated:YES];
        }else{
            [self moveRouteViewToLocation:RouteListViewLoactionTop animated:YES];
        }
    }
   
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self snapRouteListView];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    tableViewIsDecelerating = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    tableViewIsDecelerating = NO;
}


#pragma mark - TableViewMethods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return routeLocationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UIColor *darkerGrayColor = [UIColor colorWithWhite:0.28 alpha:1];
    UIColor *darkerGrayColor = [UIColor darkGrayColor];
    
    RouteLegLocation *loc = [self.routeLocationList objectAtIndex:indexPath.row];
    RouteLeg *selectedLeg = [self.route.routeLegs objectAtIndex:loc.locationLegOrder];
    UITableViewCell *cell;
    if (loc.isHeaderLocation) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"legHeaderCell"];
        
        UILabel *locNameLabel = (UILabel *)[cell viewWithTag:1002];
        UIImageView *legTypeImage = (UIImageView *)[cell viewWithTag:1001];
        UIButton *detailDesclosureButton = (UIButton *)[cell viewWithTag:1004];
        UILabel *moreInfoLabel = (UILabel *)[cell viewWithTag:1006];
        
        UILabel *lineNumberLabel = (UILabel *)[cell viewWithTag:1000];
        UIView *transportCircleBackView = [cell viewWithTag:2010];
        
        UIImageView *prevLegLine = (UIImageView *)[cell viewWithTag:2007];
        UIView *dotView = (UIView *)[cell viewWithTag:2009];
        UIImageView *nextLegLine = (UIImageView *)[cell viewWithTag:2008];
        
        UILabel *startTimeLabel = (UILabel *)[cell viewWithTag:1003];
        startTimeLabel.text = [ReittiStringFormatter formatHourStringFromDate:loc.depTime];
        
        [legTypeImage setImage:[AppManager lightColorImageForLegTransportType:loc.locationLegType]];
        legTypeImage.contentMode = UIViewContentModeScaleAspectFill;
        
        dotView.backgroundColor = [UIColor whiteColor];
        dotView.layer.borderColor = [darkerGrayColor CGColor];
        dotView.layer.borderWidth = 3.0;
        dotView.layer.cornerRadius = 6.f;
        
        transportCircleBackView.layer.cornerRadius = 17.5f;
        transportCircleBackView.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
        
        prevLegLine.backgroundColor = darkerGrayColor;
        nextLegLine.backgroundColor = darkerGrayColor;
        
        moreInfoLabel.textColor = [UIColor darkGrayColor];
        
        if (indexPath.row == 0) {
            locNameLabel.text = self.fromLocation;
            detailDesclosureButton.hidden = NO;
            nextLegLine.hidden = NO;
            prevLegLine.hidden = YES;
            transportCircleBackView.hidden = NO;
            lineNumberLabel.hidden = NO;
            moreInfoLabel.hidden = NO;
            
            dotView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        }else if (indexPath.row == self.routeLocationList.count - 1) {
            locNameLabel.text = self.toLocation;
            detailDesclosureButton.hidden = YES;
            nextLegLine.hidden = YES;
            prevLegLine.hidden = NO;
            transportCircleBackView.hidden = YES;
            [legTypeImage setImage:nil];
            lineNumberLabel.hidden = YES;
            moreInfoLabel.hidden = YES;
            
            dotView.layer.borderColor = [[AppManager systemGreenColor] CGColor];
        }else{
            locNameLabel.text = loc.name == nil || loc.name == (id)[NSNull null] ? @"" : loc.name;
            detailDesclosureButton.hidden = NO;
            nextLegLine.hidden = NO;
            prevLegLine.hidden = NO;
            transportCircleBackView.hidden = NO;
            lineNumberLabel.hidden = NO;
            moreInfoLabel.hidden = NO;
        }
        
        if (loc.locationLegType == LegTypeWalk) {
            transportCircleBackView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            transportCircleBackView.layer.borderWidth = 1;
            
            lineNumberLabel.text = @"Walk";
            
            nextLegLine.image = [UIImage asa_dottedLineImageWithFrame:nextLegLine.frame andColor:[UIColor lightGrayColor]];
            nextLegLine.backgroundColor = [UIColor clearColor];
            
            moreInfoLabel.text = [NSString stringWithFormat:@"Walk for %ld meters \nAbout %@", (long)[selectedLeg.legLength integerValue],[ReittiStringFormatter formatDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
        }else{
            transportCircleBackView.backgroundColor = darkerGrayColor;
            transportCircleBackView.layer.borderWidth = 0;
            
            lineNumberLabel.text = [selectedLeg.lineDisplayName capitalizedString];
            
            if (selectedLeg.legType != LegTypeTram) { /* the tram picture is smaller than others */
                [legTypeImage setImage:[UIImage asa_imageWithImage:[AppManager lightColorImageForLegTransportType:loc.locationLegType] scaledToSize:CGSizeMake(legTypeImage.frame.size.width - 4, legTypeImage.frame.size.height - 4)]];
                legTypeImage.contentMode = UIViewContentModeCenter;
            }
            
            nextLegLine.backgroundColor = darkerGrayColor;
            nextLegLine.image = nil;
            
            NSString *destination = [self getDestinationForLineCode:selectedLeg.lineCode];
            NSString *stopsText = ([selectedLeg getNumberOfStopsInLeg] - 1) > 1 ? @"stops" : @"stop";
            if (destination != nil) {
                moreInfoLabel.text = [NSString stringWithFormat:@"Towards %@ \n%@", destination, [ReittiStringFormatter formatDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
            }else{
                moreInfoLabel.text = [NSString stringWithFormat:@"%d %@ \n%@", [selectedLeg getNumberOfStopsInLeg] - 1, stopsText, [ReittiStringFormatter formatFullDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
            }
        }
        
        if (indexPath.row > 0) {
            RouteLegLocation *prevLoc = [self.routeLocationList objectAtIndex:indexPath.row - 1];
            switch (prevLoc.locationLegType) {
                case LegTypeWalk:
                    prevLegLine.image = [UIImage asa_dottedLineImageWithFrame:prevLegLine.frame andColor:[UIColor lightGrayColor]];
                    prevLegLine.backgroundColor = [UIColor clearColor];
                    break;
                    
                default:
                    prevLegLine.backgroundColor = darkerGrayColor;
                    prevLegLine.image = nil;
                    break;
            }
        }
        
        if (indexPath.row == self.routeLocationList.count - 1) {
//            moreInfoLabel.text = @"";
//            lineNumberLabel.hidden = YES;
        }else if (selectedLeg.legType == LegTypeWalk) {
//            moreInfoLabel.text = [NSString stringWithFormat:@"Walk for %ld meters \nAbout %@", (long)[selectedLeg.legLength integerValue],[ReittiStringFormatter formatDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
//            lineNumberLabel.hidden = NO;
//            lineNumberLabel.text = @"Walk";
        }else{
//            lineNumberLabel.hidden = NO;
//            lineNumberLabel.text = [selectedLeg.lineDisplayName capitalizedString];
//            NSString *destination = [self getDestinationForLineCode:selectedLeg.lineCode];
//            NSString *stopsText = ([selectedLeg getNumberOfStopsInLeg] - 1) > 1 ? @"stops" : @"stop";
//            if (destination != nil) {
//                moreInfoLabel.text = [NSString stringWithFormat:@"Towards %@ \n%@", destination, [ReittiStringFormatter formatDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
//                moreInfoLabel.textColor = [UIColor darkGrayColor];
//            }else{
//                moreInfoLabel.text = [NSString stringWithFormat:@"%d %@ \n%@", [selectedLeg getNumberOfStopsInLeg] - 1, stopsText, [ReittiStringFormatter formatFullDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
//                moreInfoLabel.textColor = [UIColor lightGrayColor];
//            }
        }
        
        [detailDesclosureButton setTitle:[self disclosureButtontextForLeg:selectedLeg] forState:UIControlStateNormal];
        detailDesclosureButton.userInteractionEnabled = NO;
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }else if (!loc.isHeaderLocation) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"legstopLocationCell"];
        
        UIImageView *typeLine = (UIImageView *)[cell viewWithTag:2001];
        UILabel *locNameLabel = (UILabel *)[cell viewWithTag:2002];
        UILabel *startTimeLabel = (UILabel *)[cell viewWithTag:2003];
        UIView *dotView = (UIView *)[cell viewWithTag:2004];

        if (loc.name == nil || loc.name == (id)[NSNull null])
            locNameLabel.text = @"";
        else
            locNameLabel.text = loc.name;

        if (loc.stopCode == nil || loc.stopCode == (id)[NSNull null])
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        dotView.backgroundColor = darkerGrayColor;
        dotView.layer.cornerRadius = 3.5f;
        
        if (loc.locationLegType == LegTypeWalk) {
            typeLine.backgroundColor = [UIColor clearColor];
            typeLine.image = [UIImage asa_dottedLineImageWithFrame:typeLine.frame andColor:[UIColor lightGrayColor]];
            dotView.hidden = YES;
            startTimeLabel.hidden = YES;
        }else{
            typeLine.backgroundColor = darkerGrayColor;
            typeLine.image = nil;
            dotView.hidden = NO;
            startTimeLabel.hidden = NO;
            startTimeLabel.text = [ReittiStringFormatter formatHourStringFromDate:loc.depTime];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
//    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RouteLegLocation *loc = [self.routeLocationList objectAtIndex:indexPath.row];
    
    //This numbers are critical so that the dotted lines match
    if (loc.isHeaderLocation) {
        return 138.0;
    }else{
        return 24.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RouteLegLocation *loc = [self.routeLocationList objectAtIndex:indexPath.row];

    if (loc.isHeaderLocation) {
        @try {
            RouteLeg *selectedLeg = [self.route.routeLegs objectAtIndex:loc.locationLegOrder];
            if(selectedLeg.showDetailed){
                selectedLeg.showDetailed = NO;
            }else{
                selectedLeg.showDetailed = YES;
            }
            
            //animate insertion and deletion.
            NSMutableArray *oldLocListCopy = [routeLocationList copy];
            
            routeLocationList = [self convertRouteToLocationList:self.route];
            
            @try {
                if (selectedLeg.showDetailed) {//Insert
                    NSInteger startRow = [oldLocListCopy indexOfObject:loc];
                    NSInteger endRow = [routeLocationList indexOfObject:[oldLocListCopy objectAtIndex:(startRow + 1)]];
                    
                    NSMutableArray *indexPaths = [@[] mutableCopy];
                    for (NSInteger i = startRow + 1; i < endRow; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
//                    [routeListTableView beginUpdates];
                    [routeListTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
//                    [routeListTableView endUpdates];
                } else {//Delete
                    NSInteger startRow = [routeLocationList indexOfObject:loc];
                    NSInteger endRow = [oldLocListCopy indexOfObject:[routeLocationList objectAtIndex:(startRow + 1)]];
                    
                    NSMutableArray *indexPaths = [@[] mutableCopy];
                    for (NSInteger i = startRow + 1; i < endRow; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
//                    [routeListTableView beginUpdates];
                    [routeListTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
//                    [routeListTableView endUpdates];
                }
            }
            @catch (NSException *exception) {
                [routeListTableView reloadData];
            }
            
//            [routeListTableView reloadData];
            
            UITableViewCell *selectedCell = [routeListTableView cellForRowAtIndexPath:indexPath];
            UIButton *detailDesclosureButton = (UIButton *)[selectedCell viewWithTag:1004];
            [detailDesclosureButton setTitle:[self disclosureButtontextForLeg:selectedLeg] forState:UIControlStateNormal];
            
            if (currentRouteListViewLocation == RouteListViewLoactionMiddle) {
                [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:loc.coordsString]];
                [self selectTransferAnnotationWithCode:loc.stopCode];
            }
        }
        @catch (NSException *exception) {
            
        }
        
    }else{
        if (currentRouteListViewLocation != RouteListViewLoactionMiddle) {
            [self moveRouteViewToLocation:RouteListViewLoactionMiddle animated:YES];
        }
    
        [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:loc.coordsString]];
        [self selectLocationAnnotationWithCode:loc.stopCode];
    
        [routeListTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
    }
}

-(NSString *)disclosureButtontextForLeg:(RouteLeg *)leg{
    if (leg.legType == LegTypeWalk) {
        if(leg.showDetailed)
            return @"Hide";
        else
            return @"Details";
    }else{
        NSString *stopsText = ([leg getNumberOfStopsInLeg] - 1) > 1 ? @"stops" : @"stop";
        
        if(leg.showDetailed){
            return @"Hide";
        }else{
            return [NSString stringWithFormat:@"%d %@", [leg getNumberOfStopsInLeg] - 1, stopsText];
        }
    }
}

-(bool)showDetailDisclosureButtonForLeg:(RouteLeg *)leg{
    if (leg.legType == LegTypeWalk) {
        return leg.legLocations.count > 1;
    }else{
        return YES;
    }
}

//-(void)addTransportTypePictures{
//    for (UIView *view in routeListView.subviews) {
//        if (view.tag == 9999) {
//            [view removeFromSuperview];
//        }
//    }
//
//    for (int i = 0;i < self.routeLocationList.count;i++) {
//        RouteLegLocation *loc = [self.routeLocationList objectAtIndex:i];
//        RouteLeg *selectedLeg = [self.route.routeLegs objectAtIndex:loc.locationLegOrder];
//        if (loc.isHeaderLocation) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//            CGRect rect = [routeListTableView rectForRowAtIndexPath:indexPath];
//            
//            CGFloat height = loc.locationLegType == LegTypeWalk ? 24 : 45;
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, routeListTableView.frame.origin.y + rect.origin.y + rect.size.height - height/2 , 40, height)];
//            
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 24, 24)];
//            
//            switch (loc.locationLegType) {
//                case LegTypeWalk:
//                    [imageView setImage:[UIImage imageNamed:@"walking-black-75.png"]];
//                    break;
//                case LegTypeFerry:
//                    [imageView setImage:[UIImage imageNamed:@"ferry-colored-75.png"]];
//                    break;
//                case LegTypeTrain:
//                    [imageView setImage:[UIImage imageNamed:@"train-colored-75.png"]];
//                    break;
//                case LegTypeBus:
//                    [imageView setImage:[UIImage imageNamed:@"bus-colored-75.png"]];
//                    break;
//                case LegTypeTram:
//                    [imageView setImage:[UIImage imageNamed:@"tram-colored-75.png"]];
//                    break;
//                case LegTypeMetro:
//                    [imageView setImage:[UIImage imageNamed:@"metro-colored-75.png"]];
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//            [routeListView addSubview:imageView];
//            
//            UILabel *lineNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 40, 20)];
//            
//            if(selectedLeg.legType == LegTypeMetro){
//                lineNumberLabel.text = @"Metro";
//            }else if(selectedLeg.legType == LegTypeFerry){
//                lineNumberLabel.text = @"Ferry";
//            }else if(selectedLeg.legType == LegTypeTrain){
////                NSString *unformattedTrainNumber = [ReittiStringFormatter parseBusNumFromLineCode:selectedLeg.lineCode];
////                NSString *unformattedTrainNumber = selectedLeg.lineName ? selectedLeg.lineName : selectedLeg.lineCode;
////                NSString *filteredOnce = [unformattedTrainNumber
////                                          stringByReplacingOccurrencesOfString:@"01" withString:@""];
//                lineNumberLabel.text = selectedLeg.lineName ? selectedLeg.lineName : selectedLeg.lineCode;
//            }else if (selectedLeg.lineCode != nil) {
//                lineNumberLabel.text = selectedLeg.lineName;
//            }else {
//                lineNumberLabel.text = @"";
//            }
//            
//            [lineNumberLabel sizeToFit];
//            lineNumberLabel.textAlignment = NSTextAlignmentCenter;
//            lineNumberLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
//            lineNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
//            
//            [view addSubview:lineNumberLabel];
//            
//            view.tag = 9999;
////            view.backgroundColor = [UIColor lightGrayColor];
//            
//            [routeListView addSubview:view];
//        }
//    }
//}

-(void)selectTransferAnnotationWithCode:(NSString *)code{
    for (id<MKAnnotation> annotation in routeMapView.annotations) {
        if ([annotation isKindOfClass:[StopAnnotation class]]) {
            StopAnnotation *sAnnot = (StopAnnotation *)annotation;
            if ([sAnnot.code integerValue] == [code integerValue]) {
                [routeMapView selectAnnotation:annotation animated:YES];
            }
        }
    }
}

-(void)selectLocationAnnotationWithCode:(NSString *)code{
    for (id<MKAnnotation> annotation in routeMapView.annotations) {
        if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
            LocationsAnnotation *lAnnot = (LocationsAnnotation *)annotation;
            if ([lAnnot.code integerValue] == [code integerValue]) {
                [routeMapView selectAnnotation:annotation animated:YES];
            }
        }
    }
}

#pragma mark - helper methods
- (void)evaluateBoundsForCoordsArray:(CLLocationCoordinate2D *)coords andCount:(int)count{
    for (int i = 0; i < count; i++) {
        CLLocationCoordinate2D coord = coords[i];
        
        if (coord.latitude > upperBound.latitude) {
            upperBound = coord;
        }
        if (coord.latitude < lowerBound.latitude) {
            lowerBound = coord;
        }
        if (coord.longitude > rightBound.longitude) {
            rightBound = coord;
        }
        if (coord.longitude < leftBound.longitude) {
            leftBound = coord;
        }
    }
}

-(NSMutableArray *)convertRouteToLocationList:(Route *)route{
    NSMutableArray *locationList = [[NSMutableArray alloc] init];
    int legOrder = 0;
    for (RouteLeg *leg in route.routeLegs) {
        if (leg.legType == LegTypeOther) {
            
            RouteLegLocation *loc = [leg.legLocations objectAtIndex:0];
            loc.isHeaderLocation = YES;
            loc.locationLegType = leg.legType;
            [locationList addObject:loc];
            
            if (legOrder == route.routeLegs.count - 1) {
                RouteLegLocation *loc = [leg.legLocations lastObject];
                loc.isHeaderLocation = YES;
                loc.locationLegType = leg.legType;
                [locationList addObject:loc];
            }
        }else{
            int orderCount = 0;
            for (RouteLegLocation *loc in leg.legLocations) {
                if (orderCount == 0) {
                    loc.isHeaderLocation = YES;
                }else if (orderCount == leg.legLocations.count - 1 && legOrder == route.routeLegs.count - 1) {
                    loc.isHeaderLocation = YES;
                }else{
                    loc.isHeaderLocation = NO;
                    if (loc.name == nil || loc.name == (id)[NSNull null]) {
                        orderCount++;
                        continue;
                    }
                }
                
                if (orderCount == leg.legLocations.count - 1 && legOrder != route.routeLegs.count - 1) {
                    continue;
                }
                
                loc.locationLegType = leg.legType;
                loc.locationLegOrder = leg.legOrder;
                
                if (loc.isHeaderLocation || leg.showDetailed) {
                    [locationList addObject:loc];
                }
                
                if (loc.isHeaderLocation && leg.showDetailed){
                    //Also add a copy of the header location
                    if (loc.name == nil || loc.name == (id)[NSNull null]) {
                        orderCount++;
                        continue;
                    }
                    RouteLegLocation *copyLoc = [loc copy];
                    copyLoc.isHeaderLocation = NO;
                    [locationList addObject:copyLoc];
                }
                
//                if (leg.showDetailed) {
//                    [locationList addObject:loc];
//                    
//                    //Also add a copy of the header location
//                    if (loc.isHeaderLocation) {
//                        RouteLegLocation *copyLoc = [loc copy];
//                        copyLoc.isHeaderLocation = NO;
//                        [locationList addObject:copyLoc];
//                    }
//                }else if (loc.isHeaderLocation ){
//                    [locationList addObject:loc];
//                }
                
                orderCount++;
            }
        }
        
        legOrder++;
    }
    
    return locationList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showStopFromRoute"]) {
        
        NSString *stopCode, *stopShortCode, *stopName;
        CLLocationCoordinate2D stopCoords;
        if ([sender isKindOfClass:[self class]]) {
            stopCode = [NSString stringWithFormat:@"%ld", (long)[selectedAnnotionStopCode integerValue]];
            stopCoords = selectedAnnotationStopCoords;
            stopShortCode = selectedAnnotionStopShortCode;
            stopName = selectedAnnotionStopName;
        }else{
            NSIndexPath *selectedRowIndexPath = [routeListTableView indexPathForSelectedRow];
            RouteLocation * selected = [self.routeLocationList objectAtIndex:selectedRowIndexPath.row];
            stopCode = selected.stopCode;
            stopShortCode = selected.shortCode;
            stopName = selected.name;
            stopCoords = selected.coords;
        }
        
        if (stopCode != nil && ![stopCode isEqualToString:@""]) {
//            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
            
            StopViewController *stopViewController =(StopViewController *)segue.destinationViewController;
            stopViewController.stopCode = stopCode;
            stopViewController.stopShortCode = stopShortCode;
            stopViewController.stopName = stopName;
            stopViewController.stopCoords = stopCoords;
            stopViewController.stopEntity = nil;
//            stopViewController.modalMode = [NSNumber numberWithBool:NO];
            
            
            stopViewController.reittiDataManager = self.reittiDataManager;
            stopViewController.delegate = nil;
            
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionViewedAStop label:@"From route" value:nil];
            
            isShowingStopView = YES;
        }
    }
}

#pragma mark === UIViewControllerPreviewingDelegate Methods ===

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    
    NSString *stopCode, *stopShortCode, *stopName;
    CLLocationCoordinate2D stopCoords;
    
    UIView *view = [self.view hitTest:location withEvent:UIEventTypeTouches];
    if ([view isKindOfClass:[MKAnnotationView class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *)view;
        if ([annotationView.annotation isKindOfClass:[StopAnnotation class]])
        {
            StopAnnotation *stopAnnotation = (StopAnnotation *)annotationView.annotation;
            stopCode = [stopAnnotation.code stringValue];
            stopCoords = stopAnnotation.coordinate;
            stopShortCode = stopAnnotation.subtitle;
            stopName = stopAnnotation.title;
            
        }else if ([annotationView.annotation isKindOfClass:[LocationsAnnotation class]])
        {
            LocationsAnnotation *annotation = (LocationsAnnotation *)annotationView.annotation;
            if (annotation.locationType == StopLocation || annotation.locationType == OtherStopLocation) {
                stopCode = [annotation.code stringValue];
                stopCoords = annotation.coordinate;
                stopShortCode = annotation.subtitle;
                stopName = annotation.title;
            }else{
                return nil;
            }
            
        }else{
            return nil;
        }
    }else{
        //Could be coming from table view cell
        //Convert location to table view coordinate
        CGPoint locationInTableView = [self.view convertPoint:location toView:routeListTableView];
        
        NSIndexPath *selectedRowIndexPath = [routeListTableView indexPathForRowAtPoint:locationInTableView];
        
        UITableViewCell *cell = [routeListTableView cellForRowAtIndexPath:selectedRowIndexPath];
        if (cell){
            CGRect convertedRect = [cell.superview convertRect:cell.frame toView:self.view];
            previewingContext.sourceRect = convertedRect;
        }
        else
            return nil;
        
        if (selectedRowIndexPath && selectedRowIndexPath.row <= self.routeLocationList.count) {
            RouteLocation * selected = [self.routeLocationList objectAtIndex:selectedRowIndexPath.row];
            stopCode = selected.stopCode;
            stopShortCode = selected.shortCode;
            stopName = selected.name;
            stopCoords = selected.coords;
        }else{
            return nil;
        }
    }
    
    if (stopCode != nil && ![stopCode isEqualToString:@""]) {
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionUsed3DTouch label:@"Route Stop Preview" value:nil];
        
        StopViewController *stopViewController = (StopViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ASAStopViewController"];
        stopViewController.stopCode = stopCode;
        stopViewController.stopShortCode = stopShortCode;
        stopViewController.stopName = stopName;
        stopViewController.stopCoords = stopCoords;
        stopViewController.stopEntity = nil;
        //            stopViewController.modalMode = [NSNumber numberWithBool:NO];
        stopViewController.reittiDataManager = self.reittiDataManager;
        stopViewController.delegate = nil;
        
        //            isShowingStopView = YES;
        return stopViewController;
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    if ([viewControllerToCommit isKindOfClass:[StopViewController class]]) {
        [self.navigationController showViewController:viewControllerToCommit sender:nil];
        isShowingStopView = YES;
    }else if ([viewControllerToCommit isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewControllerToCommit;
        //        [navigationController setNavigationBarHidden:NO];
        [self showViewController:navigationController sender:nil];
    }else{
        [self showViewController:viewControllerToCommit sender:nil];
    }
}

-(void)registerFor3DTouchIfAvailable{
    // Register for 3D Touch Previewing if available
    if ([self isForceTouchAvailable])
    {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }else{
        NSLog(@"3D Touch is not available on this device.!");
        
        // handle a 3D Touch alternative (long gesture recognizer)
    }
}

- (BOOL)isForceTouchAvailable {
    BOOL isForceTouchAvailable = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        isForceTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return isForceTouchAvailable;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self isForceTouchAvailable]) {
        if (!self.previewingContext) {
            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    } else {
        if (self.previewingContext) {
            [self unregisterForPreviewingWithContext:self.previewingContext];
            self.previewingContext = nil;
        }
    }
}


@end
