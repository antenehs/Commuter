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
#import "LineStop.h"
#import "LocationsAnnotation.h"
#import "StopViewController.h"
#import "ReittiNotificationHelper.h"
#import "LVThumbnailAnnotation.h"
#import "LinesManager.h"
#import "MainTabBarController.h"
#import "ReittiMapkitHelper.h"
#import "MappingExtensions.h"
#import "MapViewManager.h"
#import "AppFeatureManager.h"

@interface LineDetailViewController ()

@property (strong, nonatomic) RettiDataManager *reittiDataManager;
@property (strong, nonatomic) MapViewManager *mapViewManager;
@property (strong, nonatomic) LineStop *selectedAnnotationStop;

@end

@implementation LineDetailViewController

@synthesize staticRoute;
@synthesize line;
@synthesize reittiDataManager, settingsManager;

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapViewManager = [MapViewManager managerForMapView:mapView];
    
    [self initDataManagerIfNull];
    [self initBounds];
    
    [self hideStopsListView:YES animated:NO];
    
    if (!self.line.lineStops || self.line.lineStops.count < 1) {
        [self fetchDetailForLine];
    }
    
    viewApearForTheFirstTime = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setUpViewForLine];
    
    if ([AppFeatureManager proFeaturesAvailable])
        [self startFetchingLiveVehicles];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self stopFetchingVehicles];
    [super viewWillDisappear:animated];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self hideStopsListView:[self isStopsListViewHidden] animated:NO];
    
    titleSeparatorView.frame = CGRectMake(0, stopsTableView.frame.origin.y - 0.5, self.view.frame.size.width, 0.5);
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initializations
-(void)initDataManagerIfNull {
    // Do any additional setup after loading the view.
    
    self.settingsManager = [SettingsManager sharedManager];
    
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] init];
    }
}

-(void)initBounds{
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
        
        [self.mapViewManager drawPolyline:self.line.mapPolyline andAdjustToFit:viewApearForTheFirstTime];
        [self.mapViewManager plotAnnotations:[self lineStopAnnotations]];
        
        if (viewApearForTheFirstTime){
            [self hideStopsListView:YES animated:NO];
        }
        
        tableViewContainerView.layer.borderColor = [UIColor grayColor].CGColor;
        tableViewContainerView.layer.borderWidth = 0.5f;
        
        titleSeparatorView.frame = CGRectMake(0, stopsTableView.frame.origin.y - 0.5, self.view.frame.size.width, 0.5);
        titleSeparatorView.backgroundColor = [UIColor lightGrayColor];
        
        [stopsTableView reloadData];
        
        [[LinesManager sharedManager] saveRecentLine:self.line];
    }else{
        [self lineSearchDidFail:nil];
    }
    
    viewApearForTheFirstTime = NO;
}

-(NSArray *)lineStopAnnotations {
    NSMutableArray *stopAnnotations = [@[] mutableCopy];
    
    if (!self.line || !self.line.lineStops) return stopAnnotations;
    
    for (LocationsAnnotation *stopAnnot in self.line.lineStopAnnotations) {
        stopAnnot.primaryAccessoryAction = ^(MKAnnotationView *annotationView){
                                                [self calloutAccessoryControlTappedOnAnnotationView: annotationView];
                                            };
        stopAnnot.imageCenterOffset = CGPointMake(0, -15);
        [stopAnnotations addObject:stopAnnot];
    }
    
    return stopAnnotations;
}

-(void)setNavigationTitleView{
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, [self isLandScapeOrientation] ? 20 : 40)];
    titleView.clipsToBounds = YES;
    
    NSMutableDictionary *lineCodeDict = [NSMutableDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17] forKey:NSFontAttributeName];
    [lineCodeDict setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    NSMutableDictionary *lineNameDict = [NSMutableDictionary dictionaryWithObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
    [lineNameDict setObject:[UIColor colorWithWhite:0.9 alpha:1] forKey:NSForegroundColorAttributeName];
    
    NSMutableAttributedString *lineCodeString = [[NSMutableAttributedString alloc] initWithString:self.line.codeShort ? self.line.codeShort : @"" attributes:lineCodeDict];
    
    NSMutableAttributedString *lineNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", self.line.name ? self.line.name : @""] attributes:lineNameDict];
    
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

-(void)hideStopsListView:(BOOL)hidden{
    if (hidden) {
        tableViewTopSpacingConstraint.constant = self.view.frame.size.height - 44 - self.tabBarController.tabBar.frame.size.height;
        stopsListHeaderLabel.text = @"SHOW LINE STOPS";
    }else{
        tableViewTopSpacingConstraint.constant = 0;
        stopsListHeaderLabel.text = @"LINE STOPS";
    }
    
    [self.view layoutSubviews];
}

-(BOOL)isStopsListViewHidden{
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
    
    LineStop *lineStop = self.line.lineStops[indexPath.row];
    
    UILabel *stopNameLabel = (UILabel *)[cell viewWithTag:1001];
    UILabel *stopDetailLabel = (UILabel *)[cell viewWithTag:1002];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:1003];
    
    stopNameLabel.text = lineStop.name;
    if (lineStop.cityName) {
        stopDetailLabel.text = [NSString stringWithFormat:@"Code: %@ - %@", lineStop.codeShort, lineStop.cityName];
    } else {
        stopDetailLabel.text = [NSString stringWithFormat:@"Code: %@", lineStop.codeShort];
    }
    
    if (lineStop.time) {
        if (indexPath.row == 0)
            timeLabel.text = [NSString stringWithFormat:@"%d min", [lineStop.time intValue]];
        else
            timeLabel.text = [NSString stringWithFormat:@"+%d min", [lineStop.time intValue]];
    } else {
        timeLabel.text = @"";
    }
    
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

-(void)calloutAccessoryControlTappedOnAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[LocationsAnnotation class]]) {
        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)view.annotation;
        LineStop *stop = (LineStop *)locAnnotation.associatedObject;
        if (stop) {
            self.selectedAnnotationStop = stop;
            [self performSegueWithIdentifier:@"showStopFromLineDetail" sender:self];
        }
    }
}

#pragma mark - ReittiDataManager delegates
-(void)fetchDetailForLine {
    if (!line && line.code) [self lineSearchDidFail:@"No line code available"];
    [activityIndicator beginRefreshing];
    [self.reittiDataManager fetchLinesForLineCodes:@[line.code] withCompletionBlock:^(NSArray *lines, id searchTerm, NSString *errorString){
        if (!errorString && lines.count > 0) {
            if (lines.count > 1) {
                NSLog(@"EROOOOOOOOORRRRRRRR - MORE than one line returned");
            }
            Line *aline = lines[0];
            if (!aline.lineStops || aline.lineStops.count == 0) {
                [self lineSearchDidFail:@"Line fetching failed."];
            }
            self.line.lineStops = aline.lineStops;
            self.line.shapeCoordinates = aline.shapeCoordinates;
            
            viewApearForTheFirstTime = YES;
            [self setUpViewForLine];
        }else{
            [self lineSearchDidFail:errorString];
        }
        [activityIndicator endRefreshing];
    }];
}

-(void)lineSearchDidFail:(NSString *)error{
    [ReittiNotificationHelper showErrorBannerMessage:@"Fetching line detail failed" andContent:nil];
    [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:error value:@3];
    [self performSelector:@selector(popViewController) withObject:nil afterDelay:2];
}

-(void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - live vehicle delegates
-(void)startFetchingLiveVehicles{
    NSArray *trainLines = nil;
    NSArray *otherLines = nil;
    if (line.lineType == LineTypeTrain)
        trainLines = @[self.line.code];
    else
        otherLines = @[self.line.code];
    
    [self.reittiDataManager fetchAllLiveVehiclesWithCodes:otherLines andTrainCodes:trainLines withCompletionHandler:^(NSArray *vehicleList, NSString *errorString){
        if (!errorString) {
            [self.mapViewManager plotVehicleAnnotations:vehicleList];
        }
    }];
}

-(void)stopFetchingVehicles{
    //Remove all vehicle annotations
    [self.reittiDataManager stopFetchingLiveVehicles];
}

#pragma mark - IBActions

-(IBAction)showOrHideStopsViewButtonPressed:(id)sender {
    [self hideStopsListView:![self isStopsListViewHidden] animated:YES];
}

#pragma mark - helper methods
-(void)switchToRouteSearchViewWithRouteParameter:(RouteSearchParameters  *)searchParameters {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [tabBarController setupAndSwithToRouteSearchViewWithSearchParameters:searchParameters];
}

-(RouteSearchFromStopHandler)stopViewRouteSearchHandler {
    return ^(RouteSearchParameters *searchParams){
//        [self.navigationController popToViewController:self animated:YES];
        [self switchToRouteSearchViewWithRouteParameter:searchParams];
    };
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showStopFromLineDetail"] || [segue.identifier isEqualToString:@"showStopFromStopList"]) {
        LineStop *lineStop;
        if ([segue.identifier isEqualToString:@"showStopFromLineDetail"]) {
            lineStop = self.selectedAnnotationStop;
        } else {
            NSIndexPath *selectedRowIndexPath = [stopsTableView indexPathForSelectedRow];
            lineStop = self.line.lineStops[selectedRowIndexPath.row];
        }
        
        if (lineStop) {
            StopViewController *stopViewController =(StopViewController *)segue.destinationViewController;
            stopViewController.stopGtfsId = lineStop.gtfsId;
            stopViewController.stopShortCode = lineStop.codeShort;
            stopViewController.stopName = lineStop.name;
            stopViewController.stopCoords = [ReittiStringFormatter convertStringTo2DCoord:lineStop.coords];
            stopViewController.useApi = ReittiCurrentRegionApi;
            
            stopViewController.routeSearchHandler = [self stopViewRouteSearchHandler];
        }
    }
    
    [self.navigationItem setTitle:@""];
}

@end
