//
//  LineDetailViewController.m
//  
//
//  Created by Anteneh Sahledengel on 21/6/15.
//
//

#import "LineDetailViewController.h"
#import "ASPolylineRenderer.h"
#import "ASPolylineView.h"
#import "AppManager.h"
#import "CoreDataManager.h"
#import "LineStops.h"
#import "LocationsAnnotation.h"
#import "StopViewController.h"
#import "SVProgressHUD.h"
#import "ReittiNotificationHelper.h"

@interface LineDetailViewController ()

@end

@implementation LineDetailViewController

@synthesize staticRoute;
@synthesize line;
@synthesize reittiDataManager, settingsManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initDataManagerIfNull];
    [self initBounds];
    
    [self hideStopsListView:YES animated:NO];
    
    viewApearForTheFirstTime = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setUpViewForLine];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self hideStopsListView:[self isStopsListViewHidden] animated:NO];
    
    titleSeparatorView.frame = CGRectMake(0, stopsTableView.frame.origin.y - 0.5, self.view.frame.size.width, 0.5);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initializations
- (void)initDataManagerIfNull {
    // Do any additional setup after loading the view.
    
    if (self.reittiDataManager == nil) {
        
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:[[CoreDataManager sharedManager] managedObjectContext]];
        self.reittiDataManager.lineSearchdelegate = self;
        self.settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        
        [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    }
}

- (void)initBounds{
    CLLocationCoordinate2D _upper = {.latitude =  -90.0, .longitude =  0.0};
    upperBound = _upper;
    CLLocationCoordinate2D _lower = {.latitude =  90.0, .longitude =  0.0};
    lowerBound = _lower;
    CLLocationCoordinate2D _left = {.latitude =  0, .longitude =  180.0};
    leftBound = _left;
    CLLocationCoordinate2D _right = {.latitude =  0, .longitude =  -180.0};
    rightBound = _right;
}

#pragma mark - View methods

-(void)setUpViewForLine{
    if (self.line) {
        [self setNavigationTitleView];
        
        [self drawLineOnMap];
        [self plotStopAnnotation];
        if (viewApearForTheFirstTime){
            [self centerMapRegionToViewRoute];
            [self hideStopsListView:YES animated:NO];
        }
        
        tableViewContainerView.layer.borderColor = [UIColor grayColor].CGColor;
        tableViewContainerView.layer.borderWidth = 0.5f;
        
        titleSeparatorView.frame = CGRectMake(0, stopsTableView.frame.origin.y - 0.5, self.view.frame.size.width, 0.5);
        titleSeparatorView.backgroundColor = [UIColor lightGrayColor];
        
        [stopsTableView reloadData];
    }else{
        [self lineSearchDidFail:nil];
    }
    
    viewApearForTheFirstTime = NO;
}

-(void)setNavigationTitleView{
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, [self isLandScapeOrientation] ? 20 : 40)];
    titleView.clipsToBounds = YES;
    
    NSMutableDictionary *lineCodeDict = [NSMutableDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17] forKey:NSFontAttributeName];
    [lineCodeDict setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    NSMutableDictionary *lineNameDict = [NSMutableDictionary dictionaryWithObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
    [lineNameDict setObject:[UIColor colorWithWhite:0.9 alpha:1] forKey:NSForegroundColorAttributeName];
    
    NSMutableAttributedString *lineCodeString = [[NSMutableAttributedString alloc] initWithString:self.line.codeShort attributes:lineCodeDict];
    
    NSMutableAttributedString *lineNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", self.line.name] attributes:lineNameDict];
    
    [lineCodeString appendAttributedString:lineNameString];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 40)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = lineCodeString;
    [label sizeToFit];
    self.navigationItem.titleView = label;
}

-(BOOL)isLandScapeOrientation{
    return self.view.frame.size.height < self.view.frame.size.width;
}

-(void)hideStopsListView:(BOOL)hidden animated:(BOOL)anim{
    
    [UIView transitionWithView:tableViewContainerView duration:anim ? 0.2 : 0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self hideStopsListView:hidden];
    } completion:^(BOOL finished) {}];
}

- (void)hideStopsListView:(BOOL)hidden{
    if (hidden) {
        tableViewTopSpacingConstraint.constant = self.view.frame.size.height - 44 - self.tabBarController.tabBar.frame.size.height;
        stopsListHeaderLabel.text = @"SHOW LINE STOPS";
    }else{
        tableViewTopSpacingConstraint.constant = 0;
        stopsListHeaderLabel.text = @"LINE STOPS";
    }
    
    [self.view layoutSubviews];
}

- (BOOL)isStopsListViewHidden{
    return tableViewTopSpacingConstraint.constant > 100;
}

#pragma mark - Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return line.lineStops ? line.lineStops.count : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [stopsTableView dequeueReusableCellWithIdentifier:@"lineStopCell"];
    
    LineStops *lineStop = self.line.lineStops[indexPath.row];
    
    UILabel *stopNameLabel = (UILabel *)[cell viewWithTag:1001];
    UILabel *stopDetailLabel = (UILabel *)[cell viewWithTag:1002];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:1003];
    
    stopNameLabel.text = lineStop.name;
    if (lineStop.platformNumber) {
        stopDetailLabel.text = [NSString stringWithFormat:@"Code: %@ - Platform: %@ - %@", lineStop.codeShort, lineStop.platformNumber, lineStop.cityName];
    }else{
        stopDetailLabel.text = [NSString stringWithFormat:@"Code: %@ - %@", lineStop.codeShort, lineStop.cityName];
    }
    
    if (indexPath.row == 0)
        timeLabel.text = [NSString stringWithFormat:@"%d min", (int)lineStop.time];
    else
        timeLabel.text = [NSString stringWithFormat:@"+%d min", (int)lineStop.time];
    
    UIView *prevLine = [cell viewWithTag:2001];
    UIView *dotView = [cell viewWithTag:2002];
    UIView *nextLine = [cell viewWithTag:2003];
    
    prevLine.backgroundColor = [AppManager systemGreenColor];
    nextLine.backgroundColor = [AppManager systemGreenColor];
    
    dotView.layer.borderWidth = 3;
    dotView.layer.borderColor = [AppManager systemGreenColor].CGColor;
    dotView.backgroundColor = [UIColor whiteColor];
    dotView.layer.cornerRadius = dotView.frame.size.width/2;
    
    if (indexPath.row == 0) {
        prevLine.hidden = YES;
        nextLine.hidden = NO;
    }else if (indexPath.row == self.line.lineStops.count - 1){
        prevLine.hidden = NO;
        nextLine.hidden = YES;
    }else{
        prevLine.hidden = NO;
        nextLine.hidden = NO;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - map view methods
- (void)initializeMapView
{
    routeMapView.delegate = self;    
}

-(void)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coord{
    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    MKCoordinateRegion region = {coord, span};
    
    [UIView animateWithDuration:1.5 animations:^{
        
        [routeMapView setRegion:region animated:YES];
        
    } completion:^(BOOL finished) {}];
}

-(void)centerMapRegionToViewRoute{
    
    CLLocationCoordinate2D lowerBoundTemp = lowerBound;
    
    CLLocationCoordinate2D centerCoord = {.latitude =  (upperBound.latitude + lowerBound.latitude)/2, .longitude =  (leftBound.longitude + rightBound.longitude)/2};
    MKCoordinateSpan span = {.latitudeDelta =  upperBound.latitude - lowerBound.latitude, .longitudeDelta =  rightBound.longitude - leftBound.longitude };
    span.latitudeDelta += 0.3 * span.latitudeDelta;
    span.longitudeDelta += 0.3 * span.longitudeDelta;
    MKCoordinateRegion region = {centerCoord, span};
    
    @try {
        [routeMapView setRegion:region animated:YES];
    }
    
    @catch (NSException *exception) {
        NSLog(@"failed to ccenter map");
        LineStops *firstStop = [self.line.lineStops firstObject];
        CLLocationCoordinate2D centerCoord = [ReittiStringFormatter convertStringTo2DCoord:firstStop.coords];
        MKCoordinateSpan span = {.latitudeDelta =  0.1, .longitudeDelta = 0.1};
        MKCoordinateRegion region = {centerCoord, span};
        
        [routeMapView setRegion:region animated:YES];
    }
    
    lowerBound = lowerBoundTemp;
}

- (void)drawLineOnMap {
    
    int shapeCount = (int)line.shapeCoordinates.count;
    
    // create an array of coordinates from allPins
    CLLocationCoordinate2D coordinates[shapeCount];
    int i = 0;
    
    for (CLLocation *location in line.shapeCoordinates) {
        CLLocationCoordinate2D coord = location.coordinate;
        coordinates[i] = coord;
        i++;
    }
    
    [self evaluateBoundsForCoordsArray:coordinates andCount:shapeCount];
    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:shapeCount];
    [routeMapView addOverlay:polyline];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
   
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        ASPolylineRenderer *polylineRenderer = [[ASPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        polylineRenderer.strokeColor  = [UIColor yellowColor];
        polylineRenderer.borderColor = [UIColor blackColor];
        polylineRenderer.borderMultiplier = 1.1;
        polylineRenderer.lineWidth	  = 7.0f;
        polylineRenderer.lineJoin	  = kCGLineJoinRound;
        polylineRenderer.lineCap	  = kCGLineCapRound;
        
        polylineRenderer.alpha = 1.0;
        polylineRenderer.strokeColor = [AppManager colorForLineType:self.line.lineType];
        
        return polylineRenderer;
    } else {
        return nil;
    }
}

-(void)plotStopAnnotation{
    for (LineStops *stop in self.line.lineStops) {
        CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:stop.coords];
        
        NSString * name = stop.name;
        NSString * shortCode = stop.codeShort;
        
        if (name == nil || name == (id)[NSNull null]) {
            name = @"";
        }
        
        if (shortCode == nil || shortCode == (id)[NSNull null]) {
            shortCode = @"";
        }
        
        LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:shortCode andCoordinate:coordinate andLocationType:StopLocation];
        newAnnotation.code = [NSNumber numberWithInteger:[stop.code integerValue]];
        newAnnotation.imageNameForView = [AppManager stopAnnotationImageNameForStopType:[EnumManager stopTypeFromLegType:[EnumManager legTrasportTypeForLineType:self.line.lineType]]];
        
        [routeMapView addAnnotation:newAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *locationIdentifier = @"location";
    
    if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
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
    }
    
//    if ([annotation conformsToProtocol:@protocol(LVThumbnailAnnotationProtocol)]) {
//        
//        return [((NSObject<LVThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:routeMapView];
//    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = [view annotation];
    NSNumber *stopCode;
    NSString *stopShortCode, *stopName;
    CLLocationCoordinate2D stopCoords;
    if ([annotation isKindOfClass:[LocationsAnnotation class]])
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
        [self performSegueWithIdentifier:@"showStopFromLineDetail" sender:self];
    }
    
}

#pragma mark - ReittiDataManager delegates
-(void)lineSearchDidComplete:(NSArray *)lines{
    if (lines.count > 1) {
        NSLog(@"EROOOOOOOOORRRRRRRR - MORE than one line reterned");
    }
    
//    [SVProgressHUD dismiss];
    
    self.line = [lines objectAtIndex:0];
    [self drawLineOnMap];
    [self plotStopAnnotation];
    [self centerMapRegionToViewRoute];
}

-(void)lineSearchDidFail:(NSString *)error{
//    [SVProgressHUD dismiss];
    [ReittiNotificationHelper showErrorBannerMessage:@"Fetching line detail failed" andContent:nil];
    [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:error value:@3];
    [self performSelector:@selector(popViewController) withObject:nil afterDelay:2];
}

-(void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IBActions

- (IBAction)showOrHideStopsViewButtonPressed:(id)sender {
    [self hideStopsListView:![self isStopsListViewHidden] animated:YES];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showStopFromLineDetail"]) {
        
        NSString *stopCode, *stopShortCode, *stopName;
        CLLocationCoordinate2D stopCoords;
        if ([sender isKindOfClass:[self class]]) {
            stopCode = [NSString stringWithFormat:@"%ld", (long)[selectedAnnotionStopCode integerValue]];
            stopCoords = selectedAnnotationStopCoords;
            stopShortCode = selectedAnnotionStopShortCode;
            stopName = selectedAnnotionStopName;
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
        }
    }
    
    if ([segue.identifier isEqualToString:@"showStopFromStopList"]) {
        NSIndexPath *selectedRowIndexPath = [stopsTableView indexPathForSelectedRow];
        
        LineStops *lineStop = self.line.lineStops[selectedRowIndexPath.row];
        
        if (lineStop) {
            StopViewController *stopViewController =(StopViewController *)segue.destinationViewController;
            stopViewController.stopCode = lineStop.code;
            stopViewController.stopShortCode = lineStop.codeShort;
            stopViewController.stopName = lineStop.name;
            stopViewController.stopCoords = [ReittiStringFormatter convertStringTo2DCoord:lineStop.coords];
            stopViewController.reittiDataManager = self.reittiDataManager;
        }
    }
    
    [self.navigationItem setTitle:@""];
}

@end
