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

@interface RouteDetailViewController ()

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
@synthesize reittiDataManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    //init vars
    darkMode = YES;
    isShowingStopView = NO;
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
    NSLog(@"Number of legs = %lu", (unsigned long)_route.routeLegs.count);
    
    routeLocationList = [self convertRouteToLocationList:self.route];
    
    reittiRemindersManager = [[ReittiRemindersManager alloc] init];
    
    detailViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragRouteList:)];
    detailViewDragGestureRecognizer.delegate = self;
    [routeListView addGestureRecognizer:detailViewDragGestureRecognizer];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self setUpMainViewForRoute];
    [self initializeMapView];
    [self initMapViewForRoute:_route];
    [self moveRouteViewToLocation:RouteListViewLoactionBottom animated:NO];

}

- (void)viewDidAppear:(BOOL)animated{
    if (!isShowingStopView){
        isShowingStopView = NO;
        [self moveRouteViewToLocation:RouteListViewLoactionBottom animated:NO];
    }
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

#pragma mark - initialization

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
//    [topBarView setBlurTintColor:[UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1]];
//    topBarView.layer.borderWidth = 1;
//    topBarView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [nextRouteButton setImage:[UIImage imageNamed:@"next-lgray-100.png"] forState:UIControlStateDisabled];
    [previousRouteButton setImage:[UIImage imageNamed:@"previous-lgray-100.png"] forState:UIControlStateDisabled];
    
    [self setNextAndPrevButtonStates];
    
    [self.navigationController setToolbarHidden:YES];
    self.title = @"";
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, [self isLandScapeOrientation] ? 20 : 40)];
    titleView.clipsToBounds = YES;
    
    NSMutableDictionary *toStringDict = [NSMutableDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-light" size:14] forKey:NSFontAttributeName];
    [toStringDict setObject:[UIColor lightGrayColor] forKey:NSForegroundColorAttributeName];
    
     NSMutableDictionary *addressStringDict = [NSMutableDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue" size:15] forKey:NSFontAttributeName];
    [addressStringDict setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    NSMutableAttributedString *toAddressString = [[NSMutableAttributedString alloc] initWithString:@"To " attributes:toStringDict];
    
    NSMutableAttributedString *addressString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",toLocation] attributes:addressStringDict];
    
    [toAddressString appendAttributedString:addressString];
    
    CGFloat titleViewW = self.navigationItem.titleView.frame.size.width;
    CGFloat labelsW = titleViewW < 10 ? 300 : titleViewW;
    UILabel * toLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelsW, 20)];
    toLabel.attributedText = toAddressString;
    toLabel.textAlignment = NSTextAlignmentCenter;
//    [toLabel sizeToFit];
    
    [titleView addSubview:toLabel];
    
    if (![self isLandScapeOrientation]) {
        UILabel * fLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, labelsW, 18)];
        [fLabel setText:[NSString stringWithFormat:@"from %@",fromLocation]];
//        [fLabel sizeToFit];
        fLabel.textAlignment = NSTextAlignmentCenter;
        fLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        fLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [titleView addSubview:fLabel];
    }
    
    self.navigationItem.titleView = titleView;
    
    [routeListView setBlurTintColor:nil];
    //    routeListView.layer.borderWidth = 1;
    //    routeListView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    routeListTableView.layer.borderWidth = 0.5;
    routeListTableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    routeListTableView.backgroundColor = [UIColor clearColor];
    routeListTableView.separatorColor = [UIColor clearColor];
    
    for (UIView *view in routeView.subviews) {
        [view removeFromSuperview];
    }
    
    UIView *transportsView = [RouteViewManager viewForRoute:self.route longestDuration:[self.route.routeDurationInSeconds floatValue] width:self.view.frame.size.width - 150];
    
    [routeView addSubview:transportsView];
    routeView.contentSize = CGSizeMake(transportsView.frame.size.width, transportsView.frame.size.height);
    
    routeView.userInteractionEnabled = NO;
    [topViewBackView addGestureRecognizer:routeView.panGestureRecognizer];
    
    [timeIntervalLabel setText:[NSString stringWithFormat:@"%@ - %@",
                                               [ReittiStringFormatter formatHourStringFromDate:self.route.getStartingTimeOfRoute],
                                               [ReittiStringFormatter formatHourStringFromDate:self.route.getEndingTimeOfRoute]]];
    
    UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, routeListView.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor lightGrayColor];
    [routeListView addSubview:topLine];
    
    [routeListTableView reloadData];
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
    
    if (location == RouteListViewLoactionBottom) {
        routeLIstViewVerticalSpacing.constant = self.view.bounds.size.height - routeListTableView.frame.origin.y;
        [toggleListButton setTitle:@"List" forState:UIControlStateNormal];
        [toggleListArrowButton setImage:[UIImage imageNamed:@"expand-arrow-50.png"] forState:UIControlStateNormal];
        [self.view layoutIfNeeded];
        [self centerMapRegionToViewRoute];
    }else if (location == RouteListViewLoactionMiddle) {
        routeLIstViewVerticalSpacing.constant = self.view.bounds.size.height/2;
        [toggleListButton setTitle:@"List" forState:UIControlStateNormal];
        [toggleListArrowButton setImage:[UIImage imageNamed:@"horizontal-line-100.png"] forState:UIControlStateNormal];
        routeListTableView.frame = CGRectMake(routeListTableView.frame.origin.x, routeListTableView.frame.origin.y, routeListTableView.frame.size.width,self.view.bounds.size.height/2 - routeListTableView.frame.origin.y);
        [self.view layoutIfNeeded];
    }else{
        routeLIstViewVerticalSpacing.constant = 0;
        routeListTableView.frame = CGRectMake(routeListTableView.frame.origin.x, routeListTableView.frame.origin.y, routeListTableView.frame.size.width, self.view.bounds.size.height - routeListTableView.frame.origin.y);
        [toggleListButton setTitle:@"Map" forState:UIControlStateNormal];
        [toggleListArrowButton setImage:[UIImage imageNamed:@"collapse-arrow-100.png"] forState:UIControlStateNormal];
        [self.view layoutIfNeeded];
    }
    
    [routeListTableView reloadData];
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
    
    [UIView animateWithDuration:1.5 animations:^{
        
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
    
    CLLocationCoordinate2D centerCoord = {.latitude =  (upperBound.latitude + lowerBound.latitude)/2, .longitude =  (leftBound.longitude + rightBound.longitude)/2};
    MKCoordinateSpan span = {.latitudeDelta =  upperBound.latitude - lowerBound.latitude, .longitudeDelta =  rightBound.longitude - leftBound.longitude };
    span.latitudeDelta += 0.3 * span.latitudeDelta;
    span.longitudeDelta += 0.3 * span.longitudeDelta;
    MKCoordinateRegion region = {centerCoord, span};
    
    [routeMapView setRegion:region animated:YES];
    
    return toReturn;
}

- (void)drawLineForLeg:(RouteLeg *)leg {
    
    self.currentLeg = leg;
    int shapeCount = leg.legShapeDictionaries.count;
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
        polylineRenderer.borderColor = [UIColor darkGrayColor];
        polylineRenderer.borderMultiplier = 1.8;
        polylineRenderer.lineWidth	  = 8.0f;
        polylineRenderer.lineJoin	  = kCGLineJoinRound;
        polylineRenderer.lineCap	  = kCGLineCapRound;
        
        polylineRenderer.alpha = 0.8;
        if (currentLeg.legType == LegTypeWalk) {
            polylineRenderer.strokeColor = SYSTEM_BROWN_COLOR;
            polylineRenderer.lineDashPattern = @[@4, @10];
        }else if (currentLeg.legType == LegTypeBus){
            polylineRenderer.strokeColor = SYSTEM_BLUE_COLOR;
        }else if (currentLeg.legType == LegTypeTrain) {
            polylineRenderer.strokeColor = SYSTEM_RED_COLOR;
        }else if (currentLeg.legType == LegTypeTram) {
            polylineRenderer.strokeColor = SYSTEM_GREEN_COLOR;
        }else if (currentLeg.legType == LegTypeMetro) {
            polylineRenderer.strokeColor = SYSTEM_ORANGE_COLOR;
        }else if (currentLeg.legType == LegTypeFerry) {
            polylineRenderer.strokeColor = SYSTEM_CYAN_COLOR;
        }
        
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
    
    switch (loc.locationLegType) {
        case LegTypeWalk:
            newAnnotation.imageNameForView = @"";
            break;
        case LegTypeFerry:
            newAnnotation.imageNameForView = @"ferryAnnotationSmall.png";
//            newAnnotation.identifier = @"ferryAnnotIdentifier";
            break;
        case LegTypeTrain:
            newAnnotation.imageNameForView = @"trainAnnotationSmall.png";
//            newAnnotation.identifier = @"trainAnnotIdentifier";
            break;
        case LegTypeBus:
            newAnnotation.imageNameForView = @"busStopAnnotation-small-blue.png";
//            newAnnotation.identifier = @"busAnnotIdentifier";
            break;
        case LegTypeTram:
            newAnnotation.imageNameForView = @"tramAnnotationSmall.png";
//            newAnnotation.identifier = @"tramAnnotIdentifier";
            break;
        case LegTypeMetro:
            newAnnotation.imageNameForView = @"metroAnnotationSmall.png";
//            newAnnotation.identifier = @"metroAnnotIdentifier";
            break;
            
        default:
            newAnnotation.imageNameForView = @"busStopAnnotation-small-blue.png";
            break;
    }

//    newAnnotation.code = loc.code;
    
    [routeMapView addAnnotation:newAnnotation];
    
}

-(void)plotLocationsAnnotation:(Route *)route{
    int count = 0;
    for (RouteLeg *leg in route.routeLegs) {
       
        int locCount = 0;
        for (RouteLegLocation *loc in leg.legLocations) {
            NSLog(@"ploting location: %@", loc);
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
            
            if ([self zoomLevelForMapRect:routeMapView.visibleMapRect withMapViewSizeInPixels:routeMapView.bounds.size] >= 13) {
                if (leg.legType != LegTypeWalk && locCount != 0 && locCount != leg.legLocations.count - 1) {
                    if (loc.shortCode != nil) {
                        LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:shortCode andCoordinate:coordinate andLocationType:StopLocation];
                        newAnnotation.code = [NSNumber numberWithInteger:[loc.stopCode integerValue]];
                        switch (loc.locationLegType) {
                            case LegTypeWalk:
                                newAnnotation.imageNameForView = @"";
                                break;
                            case LegTypeFerry:
                                newAnnotation.imageNameForView = @"ferryAnnotationSmall.png";
//                                newAnnotation.identifier = @"ferryAnnotIdentifier";
                                break;
                            case LegTypeTrain:
                                newAnnotation.imageNameForView = @"trainAnnotationSmall.png";
//                                newAnnotation.identifier = @"trainAnnotIdentifier";
                                break;
                            case LegTypeBus:
                                newAnnotation.imageNameForView = @"busStopAnnotation-small-blue.png";
//                                newAnnotation.identifier = @"busAnnotIdentifier";
                                break;
                            case LegTypeTram:
                                newAnnotation.imageNameForView = @"tramAnnotationSmall.png";
//                                newAnnotation.identifier = @"tramAnnotIdentifier";
                                break;
                            case LegTypeMetro:
                                newAnnotation.imageNameForView = @"metroAnnotationSmall.png";
//                                newAnnotation.identifier = @"metroAnnotIdentifier";
                                break;
                                
                            default:
                                break;
                        }
                        
                        [routeMapView addAnnotation:newAnnotation];
                    }
                }
            }else{
                for (id<MKAnnotation> annotation in routeMapView.annotations) {
                    if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
                        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
                        if (locAnnotation.locationType == StopLocation) {
                            [routeMapView removeAnnotation:annotation];
                        }
                    }
                }
            }
            
            locCount++;
        }
        count++;
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
        [annotationView setFrame:CGRectMake(0, 0, 35, 38)];
        annotationView.centerOffset = CGPointMake(0,-19);
        
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
            [annotationView setFrame:CGRectMake(0, 0, 35, 35)];
            annotationView.centerOffset = CGPointMake(0,-18);
            
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
        }else{
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
            [annotationView setFrame:CGRectMake(0, 0, 35, 38)];
            annotationView.centerOffset = CGPointMake(0,-19);
            
            return annotationView;
        }
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = [view annotation];
    NSNumber *stopCode;
    CLLocationCoordinate2D stopCoords;
    if ([annotation isKindOfClass:[StopAnnotation class]])
    {
        StopAnnotation *stopAnnotation = (StopAnnotation *)annotation;
        stopCode = stopAnnotation.code;
        stopCoords = stopAnnotation.coordinate;
    }else if ([annotation isKindOfClass:[LocationsAnnotation class]])
    {
        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
        stopCode = locAnnotation.code;
        stopCoords = locAnnotation.coordinate;
    }else{
        return;
    }
    
    if (stopCode != nil && stopCode != (id)[NSNull null]) {
        selectedAnnotionStopCode = stopCode;
        selectedAnnotationStopCoords = stopCoords;
        [self performSegueWithIdentifier:@"showStopFromRoute" sender:self];
    }
    
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    previousRegion = mapView.visibleMapRect;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"Zoom level is: %lu ", (unsigned long)[self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size]);
    //Show detailed stop annotations when the zoom level is more than or equal to 14
    if ([self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size] != [self zoomLevelForMapRect:previousRegion withMapViewSizeInPixels:mapView.bounds.size]) {
        [mapView removeAnnotations:mapView.annotations];
        [self plotLocationsAnnotation:self.route];
        
        [mapView removeOverlays:mapView.overlays];
        
        for (RouteLeg *leg in self.route.routeLegs) {
            [self drawLineForLeg:leg];
        }
        
//        [self plotLocationsAnnotation:self.route];
    }
}

-(NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels
{
    NSUInteger zoomLevel = 20; // MAXIMUM_ZOOM is 20 with MapKit
    MKZoomScale zoomScale = mRect.size.width / viewSizeInPixels.width; //MKZoomScale is just a CGFloat typedef
    double zoomExponent = log2(zoomScale);
    zoomLevel = (NSUInteger)(20 - ceil(zoomExponent));
    return zoomLevel;
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
        NSLog(@"Index path: %ld", (long)indexPath.row);
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
    [self centerMapRegionToCoordinate:self.currentUserLocation.coordinate];
    previousCenteredLocation = self.currentUserLocation;
}

- (IBAction)reminderButtonPressed:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"When do you want to be reminded." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1 min before", @"5 min before",@"10 min before",@"15 min before", @"30 min before", nil];
    actionSheet.tag = 2001;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (actionSheet.tag == 2001) {
        NSString * timeToSetAlarm = [ReittiStringFormatter formatHourStringFromDate:self.route.getStartingTimeOfRoute];
        reittiRemindersManager.reminderMessageFormater = @"Get ready to leave in %d minutes.";
        switch (buttonIndex) {
            case 0:
                reittiRemindersManager.reminderMessageFormater = @"Get ready to leave in %d minute.";
                [reittiRemindersManager setReminderWithMinOffset:1 andHourString:timeToSetAlarm];
                break;
            case 1:
                [reittiRemindersManager setReminderWithMinOffset:5 andHourString:timeToSetAlarm];
                break;
            case 2:
                [reittiRemindersManager setReminderWithMinOffset:10 andHourString:timeToSetAlarm];
                break;
            case 3:
                [reittiRemindersManager setReminderWithMinOffset:15 andHourString:timeToSetAlarm];
                break;
            case 4:
                [reittiRemindersManager setReminderWithMinOffset:30 andHourString:timeToSetAlarm];
                break;
            default:
                break;
        }
    }
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
        NSLog(@"%@", cell.backgroundColor);
        
        UILabel *locNameLabel = (UILabel *)[cell viewWithTag:1002];
        UIImageView *legTypeImage = (UIImageView *)[cell viewWithTag:1001];
        UIImageView *detailIndicatorImage = (UIImageView *)[cell viewWithTag:1004];
        UILabel *lineNumberLabel = (UILabel *)[cell viewWithTag:1005];
        UILabel *moreInfoLabel = (UILabel *)[cell viewWithTag:1006];
        switch (loc.locationLegType) {
            case LegTypeWalk:
                [legTypeImage setImage:[UIImage imageNamed:@"walking-black-75.png"]];
                break;
            case LegTypeFerry:
                [legTypeImage setImage:[UIImage imageNamed:@"ferry-colored-75.png"]];
                break;
            case LegTypeTrain:
                [legTypeImage setImage:[UIImage imageNamed:@"train-colored-75.png"]];
                break;
            case LegTypeBus:
                [legTypeImage setImage:[UIImage imageNamed:@"bus-colored-75.png"]];
                break;
            case LegTypeTram:
                [legTypeImage setImage:[UIImage imageNamed:@"tram-colored-75.png"]];
                break;
            case LegTypeMetro:
                [legTypeImage setImage:[UIImage imageNamed:@"metro-colored-75.png"]];
                break;
                
            default:
                break;
        }
        
        if(selectedLeg.legType == LegTypeMetro){
            lineNumberLabel.text = @"Metro";
        }else if(selectedLeg.legType == LegTypeFerry){
            lineNumberLabel.text = @"Ferry";
        }else if(selectedLeg.legType == LegTypeTrain){
            NSString *unformattedTrainNumber = [ReittiStringFormatter parseBusNumFromLineCode:selectedLeg.lineCode];
            NSString *filteredOnce = [unformattedTrainNumber
                                      stringByReplacingOccurrencesOfString:@"01" withString:@""];
            lineNumberLabel.text = [filteredOnce
                                    stringByReplacingOccurrencesOfString:@"02" withString:@""];
        }else if (selectedLeg.lineCode != nil) {
            lineNumberLabel.text = [ReittiStringFormatter parseBusNumFromLineCode:selectedLeg.lineCode];
        }else {
            lineNumberLabel.text = @"";
        }
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(50, 69.5, self.view.frame.size.width - 50, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        
        if (indexPath.row == self.routeLocationList.count - 1) {
            locNameLabel.text = self.toLocation;
            [legTypeImage setImage:[UIImage imageNamed:@"finish_flag-50.png"]];
            detailIndicatorImage.hidden = YES;
            line.frame = CGRectMake(0, 69.5, self.view.frame.size.width, 0.5);
            
        }else if (indexPath.row == 0) {
//            locNameLabel.text = @"Start location";
            locNameLabel.text = self.fromLocation;
            detailIndicatorImage.hidden = NO;
        }else{
            locNameLabel.text = loc.name == nil || loc.name == (id)[NSNull null] ? @"" : loc.name;
            detailIndicatorImage.hidden = NO;
        }
        
        if (indexPath.row == self.routeLocationList.count - 1) {
            //Position the label in the middle
            moreInfoLabel.text = @"At your destination";
        }else if (selectedLeg.legType == LegTypeWalk) {
            moreInfoLabel.text = [NSString stringWithFormat:@"%ld m ( %@ )", (long)[selectedLeg.legLength integerValue],[ReittiStringFormatter formatDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
        }else{
            moreInfoLabel.text = [NSString stringWithFormat:@"%d stops ( %@ )", [selectedLeg getNumberOfStopsInLeg], [ReittiStringFormatter formatDurationString:[selectedLeg.legDurationInSeconds integerValue]] ];
        }
        
        UILabel *startTimeLabel = (UILabel *)[cell viewWithTag:1003];
        startTimeLabel.text = [ReittiStringFormatter formatHourStringFromDate:loc.depTime];
        
        if(selectedLeg.showDetailed){
            [detailIndicatorImage setImage:[UIImage imageNamed:@"up-arrow-50.png"]];
        }else{
            [detailIndicatorImage setImage:[UIImage imageNamed:@"down-arrow-50.png"]];
        }
        
        [cell addSubview:line];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
    }else if (!loc.isHeaderLocation) {
        if (loc.locationLegType == LegTypeWalk) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"legWalkLocationCell"];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"legstopLocationCell"];
        }
        
        UIView *typeLine = (UIView *)[cell viewWithTag:2001];
        UIView *dotView = (UIView *)[cell viewWithTag:2004];
        
        switch (loc.locationLegType) {
            case LegTypeWalk:
                break;
            case LegTypeFerry:
                typeLine.backgroundColor = SYSTEM_CYAN_COLOR;
                dotView.backgroundColor = SYSTEM_CYAN_COLOR;
                break;
            case LegTypeTrain:
                typeLine.backgroundColor = SYSTEM_RED_COLOR;
                dotView.backgroundColor = SYSTEM_RED_COLOR;
                break;
            case LegTypeBus:
                typeLine.backgroundColor = SYSTEM_BLUE_COLOR;
                dotView.backgroundColor = SYSTEM_BLUE_COLOR;
                break;
            case LegTypeTram:
                typeLine.backgroundColor = SYSTEM_GREEN_COLOR;
                dotView.backgroundColor = SYSTEM_GREEN_COLOR;
                break;
            case LegTypeMetro:
                typeLine.backgroundColor = SYSTEM_ORANGE_COLOR;
                dotView.backgroundColor = SYSTEM_ORANGE_COLOR;
                break;
                
            default:
                break;
        }
        
        dotView.layer.cornerRadius = 3.5f;
        
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *locNameLabel = (UILabel *)[cell viewWithTag:2002];
        if (loc.name == nil || loc.name == (id)[NSNull null]) {
            locNameLabel.text = @"";
        }else{
            locNameLabel.text = loc.name;
        }
        
        UILabel *startTimeLabel = (UILabel *)[cell viewWithTag:2003];
        startTimeLabel.text = [ReittiStringFormatter formatHourStringFromDate:loc.depTime];
        
        if (loc.stopCode == nil || loc.stopCode == (id)[NSNull null]){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RouteLegLocation *loc = [self.routeLocationList objectAtIndex:indexPath.row];
    
    if (loc.isHeaderLocation) {
        return 70.0;
    }else{
        return 30.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RouteLegLocation *loc = [self.routeLocationList objectAtIndex:indexPath.row];
    if (currentRouteListViewLocation != RouteListViewLoactionMiddle) {
        [self moveRouteViewToLocation:RouteListViewLoactionMiddle animated:YES];
    }
    
    [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:loc.coordsString]];
    [self selectTransferAnnotationWithCode:loc.stopCode];
    
    [routeListTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
//    if (loc.isHeaderLocation) {
//        @try {
//            RouteLeg *selectedLeg = [self.route.routeLegs objectAtIndex:loc.locationLegOrder];
//            if(selectedLeg.showDetailed){
//                selectedLeg.showDetailed = NO;
//            }else{
//                selectedLeg.showDetailed = YES;
//            }
//            
//            routeLocationList = [self convertRouteToLocationList:self.route];
//            
//            [routeListTableView reloadData];
//        }
//        @catch (NSException *exception) {
//            
//        }
//        
//    }
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
        
        NSString *stopCode;
        CLLocationCoordinate2D stopCoords;
        if ([sender isKindOfClass:[self class]]) {
            stopCode = [NSString stringWithFormat:@"%ld", (long)[selectedAnnotionStopCode integerValue]];
            stopCoords = selectedAnnotationStopCoords;
        }else{
            NSIndexPath *selectedRowIndexPath = [routeListTableView indexPathForSelectedRow];
            RouteLocation * selected = [self.routeLocationList objectAtIndex:selectedRowIndexPath.row];
            stopCode = selected.stopCode;
            stopCoords = CLLocationCoordinate2DMake([[selected.coordsDictionary objectForKey:@"y"] floatValue],[[selected.coordsDictionary objectForKey:@"x"] floatValue]);
        }
        
        if (stopCode != nil && ![stopCode isEqualToString:@""]) {
//            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
            
            StopViewController *stopViewController =(StopViewController *)segue.destinationViewController;
            stopViewController.stopCode = stopCode;
            stopViewController.stopCoords = stopCoords;
            stopViewController.stopEntity = nil;
            stopViewController.darkMode = self.darkMode;
            stopViewController.modalMode = [NSNumber numberWithBool:YES];
            stopViewController.reittiDataManager = self.reittiDataManager;
            stopViewController.delegate = nil;
            
            isShowingStopView = YES;
        }
    }
}


@end
