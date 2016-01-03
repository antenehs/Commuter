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
#import "StopViewController.h"
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
    
//    nextRouteButton.layer.borderColor = [UIColor grayColor].CGColor;
//    nextRouteButton.layer.borderWidth = 0.5f;
//    nextRouteButton.layer.cornerRadius = 4.0f;
//    
//    previousRouteButton.layer.borderColor = [UIColor grayColor].CGColor;
//    previousRouteButton.layer.borderWidth = 0.5f;
//    previousRouteButton.layer.cornerRadius = 4.0f;
    
    [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:NO];
    currentLocationButton.hidden = YES;
    
    [self setNextAndPrevButtonStates];
    
    [self.navigationController setToolbarHidden:YES];
    self.title = @"";
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, [self isLandScapeOrientation] ? 20 : 40)];
    titleView.clipsToBounds = YES;
    
    NSMutableDictionary *toStringDict = [NSMutableDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-light" size:16] forKey:NSFontAttributeName];
    [toStringDict setObject:[UIColor lightGrayColor] forKey:NSForegroundColorAttributeName];
    
     NSMutableDictionary *addressStringDict = [NSMutableDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17] forKey:NSFontAttributeName];
    [addressStringDict setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    NSMutableAttributedString *toAddressString = [[NSMutableAttributedString alloc] initWithString:@"To " attributes:toStringDict];
    
    NSMutableAttributedString *addressString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",toLocation] attributes:addressStringDict];
    
    [toAddressString appendAttributedString:addressString];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 20)];
    label.attributedText = toAddressString;
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
    
    UIView *transportsView = [RouteViewManager viewForRoute:self.route longestDuration:[self.route.routeDurationInSeconds floatValue] width:self.view.frame.size.width - 150];
    
    [routeView addSubview:transportsView];
    routeView.contentSize = CGSizeMake(transportsView.frame.size.width, transportsView.frame.size.height);
    
    routeView.userInteractionEnabled = NO;
    [topViewBackView addGestureRecognizer:routeView.panGestureRecognizer];
    
    [timeIntervalLabel setText:[NSString stringWithFormat:@"leave at %@ ",
                                               [ReittiStringFormatter formatHourStringFromDate:self.route.getStartingTimeOfRoute]]];
    
        [arrivalTimeLabel setText:[NSString stringWithFormat:@"| arrive at %@",
                                   [ReittiStringFormatter formatHourStringFromDate:self.route.getEndingTimeOfRoute]]];
    
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
    
    NSString *codesString = [ReittiStringFormatter commaSepStringFromArray:lineCodes withSeparator:@"|"];
    
    [self.reittiDataManager fetchLinesForSearchTerm:codesString withCompletionBlock:^(NSArray *lines, NSString *searchTerm, NSString *errorString){
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
        
        if (leg.legType == LegTypeMetro || leg.legType == LegTypeTram) {
            [tempOthersArray addObject:leg.lineCode];
        }
    }
    
    if (tempTrainArray.count > 0) {
        self.reittiDataManager.vehicleFetchDelegate = self;
        [self.reittiDataManager fetchAllLiveVehiclesWithCodesFromPubTrans:tempTrainArray];
    }
    
    if (tempOthersArray.count > 0) {
        self.reittiDataManager.vehicleFetchDelegate = self;
        [self.reittiDataManager fetchAllLiveVehiclesWithCodesFromHSLLive:tempOthersArray];
    }
}

- (void)stopFetchingVehicles{
    //Remove all vehicle annotations
    [self.reittiDataManager stopFetchingLiveVehicles];
}

-(void)moveRouteViewToLocation:(RouteListViewLoaction)location animated:(BOOL)animated{
    if (animated) {
        [UIView transitionWithView:routeListView duration:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [self moveRouteViewToLocation:location];
            
        } completion:^(BOOL finished) {}];
    }else{
        [self moveRouteViewToLocation:location];
    }
}

-(void)moveRouteViewToLocation:(RouteListViewLoaction)location{
    currentRouteListViewLocation = location;
    
//    CGFloat tabBarHeight = self.tabBarController != nil ? self.tabBarController.tabBar.frame.size.height : 0;
    
    if (location == RouteListViewLoactionBottom) {
        [self hideNavigationBar:NO animated:YES];
        routeLIstViewVerticalSpacing.constant = self.view.frame.size.height - routeListTableView.frame.origin.y;
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
        [self hideNavigationBar:YES animated:YES];
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
    
    if (nextRouteButton.enabled)
        nextRouteButton.tintColor = [AppManager systemGreenColor];
    else
        nextRouteButton.tintColor = [UIColor lightGrayColor];
    
    if (previousRouteButton.enabled)
        previousRouteButton.tintColor = [AppManager systemGreenColor];
    else
        previousRouteButton.tintColor = [UIColor lightGrayColor];

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
    
    [routeMapView setRegion:region animated:YES];
    
    lowerBound = lowerBoundTemp;
    
    return toReturn;
}

- (void)drawLineForLeg:(RouteLeg *)leg {
    
    self.currentLeg = leg;
    int shapeCount = (int)leg.legShapeDictionaries.count;
    // create an array of coordinates from allPins
    CLLocationCoordinate2D coordinates[shapeCount + 2];
    int i = 0;
    CLLocationCoordinate2D lastCoord;
    CLLocationCoordinate2D firstCoord;
    for (NSDictionary *coordDict in leg.legShapeDictionaries) {
        CLLocationCoordinate2D coord = {.latitude =  [[coordDict objectForKey:@"y"] floatValue], .longitude =  [[coordDict objectForKey:@"x"] floatValue]};
        coordinates[i] = coord;
        if (i==0) {
            firstCoord = coord;
        }
        lastCoord = coord;
        i++;
    }
//    RouteLegLocation *loc1 = [leg.legLocations objectAtIndex:0];
//    CLLocationCoordinate2D legStartLoc = {.latitude =  [[loc1.coordsDictionary objectForKey:@"y"] floatValue], .longitude =  [[loc1.coordsDictionary objectForKey:@"x"] floatValue]};
//    
//    coordinates[i] = legStartLoc;
//    i++;
    
    RouteLegLocation *loc2 = [leg.legLocations lastObject];
    CLLocationCoordinate2D legEndLoc = {.latitude =  [[loc2.coordsDictionary objectForKey:@"y"] floatValue], .longitude =  [[loc2.coordsDictionary objectForKey:@"x"] floatValue]};
    
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
    /*
    if ([overlay isKindOfClass:MKPolyline.class]) {
        MKPolylineRenderer *lineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        lineView.lineWidth = 6;
        lineView.alpha = 0.8;
        if (currentLeg.legType == LegTypeWalk) {
            lineView.strokeColor = SYSTEM_BROWN_COLOR;
            lineView.lineDashPattern = @[@4, @10];
        }else if (currentLeg.legType == LegTypeBus){
            lineView.strokeColor = SYSTEM_BLUE_COLOR;
        }else if (currentLeg.legType == LegTypeTrain) {
            lineView.strokeColor = SYSTEM_RED_COLOR;
        }else if (currentLeg.legType == LegTypeTram) {
            lineView.strokeColor = SYSTEM_GREEN_COLOR;
        }else if (currentLeg.legType == LegTypeMetro) {
            lineView.strokeColor = SYSTEM_ORANGE_COLOR;
        }else if (currentLeg.legType == LegTypeFerry) {
            lineView.strokeColor = SYSTEM_CYAN_COLOR;
        }
        
        return lineView;
    }
     
    
    return nil;
     */
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
            
//        if (currentLeg.legType == LegTypeBus){
//            polylineRenderer.strokeColor = [AppManager systemBlueColor];
//        }else if (currentLeg.legType == LegTypeTrain) {
//            polylineRenderer.strokeColor = [AppManager systemRedColor];;
//        }else if (currentLeg.legType == LegTypeTram) {
//            polylineRenderer.strokeColor = [AppManager systemGreenColor];;
//        }else if (currentLeg.legType == LegTypeMetro) {
//            polylineRenderer.strokeColor = [AppManager systemOrangeColor];;
//        }else if (currentLeg.legType == LegTypeFerry) {
//            polylineRenderer.strokeColor = [AppManager systemCyanColor];;
//        }else{
//            polylineRenderer.strokeColor = [AppManager systemBlueColor];
//        }
        
        return polylineRenderer;
    } else {
        return nil;
    }
}

-(void)plotTransferAnnotation:(RouteLegLocation *)loc{
    
    CLLocationCoordinate2D coordinate = {.latitude =  [[loc.coordsDictionary objectForKey:@"y"] floatValue], .longitude =  [[loc.coordsDictionary objectForKey:@"x"] floatValue]};
    
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
//            NSLog(@"ploting location: %@", loc);
            CLLocationCoordinate2D coordinate = {.latitude =  [[loc.coordsDictionary objectForKey:@"y"] floatValue], .longitude =  [[loc.coordsDictionary objectForKey:@"x"] floatValue]};
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
    return [self zoomLevelForMapRect:routeMapView.visibleMapRect withMapViewSizeInPixels:routeMapView.bounds.size] > 15 && currentRouteListViewLocation == RouteListViewLoactionBottom;
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

-(void)plotVehicleAnnotations:(NSArray *)vehicleList isTrainVehicles:(BOOL)isTrain{
    
    NSMutableArray *codeList = [self collectVehicleCodes:vehicleList];
    
    NSMutableArray *annotToRemove = [[NSMutableArray alloc] init];
    
    NSMutableArray *existingVehicles = [[NSMutableArray alloc] init];
    
    for (id<MKAnnotation> annotation in routeMapView.annotations) {
        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            LVThumbnailAnnotation *annot = (LVThumbnailAnnotation *)annotation;
            
            if (isTrain) {
                if (annot.vehicleType != VehicleTypeTrain) {
                    continue;
                }
            }else{
                if (annot.vehicleType == VehicleTypeTrain) {
                    continue;
                }
            }
            
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
                annot.coordinate = vehicleToUpdate.coords;
                //                annot.thumbnail.bearing = [NSNumber numberWithDouble:vehicleToUpdate.bearing];
                [((NSObject<LVThumbnailAnnotationProtocol> *)annot) updateBearing:[NSNumber numberWithDouble:vehicleToUpdate.bearing]];
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
        vehicleAnT.image = [AppManager vehicleImageForVehicleType:vehicle.vehicleType];
        vehicleAnT.bearing = [NSNumber numberWithDouble:vehicle.bearing];
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
//        NSLog(@"Index path: %ld", (long)indexPath.row);
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
//    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (actionSheet.tag == 2001) {
//        NSString * timeToSetAlarm = [ReittiStringFormatter formatHourStringFromDate:self.route.getStartingTimeOfRoute];
        reittiRemindersManager.reminderMessageFormater = @"Get ready to leave in %d minutes.";
        switch (buttonIndex) {
            case 0:
                reittiRemindersManager.reminderMessageFormater = @"Get ready to leave in %d minute.";
                [self setReminderForOffset:1 andTime:self.route.getStartingTimeOfRoute];
                break;
            case 1:
                [self setReminderForOffset:5 andTime:self.route.getStartingTimeOfRoute];
                break;
            case 2:
                [self setReminderForOffset:10 andTime:self.route.getStartingTimeOfRoute];
                break;
            case 3:
                [self setReminderForOffset:15 andTime:self.route.getStartingTimeOfRoute];
                break;
            case 4:
                [self setReminderForOffset:30 andTime:self.route.getStartingTimeOfRoute];
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
    /*
    if (routeListViewIsGoingUp) {
        if (routeLIstViewVerticalSpacing.constant > (routeListView.frame.size.height / 1.33)) {
            [self moveRouteViewToLocation:RouteListViewLoactionMiddle animated:YES];
        }else if (routeLIstViewVerticalSpacing.constant > (routeListView.frame.size.height / 4)) {
            [self moveRouteViewToLocation:RouteListViewLoactionMiddle animated:YES];
        }else{
            [self moveRouteViewToLocation:RouteListViewLoactionTop animated:YES];
        }
    }else{
        if (routeLIstViewVerticalSpacing.constant > (routeListView.frame.size.height / 5)) {
            [self moveRouteViewToLocation:RouteListViewLoactionBottom animated:YES];
        }else{
            [self moveRouteViewToLocation:RouteListViewLoactionTop animated:YES];
        }
    }
     */
 
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
    RouteLegLocation *loc = [self.routeLocationList objectAtIndex:indexPath.row];
    RouteLeg *selectedLeg = [self.route.routeLegs objectAtIndex:loc.locationLegOrder];
    UITableViewCell *cell;
    if (loc.isHeaderLocation) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"legHeaderCell"];
//        NSLog(@"%@", cell.backgroundColor);
        
        UILabel *locNameLabel = (UILabel *)[cell viewWithTag:1002];
        UIImageView *legTypeImage = (UIImageView *)[cell viewWithTag:1001];
//        UIImageView *detailIndicatorImage = (UIImageView *)[cell viewWithTag:1004];
        UIButton *detailDesclosureButton = (UIButton *)[cell viewWithTag:1004];
        UILabel *lineNumberLabel = (UILabel *)[cell viewWithTag:1005];
        UILabel *moreInfoLabel = (UILabel *)[cell viewWithTag:1006];
        
        UIView *prevDottedLine = (UIView *)[cell viewWithTag:2005];
        UIView *nextDottedLine = (UIView *)[cell viewWithTag:2006];
        UIView *prevLegLine = (UIView *)[cell viewWithTag:2007];
        UIView *dotView = (UIView *)[cell viewWithTag:2009];
        UIView *nextLegLine = (UIView *)[cell viewWithTag:2008];
        
        UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 2, 100)];
        lineView.image = [UIImage asa_dottedLineImageWithFrame:lineView.frame andColor:[UIColor lightGrayColor]];
        [cell addSubview:lineView];
        
        prevLegLine.backgroundColor = [UIColor darkGrayColor];
        nextLegLine.backgroundColor = [UIColor darkGrayColor];
        dotView.backgroundColor = [UIColor whiteColor];
        dotView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        dotView.layer.borderWidth = 3.0;
        dotView.layer.cornerRadius = 6.f;
        
        if(selectedLeg.legType == LegTypeMetro){
            lineNumberLabel.text = @"Metro";
        }else if(selectedLeg.legType == LegTypeFerry){
            lineNumberLabel.text = @"Ferry";
        }else if(selectedLeg.legType == LegTypeTrain){
            lineNumberLabel.text = selectedLeg.lineName ? selectedLeg.lineName : selectedLeg.lineCode;
        }else if (selectedLeg.lineCode != nil) {
            lineNumberLabel.text = selectedLeg.lineName;
        }else {
            lineNumberLabel.text = @"";
        }
        
        if (indexPath.row == self.routeLocationList.count - 1) {
            locNameLabel.text = self.toLocation;
//            [legTypeImage setImage:[UIImage imageNamed:@"finish_flag-50.png"]];
//            detailIndicatorImage.hidden = YES;
            detailDesclosureButton.hidden = YES;
            nextLegLine.hidden = YES;
            nextDottedLine.hidden = YES;
            prevLegLine.hidden = NO;
            prevDottedLine.hidden = NO;
//            [cell addSubview:line];
//            line.frame = CGRectMake(0, 69.5, self.view.frame.size.width, 0.5);
            
        }else if (indexPath.row == 0) {
//            locNameLabel.text = @"Start location";
            locNameLabel.text = self.fromLocation;
//            detailIndicatorImage.hidden = NO;
            detailDesclosureButton.hidden = NO;
            nextLegLine.hidden = NO;
            nextDottedLine.hidden = NO;
            prevLegLine.hidden = YES;
            prevDottedLine.hidden = YES;
        }else{
            locNameLabel.text = loc.name == nil || loc.name == (id)[NSNull null] ? @"" : loc.name;
//            detailIndicatorImage.hidden = NO;
            detailDesclosureButton.hidden = NO;
            nextLegLine.hidden = NO;
            nextDottedLine.hidden = NO;
            prevLegLine.hidden = NO;
            prevDottedLine.hidden = NO;
//            [cell addSubview:line];
        }
        
        if (indexPath.row > 0) {
            RouteLegLocation *prevLoc = [self.routeLocationList objectAtIndex:indexPath.row - 1];
            switch (prevLoc.locationLegType) {
                case LegTypeWalk:
                    prevDottedLine.hidden = NO;
                    prevLegLine.hidden = YES;
                    break;
                    
                default:
                    prevDottedLine.hidden = YES;
                    prevLegLine.hidden = NO;
                    break;
            }
        }
        
        nextDottedLine.hidden = YES;
        nextLegLine.hidden = NO;
        
        [legTypeImage setImage:[AppManager vehicleImageForLegTrasnportType:loc.locationLegType]];
        if (loc.locationLegType == LegTypeWalk) {
            nextDottedLine.hidden = NO;
            nextLegLine.hidden = YES;
        }
        
        if (indexPath.row == self.routeLocationList.count - 1) {
            nextLegLine.hidden = YES;
            nextDottedLine.hidden = YES;
            [legTypeImage setImage:nil];
        }

        if (indexPath.row == self.routeLocationList.count - 1) {
            //Position the label in the middle
            moreInfoLabel.text = @"";
        }else if (selectedLeg.legType == LegTypeWalk) {
            moreInfoLabel.text = [NSString stringWithFormat:@"Walk %ld meters · %@", (long)[selectedLeg.legLength integerValue],[ReittiStringFormatter formatDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
        }else{
            NSString *destination = [self getDestinationForLineCode:selectedLeg.lineCode];
            NSString *stopsText = ([selectedLeg getNumberOfStopsInLeg] - 1) > 1 ? @"stops" : @"stop";
            if (destination != nil) {
                moreInfoLabel.text = [NSString stringWithFormat:@"%@ towards %@ · %d %@ · %@", selectedLeg.lineName, destination, [selectedLeg getNumberOfStopsInLeg] - 1, stopsText, [ReittiStringFormatter formatDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
            }else{
                moreInfoLabel.text = [NSString stringWithFormat:@"%@ · %d %@ · %@", selectedLeg.lineName, [selectedLeg getNumberOfStopsInLeg] - 1, stopsText, [ReittiStringFormatter formatDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
            }
        }
        
        [detailDesclosureButton setTitle:[self disclosureButtontextForLeg:selectedLeg] forState:UIControlStateNormal];
        detailDesclosureButton.userInteractionEnabled = NO;
        
        UILabel *startTimeLabel = (UILabel *)[cell viewWithTag:1003];
        startTimeLabel.text = [ReittiStringFormatter formatHourStringFromDate:loc.depTime];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }else if (!loc.isHeaderLocation) {
        if (loc.locationLegType == LegTypeWalk) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"legWalkLocationCell"];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"legstopLocationCell"];
        }
        
        UIView *typeLine = (UIView *)[cell viewWithTag:2001];
        UIView *dotView = (UIView *)[cell viewWithTag:2004];
        
        typeLine.backgroundColor = [UIColor darkGrayColor];
        dotView.backgroundColor = [UIColor darkGrayColor];
        
        dotView.layer.cornerRadius = 3.5f;
        
//        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *locNameLabel = (UILabel *)[cell viewWithTag:2002];
        if (loc.name == nil || loc.name == (id)[NSNull null]) {
            locNameLabel.text = @"";
        }else{
            locNameLabel.text = loc.name;
        }
        
        if (loc.locationLegType != LegTypeWalk) {
            UILabel *startTimeLabel = (UILabel *)[cell viewWithTag:2003];
            startTimeLabel.text = [ReittiStringFormatter formatHourStringFromDate:loc.depTime];
        }
        
        if (loc.stopCode == nil || loc.stopCode == (id)[NSNull null]){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
//    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RouteLegLocation *loc = [self.routeLocationList objectAtIndex:indexPath.row];
    
    if (loc.isHeaderLocation) {
        return 100.0;
    }else{
        return 25.0;
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

-(void)addTransportTypePictures{
    for (UIView *view in routeListView.subviews) {
        if (view.tag == 9999) {
            [view removeFromSuperview];
        }
    }

    for (int i = 0;i < self.routeLocationList.count;i++) {
        RouteLegLocation *loc = [self.routeLocationList objectAtIndex:i];
        RouteLeg *selectedLeg = [self.route.routeLegs objectAtIndex:loc.locationLegOrder];
        if (loc.isHeaderLocation) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            CGRect rect = [routeListTableView rectForRowAtIndexPath:indexPath];
            
            CGFloat height = loc.locationLegType == LegTypeWalk ? 24 : 45;
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, routeListTableView.frame.origin.y + rect.origin.y + rect.size.height - height/2 , 40, height)];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 24, 24)];
            
            switch (loc.locationLegType) {
                case LegTypeWalk:
                    [imageView setImage:[UIImage imageNamed:@"walking-black-75.png"]];
                    break;
                case LegTypeFerry:
                    [imageView setImage:[UIImage imageNamed:@"ferry-colored-75.png"]];
                    break;
                case LegTypeTrain:
                    [imageView setImage:[UIImage imageNamed:@"train-colored-75.png"]];
                    break;
                case LegTypeBus:
                    [imageView setImage:[UIImage imageNamed:@"bus-colored-75.png"]];
                    break;
                case LegTypeTram:
                    [imageView setImage:[UIImage imageNamed:@"tram-colored-75.png"]];
                    break;
                case LegTypeMetro:
                    [imageView setImage:[UIImage imageNamed:@"metro-colored-75.png"]];
                    break;
                    
                default:
                    break;
            }
            
            [routeListView addSubview:imageView];
            
            UILabel *lineNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 40, 20)];
            
            if(selectedLeg.legType == LegTypeMetro){
                lineNumberLabel.text = @"Metro";
            }else if(selectedLeg.legType == LegTypeFerry){
                lineNumberLabel.text = @"Ferry";
            }else if(selectedLeg.legType == LegTypeTrain){
//                NSString *unformattedTrainNumber = [ReittiStringFormatter parseBusNumFromLineCode:selectedLeg.lineCode];
//                NSString *unformattedTrainNumber = selectedLeg.lineName ? selectedLeg.lineName : selectedLeg.lineCode;
//                NSString *filteredOnce = [unformattedTrainNumber
//                                          stringByReplacingOccurrencesOfString:@"01" withString:@""];
                lineNumberLabel.text = selectedLeg.lineName ? selectedLeg.lineName : selectedLeg.lineCode;
            }else if (selectedLeg.lineCode != nil) {
                lineNumberLabel.text = selectedLeg.lineName;
            }else {
                lineNumberLabel.text = @"";
            }
            
            [lineNumberLabel sizeToFit];
            lineNumberLabel.textAlignment = NSTextAlignmentCenter;
            lineNumberLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
            lineNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
            
            [view addSubview:lineNumberLabel];
            
            view.tag = 9999;
//            view.backgroundColor = [UIColor lightGrayColor];
            
            [routeListView addSubview:view];
        }
    }
}

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

#pragma mark - Reitti data manager delegates
- (void)vehiclesFetchCompleteFromHSlLive:(NSArray *)vehicleList{
    [self plotVehicleAnnotations:vehicleList isTrainVehicles:NO];
}
- (void)vehiclesFetchFromHSLFailedWithError:(NSError *)error{
    
}
- (void)vehiclesFetchCompleteFromPubTrans:(NSArray *)vehicleList{
    [self plotVehicleAnnotations:vehicleList isTrainVehicles:YES];
}
- (void)vehiclesFetchFromPubTransFailedWithError:(NSError *)error{
    
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
            stopCoords = CLLocationCoordinate2DMake([[selected.coordsDictionary objectForKey:@"y"] floatValue],[[selected.coordsDictionary objectForKey:@"x"] floatValue]);
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
            stopCoords = CLLocationCoordinate2DMake([[selected.coordsDictionary objectForKey:@"y"] floatValue],[[selected.coordsDictionary objectForKey:@"x"] floatValue]);
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
