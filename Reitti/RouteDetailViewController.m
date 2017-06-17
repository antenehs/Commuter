//
//  RouteDetailViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RouteDetailViewController.h"
#import "ReittiStringFormatter.h"
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
#import "BikeStation.h"
#import "ReittiModels.h"
#import "WatchCommunicationManager.h"
#import "MappingExtensions.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

typedef void (^AlertControllerAction)(UIAlertAction *alertAction);
typedef AlertControllerAction (^ActionGenerator)(int minutes);

@interface RouteDetailViewController ()

@property (nonatomic) NSArray<id<UIPreviewActionItem>> *previewActions;
@property (nonatomic, strong) id previewingContext;

@property (strong, nonatomic) NSArray * allBikeStations;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;
@property (strong, nonatomic) MapViewManager *mapViewManager;

@end

@implementation RouteDetailViewController

#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];
#define SYSTEM_ORANGE_COLOR [UIColor colorWithRed:230.0/255.0 green:126.0/255.0 blue:34.0/255.0 alpha:1.0];
#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
#define SYSTEM_RED_COLOR [UIColor redColor];
#define SYSTEM_BROWN_COLOR [UIColor brownColor];
#define SYSTEM_CYAN_COLOR [UIColor cyanColor];

@synthesize route = _route, selectedRouteIndex,routeList, lineDetailMap;;
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
    
    mapViewCenterLocation = MapViewCenterLocationCenter;
    
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
    
    UISwipeGestureRecognizer *recogLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeftDetected:)];
    recogLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
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
    [self moveRouteViewToLocation:RouteListViewLoactionBottom andFitRouteToMap:YES animated:NO];
    
    /* Register 3D touch for Peek and Pop if available */
    [self registerFor3DTouchIfAvailable];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!isShowingStopView){
        isShowingStopView = NO;
        [self moveRouteViewToLocation:RouteListViewLoactionMiddle andFitRouteToMap:YES animated:YES];
        [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (isShowingStopView){
        //Reset view to what it was before becuase when going to stopview, navigation bar is
        //enabled.
        [self moveRouteViewToLocation:currentRouteListViewLocation animated:NO];
    }
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    if (self.tabBarController) {
        [self.tabBarController.tabBar setHidden:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.reittiDataManager stopUpdatingBikeStations];
    [self stopFetchingVehicles];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self hideNavigationBar:NO animated:NO];
    [self moveRouteViewToLocation:currentRouteListViewLocation animated:NO];
    [self setUpMainViewForRoute];
}

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
    
    self.settingsManager = [SettingsManager sharedManager];
    self.mapViewManager = [MapViewManager managerForMapView:routeMapView];
    self.mapViewManager.delegate = self;
    
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] init];
    }
}

- (void)initMapViewForRoute:(Route *)route{
    [routeMapView removeOverlays:routeMapView.overlays];
    [routeMapView removeAnnotations:routeMapView.annotations];
    for (RouteLeg *leg in route.routeLegs) {
        [self drawLineForLeg:leg];
        [self drawFullLineShapeForLeg:leg];
        [self plotTransferAnnotationsForLeg:leg];
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
    [self startFetchingBikeStations];
    
    [self setupRoutePreviewView];
    
    [timeIntervalLabel setText:[NSString stringWithFormat:@"leave at %@ ",
                                               [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:self.route.startingTimeOfRoute]]];
    
        [arrivalTimeLabel setText:[NSString stringWithFormat:@"| arrive at %@",
                                   [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:self.route.endingTimeOfRoute]]];
    
    UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, routeListView.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor lightGrayColor];
//    [routeListView addSubview:topLine];
    
    [routeListTableView reloadData];
//    [self addTransportTypePictures];
    
    [self sendRouteToWatch:self.route];
}

- (void)setupRoutePreviewView {
    for (UIView *view in routeView.subviews) {
        [view removeFromSuperview];
    }
    
    for (RouteLeg *leg in self.route.routeLegs) {
        if (!leg.lineName || [leg.lineName isEqualToString:@"-"] || [leg.lineName isEqualToString:@""]) {
            NSString *codeFromLineDetail = [self getLineShortCodeForLineCode:leg.lineCode];
            if (codeFromLineDetail)
                leg.lineName = codeFromLineDetail;
        }
    }
    
    UIView *transportsView = [RouteViewManager viewForRoute:self.route longestDuration:[self.route.routeDurationInSeconds floatValue] width:self.view.frame.size.width - 150 alwaysShowVehicle:NO];
    
    [routeView addSubview:transportsView];
    routeView.contentSize = CGSizeMake(transportsView.frame.size.width, transportsView.frame.size.height);
    
    routeView.userInteractionEnabled = NO;
    [topViewBackView addGestureRecognizer:routeView.panGestureRecognizer];
}

- (void)sendRouteToWatch:(Route *)route {
    if (!route) return;
    
    route.fromLocationName = fromLocation;
    route.toLocationName = toLocation;
    NSDictionary *routeDict = [route dictionaryRepresentation];
    if (!routeDict) return;
    
    [[WatchCommunicationManager sharedManager] transferRoutes:@[routeDict]];
}

//Line maps should come from routeSearchView. Search here if they didn't
- (void)fetchLineDetailsForRoute:(Route *)aRoute{
    
    if (!aRoute || !aRoute.routeLegs)
        return;
    
    if (!lineDetailMap) lineDetailMap = [@{} mutableCopy];
    
    NSMutableArray *lineCodes = [@[] mutableCopy];
    for (RouteLeg *leg in aRoute.routeLegs) {
        if (leg.lineCode && leg.lineCode.length > 0 && ![lineDetailMap objectForKey:leg.lineCode])
            [lineCodes addObject:leg.lineCode];
    }
    
    if (lineCodes.count < 1)
        return;
    
    if (self.useApi == ReittiAutomaticApi) self.useApi = ReittiCurrentRegionApi;
    
    [self.reittiDataManager fetchLinesForLineCodes:lineCodes fetchFromApi:self.useApi withCompletionBlock:^(NSArray *lines, NSString *searchTerm, NSString *errorString){
        if (!errorString) {
            [self populateLineDetailMapFromLines:lines];
            [routeListTableView reloadData];
            [self setupRoutePreviewView];
        }
    }];
}

#warning Might be obsolete with DigiTransit
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

#warning Might be obsolete with DigiTransit
- (NSString *)getDestinationForLineCode:(NSString *)code{
    if (!code)
        return nil;
    NSAssert(false, @"");
    Line *detailLine = [lineDetailMap objectForKey:code];
    
    if (detailLine)
        return detailLine.lineEnd;
    
    return nil;
}

#warning Might be obsolete with DigiTransit
- (NSString *)getLineShortCodeForLineCode:(NSString *)code{
    if (!code)
        return nil;
    
    NSAssert(false, @"");
    Line *detailLine = [lineDetailMap objectForKey:code];
    
    if (detailLine)
        return detailLine.codeShort;
    
    return nil;
}

-(void)dealloc {
    
}

- (void)startFetchingVehicles {
    //Start fetching vehicle locations for route
    NSMutableArray *tempTrainArray = [@[] mutableCopy];
    NSMutableArray *tempOthersArray = [@[] mutableCopy];
    for (RouteLeg *leg in self.route.routeLegs) {
        if (leg.legType == LegTypeTrain) {
            [tempTrainArray addObject:leg.lineCode];
        }
        
        if (leg.legType == LegTypeMetro || leg.legType == LegTypeTram || leg.legType == LegTypeBus || leg.legType == LegTypeFerry ) {
            if (leg.lineCode)
                [tempOthersArray addObject:leg.lineCode];
        }
    }
    
    [self.reittiDataManager fetchAllLiveVehiclesWithCodes:tempOthersArray andTrainCodes:tempTrainArray withCompletionHandler:^(NSArray *vehicleList, NSString *errorString){
        [self.mapViewManager plotVehicleAnnotations:vehicleList];
    }];
}

- (void)stopFetchingVehicles{
    //Remove all vehicle annotations
    [self.reittiDataManager stopFetchingLiveVehicles];
}

//Bike stations needs to be updated constantly to get available bikes
- (void)startFetchingBikeStations {
    [self.reittiDataManager startFetchingBikeStationsWithCompletionBlock:^(NSArray *bikeStations, NSString *errorString){
        if (!errorString && bikeStations && bikeStations.count > 0) {
            self.allBikeStations = bikeStations;
            [self plotBikeStationAnnotations:bikeStations];
        }
    }];
}

-(void)moveRouteViewToLocation:(RouteListViewLoaction)location animated:(BOOL)animated{
    [self moveRouteViewToLocation:location andFitRouteToMap:NO animated:animated];
}

-(void)moveRouteViewToLocation:(RouteListViewLoaction)location andFitRouteToMap:(BOOL)fitMap animated:(BOOL)animated {
    [UIView transitionWithView:routeListView duration:animated ? 0.2 : 0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self moveRouteViewToLocation:location andFitRouteToMap:fitMap];
        
    } completion:^(BOOL finished) {}];
}

-(void)moveRouteViewToLocation:(RouteListViewLoaction)location andFitRouteToMap:(BOOL)fitMap{
    currentRouteListViewLocation = location;

    if (location == RouteListViewLoactionBottom) {
        [self hideNavigationBar:NO animated:YES];
        routeLIstViewVerticalSpacing.constant = self.view.frame.size.height - routeListTableView.frame.origin.y + 15;
        [toggleListButton setTitle:@"List" forState:UIControlStateNormal];
        [toggleListArrowButton setImage:[UIImage imageNamed:@"expand-arrow-50.png"] forState:UIControlStateNormal];
    }else if (location == RouteListViewLoactionMiddle) {
        [self hideNavigationBar:NO animated:YES];
        routeLIstViewVerticalSpacing.constant = self.view.frame.size.height/2;
        [toggleListButton setTitle:@"List" forState:UIControlStateNormal];
        [toggleListArrowButton setImage:[UIImage imageNamed:@"horizontal-line-100.png"] forState:UIControlStateNormal];
        routeListTableView.frame = CGRectMake(routeListTableView.frame.origin.x, routeListTableView.frame.origin.y, routeListTableView.frame.size.width,self.view.bounds.size.height/2 - routeListTableView.frame.origin.y);
    }else{
        routeLIstViewVerticalSpacing.constant = 0;
        routeListTableView.frame = CGRectMake(routeListTableView.frame.origin.x, routeListTableView.frame.origin.y, routeListTableView.frame.size.width, self.view.bounds.size.height - routeListTableView.frame.origin.y);
        [toggleListButton setTitle:@"Map" forState:UIControlStateNormal];
        [toggleListArrowButton setImage:[UIImage imageNamed:@"collapse-arrow-100.png"] forState:UIControlStateNormal];
        [self hideNavigationBar:![self isLandScapeOrientation] animated:YES];
    }
    
    [self.view layoutIfNeeded];
    if (fitMap) {
        [self centerMapRegionToViewRoute];
    } else {
        [self adjustMapViewCenterForCurrentListViewPosition];
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
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentUserLocation = [locations lastObject];
    
    currentLocationButton.hidden = NO;
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
    } completion:^(BOOL finished) {}];
    
    return toReturn;
}

//Call this only when location is changed
-(void)adjustMapViewCenterForCurrentListViewPosition {
    CLLocationCoordinate2D currentCenter = routeMapView.centerCoordinate;
    
    MKCoordinateSpan span = routeMapView.region.span;
    double centerDelta = span.latitudeDelta/4;
    
    if (currentRouteListViewLocation == RouteListViewLoactionMiddle && mapViewCenterLocation != MapViewCenterLocationShiftedUp) {
        currentCenter.latitude =  currentCenter.latitude - centerDelta;
        mapViewCenterLocation = MapViewCenterLocationShiftedUp;
    } else if(currentRouteListViewLocation == RouteListViewLoactionBottom && mapViewCenterLocation != MapViewCenterLocationCenter) {
        currentCenter.latitude =  currentCenter.latitude + centerDelta;
        mapViewCenterLocation = MapViewCenterLocationCenter;
    } else {
        return;
    }
    
    MKCoordinateRegion region = {currentCenter, span};
    
    [UIView animateWithDuration:0.7 animations:^{
        [routeMapView setRegion:region animated:YES];
    } completion:^(BOOL finished) {}];
}

-(BOOL)centerMapRegionToViewRoute {
    
    BOOL toReturn = YES;
    
    CLLocationCoordinate2D lowerBoundTemp = lowerBound;
    
    if (currentRouteListViewLocation == RouteListViewLoactionMiddle) {
        float latBoundSpan = upperBound.latitude - lowerBound.latitude;
        lowerBound.latitude =  lowerBound.latitude - (latBoundSpan);
        mapViewCenterLocation = MapViewCenterLocationShiftedUp;
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

#pragma mark - Draw polylines

-(void)drawLineForLeg:(RouteLeg *)leg {
    if (leg.legShapeCoordLocations.count < 2) return;
    
    self.currentLeg = leg;
    int shapeCount = (int)leg.legShapeCoordLocations.count;

    CLLocationCoordinate2D coordinates[shapeCount];
    
    for (int i = 0; i < shapeCount ; i++) {
        coordinates[i] = [leg.legShapeCoordLocations[i] coordinate];
    }
    
    [self evaluateBoundsForCoordsArray:coordinates andCount:shapeCount];
    
    ReittiPolyline *polyline = [leg mapPolyline];
    
    [self.mapViewManager drawPolyline:polyline];
}

-(void)drawFullLineShapeForLeg:(RouteLeg *)leg {
    if (!leg || leg.legType == LegTypeWalk || !leg.fullLineShapeLocations) return;
    
    ReittiPolyline *polyline = [leg fullLinePolyline];
    if (polyline) [self.mapViewManager drawPolyline:polyline];
}

#pragma mark - Plot annotations

-(void)plotTransferAnnotationsForLeg:(RouteLeg *)leg {
    if (leg.legType != LegTypeWalk && leg.legLocations && leg.legLocations.count > 0) {
        [self plotTransferAnnotation:[leg.legLocations firstObject]];
        if (leg.legOrder != self.route.routeLegs.count) {
            [self plotTransferAnnotation:[leg.legLocations lastObject]];
        }
    }
}

-(void)plotTransferAnnotation:(RouteLegLocation *)loc {
    LocationsAnnotation *annotation = (LocationsAnnotation *)loc.mapAnnotation;
    annotation.calloutAccessoryAction = ^(MKAnnotationView *annotationView){
        [self calloutAccessoryControlTappedOnAnnotationView: annotationView];
    };
    if (annotation) [self.mapViewManager plotAnnotations:@[annotation]];
}

-(void)plotLocationsAnnotation:(Route *)route{
    int count = 0;
    for (RouteLeg *leg in route.routeLegs) {
       
        int locCount = 0;
        for (RouteLegLocation *loc in leg.legLocations) {
            if (count == 0 && locCount == 0) {
                LocationsAnnotation *startAnnotation = (LocationsAnnotation *)loc.routeStartLocationAnnotation;
                startAnnotation.preferedSize = CGSizeMake(16, 16);
                if (startAnnotation) [self.mapViewManager plotAnnotations:@[startAnnotation]];
            }
            
            if (count == route.routeLegs.count - 1 && locCount == leg.legLocations.count - 1) {
                LocationsAnnotation *endAnnotation = (LocationsAnnotation *)loc.routeEndLocationAnnotation;
                endAnnotation.preferedSize = CGSizeMake(30, 30);
                endAnnotation.imageCenterOffset = CGPointMake(5, -15);
                if (endAnnotation) [self.mapViewManager plotAnnotations:@[endAnnotation]];
            }
            
            if (leg.legType != LegTypeWalk && locCount != 0 && locCount != leg.legLocations.count - 1) {
                if (loc.shortCode != nil) {
                    LocationsAnnotation *annotation = (LocationsAnnotation *)loc.mapAnnotation;
                    if (annotation) {
                        annotation.locationType = StopLocation;
                        annotation.imageCenterOffset = CGPointMake(0, -15);
                        annotation.shrinksWhenZoomedOut = YES;
                        annotation.calloutAccessoryAction = ^(MKAnnotationView *annotationView){
                            [self calloutAccessoryControlTappedOnAnnotationView: annotationView];
                        };
                        [self.mapViewManager plotAnnotations:@[annotation]];
                    }
                }
            }
            
            locCount++;
        }
        count++;
    }
}

-(void)plotBikeStationAnnotations:(NSArray *)stationList{
//    if (![self shouldShowOtherStopAnnotations]) return;
    
    if (!stationList || stationList.count == 0) return;
    
    [self removeAllBikeStationAnnotations];
    
    for (BikeStation *station in stationList) {
        LocationsAnnotation *stationAnnotation = (LocationsAnnotation *)station.mapAnnotation;
        stationAnnotation.preferedSize = CGSizeMake(16, 25);
        stationAnnotation.imageCenterOffset = CGPointMake(0, -8);
        stationAnnotation.shrinksWhenZoomedOut = YES;
        stationAnnotation.shrinkingZoomLevel = 16;
        stationAnnotation.disappearsWhenZoomedOut = YES;
        stationAnnotation.disappearingZoomLevel = 15;
        
        if (stationAnnotation) [self.mapViewManager plotAnnotations:@[stationAnnotation]];
    }
}

-(void)plotOtherStopAnnotationsForStops:(NSArray *)stopList {
    NSMutableArray *allAnots = [@[] mutableCopy];
    for (BusStop *stop in stopList) {
        if ([self isOtherStopOneOfTheLocationStops:stop]) continue;
        
        LocationsAnnotation *newAnnotation = (LocationsAnnotation *)[stop basicLocationAnnotation];
        newAnnotation.locationType = OtherStopLocation;
        newAnnotation.preferedSize = CGSizeMake(16, 25);
        newAnnotation.imageCenterOffset = CGPointMake(0, -8);
        newAnnotation.shrinksWhenZoomedOut = YES;
        newAnnotation.shrinkingZoomLevel = 16;
        newAnnotation.disappearsWhenZoomedOut = YES;
        newAnnotation.disappearingZoomLevel = 14;
        
        newAnnotation.calloutAccessoryAction = ^(MKAnnotationView *annotationView){
            [self calloutAccessoryControlTappedOnAnnotationView: annotationView];
        };
        if (newAnnotation) [allAnots addObject:newAnnotation];
    }
    
    [self.mapViewManager plotOnlyNewAnnotations:allAnots forAnnotationType:OtherStopLocation];

}

//-(MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
//    if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
//        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
//        if (locAnnotation.locationType == DestinationLocation) {
//            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:locAnnotation.annotIdentifier];
//            if (annotationView == nil) {
//                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:locAnnotation.annotIdentifier];
//                annotationView.enabled = YES;
//                
//                annotationView.canShowCallout = YES;
//                
//            } else {
//                annotationView.annotation = annotation;
//            }
//            
//            annotationView.image = [UIImage imageNamed:locAnnotation.imageNameForView];
//            [annotationView setFrame:CGRectMake(0, 0, 30, 30)];
//            annotationView.centerOffset = CGPointMake(5,-15);
//            
//            return annotationView;
//        }
//        else
//        if (locAnnotation.locationType == StartLocation){
//            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:locAnnotation.annotIdentifier];
//            if (annotationView == nil) {
//                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:locAnnotation.annotIdentifier];
//                annotationView.enabled = YES;
//                
//                annotationView.canShowCallout = YES;
//                
//            } else {
//                annotationView.annotation = annotation;
//            }
//            
//            annotationView.image = [UIImage imageNamed:locAnnotation.imageNameForView];
//            [annotationView setFrame:CGRectMake(0, 0, 16, 16)];
//            
//            return annotationView;
//        }else
//        if (locAnnotation.locationType == StopLocation || locAnnotation.locationType == TransferStopLocation || locAnnotation.locationType == OtherStopLocation){
//            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:locAnnotation.annotIdentifier];
//            if (annotationView == nil) {
//                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:locAnnotation.annotIdentifier];
//                annotationView.enabled = YES;
//                
//                annotationView.canShowCallout = YES;
//                if (locAnnotation.code != nil && locAnnotation.code != (id)[NSNull null]) {
//                    annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//                }
//                
//            } else {
//                annotationView.annotation = annotation;
//            }
//            
//            annotationView.image = [UIImage imageNamed:locAnnotation.imageNameForView];
//            
//            if (locAnnotation.locationType == StopLocation || locAnnotation.locationType == TransferStopLocation) {
//                [annotationView setFrame:CGRectMake(0, 0, 28, 42)];
//                annotationView.centerOffset = CGPointMake(0,-15);
//            } else {
//                [annotationView setFrame:CGRectMake(0, 0, 16, 25)];
//                annotationView.centerOffset = CGPointMake(0,-8);
//            }
//
//            return annotationView;
//        } else if (locAnnotation.locationType == BikeStationLocation){
//            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:locAnnotation.annotIdentifier];
//            if (annotationView == nil) {
//                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:locAnnotation.annotIdentifier];
//                annotationView.enabled = YES;
//                
//                annotationView.canShowCallout = YES;
//                if (locAnnotation.code != nil && locAnnotation.code != (id)[NSNull null]) {
//                    annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//                }
//                
//            } else {
//                annotationView.annotation = annotation;
//            }
//            
//            annotationView.image = [UIImage imageNamed:locAnnotation.imageNameForView];
//            [annotationView setFrame:CGRectMake(0, 0, 16, 25)];
//            annotationView.centerOffset = CGPointMake(0,-8);
//            
//            return annotationView;
//        }
//    }
    
//    if ([annotation conformsToProtocol:@protocol(LVThumbnailAnnotationProtocol)]) {
//        return [((NSObject<ReittiAnnotationProtocol> *)annotation) annotationViewInMap:routeMapView];
//    }
    
//    return nil;
//}

//-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
//{
//    id <MKAnnotation> annotation = [view annotation];
//    NSString *stopCode;
//    NSString *stopShortCode, *stopName;
//    CLLocationCoordinate2D stopCoords;
////    if ([annotation isKindOfClass:[StopAnnotation class]])
////    {
////        StopAnnotation *stopAnnotation = (StopAnnotation *)annotation;
////        stopCode = stopAnnotation.code;
////        stopCoords = stopAnnotation.coordinate;
////        stopShortCode = stopAnnotation.subtitle;
////        stopName = stopAnnotation.title;
////        
////    }else
//    if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
//        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
//        stopCode = locAnnotation.code;
//        stopCoords = locAnnotation.coordinate;
//        stopShortCode = locAnnotation.subtitle;
//        stopName = locAnnotation.title;
//    }else{
//        return;
//    }
//    
//    if (stopCode != nil && stopCode != (id)[NSNull null]) {
//        selectedAnnotionStopCode = stopCode;
//        selectedAnnotationStopCoords = stopCoords;
//        selectedAnnotionStopShortCode = stopShortCode;
//        selectedAnnotionStopName = stopName;
//        [self performSegueWithIdentifier:@"showStopFromRoute" sender:self];
//    }
//    
//}

-(void)calloutAccessoryControlTappedOnAnnotationView:(MKAnnotationView *)view {
    id <MKAnnotation> annotation = [view annotation];
    NSString *stopCode;
    NSString *stopShortCode, *stopName;
    CLLocationCoordinate2D stopCoords;
    
    if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
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

//-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
//    previousRegion = mapView.visibleMapRect;
//}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //Show detailed stop annotations when the zoom level is more than or equal to 14
//    if ([self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size] != [self zoomLevelForMapRect:previousRegion withMapViewSizeInPixels:mapView.bounds.size]) {
//        [self removeAnnotationsExceptVehicles];
//        [self plotLocationsAnnotation:self.route];
//        
//        [mapView removeOverlays:mapView.overlays];
//        
//        for (RouteLeg *leg in self.route.routeLegs) {
//            [self drawLineForLeg:leg];
//            [self plotTransferAnnotationsForLeg:leg];
//        }
//    }
//    
//    if ([self shouldShowOtherStopAnnotations]) {
//        [self.reittiDataManager fetchStopsInAreaForRegion:routeMapView.region fetchFromApi:self.useApi withCompletionBlock:^(NSArray *stops, NSString *error){
//            if (!error) {
//                [self plotOtherStopAnnotationsForStops:stops];
//            }
//        }];
//        
//        if (self.allBikeStations && !isShowingBikeAnnotations)
//            [self plotBikeStationAnnotations:self.allBikeStations];
//    }else{
//        isShowingBikeAnnotations = NO;
//    }
    
    [self.reittiDataManager fetchStopsInAreaForRegion:routeMapView.region fetchFromApi:self.useApi withCompletionBlock:^(NSArray *stops, NSString *error){
        if (!error) {
            [self plotOtherStopAnnotationsForStops:stops];
        }
    }];
    
    
    [self plotBikeStationAnnotations:self.allBikeStations];
    
    
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

-(BOOL)isOtherStopOneOfTheLocationStops:(BusStop *)stop{
    for (RouteLeg *leg in self.route.routeLegs) {
        for (RouteLegLocation *loc in leg.legLocations) {
            if (loc.shortCode == stop.codeShort) {
                return YES;
            }
        }
    }
    
    return NO;
}

//-(BOOL)shouldShowStopAnnotations {
//    return [self zoomLevelForMapRect:routeMapView.visibleMapRect withMapViewSizeInPixels:routeMapView.bounds.size] >= 13;
//}

//-(BOOL)shouldShowOtherStopAnnotations{
//    //15 is the level the current user location is displayed. Have to zoom more to view the other stops.
////    return [self zoomLevelForMapRect:routeMapView.visibleMapRect withMapViewSizeInPixels:routeMapView.bounds.size] > 14 && currentRouteListViewLocation == RouteListViewLoactionBottom;
//    
//    return YES;
//}
//Stop locations are the stops in legs. Not transfer locations
-(void)removeAllNonTransferStopLocationAnnotations {
    [self.mapViewManager removeAllReittiAnotationsOfType:StopLocation];
}

-(void)removeAllOtherStopAnnotations {
    [self.mapViewManager removeAllReittiAnotationsOfType:OtherStopLocation];
}

-(void)removeAllBikeStationAnnotations {
    [self.mapViewManager removeAllReittiAnotationsOfType:BikeStationLocation];
//    isShowingBikeAnnotations = NO;
}

-(void)removeAnnotationsExceptVehicles {
    [self.mapViewManager removeAllAnotationsExceptOfType:[LVThumbnailAnnotation class]];

//    isShowingBikeAnnotations = NO;
}

-(NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels {
    NSUInteger zoomLevel = 20; // MAXIMUM_ZOOM is 20 with MapKit
    MKZoomScale zoomScale = mRect.size.width / viewSizeInPixels.width; //MKZoomScale is just a CGFloat typedef
    double zoomExponent = log2(zoomScale);
    zoomLevel = (NSUInteger)(20 - ceil(zoomExponent));
    return zoomLevel;
}

#pragma mark - Peek and Pop actions support
-(NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    return self.previewActions;
}

-(NSArray<id<UIPreviewActionItem>> *)previewActions {
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
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"When do you want to be reminded." message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    ActionGenerator actionGenerator = ^(int minutes){
        return ^(UIAlertAction *alertAction) {
            [self setReminderForRouteWithOfset:minutes];
            
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSetRouteReminder label:[NSString stringWithFormat:@"%d min", minutes] value:nil];
        };
    };
    
    UIAlertAction *action1min = [UIAlertAction actionWithTitle:@"1 min before" style:UIAlertActionStyleDefault handler:actionGenerator(1)];
    UIAlertAction *action5min = [UIAlertAction actionWithTitle:@"5 min before" style:UIAlertActionStyleDefault handler:actionGenerator(5)];
    UIAlertAction *action10min = [UIAlertAction actionWithTitle:@"10 min before" style:UIAlertActionStyleDefault handler:actionGenerator(10)];
    UIAlertAction *action15min = [UIAlertAction actionWithTitle:@"15 min before" style:UIAlertActionStyleDefault handler:actionGenerator(15)];
    UIAlertAction *action30min = [UIAlertAction actionWithTitle:@"30 min before" style:UIAlertActionStyleDefault handler:actionGenerator(30)];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction){}];
    
    [alertController addAction:action1min];
    [alertController addAction:action5min];
    [alertController addAction:action10min];
    [alertController addAction:action15min];
    [alertController addAction:action30min];
    
    NSArray *existingNotifs = [[ReittiRemindersManager sharedManger] getRouteNotificationsForRoute:self.route];
    if (existingNotifs && existingNotifs.count > 0) {
        UIAlertAction *deleteExisting = [UIAlertAction actionWithTitle:@"Cancel Current Reminders" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [[ReittiRemindersManager sharedManger] cancelNotifications:existingNotifs];
        }];
        
        [alertController addAction:deleteExisting];
    }
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)setReminderForRouteWithOfset:(int)offset {
    [[ReittiRemindersManager sharedManger] setNotificationForRoute:self.route withMinOffset:offset];
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

-(void)snapRouteListView {
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
//    UIColor *darkerGrayColor = [UIColor darkGrayColor];
    
    RouteLegLocation *loc = [self.routeLocationList objectAtIndex:indexPath.row];
    RouteLeg *selectedLeg = [self.route.routeLegs objectAtIndex:loc.locationLegOrder];
    
    UIColor *darkerGrayColor = [AppManager colorForLegType:selectedLeg.legType];
    
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
        startTimeLabel.text = [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:loc.depTime];
        
        UIImage *image = [AppManager lightColorImageForLegTransportType:loc.locationLegType];
        if (selectedLeg.legType != LegTypeMetro)
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [legTypeImage setImage:image];
        legTypeImage.contentMode = UIViewContentModeScaleAspectFill;
        if (selectedLeg.legType != LegTypeWalk)
            legTypeImage.tintColor = [UIColor whiteColor];
        else
            legTypeImage.tintColor = [UIColor darkGrayColor];
        
        dotView.backgroundColor = [UIColor whiteColor];
        dotView.layer.borderColor = [darkerGrayColor CGColor];
        dotView.layer.borderWidth = 3.0;
        dotView.layer.cornerRadius = 6.f;
        
        transportCircleBackView.layer.cornerRadius = 15.5f;
        transportCircleBackView.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
        
        prevLegLine.backgroundColor = darkerGrayColor;
        nextLegLine.backgroundColor = darkerGrayColor;
        
        moreInfoLabel.textColor = [UIColor darkGrayColor];
        
        if (indexPath.row == 0) {
            locNameLabel.text = self.fromLocation;
            detailDesclosureButton.hidden = selectedLeg.legLocations.count <= 2; //if there are intermid locs
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
            detailDesclosureButton.hidden = selectedLeg.legLocations.count <= 2; //if there are intermid locs
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
            
            if (!selectedLeg.lineName || [selectedLeg.lineName isEqualToString:@""] || [selectedLeg.lineName isEqualToString:@"-"]) {
                NSString *nameFromDetail = [self getLineShortCodeForLineCode:selectedLeg.lineCode];
                if (nameFromDetail)selectedLeg.lineName = nameFromDetail;
            }
            
            lineNumberLabel.text = selectedLeg.lineDisplayName;
            
            if (selectedLeg.legType != LegTypeTram) { /* the tram picture is smaller than others */
                UIImage *image = [UIImage asa_imageWithImage:[AppManager lightColorImageForLegTransportType:loc.locationLegType] scaledToSize:CGSizeMake(legTypeImage.frame.size.width - 4, legTypeImage.frame.size.height - 4)];
                if (selectedLeg.legType != LegTypeMetro)
                    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [legTypeImage setImage:image];
                legTypeImage.contentMode = UIViewContentModeScaleAspectFill;
                if (selectedLeg.legType != LegTypeWalk)
                    legTypeImage.tintColor = [UIColor whiteColor];
                else
                    legTypeImage.tintColor = [UIColor darkGrayColor];
            }
            
            nextLegLine.backgroundColor = darkerGrayColor;
            nextLegLine.image = nil;
            
            NSString *destination = selectedLeg.lineDestination;
            if (!destination && selectedLeg.legType != LegTypeWalk) {
                destination = [self getDestinationForLineCode:selectedLeg.lineCode];
            }
            
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
                    prevLegLine.backgroundColor = [AppManager colorForLegType:prevLoc.locationLegType];
                    prevLegLine.image = nil;
                    break;
            }
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
            startTimeLabel.text = [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:loc.depTime];
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
                [self selectLocationAnnotationWithCode:loc.stopCode];
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

-(void)selectLocationAnnotationWithCode:(NSString *)code{
    for (id<MKAnnotation> annotation in routeMapView.annotations) {
        if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
            LocationsAnnotation *lAnnot = (LocationsAnnotation *)annotation;
            if ([lAnnot.code isEqualToString:code]) {
                [routeMapView selectAnnotation:annotation animated:YES];
            }
        }
    }
}

#pragma mark - helper methods
- (void)evaluateBoundsForCoordsArray:(CLLocationCoordinate2D *)coords andCount:(NSUInteger)count{
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
                
                //Only for the first row if it header and show detail for leg. Add if there are other intermidiate locations too.
                if (loc.isHeaderLocation && leg.showDetailed && leg.legLocations.count > 2 && orderCount == 0){
                    //Also add a copy of the header location
                    if (loc.name == nil || loc.name == (id)[NSNull null]) {
                        orderCount++;
                        continue;
                    }
                    RouteLegLocation *copyLoc = [loc copy];
                    copyLoc.isHeaderLocation = NO;
                    [locationList addObject:copyLoc];
                }
                
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showStopFromRoute"]) {
        
        NSString *stopCode, *stopShortCode, *stopName;
        CLLocationCoordinate2D stopCoords;
        if ([sender isKindOfClass:[self class]]) {
            stopCode = selectedAnnotionStopCode;
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
            stopViewController.stopGtfsId = stopCode;
            stopViewController.stopShortCode = stopShortCode;
            stopViewController.stopName = stopName;
            stopViewController.stopCoords = stopCoords;
            stopViewController.stopEntity = nil;
//            stopViewController.modalMode = [NSNumber numberWithBool:NO];
            stopViewController.useApi = self.useApi;
            
            
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
//        if ([annotationView.annotation isKindOfClass:[StopAnnotation class]])
//        {
//            StopAnnotation *stopAnnotation = (StopAnnotation *)annotationView.annotation;
//            stopCode = stopAnnotation.code;
//            stopCoords = stopAnnotation.coordinate;
//            stopShortCode = stopAnnotation.subtitle;
//            stopName = stopAnnotation.title;
//            
//        }else
        if ([annotationView.annotation isKindOfClass:[LocationsAnnotation class]]) {
            LocationsAnnotation *annotation = (LocationsAnnotation *)annotationView.annotation;
            if (annotation.locationType == StopLocation || annotation.locationType == TransferStopLocation || annotation.locationType == OtherStopLocation) {
                stopCode = annotation.code;
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
        stopViewController.stopGtfsId = stopCode;
        stopViewController.stopShortCode = stopShortCode;
        stopViewController.stopName = stopName;
        stopViewController.stopCoords = stopCoords;
        stopViewController.stopEntity = nil;
        //            stopViewController.modalMode = [NSNumber numberWithBool:NO];
        stopViewController.reittiDataManager = self.reittiDataManager;
        stopViewController.delegate = nil;
        stopViewController.useApi = self.useApi;
        
        //            isShowingStopView = YES;
        return stopViewController;
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    if ([viewControllerToCommit isKindOfClass:[StopViewController class]]) {
        //if navigation bar is hidden, unhide it by moving to mid location.
        [self.navigationController setNavigationBarHidden:NO];
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
