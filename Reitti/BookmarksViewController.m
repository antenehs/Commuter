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
#import "SearchController.h"
#import "RouteViewManager.h"
#import "AppManager.h"
#import "CoreDataManager.h"
#import "EmptyWorkAddressCell.h"
#import "EmptyHomeAddressCell.h"
#import "EmptyBookmarkCell.h"
#import "DroppedPinManager.h"
#import "ASA_Helpers.h"
#import "TableViewCells.h"
#import "MainTabBarController.h"
#import "ReittiDateFormatter.h"

const NSInteger kTimerRefreshInterval = 60;

@interface BookmarksViewController ()

@property (nonatomic, strong) id previewingContext;
@property (nonatomic, readonly) BOOL showRouteSuggestions;
@property (nonatomic, readonly) BOOL showStopDepartures;

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
@synthesize savedRoutes, recentRoutes;
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
    trackedMoveOnce = NO;
    trackedNumbersOnce = NO;
    swipedToDelete = NO;
    
    namedBookmarkSection = 0, savedStopsSection = 1, savedRouteSection = 2;

    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:[[CoreDataManager sharedManager] managedObjectContext]];
        
        if (settingsManager == nil) {
            settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        }
        
        [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    }
    
    [self loadSavedValues];
    
    if (([settingsManager userLocation] != HSLRegion) || settingsManager == nil) {
        self.canDisplayBannerAds = NO;
    }
    
    listSegmentControl.selectedSegmentIndex = self.mode;
    [self setUpViewForTheSelectedMode];
    
    [self.tableView setBlurredBackgroundWithImageNamed:nil];
    
    self.tableView.rowHeight = 60;
    
    [self initNamedBookmarkRouteDictionary];
    [self initLocationManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeSearchOptionsChanged:)
                                                 name:routeSearchOptionsChangedNotificationName object:nil];
    
    boomarkActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    boomarkActivityIndicator.alpha = 1.0;
    boomarkActivityIndicator.hidesWhenStopped = YES;
    
    stopActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    stopActivityIndicator.alpha = 1.0;
    stopActivityIndicator.hidesWhenStopped = YES;
    
    [self.navigationItem setTitle:@""];
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"StopTableViewCell" bundle:nil] forCellReuseIdentifier:@"savedStopCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RouteTableViewCell" bundle:nil] forCellReuseIdentifier:@"savedRouteCell"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"NamedBookmarkTableViewCell" bundle:nil] forCellReuseIdentifier:@"namedBookmarkCell"];
    
    /* Register 3D touch for Peek and Pop if available */
    [self registerFor3DTouchIfAvailable];
    
    //Editing
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self.navigationController setToolbarHidden:!self.tableView.isEditing animated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadSavedValues];
    
    [self setEditing:NO animated:YES];
    [self setUpViewForTheSelectedMode];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerRefreshInterval target:self selector:@selector(refreshDetailData:) userInfo:nil repeats:YES];
    [locationManager startUpdatingLocation];
    
    [self setICloudButtonAvailablility];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
//    NSLog(@"will enter foreground notification");
    [self refreshDetailData:self];
    
    [self setICloudButtonAvailablility];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerRefreshInterval target:self selector:@selector(refreshDetailData:) userInfo:nil repeats:YES];
    [locationManager startUpdatingLocation];
}

- (void)appWillEnterBackground:(NSNotification *)notification {
//    NSLog(@"will enter background notification");
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

- (void)setICloudButtonAvailablility {
    if (![ICloudManager isICloudContainerAvailable]) {
        self.navigationItem.leftBarButtonItem.customView.hidden = YES;
    } else {
        self.navigationItem.leftBarButtonItem.customView.hidden = NO;
    }
}

- (void)initNamedBookmarkRouteDictionary{
    //Init data
    if (namedBRouteDetail == nil)
        namedBRouteDetail = [[NSMutableDictionary alloc] init];
    
    for (NamedBookmark *nmdBkmrk in self.savedNamedBookmarks) {
        if ([self getRoutesForNamedBookmark:nmdBkmrk] == nil) {
            [self setRoutesForNamedBookmark:nmdBkmrk routes:[NSArray new]];
        }
    }
}

- (NSArray *)getRoutesForNamedBookmark:(NamedBookmark *)namedBookmark{
    return [namedBRouteDetail objectForKey:[namedBookmark getUniqueIdentifier]];
}

- (void)setRoutesForNamedBookmark:(NamedBookmark *)namedBookmark routes:(NSArray *)routes{
    if (namedBookmark && [namedBookmark getUniqueIdentifier] != nil) {
        [namedBRouteDetail setValue:routes forKey:[namedBookmark getUniqueIdentifier]];
    }
}

- (void)clearNamedBookmarkRouteDictionary{
    self.namedBRouteDetail = [@{} mutableCopy];
}

- (void)requestRoutesIfNeeded{
    if (!self.showRouteSuggestions) return;
    [self fetchRouteForNamedBookmarks:self.savedNamedBookmarks];
}

- (void)requestStopDetailsIfNeeded{
    if (!self.showStopDepartures) return;
    [self fetchStopDetailForBusStops:self.savedStops];
}

- (void)refreshDetailData:(id)sender {
    [self requestRoutesIfNeeded];
    [self requestStopDetailsIfNeeded];
}

- (void)forceResetRoutesAndRequest{
    //Reset already searched routes to force new route fetching
    [self clearNamedBookmarkRouteDictionary];
    [self requestRoutesIfNeeded];
}

- (void)fetchRouteForNamedBookmarks:(NSArray *)namedBookmarks
{
    if (!namedBookmarks || namedBookmarks.count < 1)
        return;
    
    __block NSInteger numberOfBookmarks = 0;
    
    for (NamedBookmark *namedBookmark in namedBookmarks) {
        if ([self bookmarkHasValidRouteInfo:namedBookmark] || !self.currentUserLocation)
            continue;
        
        //Check if it should be updated because walking routes are not considered true. this method check if a new walking route should be fetched.
        if (![self shouldUpdateRouteInfoForBookmark:namedBookmark])
            continue;
        
        [boomarkActivityIndicator startAnimating];
        showRoutesButton.hidden = YES;
        numberOfBookmarks ++;
        
        [self.reittiDataManager searchRouteForFromCoords:[ReittiStringFormatter convert2DCoordToString:[currentUserLocation coordinate]] andToCoords:namedBookmark.coords andCompletionBlock:^(NSArray *result, NSString *error, ReittiApi usedApi){
            if (!error) {
                [self setRoutesForNamedBookmark:namedBookmark routes:result];
            }else{
                [self setRoutesForNamedBookmark:namedBookmark routes:nil];
            }
            
            [self.tableView asa_reloadDataAnimated];
            numberOfBookmarks--;
            if (numberOfBookmarks == 0) {
                [boomarkActivityIndicator stopAnimating];
                showRoutesButton.hidden = NO;
            }
        }];
    }
    
//    if (self.currentUserLocation) {
//        [activityIndicator startAnimating];
//        [self.reittiDataManager searchRouteForFromCoords:[ReittiStringFormatter convert2DCoordToString:[currentUserLocation coordinate]] andToCoords:namedBookmark.coords andCompletionBlock:^(NSArray *result, NSString *error){
//            if (!error) {
//                [self routeSearchDidComplete:result forBookmark:namedBookmark];
//            }else{
//                [self routeSearchDidFail:error];
//            }
//        }];
//    }
}

- (void)fetchStopDetailForBusStops:(NSArray *)stopEntitys{
    if (!stopEntitys || stopEntitys.count < 1)
        return;
    
    __block NSInteger numberOfStops = 0;
    
    for (StopEntity *stopEntity in stopEntitys) {
        if ([self isthereValidDetailForStop:stopEntity])
            continue;
        
        [stopActivityIndicator startAnimating];
        showDeparturesButton.hidden = YES;
        numberOfStops ++;
        
        RTStopSearchParam *searchParam = [RTStopSearchParam new];
        searchParam.longCode = [stopEntity.busStopCode stringValue];
        searchParam.shortCode = stopEntity.busStopShortCode;
        searchParam.stopName = stopEntity.busStopName;
        
        [self.reittiDataManager fetchStopsForSearchParams:searchParam andCoords:[ReittiStringFormatter convertStringTo2DCoord:stopEntity.busStopCoords] withCompletionBlock:^(BusStop *stop, NSString *errorString){
            if (!errorString) {
                [self setDetailStopForBusStop:stopEntity busStop:stop];
                [self.tableView asa_reloadDataAnimated];
            }
            
            numberOfStops--;
            if (numberOfStops == 0) {
                [stopActivityIndicator stopAnimating];
                showDeparturesButton.hidden = NO;
            }
        }];
    }
}


#pragma mark - View methods

- (void)setUpViewForTheSelectedMode{
    if (listSegmentControl.selectedSegmentIndex == 0) {
        dataToLoad = nil;
        if (savedNamedBookmarks.count == 0) {
            EmptyHomeAddressCell *hCell = [[EmptyHomeAddressCell alloc] init];
            EmptyWorkAddressCell *wCell = [[EmptyWorkAddressCell alloc] init];
            
            dataToLoad = [[NSMutableArray alloc] initWithArray:@[hCell,wCell]];
        }else if (savedNamedBookmarks.count > 0){
            //Identify what location type is missing and add it
            dataToLoad = [[NSMutableArray alloc] init];
            [dataToLoad addObjectsFromArray:savedNamedBookmarks];
            
            if (!self.tableView.isEditing) {
                if (![self isHomeAddressCreated]) {
                    [dataToLoad addObject:[[EmptyHomeAddressCell alloc] init]];
                }
                
                if (![self isWorkAddressCreated]) {
                    [dataToLoad addObject:[[EmptyWorkAddressCell alloc] init]];
                }
            }
        }
        
        if (savedStops.count == 0) {
            EmptyBookmarkCell *bCell = [[EmptyBookmarkCell alloc] init];
            [dataToLoad addObject:bCell];
        }else{
            [dataToLoad addObjectsFromArray:savedStops];
        }
        
        if (savedRoutes.count == 0) {
            EmptyBookmarkCell *bCell = [[EmptyBookmarkCell alloc] init];
            [dataToLoad addObject:bCell];
        }else{
            [dataToLoad addObjectsFromArray:savedRoutes];
        }
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self refreshDetailData:self];
    }else{
        dataToLoad = nil;
        dataToLoad = [[NSMutableArray alloc] initWithArray:recentRoutes];
        [dataToLoad addObjectsFromArray:recentStops];
        self.dataToLoad = [self sortDataArray:dataToLoad];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView reloadData];
}

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

-(void)updateDetailToggleButtonTitles {
    [showRoutesButton setTitle:!self.showRouteSuggestions ? NSLocalizedString(@"SHOW ROUTES", @"SHOW ROUTES") : NSLocalizedString(@"HIDE ROUTES", @"HIDE ROUTES") forState:UIControlStateNormal];

    [showDeparturesButton setTitle:!self.showStopDepartures ? NSLocalizedString(@"SHOW DEPARTURES", @"SHOW DEPARTURES") : NSLocalizedString(@"HIDE DEPARTURES", @"HIDE DEPARTURES") forState:UIControlStateNormal];
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
//    NSLog(@"%d",[CLLocationManager authorizationStatus]);
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
        [self requestRoutesIfNeeded];
        firstTimeLocation = NO;
    }
}

#pragma mark - ibactions
-(void)routeSearchOptionsChanged:(id)sender {
    [self forceResetRoutesAndRequest];
}

- (IBAction)clearAllButtonPressed:(id)sender {
    // Delete the row from the data source
    if (dataToLoad.count > 0) {
        NSString * message;
        if (mode == 0) {
            message  = NSLocalizedString(@"Hold on! Are you sure you want to delete all your bookmarks? This action cannot be undone", @"Hold on! Are you sure you want to delete all your bookmarks? This action cannot be undone");
        }else{
            message  = NSLocalizedString(@"Hold on! Are you sure you want to delete all your history? This action cannot be undone", @"Hold on! Are you sure you want to delete all your history? This action cannot be undone");
        }
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:message
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                   destructiveButtonTitle:NSLocalizedString(@"Delete", @"Delete")
                                                        otherButtonTitles:nil];
        
        [actionSheet showInView:self.view];
    }    
}

- (IBAction)addBookmarkButtonPressed:(id)sender {
    [self openAddBookmarkController];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    if (buttonIndex == 0) {
        if (mode == 0) {
//            [delegate deletedAllSavedStops];
            [self.reittiDataManager deleteAllSavedStop];
            [self.reittiDataManager deleteAllSavedroutes];
            [self.reittiDataManager deleteAllNamedBookmarks];
            
            //NO need to hide the widget settings button
//            [self hideWidgetSettingsButton:YES];
        }else{
//            [delegate deletedAllHistoryStops];
            [self.reittiDataManager deleteAllHistoryStop];
            [self.reittiDataManager deleteAllHistoryRoutes];
        }
        
        [dataToLoad removeAllObjects];
        [self loadSavedValues];
        [self setUpViewForTheSelectedMode];
    }
}

- (IBAction)segmentControlValueChanged:(id)sender {
    
    [self setUpViewForTheSelectedMode];
    
    self.mode = (int)listSegmentControl.selectedSegmentIndex;
    
    if (listSegmentControl.selectedSegmentIndex == 1) {
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionInteractWithHistoryObject label:nil value:nil];
    }
}

- (IBAction)showRoutesButtonTapped:(id)sender {
    [SettingsManager setShowBookmarkRoutes:!self.showRouteSuggestions];
    
    [self updateDetailToggleButtonTitles];
    
    if (self.showRouteSuggestions) {
        [self.tableView asa_reloadDataAnimated];
        [self requestRoutesIfNeeded];
    }  else {
        [self.tableView reloadData];
    }
}

- (IBAction)showDeparturesButtonTapped:(id)sender {
    [SettingsManager setShowBookmarkDepartures:!self.showStopDepartures];
    
    [self updateDetailToggleButtonTitles];
    
    if (self.showStopDepartures) {
        [self.tableView asa_reloadDataAnimated];
        [self requestStopDetailsIfNeeded];
    } else {
        [self.tableView reloadData];
    }
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
    if (listSegmentControl.selectedSegmentIndex == 0){
        if (section == namedBookmarkSection) {
            NSInteger emptyHome = [self isHomeAddressCreated] || tableView.isEditing ? 0 : 1;
            NSInteger emptyWork = [self isWorkAddressCreated] || tableView.isEditing ? 0 : 1;
            return self.savedNamedBookmarks.count > 0 ? self.savedNamedBookmarks.count + emptyHome + emptyWork: 2;
        }else if (section == savedRouteSection){
            return self.savedRoutes.count > 1 ? self.savedRoutes.count : 1;
        }else{
            return self.savedStops.count > 1 ? self.savedStops.count : 1;
        }
    }
    return self.dataToLoad.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataIndex = [self dataIndexForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
    
    @try {
        if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[EmptyHomeAddressCell class]] ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"setHomeAddressCell"];
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[EmptyWorkAddressCell class]] ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"setWorkAddressCell"];
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[EmptyBookmarkCell class]] && indexPath.section == savedRouteSection){
            cell = [tableView dequeueReusableCellWithIdentifier:@"nothingSavedCell"];
            UILabel *title = (UILabel *)[cell viewWithTag:1001];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:1002];
            
            title.text = NSLocalizedString(@"No routes bookmarked yet", @"No routes bookmarked yet");
            subTitle.text = NSLocalizedString(@"Press on the star icon on your route search result for easy access later.", @"Press on the star icon on your route search result for easy access later.");
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[EmptyBookmarkCell class]] && indexPath.section == savedStopsSection){
            cell = [tableView dequeueReusableCellWithIdentifier:@"nothingSavedCell"];
            UILabel *title = (UILabel *)[cell viewWithTag:1001];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:1002];
            
            title.text = NSLocalizedString(@"No stops bookmarked yet", @"No stops bookmarked yet");
            subTitle.text = NSLocalizedString(@"Press on the star icon on the stop view and you'll be amazed how much time you'll save.", @"Press on the star icon on the stop view and you'll be amazed how much time you'll save.");
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[HistoryEntity class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
            
            StopEntity *stopEntity = [StopEntity alloc];
            if (dataIndex < self.dataToLoad.count) {
                stopEntity = [self.dataToLoad objectAtIndex:dataIndex];
            }
            
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            UILabel *dateLabel = (UILabel *)[cell viewWithTag:2004];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:2005];
            imageView.image = [AppManager stopIconForStopType:stopEntity.stopType];
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.text = stopEntity.busStopName;
            //stopName.font = CUSTOME_FONT_BOLD(23.0f);
            
            if (stopEntity.busStopCity && ![stopEntity.busStopCity isEqualToString:@""]) {
                subTitle.text = [NSString stringWithFormat:@"%@ - %@", stopEntity.busStopShortCode, stopEntity.busStopCity];
            } else {
                subTitle.text = [NSString stringWithFormat:@"%@", stopEntity.busStopShortCode];
            }
            
            UICollectionView *collectionView = (UICollectionView *)[cell viewWithTag:2007];
            
            if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[HistoryEntity class]]) {
                dateLabel.hidden = NO;
                dateLabel.text = [[ReittiDateFormatter sharedFormatter] formatPrittyDate:stopEntity.dateModified];
                collectionView.hidden = YES;
                collectionView.restorationIdentifier = nil; /* Just to be sure */
            }else{
                dateLabel.hidden = YES;
                if ([self isthereValidDetailForStop:[self.dataToLoad objectAtIndex:dataIndex]] && self.showStopDepartures) {
                    collectionView.hidden = NO;
                    collectionView.restorationIdentifier = [NSString stringWithFormat:@"%li", (long)indexPath.row, nil];
                    collectionView.backgroundColor = [UIColor clearColor];
                    
                    collectionView.userInteractionEnabled = NO;
                    [cell.contentView addGestureRecognizer:collectionView.panGestureRecognizer];
                    
                    [collectionView reloadData];
                }else{
                    collectionView.hidden = YES;
                }
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
            subTitle.text = [NSString stringWithFormat:@"%@", [namedBookmark getFullAddress]];
            
            UIButton *editButton = (UIButton *)[cell viewWithTag:2007];
            UIView *separatorView = [cell viewWithTag:2008];
            
            editButton.hidden = tableView.isEditing;
            separatorView.hidden = tableView.isEditing;
            
            cell.accessoryType = tableView.isEditing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            
            UIScrollView *transportsScrollView = (UIScrollView *)[cell viewWithTag:2004];
            UILabel *leavesTime = (UILabel *)[cell viewWithTag:2005];
            UILabel *arrivesTime = (UILabel *)[cell viewWithTag:2006];
            
            transportsScrollView.hidden = YES;
            leavesTime.hidden = YES;
            arrivesTime.hidden = YES;
            
            if ([self bookmarkHasValidRouteInfo:namedBookmark] && self.showRouteSuggestions) {
                NSArray * routes = [self getRoutesForNamedBookmark:namedBookmark];
                Route *route = [routes firstObject];
                
                if (!route.isOnlyWalkingRoute) {
                    transportsScrollView.hidden = NO;
                    leavesTime.hidden = NO;
                    arrivesTime.hidden = NO;
                    
                    for (UIView * view in transportsScrollView.subviews) {
                        [view removeFromSuperview];
                    }
                    
                    UIView *transportsView = [RouteViewManager viewForRoute:route longestDuration:[route.routeDurationInSeconds floatValue] width:transportsScrollView.frame.size.width - 30 alwaysShowVehicle:NO];
                    
                    [transportsScrollView addSubview:transportsView];
                    transportsScrollView.userInteractionEnabled = NO;
                    [cell.contentView addGestureRecognizer:transportsScrollView.panGestureRecognizer];
                    
                    leavesTime.text = [NSString stringWithFormat:NSLocalizedString(@"leave at %@ ", @"leave at %@ "), [[ReittiDateFormatter sharedFormatter] formatHourStringFromDate:route.startingTimeOfRoute]];
                    arrivesTime.text = [NSString stringWithFormat:NSLocalizedString(@"| arrive at %@", @"| arrive at %@"), [[ReittiDateFormatter sharedFormatter] formatHourStringFromDate:route.endingTimeOfRoute]];
                }
            }else{
                transportsScrollView.hidden = YES;
                leavesTime.hidden = YES;
                arrivesTime.hidden = YES;
            }
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteEntity class]]){
            RouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedRouteCell"];
            
            RouteEntity *routeEntity = [RouteEntity alloc];
            if (dataIndex < self.dataToLoad.count) {
                routeEntity = [self.dataToLoad objectAtIndex:dataIndex];
            }
            
            if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteHistoryEntity class]]) {
                [cell setupFromHistoryEntity:(RouteHistoryEntity *)routeEntity];
            }else{
                [cell setupFromRouteEntity:routeEntity];
            }
            
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    }
    @catch (NSException *exception) {
//        NSLog(NSLog@"Exception when displaying table: %@", [exception description]);
        //This is to leave on extra empty row
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listSegmentControl.selectedSegmentIndex == 0) {
        
        NSInteger dataIndex = [self dataIndexForIndexPath:indexPath];
        
        if (savedNamedBookmarks.count < 1 && indexPath.section == namedBookmarkSection) {
            return 60;
        }else if (savedRoutes.count < 1 && indexPath.section == savedRouteSection){
            return 80;
        }else if (savedStops.count < 1 && indexPath.section == savedStopsSection){
            return 80;
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[NamedBookmark class]]) {
            return [self bookmarkHasValidRouteInfo:[self.dataToLoad objectAtIndex:dataIndex]] && self.showRouteSuggestions ? 135 : 60;
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[StopEntity class]]) {
            if ([self isthereValidDetailForStop:[self.dataToLoad objectAtIndex:dataIndex]] && self.showStopDepartures ){
                BusStop *stop = [self getDetailStopForBusStop:[self.dataToLoad objectAtIndex:dataIndex]];
                if (!stop.departures || stop.departures.count < 3) {
                    return 110;
                }else{
                    return 150;
                }
            }
            return 60;
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
        titleLabel.font = [titleLabel.font fontWithSize:13];
        titleLabel.textColor = [UIColor darkGrayColor];
        if (section == namedBookmarkSection) {
            titleLabel.text = NSLocalizedString(@"   LOCATIONS", @"   LOCATIONS");
            boomarkActivityIndicator.center = CGPointMake(self.view.frame.size.width - 30, 15);
            [view addSubview:boomarkActivityIndicator];
            
            showRoutesButton.frame = CGRectMake(self.view.frame.size.width - showRoutesButton.frame.size.width - 10, 3, showRoutesButton.frame.size.width, 24);
            [self updateDetailToggleButtonTitles];
            showRoutesButton.hidden = self.savedNamedBookmarks.count == 0 || tableView.isEditing;
            [view addSubview:showRoutesButton];
        }else if (section == savedRouteSection){
            titleLabel.text = NSLocalizedString(@"   SAVED ROUTES", @"   SAVED ROUTES");
        }else{
            titleLabel.text = NSLocalizedString(@"   SAVED STOPS", @"   SAVED STOPS");
            stopActivityIndicator.center = CGPointMake(self.view.frame.size.width - 30, 15);
            [view addSubview:stopActivityIndicator];
            showDeparturesButton.frame = CGRectMake(self.view.frame.size.width - showDeparturesButton.frame.size.width - 6, 3, showDeparturesButton.frame.size.width, 24);
            [self updateDetailToggleButtonTitles];
            showDeparturesButton.hidden = self.savedStops.count == 0  || tableView.isEditing;
            [view addSubview:showDeparturesButton];
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
        if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[EmptyHomeAddressCell class]] ||
            [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[EmptyWorkAddressCell class]] ||
            [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[EmptyBookmarkCell class]]) {
            return NO;
        }
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
            if (listSegmentControl.selectedSegmentIndex == 1)
                [dataToLoad removeObject:deletedStop];
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteEntity class]]){
            deletedRoute = [dataToLoad objectAtIndex:dataIndex];
            if (listSegmentControl.selectedSegmentIndex == 1)
                [dataToLoad removeObject:deletedRoute];
        }else if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[NamedBookmark class]]){
            deletedNamedBookmark = [dataToLoad objectAtIndex:dataIndex];
            if (listSegmentControl.selectedSegmentIndex == 1)
                [dataToLoad removeObject:deletedNamedBookmark];
        }
        // Delete the row from the data source
        
        if (mode == 0) {
            if (deletedRoute != nil) {
                [self.reittiDataManager deleteSavedRouteForCode:deletedRoute.routeUniqueName];
                [savedRoutes removeObject:deletedRoute];
            }else if (deletedNamedBookmark != nil) {
                [self.reittiDataManager deleteNamedBookmarkForName:deletedNamedBookmark.name];
                [savedNamedBookmarks removeObject:deletedNamedBookmark];
            }else{
                [self.reittiDataManager deleteSavedStop:deletedStop];
                [savedStops removeObject:deletedStop];
            }
        }else{
            if (deletedRoute != nil) {
                [self.reittiDataManager deleteHistoryRouteForCode:deletedRoute.routeUniqueName];
                [recentRoutes removeObject:deletedRoute];
            }else{
                [self.reittiDataManager deleteHistoryStopForCode:deletedStop.busStopCode];
                [recentStops removeObject:deletedStop];
            }
        }
        
        if (listSegmentControl.selectedSegmentIndex == 1) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [self loadSavedValues];
        if (listSegmentControl.selectedSegmentIndex == 0) {
            [self setUpViewForTheSelectedMode];
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

//Will be used to differentiate swipe to delete with edit button calling setEditing
-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
    
    swipedToDelete = YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate {
    [super setEditing:editing animated:animate];
    
    if (swipedToDelete) {
        swipedToDelete = NO;
    } else {
        if(editing) {
            [self.navigationController setToolbarHidden:NO animated:YES];
            showDeparturesButton.hidden = YES;
            showRoutesButton.hidden = YES;
        } else {
            [self.navigationController setToolbarHidden:YES animated:YES];
            showDeparturesButton.hidden = NO;
            showRoutesButton.hidden = NO;
        }
        
        [self setUpViewForTheSelectedMode];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if (fromIndexPath.section == namedBookmarkSection) {
        NSInteger adjustedFromIndex = fromIndexPath.row;
        NSInteger adjustedToIndex = toIndexPath.row;
        
        id movedBookmark = self.savedNamedBookmarks[adjustedFromIndex];
        [self.savedNamedBookmarks removeObject: movedBookmark];
        [self.savedNamedBookmarks insertObject:movedBookmark atIndex:adjustedToIndex];
        
        [self.reittiDataManager updateOrderedManagedObjectOrderTo:self.savedNamedBookmarks];
    } else if (fromIndexPath.section == savedStopsSection) {
        id movedStop = self.savedStops[fromIndexPath.row];
        [self.savedStops removeObject: movedStop];
        [self.savedStops insertObject:movedStop atIndex:toIndexPath.row];
        
        [self.reittiDataManager updateOrderedManagedObjectOrderTo:self.savedStops];
    } else {
        id movedRoute = self.savedRoutes[fromIndexPath.row];
        [self.savedRoutes removeObject: movedRoute];
        [self.savedRoutes insertObject:movedRoute atIndex:toIndexPath.row];
        
        [self.reittiDataManager updateOrderedManagedObjectOrderTo:self.savedRoutes];
    }
    
    [self loadSavedValues];
    
    if (!trackedMoveOnce) {
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionReorderedBookmarks label:@"" value:nil];
        trackedMoveOnce = YES;
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return listSegmentControl.selectedSegmentIndex == 0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataIndex = [self dataIndexForIndexPath:indexPath];
    if (dataIndex < self.dataToLoad.count) {
        if([self.dataToLoad[dataIndex] isKindOfClass:[RouteHistoryEntity class]]  || [self.dataToLoad[dataIndex] isKindOfClass:[RouteEntity class]]){
//            [self performSegueWithIdentifier:@"routeSelected" sender:self];
            RouteEntity * routeEntity = [self.dataToLoad objectAtIndex:dataIndex];
            
            RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:routeEntity.toLocationName toCoords:routeEntity.toLocationCoordsString fromLocation:routeEntity.fromLocationName fromCoords:routeEntity.fromLocationCoordsString];
            [self switchToRouteSearchViewWithRouteParameter:searchParms];
            
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSearchedRoute label:@"From saved route" value:nil];
        }else if([self.dataToLoad[dataIndex] isKindOfClass:[NamedBookmark class]]){
            //            [self performSegueWithIdentifier:@"routeSelected" sender:self];
            NamedBookmark *namedBookmark = [self.dataToLoad objectAtIndex:dataIndex];
            
            RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:namedBookmark.name toCoords:namedBookmark.coords fromLocation:nil fromCoords:nil];
            [self switchToRouteSearchViewWithRouteParameter:searchParms];
            
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSearchedRoute label:@"From named bookmark" value:nil];
        }
    }
    
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView.restorationIdentifier) {
        int row = [collectionView.restorationIdentifier intValue];
        if ([self isthereValidDetailForStop:self.savedStops[row]]) {
            BusStop *stop = [self getDetailStopForBusStop:self.savedStops[row]];
            return stop.departures ? stop.departures.count : 0;
        }
    }
    
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"departureCollectionCell" forIndexPath:indexPath];
    int row = [collectionView.restorationIdentifier intValue];
    
    BusStop *stop = [self getDetailStopForBusStop:self.savedStops[row]];
    
    StopDeparture *departure = stop.departures[indexPath.row];
    
    UILabel *lineName = (UILabel *)[cell viewWithTag:3001];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:3002];
    UIImageView *realtimeIndicatorImageView = (UIImageView *)[cell viewWithTag:3004];
    
    lineName.text = departure.code;
    lineName.textColor = [UIColor blackColor];
    
    NSDate *departureTime = departure.parsedScheduledDate;
    if (departure.isRealTime) {
        realtimeIndicatorImageView.hidden = NO;
//        timeLabel.textColor = [AppManager systemGreenColor];
        if (departure.parsedRealtimeDate) {
            departureTime = departure.parsedRealtimeDate;
        }
    } else {
        realtimeIndicatorImageView.hidden = YES;
//        timeLabel.textColor = [UIColor darkGrayColor];
    }
    
    NSString *formattedHour = [[ReittiDateFormatter sharedFormatter] formatHourStringFromDate:departureTime];
    if (!formattedHour || formattedHour.length < 1 ) {
        NSString *notFormattedTime = departure.time ;
        formattedHour = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
        timeLabel.text = formattedHour;
    } else {
        if ([departureTime timeIntervalSinceNow] < 300) {
            timeLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:formattedHour
                                                                               substring:formattedHour
                                                                          withNormalFont:timeLabel.font];
            ;
        }else{
            timeLabel.text = formattedHour;
        }
    }
    
    UIView *backgroundView = [cell viewWithTag:3003];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
//    backgroundView.backgroundColor = [AppManager colorForStopType:stop.stopType];
    
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
    
    return cell;
}

#pragma mark - UICollectionView Delegate

#pragma mark - Route detail methods
-(BOOL)showRouteSuggestions {
    return [SettingsManager showBookmarkRoutes] && !self.tableView.isEditing;
}

- (BOOL)shouldUpdateRouteInfoForBookmark:(NamedBookmark *)namedBookmark {
    if (![self isValidBookmarkForRouteSearch:namedBookmark])
        return NO;
    
    NSMutableArray *routes = [[self getRoutesForNamedBookmark:namedBookmark] mutableCopy];
    
    if (routes.count == 0)
        return YES;
    
    CLLocationDistance dist = [previousCenteredLocation distanceFromLocation:self.currentUserLocation];
    if (dist > 150) {
        return YES;
    }
    
    for (int i = 0; i < routes.count;i++) {
        Route *route = [routes objectAtIndex:i];
        if ([route.startingTimeOfRoute timeIntervalSinceNow] < 0){
            if (route.isOnlyWalkingRoute) {
                if ([route.startingTimeOfRoute timeIntervalSinceNow] < -600){
                    return YES;
                }else{
                    return NO;
                }
            }
            [routes removeObject:route];
        }else{
            [self setRoutesForNamedBookmark:namedBookmark routes:routes];
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
        if (![self isValidBookmarkForRouteSearch:namedBookmark])
            return NO;
        NSMutableArray *routes = [[self getRoutesForNamedBookmark:namedBookmark] mutableCopy];
        Route *route = [routes objectAtIndex:0];
        
        if (route.isOnlyWalkingRoute)
            return NO;
        
        return YES;
    }
}

/**
 Mean that route could be searched for the bookmarks
 */
- (BOOL)isValidBookmarkForRouteSearch:(NamedBookmark *)nmdBookmark{
    if (![nmdBookmark isKindOfClass:[NamedBookmark class]])
        return NO;
    
    if (!self.currentUserLocation) {
//        return [self.reittiDataManager canRouteBeSearchedBetweenCoordinates:self.currentUserLocation.coordinate andCoordinate:[ReittiStringFormatter convertStringTo2DCoord:nmdBookmark.coords]];;
        return NO;
    }
    
    return YES;
}

- (NSInteger)dataIndexForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataIndex;
    BOOL isBookmarksView = listSegmentControl.selectedSegmentIndex == 0;
    if (isBookmarksView) {
        //this will account for in case there is nothing saved and an empty cell is shown
        NSInteger emptyHome = [self isHomeAddressCreated] || self.tableView.isEditing ? 0 : 1;
        NSInteger emptyWork = [self isWorkAddressCreated] || self.tableView.isEditing ? 0 : 1;
        NSInteger numOfNamedBkmrks = self.savedNamedBookmarks.count > 0 ? self.savedNamedBookmarks.count + emptyHome + emptyWork : 2;
//        NSInteger numOfSavedRoutes = savedRoutes.count > 0 ? savedRoutes.count : 1;
        NSInteger numOfSavedStops = savedStops.count > 0 ? savedStops.count : 1;
//        NSInteger emptySavedStops = savedStops.count == 0 ? 1 : 0;
        if (indexPath.section == 0) {
            dataIndex = indexPath.row;
        }else if (indexPath.section == 1){
            dataIndex = indexPath.row + numOfNamedBkmrks;
        }else{
            dataIndex = indexPath.row + numOfNamedBkmrks + numOfSavedStops;
        }
    }else{
        dataIndex = indexPath.row;
    }
    return dataIndex;
}

-(NSInteger)indexOfEmptyBookmarkOfType:(Class)class {
    NSArray *filtered = [self.dataToLoad filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings){
        if ([(NSObject *)object isKindOfClass:class]) {
            return YES;
        }
        
        return NO;
    }]];
    
    if (filtered && filtered.count > 0) {
        return [self.dataToLoad indexOfObject:filtered[0]];
    }
    
    return NSNotFound;
}

#pragma mark - stop detail handling
-(BOOL)showStopDepartures {
    return [SettingsManager showBookmarkDepartures] && !self.tableView.isEditing;
}

-(NSMutableDictionary *)stopDetailMap{
    if (!_stopDetailMap) {
        _stopDetailMap = [@{} mutableCopy];
    }
    
    return _stopDetailMap;
}

- (BusStop *)getDetailStopForBusStop:(StopEntity *)stopEntity{
    return [self.stopDetailMap objectForKey:[stopEntity.busStopCode stringValue]];
}

- (void)setDetailStopForBusStop:(StopEntity *)stopEntity busStop:(BusStop *)stop{
    if (stop) {
        [self.stopDetailMap setValue:stop forKey:[stopEntity.busStopCode stringValue]];
    }
}

- (void)clearStopDetailMap{
    [self.stopDetailMap removeAllObjects];
}

- (BOOL)isthereValidDetailForStop:(StopEntity *)stopEntity{
    
    @try {
        BusStop *detailStop = [self getDetailStopForBusStop:stopEntity];
        
        if (!detailStop || !detailStop.departures || detailStop.departures.count < 1)
            return NO;
        
        NSMutableArray *departuresCopy = [detailStop.departures mutableCopy];
        for (int i = 0; i < departuresCopy.count;i++) {
            StopDeparture *departure = [departuresCopy objectAtIndex:i];
            if ([departure.parsedScheduledDate timeIntervalSinceNow] < 0){
                [departuresCopy removeObject:departure];
            }else{
                [detailStop setDepartures:departuresCopy];
                return YES;
            }
            
            if (i == departuresCopy.count - 1) {
                return NO;
            }
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
    
    return NO;
}

#pragma mark - Helpers

- (BOOL)isHomeAddressCreated{
    if (savedNamedBookmarks.count > 0) {
        NSArray *array = [savedNamedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isHomeAddress == true" ]];
        if (array != nil && array.count > 0) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isWorkAddressCreated{
    if (savedNamedBookmarks.count > 0) {
        NSArray *array = [savedNamedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isWorkAddress == true" ]];
        if (array != nil && array.count > 0) {
            return YES;
        }
    }
    
    return NO;
}

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
    
    [self initNamedBookmarkRouteDictionary];
    
    if (!trackedNumbersOnce) {
        [[ReittiAnalyticsManager sharedManager] trackUserProperty:kUserNumberOfNamedBookmarks value:[NSString stringWithFormat:@"%ld", namedBookmarks.count]];
        [[ReittiAnalyticsManager sharedManager] trackUserProperty:kUserNumberOfSavedStops value:[NSString stringWithFormat:@"%ld", sStops.count]];
        [[ReittiAnalyticsManager sharedManager] trackUserProperty:kUserNumberOfSavedRoutes value:[NSString stringWithFormat:@"%ld", sRoutes.count]];
        trackedNumbersOnce = YES;
    }
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

- (void)openAddBookmarkController {
    [self performSegueWithIdentifier:@"addAddress" sender:self];
}

#pragma mark - Delegates

- (void)savedStop:(BusStop *)busStop{
    if (mode == 0) {
        [dataToLoad addObject:busStop];
        [savedStops addObject:busStop];
        [self.tableView reloadData];
        [self refreshDetailData:self];
    }else{
        [savedStops addObject:busStop];
    }
    
}
- (void)deletedSavedStop:(BusStop *)busStop{
    if (mode == 0) {
        [dataToLoad removeObject:busStop];
        [savedStops removeObject:busStop];
        [self.tableView reloadData];
        [self refreshDetailData:self];
    }else{
        [savedStops removeObject:busStop];
    }
    
}
- (void)routeModified{
    //Fetch saved route list again
    savedRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRoutesFromCoreData]];
    
    recentRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData]];
}

- (NSArray *)sortedNamedBookmarksByLocationTo:(CLLocationCoordinate2D)coords{
    if (self.savedNamedBookmarks == nil) {
        return nil;
    }
    return [self.savedNamedBookmarks sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        if ([a isKindOfClass:[NamedBookmark class]] && [b isKindOfClass:[NamedBookmark class]]) {
            NamedBookmark *first = (NamedBookmark *)a;
            NamedBookmark *second = (NamedBookmark *)b;
            
            CLLocation *locA = [[CLLocation alloc] initWithLatitude:first.cl2dCoords.latitude longitude:first.cl2dCoords.longitude];
            CLLocation *locB = [[CLLocation alloc] initWithLatitude:second.cl2dCoords.latitude longitude:second.cl2dCoords.longitude];
            CLLocation *ref = [[CLLocation alloc] initWithLatitude:coords.latitude longitude:coords.longitude];
            
            CLLocationDistance distanceA = [locA distanceFromLocation:ref];
            CLLocationDistance distanceB = [locB distanceFromLocation:ref];
            
            if (distanceA > distanceB) {
                return NSOrderedDescending;
            }else if (distanceB > distanceA){
                return NSOrderedAscending;
            }else{
                return NSOrderedSame;
            }
        }
        
        return NSOrderedSame;
    }];
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

#pragma mark - View transitions
-(void)switchToRouteSearchViewWithRouteParameter:(RouteSearchParameters  *)searchParameters {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [tabBarController setupAndSwithToRouteSearchViewWithSearchParameters:searchParameters];
}

-(RouteSearchViewController *)routeSearchViewWithRouteParameter:(RouteSearchParameters  *)searchParameters {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    return [tabBarController setupRouteSearchViewWithSearchParameters:searchParameters];
}

-(void)switchToAlreadySetupRouteSearchView {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [tabBarController switchToRouteSearchViewController];
}

-(RouteSearchFromStopHandler)stopViewRouteSearchHandler {
    return ^(RouteSearchParameters *searchParams){
//        [self.navigationController popToViewController:self animated:YES];
        [self switchToRouteSearchViewWithRouteParameter:searchParams];
    };
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
                
                StopViewController *stopViewController = (StopViewController *)segue.destinationViewController;
                [self configureStopViewController:stopViewController withStopEntity:selected];
            }
        }
        
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionViewedAStop label:@"From saved stop" value:nil];
    } else if([segue.identifier isEqualToString:@"addAddress"] ||
             [segue.identifier isEqualToString:@"setHomeAddress"] ||
             [segue.identifier isEqualToString:@"setHomeAddressButton"] ||
             [segue.identifier isEqualToString:@"setWorkAddress"] ||
             [segue.identifier isEqualToString:@"setWorkAddressButton"]){
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
         EditAddressTableViewController *controller = (EditAddressTableViewController *)[[navigationController viewControllers] lastObject];
//        controller.droppedPinGeoCode = self.droppedPinGeoCode;
        controller.managedObjectContext = self.reittiDataManager.managedObjectContext;
        controller.viewControllerMode = ViewControllerModeAddNewAddress;
        controller.currentUserLocation = self.currentUserLocation;
        
        if([segue.identifier isEqualToString:@"setHomeAddress"] ||
           [segue.identifier isEqualToString:@"setHomeAddressButton"])
            controller.preSelectType = @"Home";
        
        if([segue.identifier isEqualToString:@"setWorkAddress"] ||
           [segue.identifier isEqualToString:@"setWorkAddressButton"])
            controller.preSelectType = @"Work";
        
    }else if([segue.identifier isEqualToString:@"namedBookmarkSelected"]){
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        if (indexPath != nil)
        {
            dataIndex = [self dataIndexForIndexPath:indexPath];
        }
        
        NamedBookmark * selected = [self.dataToLoad objectAtIndex:dataIndex];
        
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        EditAddressTableViewController *controller = (EditAddressTableViewController *)[[navigationController viewControllers] lastObject];
        
        controller.namedBookmark = selected;
        controller.viewControllerMode = ViewControllerModeViewNamedBookmark;
        controller.managedObjectContext = self.reittiDataManager.managedObjectContext;
        controller.currentUserLocation = self.currentUserLocation;
    }
}

- (RouteSearchViewController *)routeSearchViewControllerForNamedBookmark:(NamedBookmark *)namedBookmark{
//    if ([navigationController.topViewController isKindOfClass:[RouteSearchViewController class]]) {
//        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
//        
//        routeSearchViewController.prevToLocation = namedBookmark.name;
//        routeSearchViewController.prevToCoords = namedBookmark.coords;
//        
//        routeSearchViewController.delegate = self;
//        routeSearchViewController.managedObjectContext = self.reittiDataManager.managedObjectContext;
//    }
    
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:namedBookmark.name toCoords:namedBookmark.coords fromLocation:nil fromCoords:nil];
    
    return [self routeSearchViewWithRouteParameter:searchParms];
}

- (RouteSearchViewController *)routeSearchControllerForRouteEntity:(RouteEntity *)routeEntity{
//    if ([navigationController.topViewController isKindOfClass:[RouteSearchViewController class]]) {
//        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
//        
//        routeSearchViewController.prevToLocation = routeEntity.toLocationName;
//        routeSearchViewController.prevToCoords = routeEntity.toLocationCoordsString;
//        routeSearchViewController.prevFromLocation = routeEntity.fromLocationName;
//        routeSearchViewController.prevFromCoords = routeEntity.fromLocationCoordsString;
//        
//        routeSearchViewController.delegate = self;
//        routeSearchViewController.managedObjectContext = self.reittiDataManager.managedObjectContext;
//    }
    
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:routeEntity.toLocationName toCoords:routeEntity.toLocationCoordsString fromLocation:routeEntity.fromLocationName fromCoords:routeEntity.fromLocationCoordsString];
    
    return [self routeSearchViewWithRouteParameter:searchParms];
}

- (void)configureStopViewController:(StopViewController *)stopViewController withStopEntity:(StopEntity *)stopEntity{
    if ([stopViewController isKindOfClass:[StopViewController class]]) {
        stopViewController.stopCode = [NSString stringWithFormat:@"%d", [stopEntity.busStopCode intValue]];
        stopViewController.stopShortCode = stopEntity.busStopShortCode;
        stopViewController.stopName = stopEntity.busStopName;
        stopViewController.stopCoords = [ReittiStringFormatter convertStringTo2DCoord:stopEntity.busStopWgsCoords];
        stopViewController.stopEntity = stopEntity;
        stopViewController.managedObjectContext = self.reittiDataManager.managedObjectContext;
        stopViewController.backButtonText = self.title;
        stopViewController.delegate = self;
        
        stopViewController.routeSearchHandler = [self stopViewRouteSearchHandler];
    }
}

#pragma mark === UIViewControllerPreviewingDelegate Methods ===

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForRowAtPoint:location];
    NSInteger dataIndex = [self dataIndexForIndexPath:selectedRowIndexPath];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedRowIndexPath];
    if (cell)
        previewingContext.sourceRect = cell.frame;
    
    if ((dataIndex < self.dataToLoad.count)) {
        if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[NamedBookmark class]]){
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionUsed3DTouch label:@"Route to named bookmark" value:nil];
            
            NamedBookmark * selected = [self.dataToLoad objectAtIndex:dataIndex];
//
//            UINavigationController *navigationController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ASARouteSearchNavigationController"];
            return [self routeSearchViewControllerForNamedBookmark:selected];
            
//            [navigationController setNavigationBarHidden:YES];
            
//            return navigationController;
        }
        
        if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[RouteEntity class]]){
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionUsed3DTouch label:@"Viewed saved route" value:nil];
            
            RouteEntity * selected = [self.dataToLoad objectAtIndex:dataIndex];
            
//            UINavigationController *navigationController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ASARouteSearchNavigationController"];
            return [self routeSearchControllerForRouteEntity:selected];
            
//            [navigationController setNavigationBarHidden:YES];
            
//            return navigationController;
        }
        
        if ([[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:dataIndex] isKindOfClass:[HistoryEntity class]]){
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionUsed3DTouch label:@"Viewed saved stop" value:nil];
            StopEntity * selected = [self.dataToLoad objectAtIndex:dataIndex];
            
            StopViewController *stopViewController = (StopViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ASAStopViewController"];
            
            [self configureStopViewController:stopViewController withStopEntity:selected];
            
            return stopViewController;
        }
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    if ([viewControllerToCommit isKindOfClass:[StopViewController class]]) {
        [self.navigationController showViewController:viewControllerToCommit sender:nil];
    }else if ([viewControllerToCommit isKindOfClass:[UINavigationController class]]) {
//        UINavigationController *navigationController = (UINavigationController *)viewControllerToCommit;
//        [navigationController setNavigationBarHidden:NO];
//        [self showViewController:navigationController sender:nil];
        [self switchToAlreadySetupRouteSearchView];
    }else{
//        [self showViewController:viewControllerToCommit sender:nil];
        [self switchToAlreadySetupRouteSearchView];
    }
}

-(void)registerFor3DTouchIfAvailable{
    // Register for 3D Touch Previewing if available
    if ([self isForceTouchAvailable])
    {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }else{
//        NSLog(@"3D Touch is not available on this device.!");
        
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

- (void)dealloc
{
    NSLog(@"BookmarksController:This ARC deleted my UIView.");
}

@end
