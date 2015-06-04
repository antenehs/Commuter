//
//  BookmarksViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "BookmarksViewController.h"
#import "StopEntity.h"
#import "HistoryEntity.h"
#import "RouteEntity.h"
#import "RouteHistoryEntity.h"
#import "StopViewController.h"
#import "RouteSearchViewController.h"
#import "WidgetSettingsViewController.h"
#import "SearchController.h"
#import "RouteViewManager.h"

@interface BookmarksViewController ()

@end

@implementation BookmarksViewController

#define CUSTOME_FONT(s) [UIFont fontWithName:@"Aspergit" size:s]
#define CUSTOME_FONT_BOLD(s) [UIFont fontWithName:@"AspergitBold" size:s]
#define CUSTOME_FONT_LIGHT(s) [UIFont fontWithName:@"AspergitLight" size:s]

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
#define SYSTEM_ORANGE_COLOR [UIColor colorWithRed:230.0/255.0 green:126.0/255.0 blue:34.0/255.0 alpha:1.0];
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

@synthesize savedStops;
@synthesize recentStops;
@synthesize savedRoutes, recentRoutes, droppedPinGeoCode;
@synthesize savedNamedBookmarks;
@synthesize mode, darkMode;
@synthesize dataToLoad;
@synthesize delegate;
@synthesize _tintColor;
@synthesize reittiDataManager, settingsManager;
@synthesize namedBRouteDetail;
@synthesize currentUserLocation, previousCenteredLocation, locationManager;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstTimeLocation = YES;
    //defaultBlueColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    //defaultGreenColor = [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102.0/255.0 alpha:1.0];
//    [self selectSystemColors];
    UINavigationController * homeViewNavController = (UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:0];
    SearchController *homeViewController = (SearchController *)[[homeViewNavController viewControllers] lastObject];
    
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:homeViewController.managedObjectContext];
        
        if (settingsManager == nil) {
            settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        }
        
        [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
        
        self.reittiDataManager.routeSearchdelegate = self;
    }
    
    [self loadSavedValues];
    self.droppedPinGeoCode = homeViewController.droppedPinGeoCode;
    
    if (([settingsManager userLocation] != HSLRegion) || settingsManager == nil) {
//        [self initAdBannerView];
        self.canDisplayBannerAds = YES;
    }
    
    listSegmentControl.selectedSegmentIndex = self.mode;
    [self setUpViewForTheSelectedMode];
    
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    [bluredBackView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = bluredBackView;
    
    self.tableView.rowHeight = 60;
    
    [self updateDetailStores];
    [self initLocationManager];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.alpha = 1.0;
    activityIndicator.hidesWhenStopped = YES;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadSavedValues];
    
    [self setUpViewForTheSelectedMode];
    [self resetAndRequestRoutesIfNeeded];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refreshTableView:) userInfo:nil repeats:YES];
    [locationManager startUpdatingLocation];
}

//- (void)appDidBecomeActive:(NSNotification *)notification {
//    NSLog(@"did become active notification");
//}

- (void)appWillEnterForeground:(NSNotification *)notification {
    NSLog(@"will enter foreground notification");
    [self resetAndRequestRoutesIfNeeded];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refreshTableView:) userInfo:nil repeats:YES];
    [locationManager startUpdatingLocation];
}

- (void)appWillEnterBackground:(NSNotification *)notification {
    NSLog(@"will enter foreground notification");
    [refreshTimer invalidate];
    [locationManager stopUpdatingLocation];
}

-(void)viewDidDisappear:(BOOL)animated{
    [refreshTimer invalidate];
    [locationManager stopUpdatingLocation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    [self layoutAnimated:NO];
}
//
//- (void)fetchData
//{
//    NSArray * __savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
//    NSArray * __savedRoutes = [self.reittiDataManager fetchAllSavedRoutesFromCoreData];
//    NSArray * __recentStops = [self.reittiDataManager fetchAllSavedStopHistoryFromCoreData];
//    NSArray * __recentRoutes = [self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData];
//    NSArray * __namedBookmarks = [self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData];
//    
//    self.savedStops = [NSMutableArray arrayWithArray:__savedStops];
//    self.savedRoutes = [NSMutableArray arrayWithArray:__savedRoutes];
//    self.recentStops = [NSMutableArray arrayWithArray:__recentStops];
//    self.recentRoutes = [NSMutableArray arrayWithArray:__recentRoutes];
//    self.savedNamedBookmarks = [NSMutableArray arrayWithArray:__namedBookmarks];
//}


- (void)updateDetailStores
{
    //Init data
    if (namedBRouteDetail == nil) {
        namedBRouteDetail = [[NSMutableDictionary alloc] init];
    }
    
    for (NamedBookmark *nmdBkmrk in self.savedNamedBookmarks) {
        if ([namedBRouteDetail objectForKey:nmdBkmrk.coords] == nil) {
             [namedBRouteDetail setObject:[[NSArray alloc] init] forKey:nmdBkmrk.coords];
        }
    }
}

- (void)resetAndRequestRoutesIfNeeded{
//    [self initDetailStores];
    
//    for (int i = 0; i < self.savedNamedBookmarks.count; i++) {
//        NamedBookmark *nmdBkmrk = [self.savedNamedBookmarks objectAtIndex:i];
//        
//        if ([self shouldUpdateRouteInfoForBookmark:nmdBkmrk]) {
//            [self fetchRouteForNamedBookmark:nmdBkmrk];
//            
//            NSIndexPath *indexPathToUpdate = [NSIndexPath indexPathForRow:i inSection:0];
//            
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathToUpdate, nil] withRowAnimation:UITableViewRowAnimationNone];
//        }
//    }
    
    [self.tableView reloadData];
}

- (void)fetchRouteForNamedBookmark:(NamedBookmark *)namedBookmark
{
//    UINavigationController * homeViewNavController = (UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:0];
//    SearchController *homeViewController = (SearchController *)[[homeViewNavController viewControllers] lastObject];
//    
//    CLLocationCoordinate2D currentLocation = [homeViewController.currentUserLocation coordinate];
    
    if (self.currentUserLocation) {
        [self.reittiDataManager searchRouteForFromCoords:[ReittiStringFormatter convert2DCoordToString:[currentUserLocation coordinate]] andToCoords:namedBookmark.coords];
        [activityIndicator startAnimating];
    }
}


#pragma mark - View methods
- (void)selectSystemColors{
    if (self.darkMode) {
        systemBackgroundColor = [UIColor clearColor];
        systemTextColor = SYSTEM_GREEN_COLOR;
        systemSubTextColor = [UIColor lightGrayColor];
    }else{
        systemBackgroundColor = nil;
        systemTextColor = SYSTEM_GREEN_COLOR;
        systemSubTextColor = [UIColor darkGrayColor];
    }
}

- (void)setUpViewForTheSelectedMode{
    if (listSegmentControl.selectedSegmentIndex == 0) {
//        self.title = @"BOOKMARKS";
//        self._tintColor = SYSTEM_GREEN_COLOR;
        dataToLoad = nil;
        dataToLoad = [[NSMutableArray alloc] initWithArray:savedNamedBookmarks];
        [dataToLoad addObjectsFromArray:savedRoutes];
        [dataToLoad addObjectsFromArray:savedStops];
//        self.dataToLoad = [self sortDataArray:dataToLoad];
        if (self.savedStops != nil && self.savedStops.count > 0) {
            [self hideWidgetSettingsButton:NO];
        }else{
            [self hideWidgetSettingsButton:YES];
        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
//        self.title = @"HISTORY";
//        self._tintColor = SYSTEM_ORANGE_COLOR;
        dataToLoad = nil;
        dataToLoad = [[NSMutableArray alloc] initWithArray:recentRoutes];
        [dataToLoad addObjectsFromArray:recentStops];
        self.dataToLoad = [self sortDataArray:dataToLoad];
        
        [self hideWidgetSettingsButton:YES];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView reloadData];
    
//    self.navigationController.navigationBar.tintColor = self._tintColor;
    //selectorView.tintColor = self._tintColor;
}

//- (void)setUpToolbar
//{
//    UIToolbar* toolbar = [[UIToolbar alloc] init];
//    toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
//    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePhoto:)];
//    NSArray *buttonItems = [NSArray arrayWithObjects:shareButton,nil];
//    [toolbar setItems:buttonItems];
//    
//}

-(void)hideWidgetSettingsButton:(BOOL)hidden{
    NSMutableArray *toolBarButtons = [self.navigationController.toolbar.items mutableCopy];
    if (hidden) {
        [toolBarButtons removeObject:widgetSettingButton];
        [self.navigationController.toolbar setItems:toolBarButtons animated:YES];
    }else{
        if (![toolBarButtons containsObject:widgetSettingButton])
            [toolBarButtons addObject:widgetSettingButton];
        [self.navigationController.toolbar setItems:toolBarButtons animated:YES];
    }
    
}

#pragma mark - location services
- (void)initLocationManager{
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    [locationManager startUpdatingLocation];
    locationManager.delegate = self;
}

-(BOOL)isLocationServiceAvailable{
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    NSLog(@"%d",[CLLocationManager authorizationStatus]);
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServicesEnabled) {
        return NO;
    }
    
    if (!accessGranted) {
        return NO;
    }
    
    return YES;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    previousCenteredLocation = self.currentUserLocation;
    
    self.currentUserLocation = [locations lastObject];
    
    CLLocationDistance dist = [previousCenteredLocation distanceFromLocation:self.currentUserLocation];
    if (dist > 250) {
        firstTimeLocation = YES;
    }
    
    if (firstTimeLocation) {
        [self.tableView reloadData];
        firstTimeLocation = NO;
    }
}

#pragma mark - ibactions
- (IBAction)CancelButtonPressed:(id)sender {
    [delegate viewControllerWillBeDismissed:self.mode];
    [self dismissViewControllerAnimated:YES completion:nil ];
}
- (IBAction)clearAllButtonPressed:(id)sender {
    // Delete the row from the data source
    if (dataToLoad.count > 0) {
        NSString * message;
        if (mode == 0) {
            message  = @"Are you sure you want to delete all your bookmarks? This action cannot  be undone";
        }else{
            message  = @"Are you sure you want to delete all your history? This action cannot  be undone";
        }
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        
        [actionSheet showInView:self.view];
    }    
}
- (IBAction)addBookmarkButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"addAddress" sender:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    if (buttonIndex == 0) {
        if (mode == 0) {
//            [delegate deletedAllSavedStops];
            [self.reittiDataManager deleteAllSavedStop];
            [self.reittiDataManager deleteAllSavedroutes];
            [self.reittiDataManager deleteAllNamedBookmarks];
            [self hideWidgetSettingsButton:YES];
        }else{
//            [delegate deletedAllHistoryStops];
            [self.reittiDataManager deleteAllHistoryStop];
            [self.reittiDataManager deleteAllHistoryRoutes];
        }
        
        [dataToLoad removeAllObjects];
        [self.tableView reloadData];
    }
}

- (IBAction)segmentControlValueChanged:(id)sender {
    
    [self setUpViewForTheSelectedMode];
    
    self.mode = (int)listSegmentControl.selectedSegmentIndex;
}

- (IBAction)refreshTableView:(id)sender {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (listSegmentControl.selectedSegmentIndex == 0){
        return 3;
    }else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"%@",self.dataToLoad);
    if (listSegmentControl.selectedSegmentIndex == 0){
        if (section == 0) {
            return self.savedNamedBookmarks.count;
        }else if (section == 1){
            return self.savedRoutes.count;
        }else{
            return self.savedStops.count;
        }
    }
    return self.dataToLoad.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataIndex = [self dataIndexForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
    if (dataIndex < self.dataToLoad.count) {
        @try {
            if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[HistoryEntity class]]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
                
                StopEntity *stopEntity = [StopEntity alloc];
                if (dataIndex < self.dataToLoad.count) {
                    stopEntity = [self.dataToLoad objectAtIndex:dataIndex];
                }
                
                UILabel *title = (UILabel *)[cell viewWithTag:2002];
                UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
                UILabel *dateLabel = (UILabel *)[cell viewWithTag:2004];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                
                title.text = stopEntity.busStopName;
                //stopName.font = CUSTOME_FONT_BOLD(23.0f);
                
                subTitle.text = [NSString stringWithFormat:@"%@ - %@", stopEntity.busStopShortCode, stopEntity.busStopCity];
                //cityName.font = CUSTOME_FONT_BOLD(19.0f);
                if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[HistoryEntity class]]) {
                    dateLabel.hidden = NO;
                    dateLabel.text = [ReittiStringFormatter formatPrittyDate:stopEntity.dateModified];
                }else{
                    dateLabel.hidden = YES;
                }
            }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[NamedBookmark class]]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"namedBookmarkCell"];
                
                NamedBookmark *namedBookmark = [NamedBookmark alloc];
                if (dataIndex < self.dataToLoad.count) {
                    namedBookmark = [self.dataToLoad objectAtIndex:dataIndex];
                }
                
                UIImageView *imageView = (UIImageView *)[cell viewWithTag:2001];
                UILabel *title = (UILabel *)[cell viewWithTag:2002];
                UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                
                [imageView setImage:[UIImage imageNamed:namedBookmark.iconPictureName]];
                
                title.text = namedBookmark.name;
                subTitle.text = [NSString stringWithFormat:@"%@, %@", namedBookmark.streetAddress, namedBookmark.city];
                
                UIScrollView *transportsScrollView = (UIScrollView *)[cell viewWithTag:2004];
                UILabel *leavesTime = (UILabel *)[cell viewWithTag:2005];
                UILabel *arrivesTime = (UILabel *)[cell viewWithTag:2006];
                
                if (![self shouldUpdateRouteInfoForBookmark:namedBookmark]) {
                    NSArray * routes = [namedBRouteDetail objectForKey:namedBookmark.coords];
                    Route *route = [routes firstObject];
                    
                    if (!route.isOnlyWalkingRoute) {
                        transportsScrollView.hidden = NO;
                        leavesTime.hidden = NO;
                        arrivesTime.hidden = NO;
                        
                        for (UIView * view in transportsScrollView.subviews) {
                            [view removeFromSuperview];
                        }
                        
                        UIView *transportsView = [RouteViewManager viewForRoute:route longestDuration:[route.routeDurationInSeconds floatValue] width:transportsScrollView.frame.size.width - 30];
                        
                        [transportsScrollView addSubview:transportsView];
                        //                    transportsScrollView.contentSize = CGSizeMake(transportsView.frame.size.width, transportsView.frame.size.height);
                        transportsScrollView.userInteractionEnabled = NO;
                        [cell.contentView addGestureRecognizer:transportsScrollView.panGestureRecognizer];
                        
                        leavesTime.text = [NSString stringWithFormat:@"leave at %@ ", [ReittiStringFormatter formatHourStringFromDate:route.getStartingTimeOfRoute]];
                        arrivesTime.text = [NSString stringWithFormat:@"| arrive at %@", [ReittiStringFormatter formatHourStringFromDate:route.getEndingTimeOfRoute]];
                    }else{
                        transportsScrollView.hidden = YES;
                        leavesTime.hidden = YES;
                        arrivesTime.hidden = YES;
                    }
                }else{
                    transportsScrollView.hidden = YES;
                    leavesTime.hidden = YES;
                    arrivesTime.hidden = YES;
                    
                    [self fetchRouteForNamedBookmark:namedBookmark];
                }
                
                //cityName.font = CUSTOME_FONT_BOLD(19.0f);
            }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteEntity class]]){
                cell = [tableView dequeueReusableCellWithIdentifier:@"savedRouteCell"];
                
                RouteEntity *routeEntity = [RouteEntity alloc];
                if (dataIndex < self.dataToLoad.count) {
                    routeEntity = [self.dataToLoad objectAtIndex:dataIndex];
                }
                
                UILabel *title = (UILabel *)[cell viewWithTag:2002];
                UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
                UILabel *dateLabel = (UILabel *)[cell viewWithTag:2004];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                
                title.text = routeEntity.toLocationName;
                //stopName.font = CUSTOME_FONT_BOLD(23.0f);
                
                subTitle.text = [NSString stringWithFormat:@"%@", routeEntity.fromLocationName];
                
                if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteHistoryEntity class]]) {
                    dateLabel.hidden = NO;
                    dateLabel.text = [ReittiStringFormatter formatPrittyDate:routeEntity.dateModified];
                }else{
                    dateLabel.hidden = YES;
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception when displaying table: %@", [exception description]);
            //This is to leave on extra empty row
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listSegmentControl.selectedSegmentIndex == 0) {
        NSInteger dataIndex = [self dataIndexForIndexPath:indexPath];
        
        if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[NamedBookmark class]]) {
            return [self bookmarkHasValidRouteInfo:[self.dataToLoad objectAtIndex:dataIndex]] ? 135 : 60;
        }else{
            return 60;
        }
    }else{
        return 60;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (listSegmentControl.selectedSegmentIndex == 0) {
        return 30;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (listSegmentControl.selectedSegmentIndex == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 60, 30)];
        titleLabel.font = [titleLabel.font fontWithSize:14];
        titleLabel.textColor = [UIColor darkGrayColor];
        if (section == 0) {
            titleLabel.text = @"   LOCATIONS";
            activityIndicator.center = CGPointMake(self.view.frame.size.width - 30, 15);
            [view addSubview:activityIndicator];
        }else if (section == 1){
            titleLabel.text = @"   SAVED ROUTES";
        }else{
            titleLabel.text = @"   SAVED STOPS";
        }
        
        [view addSubview:titleLabel];
        
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        
        return view;
    }else{
        return nil;
    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    NSInteger dataIndex = [self dataIndexForIndexPath:indexPath];
    if (dataIndex < self.dataToLoad.count) {
        return YES;
    }else{
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger dataIndex = [self dataIndexForIndexPath:indexPath];
        StopEntity *deletedStop;
        RouteEntity *deletedRoute;
        NamedBookmark *deletedNamedBookmark;
        if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[HistoryEntity class]]) {
            deletedStop = [dataToLoad objectAtIndex:dataIndex];
            [dataToLoad removeObject:deletedStop];
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteEntity class]]){
            deletedRoute = [dataToLoad objectAtIndex:dataIndex];
            [dataToLoad removeObject:deletedRoute];
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[NamedBookmark class]]){
            deletedNamedBookmark = [dataToLoad objectAtIndex:dataIndex];
            [dataToLoad removeObject:deletedNamedBookmark];
        }
        // Delete the row from the data source
        
        if (mode == 0) {
            if (deletedRoute != nil) {
//                [delegate deletedSavedRouteForCode:deletedRoute.routeUniqueName];
                [self.reittiDataManager deleteSavedRouteForCode:deletedRoute.routeUniqueName];
                [savedRoutes removeObject:deletedRoute];
            }else if (deletedNamedBookmark != nil) {
                [self.reittiDataManager deleteNamedBookmarkForName:deletedNamedBookmark.name];
                [savedNamedBookmarks removeObject:deletedNamedBookmark];
            }else{
                [self.reittiDataManager deleteSavedStopForCode:deletedStop.busStopCode];
                [savedStops removeObject:deletedStop];
            }
        }else{
            if (deletedRoute != nil) {
//                [delegate deletedHistoryRouteForCode:deletedRoute.routeUniqueName];
                [self.reittiDataManager deleteHistoryRouteForCode:deletedRoute.routeUniqueName];
                [recentRoutes removeObject:deletedRoute];
            }else{
                [self.reittiDataManager deleteHistoryStopForCode:deletedStop.busStopCode];
                [recentStops removeObject:deletedStop];
            }
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (![self.reittiDataManager fetchAllSavedStopsFromCoreData]) {
            [self hideWidgetSettingsButton:YES];
        }else{
            [self hideWidgetSettingsButton:NO];
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - helper methods
- (BOOL)shouldUpdateRouteInfoForBookmark:(NamedBookmark *)namedBookmark {
    NSMutableArray *routes = [[namedBRouteDetail objectForKey:namedBookmark.coords] mutableCopy];
    
    if (routes.count == 0)
        return YES;
    
    CLLocationDistance dist = [previousCenteredLocation distanceFromLocation:self.currentUserLocation];
    if (dist > 100) {
//        [self.tableView reloadData];
        return YES;
    }
    
    for (int i = 0; i < routes.count;i++) {
        Route *route = [routes objectAtIndex:i];
        if ([route.getStartingTimeOfRoute timeIntervalSinceNow] < 0){
            if (route.isOnlyWalkingRoute) {
                if ([route.getStartingTimeOfRoute timeIntervalSinceNow] < -600){
                    return YES;
                }else{
                    return NO;
                }
            }
            [routes removeObject:route];
        }else{
            [namedBRouteDetail setObject:routes forKey:namedBookmark.coords];
            return NO;
        }
        
        if (i == routes.count - 1) {
            return YES;
        }
    }
    
    return YES;
}

- (BOOL)bookmarkHasValidRouteInfo:(NamedBookmark *)namedBookmark{
    
    if([self shouldUpdateRouteInfoForBookmark:namedBookmark]){
        return NO;
    }else{
        NSMutableArray *routes = [[namedBRouteDetail objectForKey:namedBookmark.coords] mutableCopy];
        Route *route = [routes objectAtIndex:0];
        
        if (route.isOnlyWalkingRoute)
            return NO;
        
        return YES;
    }
}

- (NSInteger)dataIndexForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataIndex;
    BOOL isBookmarksView = listSegmentControl.selectedSegmentIndex == 0;
    if (isBookmarksView) {
        if (indexPath.section == 0) {
            dataIndex = indexPath.row;
        }else if (indexPath.section == 1){
            dataIndex = indexPath.row + savedNamedBookmarks.count;
        }else{
            dataIndex = indexPath.row + savedNamedBookmarks.count + savedRoutes.count;
        }
    }else{
        dataIndex = indexPath.row;
    }
    return dataIndex;
}

- (NSIndexPath *)nsIndexForNamedBookmarkCoords:(NSString *)namedBookmarkCoords{
    NSIndexPath * indexPathToUpdate = [NSIndexPath indexPathForRow:0 inSection:0];
    for (int i=0; i < self.savedNamedBookmarks.count; i++) {
        NamedBookmark *bookmark = [self.savedNamedBookmarks objectAtIndex:i];
        if ([bookmark.coords isEqualToString:namedBookmarkCoords]) {
            indexPathToUpdate = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
    }
    
    return indexPathToUpdate;
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Delegates

- (void)savedStop:(BusStop *)busStop{
    if (mode == 0) {
        [dataToLoad addObject:busStop];
        [savedStops addObject:busStop];
        [self.tableView reloadData];
    }else{
        [savedStops addObject:busStop];
    }
    
}
- (void)deletedSavedStop:(BusStop *)busStop{
    if (mode == 0) {
        [dataToLoad removeObject:busStop];
        [savedStops removeObject:busStop];
        [self.tableView reloadData];
    }else{
        [savedStops removeObject:busStop];
    }
    
}
- (void)routeModified{
    //Fetch saved route list again
    savedRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRoutesFromCoreData]];
    
    recentRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData]];
}

#pragma mark - helper methods
- (void)loadSavedValues{
    NSArray * sStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
    NSArray * sRoutes = [self.reittiDataManager fetchAllSavedRoutesFromCoreData];
    NSArray * rStops = [self.reittiDataManager fetchAllSavedStopHistoryFromCoreData];
    NSArray * rRoutes = [self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData];
    NSArray * namedBookmarks = [self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData];
    
    self.savedStops = [NSMutableArray arrayWithArray:sStops];
    self.savedRoutes = [NSMutableArray arrayWithArray:sRoutes];
    self.recentStops = [NSMutableArray arrayWithArray:rStops];
    self.recentRoutes = [NSMutableArray arrayWithArray:rRoutes];
    self.savedNamedBookmarks = [NSMutableArray arrayWithArray:namedBookmarks];
    
    [self updateDetailStores];
}

- (NSMutableArray *)sortDataArray:(NSMutableArray *)array{
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        //We can cast all types to ReittiManagedObjectBase since we are only interested in the date modified property
        NSDate *first = [(ReittiManagedObjectBase*)a dateModified];
        NSDate *second = [(ReittiManagedObjectBase*)b dateModified];
        
        if (first == nil) {
            return NSOrderedDescending;
        }
        
        //Decending by date - latest to earliest
        return [second compare:first];
    }];
    
    return [NSMutableArray arrayWithArray:sortedArray];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataIndex = [self dataIndexForIndexPath:indexPath];
    if (dataIndex < self.dataToLoad.count) {
        //StopEntity * selected = [self.dataToLoad objectAtIndex:indexPath.row];
        //[self dismissViewControllerAnimated:YES completion:nil ];
    }
}

#pragma mark - Route search delegate methods
- (void)routeSearchDidComplete:(NSArray *)routeList{
    Route *first = [routeList firstObject];
    [namedBRouteDetail setObject:routeList forKey:[first getDestinationCoords]];
    //Update affected row is slow in performance
//    NSIndexPath *indexPathToUpdate = [self nsIndexForNamedBookmarkCoords:[first getDestinationCoords]];
    
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathToUpdate, nil] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
    [activityIndicator stopAnimating];
}
- (void)routeSearchDidFail:(NSString *)error{
    [activityIndicator stopAnimating];
}

#pragma mark - iAd methods
-(void)initAdBannerView{
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else {
        _bannerView = [[ADBannerView alloc] init];
    }
    _bannerView.delegate = self;
    
    CGRect bannerFrame = _bannerView.frame;
    bannerFrame.origin.y = self.view.bounds.size.height;
    _bannerView.frame = bannerFrame;
    
    [self.view addSubview:_bannerView];
}

- (void)layoutAnimated:(BOOL)animated
{
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    CGRect contentFrame = self.view.bounds;
    if (contentFrame.size.width < contentFrame.size.height) {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    
    CGRect bannerFrame = _bannerView.frame;
    bannerFrame.origin.y = contentFrame.size.height;
    _bannerView.frame = bannerFrame;
    if (_bannerView.bannerLoaded) {
        contentFrame.size.height -= _bannerView.frame.size.height + self.navigationController.toolbar.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        //cardView.frame = contentFrame;
        _bannerView.frame = bannerFrame;
    }];
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES ;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}


#pragma mark - Seague
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    NSInteger dataIndex = [self dataIndexForIndexPath:selectedRowIndexPath];
    if (dataIndex < self.dataToLoad.count)
        return YES;
    return NO;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    NSInteger dataIndex = [self dataIndexForIndexPath:selectedRowIndexPath];
    
    if ([segue.identifier isEqualToString:@"bookmarkSelected"]) {
        if (dataIndex < self.dataToLoad.count) {
            if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[HistoryEntity class]]) {
                
                StopEntity * selected = [self.dataToLoad objectAtIndex:dataIndex];
                
                UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
                StopViewController *stopViewController =[[navigationController viewControllers] lastObject];
                stopViewController.stopCode = [NSString stringWithFormat:@"%d", [selected.busStopCode intValue]];
                stopViewController.stopCoords = [ReittiStringFormatter convertStringTo2DCoord:selected.busStopWgsCoords];
                stopViewController.stopEntity = selected;
//                stopViewController.reittiDataManager = self.reittiDataManager;
                stopViewController.droppedPinGeoCode = self.droppedPinGeoCode;
                stopViewController.managedObjectContext = self.reittiDataManager.managedObjectContext;
                stopViewController.backButtonText = self.title;
                stopViewController.delegate = self;
            }
        }
    }else if ([segue.identifier isEqualToString:@"routeSelected"]){
        if (dataIndex < self.dataToLoad.count){
            if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteEntity class]]){
                
                RouteEntity * selected = [self.dataToLoad objectAtIndex:dataIndex];
                
                UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
                RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
                
                routeSearchViewController.prevToLocation = selected.toLocationName;
                routeSearchViewController.prevToCoords = selected.toLocationCoordsString;
                routeSearchViewController.prevFromLocation = selected.fromLocationName;
                routeSearchViewController.prevFromCoords = selected.fromLocationCoordsString;
                routeSearchViewController.droppedPinGeoCode = self.droppedPinGeoCode;
                
                routeSearchViewController.delegate = self;
                routeSearchViewController.managedObjectContext = self.reittiDataManager.managedObjectContext;
            }
        }
    }else if ([segue.identifier isEqualToString:@"routeToNamedBookmark"]){
        if (dataIndex < self.dataToLoad.count){
            if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[NamedBookmark class]]){
                
                NamedBookmark * selected = [self.dataToLoad objectAtIndex:dataIndex];
                
                UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
                RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
                
                routeSearchViewController.prevToLocation = selected.name;
                routeSearchViewController.prevToCoords = selected.coords;
                
                routeSearchViewController.droppedPinGeoCode = self.droppedPinGeoCode;
                
                routeSearchViewController.delegate = self;
                routeSearchViewController.managedObjectContext = self.reittiDataManager.managedObjectContext;
            }
        }
    }else if([segue.identifier isEqualToString:@"editSelectionForWidget"]){
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        WidgetSettingsViewController *controller = (WidgetSettingsViewController *)[[navigationController viewControllers] lastObject];
        
        controller.savedStops = self.savedStops;
        
    }else if([segue.identifier isEqualToString:@"addAddress"]){
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
         EditAddressTableViewController *controller = (EditAddressTableViewController *)[[navigationController viewControllers] lastObject];
        controller.droppedPinGeoCode = self.droppedPinGeoCode;
        controller.managedObjectContext = self.reittiDataManager.managedObjectContext;
        controller.viewControllerMode = ViewControllerModeAddNewAddress;
        
    }else if([segue.identifier isEqualToString:@"namedBookmarkSelected"]){
        if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[NamedBookmark class]]) {
            
            NamedBookmark * selected = [self.dataToLoad objectAtIndex:dataIndex];
            
            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
            EditAddressTableViewController *controller = (EditAddressTableViewController *)[[navigationController viewControllers] lastObject];
            
            controller.namedBookmark = selected;
            controller.droppedPinGeoCode = self.droppedPinGeoCode;
            controller.viewControllerMode = ViewControllerModeViewNamedBookmark;
            controller.managedObjectContext = self.reittiDataManager.managedObjectContext;
        }
    }
}

- (void)dealloc
{
    NSLog(@"BookmarksController:This bitchass ARC deleted my UIView.");
}

@end
