//
//  StopViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "StopViewController.h"
#import "WebViewController.h"
#import "MyFixedLayoutGuide.h"
#import "MBProgressHUD.h"
#import "RouteSearchViewController.h"
#import "SearchController.h"
#import "UIScrollView+APParallaxHeader.h"
#import "AppManager.h"
#import "ASA_Helpers.h"
#import "CacheManager.h"
#import "ReittiDateHelper.h"
#import "DepartureTableViewCell.h"
#import "ReittiConfigManager.h"
#import "CoreDataManagers.h"
#import "LocationsAnnotation.h"
#import "MapViewManager.h"
#import "MappingExtensions.h"
#import "ReittiLocationManager.h"

typedef void (^AlertControllerAction)(UIAlertAction *alertAction);
typedef AlertControllerAction (^ActionGenerator)(int minutes);

@interface StopViewController () <ReittiLocationManagerProtocol> {
    BOOL fetchedRouteAlready;
    BOOL mapViewCenteredAlready;
}

@property (nonatomic) NSArray<id<UIPreviewActionItem>> *previewActions;
@property (nonatomic) NSTimer *reloadTimer;

@property (strong, nonatomic) MapViewManager *mapViewManager;
@property (strong, nonatomic) ReittiLocationManager *locationManager;

@end

@implementation StopViewController

//@synthesize StopView;
@synthesize modalMode;
@synthesize departures, _busStop, stopEntity;
@synthesize reittiDataManager, settingsManager, reittiReminderManager;
@synthesize stopGtfsId, stopShortCode, stopName, stopCoords;
@synthesize backButtonText;
@synthesize delegate;
@synthesize refreshControl;
//@synthesize droppedPinGeoCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataManagerIfNull];
    
    stopFetched = NO;
    stopFetchFailed = NO;
    stopDetailRequested = NO;
    stopFetchSuccessfulOnce = NO;
    stopHasRealtimeDepartures = YES;
    
    stopBookmarked = NO;
    departuresTableIndex = nil;
    
    fetchedRouteAlready = NO;
    mapViewCenteredAlready = NO;
    
    modalMode = [NSNumber numberWithBool:NO];
    
    [departuresTable registerNib:[UINib nibWithNibName:@"DepartureTableViewCell" bundle:nil] forCellReuseIdentifier:@"departureCell"];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    if (modalMode != nil && ![modalMode boolValue]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    if (settingsManager == nil) {
        settingsManager = [SettingsManager sharedManager];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    mapView = [[MKMapView alloc] init];
    mapView.showsUserLocation = YES;
    self.mapViewManager = [MapViewManager managerForMapView:mapView];
    [self initLocationUpdating];
    
    [self initNotifications];
    
    [self requestStopInfoAsyncForCode:stopGtfsId andCoords:stopCoords];
    
    [self setUpMainView];
    
//    NSAssert(self.routeSearchHandler != nil, @"There should be route search handler");
}

-(void)viewDidAppear:(BOOL)animated{
    [self setUpMapViewForBusStop];
    [self.navigationController setToolbarHidden:YES animated:NO];
//    [self layoutAnimated:NO];
    self.activityIndicator.hidden = NO;
    
    //Done like this because some how when peeked with 3d it didn't work
    if (stopDetailRequested) {
        [self.activityIndicator beginRefreshing];
    }
    
    self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateDepartures:) userInfo:nil repeats:YES];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.reloadTimer invalidate];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setUpMapViewForBusStop];
    [departuresTable reloadData];
}

- (id<UILayoutSupport>)topLayoutGuide {
    return [[MyFixedLayoutGuide alloc] initWithLength:topBarView.frame.size.height];
}

#pragma mark - initialization
- (void)initDataManagerIfNull {
    // Do any additional setup after loading the view.
    
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] init];
    }
}

#pragma mark - View methods
-(void)setUpLoadingView{
    [self.activityIndicator beginRefreshing];
    stopView.hidden = YES;
}

-(void)setUpMainView{
    
    if ([stopShortCode isEqualToString:@""] || stopShortCode == nil) {
        [stopViewTitle setText:stopName];
        [stopViewSubTitle setText:@""];
    }else{
        [stopViewTitle setText:stopShortCode];
        [stopViewSubTitle setText:stopName];
    }
    
    bookmarkButton.enabled = NO;
    
    departuresTable.backgroundColor = [UIColor clearColor];
    
    topToolBar.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    topToolBar.layer.borderWidth = 0.5;
    
    topToolbarHeightConstraint.constant = self.routeSearchHandler == nil ? 0 : 44;
    [self.view layoutSubviews];
    
    [self setUpMapViewForBusStop];
    
    [departuresTable reloadData];
    [departuresTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    @try { //Number conversions could be problematic
//        NSNumber *codeNumber = [NSNumber numberWithInteger:[self.stopCode integerValue]];
        if ([[StopCoreDataManager sharedManager] isBusStopSavedWithCode:self.stopGtfsId]) {
            [self setStopBookmarkedState];
        }else{
            [self setStopNotBookmarkedState];
        }
    }
    @catch (NSException *exception) {}
}

- (void)setUpMapViewForBusStop {
    [mapView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
    
    if (!mapViewCenteredAlready) {
        [self centerMapRegionToCoordinate:stopCoords];
        mapViewCenteredAlready = YES;
    }
    [self plotStopAnnotation];
    
    [departuresTable addParallaxWithView:mapView andHeight:160];
}

//This method is called after the busStop object is fetched
-(void)setUpStopViewForBusStop:(BusStop *)busStop{
    
    self.departures = busStop.departures;
    self._busStop = busStop;
    
    //Update title  and subttile
    [stopViewTitle setText:self._busStop.codeShort];
    [stopViewSubTitle setText:self._busStop.name];
    
    bookmarkButton.enabled = YES;
    
    if ([[StopCoreDataManager sharedManager] isBusStopSaved:self._busStop]) {
        [self setStopBookmarkedState];
    }else{
        [self setStopNotBookmarkedState];
    }
    
    [self setUpMapViewForBusStop];
    
    [departuresTable reloadData];
    [departuresTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
    stopView.hidden = NO;
    fullTimeTableButton.enabled = busStop.timetableLink != nil;
    
    [self.activityIndicator endRefreshing];
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)initNotifications{
    reittiReminderManager = [ReittiRemindersManager sharedManger];
}

#pragma mark - ibactions
- (IBAction)routeFromHerePressed:(id)sender {
    if (self.routeSearchHandler) {
        NSString *coords = [ReittiStringFormatter convert2DCoordToString:self.stopCoords];
        RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:nil toCoords:nil fromLocation:self.stopName fromCoords:coords];
        self.routeSearchHandler(searchParms);
    }
}

- (IBAction)routeToHerePressed:(id)sender {
    if (self.routeSearchHandler) {
        NSString *coords = [ReittiStringFormatter convert2DCoordToString:self.stopCoords];
        RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:self.stopName toCoords:coords fromLocation:nil fromCoords:nil];
        self.routeSearchHandler(searchParms);
    }
}

- (IBAction)BookmarkButtonPressed:(id)sender {
    if (stopBookmarked) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete your bookmark?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        actionSheet.tag = 1001;
        [actionSheet showInView:self.view];
        
    }else{
        [[StopCoreDataManager sharedManager] saveToCoreDataStop:self._busStop];
        
        [bookmarkButton asa_bounceAnimateViewByScale:0.2];
        [self setStopBookmarkedState];
        [delegate savedStop:self.stopEntity];
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionBookmarkedStop label:@"All" value:nil];
    }
}

- (IBAction)goProButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kProAppAppstoreLink]];
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionGoToProVersionAppStore label:@"Stop View" value:nil];
}

-(IBAction)showFullTimeTable:(id)sender{
    [self performSegueWithIdentifier:@"seeFullTimeTable" sender:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1001) {
        if (buttonIndex == 0) {
            
            [self setStopNotBookmarkedState];
            NSString *code = self._busStop ? self._busStop.gtfsId : self.stopGtfsId;
            [[StopCoreDataManager sharedManager] deleteSavedStopForCode:code];
            [delegate deletedSavedStop:self.stopEntity];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1005){
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

#pragma mark - Peek and Pop actions support
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    return self.previewActions;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActions {
    if (!self._busStop)
        return @[];
    
    if (_previewActions == nil) {
        
        UIPreviewAction *printAction = [UIPreviewAction
                                        actionWithTitle:stopBookmarked ? @"UnBookmark Stop" : @"Bookmark Stop"
                                        style:UIPreviewActionStyleDefault
                                        handler:^(UIPreviewAction * _Nonnull action,
                                                  UIViewController * _Nonnull previewViewController) {
                                            StopViewController *viewController = (StopViewController *)previewViewController;
                                            [viewController BookmarkButtonPressed:self];
                                        }];
        _previewActions = @[printAction];
    }
    return _previewActions;
}

#pragma mark - mapView methods
-(void)initLocationUpdating {
    self.locationManager = [ReittiLocationManager sharedManager];
    self.locationManager.delegate = self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //Search route
    if (!fetchedRouteAlready) {
        CLLocationCoordinate2D coord = self.locationManager.currentUserLocation.coordinate;
        NSString *toCoordsString = [ReittiStringFormatter convert2DCoordToString:coord];

        NSString *fromCoordsString = [ReittiStringFormatter convert2DCoordToString:stopCoords];
        
        [self.reittiDataManager getFirstRouteForFromCoords:fromCoordsString andToCoords:toCoordsString andCompletionBlock:^(NSArray *result, NSString *error, ReittiApi usedApi){
            if (!error && result && result.count > 0) {
                [self drawWalkingPolylineForRoute:[result firstObject]];
            }
        }];
        
        fetchedRouteAlready = YES;
    }
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate{
    if (coordinate.latitude < 30 || coordinate.latitude > 90 || coordinate.longitude < 0 || coordinate.longitude > 150)
        return NO;
    
    MKCoordinateSpan span = {.latitudeDelta =  0.005, .longitudeDelta =  0.005};
    MKCoordinateRegion region = {coordinate, span};
    
    [mapView setRegion:region animated:YES];
    
    return YES;
}

-(void)plotStopAnnotation {
    [mapView removeAnnotations:mapView.annotations];
    
    NSString * name = stopGtfsId;
    NSString * shortCode = stopGtfsId;
    
    if (_busStop) {
        id annotation = [_busStop basicLocationAnnotation];
        if(annotation) [self.mapViewManager plotAnnotations:@[annotation]];
    } else {
        LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:shortCode andSubtitle:name andCoordinate:stopCoords andLocationType:StopLocation];
        newAnnotation.code = stopGtfsId;
        newAnnotation.imageNameForView = [AppManager stopAnnotationImageNameForStopType:StopTypeBus];
        
        [mapView addAnnotation:newAnnotation];
    }
}

-(void)drawWalkingPolylineForRoute:(Route *)route {
    if (route.isOnlyWalkingRoute && route.routeLegs && route.routeLegs.count > 0) {
        [self.mapViewManager drawPolylineForObject:route.routeLegs[0] andAdjustToFit:YES];
    }
}

#pragma mark - reminder methods
- (void)setStopBookmarkedState{
    [bookmarkButton setImage:[UIImage imageNamed:@"star-filled-white-100.png"] forState:UIControlStateNormal];
    stopBookmarked = YES;
}

- (void)setStopNotBookmarkedState{
    [bookmarkButton setImage:[UIImage imageNamed:@"star-line-white-100.png"] forState:UIControlStateNormal];
    stopBookmarked = NO;
}

- (IBAction)seeFullTimeTablePressed:(id)sender {
    NSURL *url = [NSURL URLWithString:self._busStop.timetableLink];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (void)updateDepartures:(id)userData {
    [self requestStopInfoAsyncForCode:stopGtfsId andCoords:stopCoords];
}

- (void)requestStopInfoAsyncForCode:(NSString *)code andCoords:(CLLocationCoordinate2D)coords{
    stopDetailRequested = YES;
    stopFetchFailed = NO;
    
    RTStopSearchParam *searchParam = [RTStopSearchParam new];
    searchParam.longCode = code;
    searchParam.shortCode = stopShortCode;
    searchParam.stopName = stopName;
    
    if (self.useApi != ReittiAutomaticApi) {
        [self.reittiDataManager fetchStopsForSearchParams:searchParam fetchFromApi:self.useApi withCompletionBlock:^(BusStop * stop, NSString * error){
            [self stopFetchCompletedWithStop:stop andError:error];
        }];
    } else {
        [self.reittiDataManager fetchStopsForSearchParams:searchParam andCoords:coords withCompletionBlock:^(BusStop * stop, NSString * error){
            [self stopFetchCompletedWithStop:stop andError:error];
        }];
    }
}

-(void)stopFetchCompletedWithStop:(BusStop *)stop andError:(NSString *)error {
    if (!error) {
        stopFetchSuccessfulOnce = YES;
        [self stopFetchDidComplete:stop];
    }else{
        if (!stopFetchSuccessfulOnce) [self stopFetchDidFail:error];
    }
    stopDetailRequested = NO;
}

- (IBAction)reloadButtonPressed:(id)sender{
    if (_busStop != nil) {
        if ([SettingsManager useDigiTransit]) {
            [self requestStopInfoAsyncForCode:_busStop.gtfsId
                                    andCoords:[ReittiStringFormatter convertStringTo2DCoord:_busStop.coords]];
        } else {
            [self requestStopInfoAsyncForCode:_busStop.gtfsId
                                    andCoords:[ReittiStringFormatter convertStringTo2DCoord:_busStop.coords]];
        }
    }
}

#pragma mark - Table view delegate methods

- (void)initRefreshControl{
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = departuresTable;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadButtonPressed:) forControlEvents:UIControlEventValueChanged];
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh Departures"];
    tableViewController.refreshControl = self.refreshControl;
}

- (BOOL)thereAreLiveDepartures {
    if (!self.departures || self.departures.count < 1) return NO;
    for (StopDeparture *dep in self.departures) {
        if (dep.isRealTime) return YES;
    }
    
    return NO;
}

-(NSInteger)showGoProRequestCount {
    if (!_showGoProRequestCount) {
        _showGoProRequestCount = [NSNumber numberWithInteger:[SettingsManager showGoProInStopViewRequestCount]];
    }
    
    return [_showGoProRequestCount integerValue];
}

- (BOOL)shouldShowGoProRow {
    BOOL canShow = NO;
    if (![AppManager isProVersion] && [self thereAreLiveDepartures]) {
        NSInteger requestCount = [self showGoProRequestCount];
        NSInteger minInterval = [[ReittiConfigManager sharedManager] intervalBetweenGoProShowsInStopView];
        canShow = requestCount > 0 && requestCount % minInterval == 0;
    }
    
    return canShow;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.departures.count > 0) {
        return [self shouldShowGoProRow] ? self.departures.count + 1 : self.departures.count;
    }else{
        return stopFetched ? 1 : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DepartureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"departureCell"];
    
    CustomeTableViewCell __weak *weakCell = (CustomeTableViewCell *)cell;
    NSMutableArray * leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102.0/255.0 alpha:1.0]
                                                icon:[UIImage imageNamed:@"alarmClock_small.png"]];
    
    NSArray *buttonsArray = [NSArray arrayWithArray:leftUtilityButtons];
    
    [cell setAppearanceWithBlock:^{
        weakCell.leftUtilityButtons = buttonsArray;
        weakCell.delegate = self;
        weakCell.containingTableView = tableView;
    } force:NO];
    
    
    if (self.departures.count > 0) {
        if ([self shouldShowGoProRow] && indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goProCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            NSInteger departureIndex = [self shouldShowGoProRow] ? indexPath.row - 1 : indexPath.row;
            StopDeparture *departure = [self.departures objectAtIndex:departureIndex];
            
            @try {
                [cell setupFromStopDeparture:departure compactMode:NO];
            }
            @catch (NSException *exception) {
                if (self.departures.count == 1) {
                    UITableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
                    infoCell.backgroundColor = [UIColor clearColor];
                    return infoCell;
                }
            }
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *infoLabel = [cell viewWithTag:1003];
        if (stopFetchFailed && stopFetchFailMessage) {
            infoLabel.text = stopFetchFailMessage;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
    
    [cell setCellHeight:56];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    cell.backgroundColor = [UIColor clearColor];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
    titleLabel.font = [titleLabel.font fontWithSize:14];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    if (section == 0) {
        titleLabel.text = @"   DEPARTURES";
    }
    [view addSubview:titleLabel];
    
    if (self._busStop.timetableLink) {
        fullTimeTableButton = [UIButton buttonWithType:UIButtonTypeSystem];
        fullTimeTableButton.frame = CGRectMake(self.view.frame.size.width - 120, 0, 120, 30);
        [fullTimeTableButton setTitle:@"FULL TIMETABLE" forState:UIControlStateNormal];
        fullTimeTableButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [fullTimeTableButton setTintColor:[AppManager systemGreenColor]];
        [fullTimeTableButton addTarget:self action:@selector(showFullTimeTable:) forControlEvents:UIControlEventTouchUpInside];
        
        fullTimeTableButton.enabled = stopFetched;
        
        [view addSubview:fullTimeTableButton];
    }
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1.5)];
    topLineView.backgroundColor = [AppManager systemGreenColor];
    
    [view addSubview:topLineView];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    return view;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomeTableViewCell *cell = (CustomeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil) {
        if ([cell isKindOfClass:[CustomeTableViewCell class]]) {
            [cell showUtilityButtonsAnimated:YES];
        }
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:{
            StopDeparture *departure = [self.departures objectAtIndex:[[departuresTable indexPathForCell:cell] row]];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"When do you want to be reminded." message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            ActionGenerator actionGenerator = ^(int minutes){
                return ^(UIAlertAction *alertAction) {
                    [self setReminderForDeparture:departure Offset:minutes];
                    
                    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSetDepartureReminder label:[NSString stringWithFormat:@"%d min", minutes] value:nil];
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
            
            NSArray *existingNotifs = [[ReittiRemindersManager sharedManger] getDepartureNotificationsForStop:self._busStop];
            if (existingNotifs && existingNotifs.count > 0) {
                UIAlertAction *deleteExisting = [UIAlertAction actionWithTitle:@"Cancel Current Reminders" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [[ReittiRemindersManager sharedManger] cancelNotifications:existingNotifs];
                }];
                
                [alertController addAction:deleteExisting];
            }
            
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            [cell hideUtilityButtonsAnimated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)setReminderForDeparture:(StopDeparture *)departure Offset:(int)offset {
    [[ReittiRemindersManager sharedManger] setNotificationForDeparture:departure inStop:self._busStop offset:offset];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state{
    NSIndexPath *index = [departuresTable indexPathForCell:cell];
    if (departuresTableIndex != nil && state == kCellStateLeft && index.row != departuresTableIndex.row) {
        [(CustomeTableViewCell *)[departuresTable cellForRowAtIndexPath:departuresTableIndex] hideUtilityButtonsAnimated:YES];
    }
    departuresTableIndex = [departuresTable indexPathForCell:cell];
    
}

#pragma - mark RettiDataManager Delegate methods
-(void)stopFetchDidComplete:(BusStop *)stop{
    stopFetched = YES;
    stopFetchFailed = NO;
    if (stop != nil) {
        self._busStop = stop;
        [self setUpStopViewForBusStop:self._busStop];
        
        [[StopCoreDataManager sharedManager] saveHistoryToCoreDataStop:self._busStop];
    } else {
        //Just reload and show no departures
        [departuresTable reloadData];
    }
}

-(void)stopFetchDidFail:(NSString *)error{
    stopFetched = YES;
    stopFetchFailed = YES;
    
    stopFetchFailMessage = error;
    
    [departuresTable reloadData];
    
    [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:error value:@2];
}

#pragma mark - Seague

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"seeFullTimeTable"]) {
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        NSURL *url = [NSURL URLWithString:self._busStop.timetableLink];
        webViewController._url = url;
        webViewController._pageTitle = _busStop.codeShort;
        
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionViewedFullTimeTable label:nil value:nil];
    }
    
    if ([segue.identifier isEqualToString:@"routeToHere"] || [segue.identifier isEqualToString:@"routeFromHere"]) {
        UINavigationController * navigationController = (UINavigationController *)[segue destinationViewController];
        
        RouteSearchViewController *routeSearchViewController = (RouteSearchViewController *)[navigationController.viewControllers lastObject];
        
        if ([segue.identifier isEqualToString:@"routeToHere"]) {
            routeSearchViewController.prevToLocation = self.stopName;
            routeSearchViewController.prevToCoords = [NSString stringWithFormat:@"%f,%f",self.stopCoords.longitude, self.stopCoords.latitude];
        }
        if ([segue.identifier isEqualToString:@"routeFromHere"]) {
            routeSearchViewController.prevFromLocation = self.stopName;
            routeSearchViewController.prevFromCoords = [NSString stringWithFormat:@"%f,%f",self.stopCoords.longitude, self.stopCoords.latitude];
        }
        
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSearchedRoute label:@"From stop" value:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (_reloadTimer)
        [_reloadTimer invalidate];
    NSLog(@"StopViewController:This ARC deleted my UIView.");
}

@end
