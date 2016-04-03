
//
//  RouteSearchViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RouteSearchViewController.h"
#import "Transport.h"
#import "RouteDetailViewController.h"
#import "InfoViewController.h"
#import "SVProgressHUD.h"
#import "RouteViewManager.h"
#import "SearchController.h"
#import "AppDelegate.h"
#import "AppManager.h"
#import "CoreDataManager.h"
#import "DroppedPinManager.h"
#import "ASA_Helpers.h"
#import "TableViewCells.h"

typedef enum
{
    TableViewModeSuggestions = 1,
    TableViewModeRouteResults = 2
} TableViewMode;

@interface RouteSearchViewController ()

@property (nonatomic)TableViewMode tableViewMode;
@property (nonatomic, strong) id previewingContext;

@end

@implementation RouteSearchViewController

@synthesize savedStops, recentStops,savedRoutes, recentRoutes, namedBookmarks, dataToLoad, routeList, prevFromCoords, prevFromLocation, prevToCoords, prevToLocation, droppedPinGeoCode;
@synthesize reittiDataManager, settingsManager;
@synthesize delegate,viewCycledelegate;
@synthesize darkMode, isRootViewController;
@synthesize locationManager, currentUserLocation;
@synthesize refreshControl;
@synthesize managedObjectContext;
@synthesize disruptionsList;

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
//#008411
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:0.0/255.0 green:132.0/255.0 blue:17.0/255.0 alpha:1.0];
#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataManagerIfNull];
    
    [self loadData];
    
    if (![self isModalMode]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    currentLocationText = @"Current location";
    
    localRouteSearchOptions = [[self.settingsManager globalRouteOptions] copy];
    if (localRouteSearchOptions == nil)
        localRouteSearchOptions = [RouteSearchOptions defaultOptions];
    
    localRouteSearchOptions.date = [NSDate date];
    localRouteSearchOptions.selectedTimeType = RouteTimeNow;
    
    refreshingRouteTable = NO;
    nextRoutesRequested = NO;
    prevRoutesRequested = NO;
    
    tableReloadAnimatedMode = NO;
    tableRowNumberForAnimation = 0;
    
    tableViewController = [[UITableViewController alloc] init];
    
    [self setMainTableViewMode:TableViewModeSuggestions];
    [self setUpMergedBookmarksAndHistory];
    
    [self hideToolBar:YES animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    [self initLocationManager];
    [self setUpMainView];
    [self registerFor3DTouchIfAvailable];
    
    [routeResultsTableView registerNib:[UINib nibWithNibName:@"StopTableViewCell" bundle:nil] forCellReuseIdentifier:@"savedStopCell"];
    [routeResultsTableView registerNib:[UINib nibWithNibName:@"RouteTableViewCell" bundle:nil] forCellReuseIdentifier:@"savedRouteCell"];
    [routeResultsTableView registerNib:[UINib nibWithNibName:@"NamedBookmarkTableViewCell" bundle:nil] forCellReuseIdentifier:@"namedBookmarkCell"];
    [routeResultsTableView registerNib:[UINib nibWithNibName:@"AddressTableViewCell" bundle:nil] forCellReuseIdentifier:@"droppedPinCell"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationItem setTitle:@"PLANNER"];
    if (![self isModalMode]) {
        [self.tabBarController.tabBar setHidden:NO];
    }
    
    [self setUpToolBar];
    if (toolBarIsShowing) {
        [self hideToolBar:NO animated:YES];
    }
    [self refreshData];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    if (self.navigationController.visibleViewController != self)
        return;

    [self refreshData];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (darkMode) {
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [routeResultsTableView reloadData];
//    [self setTableBackgroundView];
}

-(BOOL)isModalMode{
    if (self.modalViewControllerMode) {
        return [self.modalViewControllerMode boolValue];
    }
    
    return self.tabBarController == nil;
}

#pragma mark - initializations
- (void)initDataManagerIfNull {
    // Do any additional setup after loading the view.
    
    if (self.reittiDataManager == nil) {
        
        self.managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
        
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        
        self.settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        
        [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
        
        self.droppedPinGeoCode = [[DroppedPinManager sharedManager] droppedPin];
    }
    
    if (self.settingsManager == nil) {
        self.settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeSearchOptionsChanged:)
                                                 name:routeSearchOptionsChangedNotificationName object:nil];
}


- (void)refreshData {
    //update time to now and reload route.
    if ([[[self.routeList firstObject] getStartingTimeOfRoute] timeIntervalSinceNow] < -300) {
        localRouteSearchOptions.date = [NSDate date];
        [self setSelectedTimesForDate:localRouteSearchOptions.date];
        [self searchRouteIfPossible];
    }
    
    [self loadData];
    self.droppedPinGeoCode = [[DroppedPinManager sharedManager] droppedPin];
    [self setUpMergedBookmarksAndHistory];
    
    if (self.tableViewMode == TableViewModeSuggestions) {
        localRouteSearchOptions.date = [NSDate date];
        [self setSelectedTimesForDate:localRouteSearchOptions.date];
        
        [routeResultsTableView reloadData];
    }
}

- (void)loadData {
    NSArray * _savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
    NSArray * _savedRoutes = [self.reittiDataManager fetchAllSavedRoutesFromCoreData];
    NSArray * _recentStops = [self.reittiDataManager fetchAllSavedStopHistoryFromCoreData];
    NSArray * _recentRoutes = [self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData];
    NSArray * _namedBookmarks = [self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData];
    
    self.savedStops = [NSMutableArray arrayWithArray:_savedStops];
    self.recentStops = [NSMutableArray arrayWithArray:_recentStops];
    self.savedRoutes = [NSMutableArray arrayWithArray:_savedRoutes];
    self.recentRoutes = [NSMutableArray arrayWithArray:_recentRoutes];
    self.namedBookmarks = [NSMutableArray arrayWithArray:_namedBookmarks];
}

-(void)setMainTableViewMode:(TableViewMode)tblViewMode{
    self.tableViewMode = tblViewMode;
    if (tblViewMode == TableViewModeSuggestions) {
        tableViewController.refreshControl = nil;
        
        routeResultsTableView.separatorColor = [UIColor lightGrayColor];
    }else{
        [self initRefreshControl];
        routeResultsTableView.separatorColor = [UIColor clearColor];
    }
}

-(void)setUpMainView{
    
    fromFieldBackView.layer.borderWidth = 0.5;
    fromFieldBackView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    fromFieldBackView.layer.cornerRadius = 5;
    
    toFieldBackView.layer.borderWidth = 0.5;
    toFieldBackView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    toFieldBackView.layer.cornerRadius = 5;
    
    localRouteSearchOptions.selectedTimeType = RouteTimeDeparture;
    [self setSelectedTimesForDate:[NSDate date]];
    [self setOptionsTextToRouteOptionsLabel];
    
    routeResultsTableView.backgroundColor = [UIColor clearColor];
    
    CGRect tableFrame = routeResultsTableView.frame;
    tableFrame.size.height = self.view.bounds.size.height - routeResultsTableContainerView.frame.origin.y;
    routeResultsTableView.frame = tableFrame;
    
    [self setTableBackgroundView];
    
    // Customize the activity indicator
    searchActivitySpinner.hidden = YES;
    
    [self.refreshControl endRefreshing];
    
    //Set searchbar look
    [fromSearchBar asa_removeBackgroundAndBorder];
    [fromSearchBar setImage:[UIImage imageNamed:@"location-light-25.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [toSearchBar asa_removeBackgroundAndBorder];
    [toSearchBar setImage:[UIImage imageNamed:@"finish_flag-light-50.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [self setBookmarkButtonStatus];
    
    if (prevFromLocation != nil) {
        if ([prevFromLocation isEqualToString:currentLocationText]) {
            [self setCurrentLocationIfAvailableToFromSearchBar];
        }else{
            [self setTextToSearchBar:fromSearchBar text:prevFromLocation];
            fromString = prevFromLocation;
        }
    }else{
        [self setCurrentLocationIfAvailableToFromSearchBar];
    }
    
    if (prevFromCoords != nil) {
        fromCoords = prevFromCoords;
    }
    
    if (prevToLocation != nil) {
        if ([prevToLocation isEqualToString:currentLocationText]) {
            toString = prevToLocation;
            [self setCurrentLocationIfAvailableToToSearchBar];
        }else{
            [self setTextToSearchBar:toSearchBar text:prevToLocation];
            toString = prevToLocation;
        }
    }
    if (prevToCoords != nil) {
        toCoords = prevToCoords;
    }
    
    [self searchRouteIfPossible];
}

-(void)setUpToolBar{
    UIImage *image1 = [UIImage imageNamed:@"previous-green-64.png"];
    CGRect frame = CGRectMake(0, 0, 22, 22);
    
    UIButton* prevButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [prevButton setFrame:frame];
    [prevButton setImage:image1 forState:UIControlStateNormal];
    prevButton.tintColor = [AppManager systemGreenColor];
    
    [prevButton addTarget:self action:@selector(previousRoutesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* prevBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:prevButton];
    
    UIBarButtonItem *firstSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    firstSpace.width = 30;
    
    UIBarButtonItem *nowBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Now" style:UIBarButtonItemStyleDone target:self action:@selector(currentTimeRoutesButtonPressed:)];
    nowBarButtonItem.tintColor = [AppManager systemGreenColor];
    
    UIBarButtonItem *secondSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    secondSpace.width = 30;
    
    UIImage *image2 = [UIImage imageNamed:@"next-green-100.png"];
    
    UIButton* nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton setFrame:frame];
    [nextButton setImage:image2 forState:UIControlStateNormal];
    nextButton.tintColor = [AppManager systemGreenColor];
    [nextButton addTarget:self action:@selector(nextRoutesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* nextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
    
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *clearBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleDone target:self action:@selector(clearSearchButtonPressed:)];
    clearBarButtonItem.tintColor = [AppManager systemGreenColor];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:prevBarButtonItem];
    [items addObject:firstSpace];
    [items addObject:nextBarButtonItem];
    [items addObject:secondSpace];
    [items addObject:nowBarButtonItem];
    [items addObject:flexiSpace];
    [items addObject:clearBarButtonItem];
    self.toolbarItems = items;
    
//    self.navigationController.toolbar.translucent = NO;
}

-(void)hideToolBar:(BOOL)hidden animated:(BOOL)animated{
    [self.navigationController setToolbarHidden:hidden animated:animated];
    toolBarIsShowing = !hidden;
}

- (IBAction)swipeToAndFromSelections:(id)sender {
    NSString * curToText = toSearchBar.text;
    toString = fromString;
    fromString = curToText;
    
    NSString * curToCoords = toCoords;
    toCoords = fromCoords;
    fromCoords = curToCoords;
    
    [self setTextToSearchBar:fromSearchBar text:fromString];
    [self setTextToSearchBar:toSearchBar text:toString];
    [self searchRouteIfPossible];
}

-(void)setTextToSearchBar:(UISearchBar *)searchBar text:(NSString *)text{
    if ([text isEqualToString:currentLocationText]) {
        for (UIView *subView in searchBar.subviews)
        {
            for (UIView *secondLevelSubview in subView.subviews){
                if ([secondLevelSubview isKindOfClass:[UITextField class]])
                {
                    UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                    
                    //set font color here
                    searchBarTextField.textColor = [AppManager systemGreenColor];
                    
                    break;
                }
            }
        }
    }else{
        for (UIView *subView in searchBar.subviews)
        {
            for (UIView *secondLevelSubview in subView.subviews){
                if ([secondLevelSubview isKindOfClass:[UITextField class]])
                {
                    UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                    
                    //set font color here
                    searchBarTextField.textColor = [UIColor colorWithWhite:0.8 alpha:1];
                    
                    break;
                }
            }
        }
    }
    
    searchBar.text = text;
    
}

-(void)clearSearchTexts{
    [fromSearchBar setText:@""];
    [toSearchBar setText:@""];
    toString = @"";
    toCoords = nil;
    fromString = nil;
    fromCoords = nil;
}

-(void)setCurrentLocationIfAvailableToFromSearchBar{
    if(self.currentUserLocation != nil){
        fromCoords = [NSString stringWithFormat:@"%f,%f", self.currentUserLocation.coordinate.longitude, self.currentUserLocation.coordinate.latitude];
        fromString = currentLocationText;
        [self setTextToSearchBar:fromSearchBar text:fromString];
        [self searchRouteIfPossible];
    }
    
}

-(void)setCurrentLocationIfAvailableToToSearchBar{
    if(self.currentUserLocation != nil){
        toCoords = [NSString stringWithFormat:@"%f,%f", self.currentUserLocation.coordinate.longitude, self.currentUserLocation.coordinate.latitude];
        toString = currentLocationText;
        [self setTextToSearchBar:toSearchBar text:toString];
        [self searchRouteIfPossible];
    }
    
}

- (void)initLocationManager{
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    [locationManager startUpdatingLocation];
    locationManager.delegate = self;
}

-(BOOL)isLocationServiceAvailableWithMessage:(bool)showMessage{
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
//    NSLog(@"%d",[CLLocationManager authorizationStatus]);
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServicesEnabled) {
        if(showMessage){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Looks like location services is not enabled"
                                                                message:@"Enable it from Settings/Privacy/Location Services to get route searches from current location (which makes your life way easier BTW)."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:@"Settings", nil];
            alertView.tag = 1243;
            [alertView show];
        }
        
        return NO;
    }
    
    if (!accessGranted) {
        if(showMessage){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Looks like access is not granted to this app for location services."
                                                                message:@"Grant access from Settings/Privacy/Location Services to get route searches from current location (which makes your life way easier BTW)."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:@"Settings", nil];
            alertView.tag = 1243;
            [alertView show];
        }
        
        return NO;
    }
    
    return YES;

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentUserLocation = [locations lastObject];
    //set from search bar value if it still empty and search route if possible
    if ([fromSearchBar.text isEqualToString:@""] || fromSearchBar.text == nil) {
        [self setCurrentLocationIfAvailableToFromSearchBar];
    }
    
    if (([toSearchBar.text isEqualToString:@""] || toSearchBar.text == nil) && [toString isEqualToString:currentLocationText]) {
        [self setCurrentLocationIfAvailableToToSearchBar];
    }
}

#pragma mark - view methods
/*
- (void)hideSuggestionTableView:(BOOL)hidden{
    CGRect tableFrame = searchSuggestionsTableView.frame;
    CGRect sBVF = searchBarsView.frame;
    
    if (!hidden) {
        searchSuggestionsTableView.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, self.view.bounds.size.height- 145);
        searchBarsView.frame = CGRectMake(sBVF.origin.x, sBVF.origin.y, sBVF.size.width, self.view.bounds.size.height);
    }else{
        searchBarsView.frame = CGRectMake(sBVF.origin.x, sBVF.origin.y, sBVF.size.width, 140);
    }
}

- (void)hideSuggestionTableView:(BOOL)hidden animated:(bool)animated{
    if (animated) {
        [UIView transitionWithView:searchBarsView duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            
            [self hideSuggestionTableView:hidden];
            
        } completion:^(BOOL finished) {}];
    }else{
        [self hideSuggestionTableView:hidden];
    }
}
*/

/*
-(void)hideTimeSelectionView:(BOOL)hidden animated:(BOOL)animated{
    if (animated) {
        [UIView transitionWithView:timeSelectionView duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            
            [self hideTimeSelectionView:hidden];
            
        } completion:^(BOOL finished) {
            timeSelectionViewShadeView.hidden = hidden;
        }];
    }else{
        [self hideTimeSelectionView:hidden];
        timeSelectionViewShadeView.hidden = hidden;
    }
}

-(void)hideTimeSelectionView:(BOOL)hidden{
    CGRect viewFrame = timeSelectionView.frame;
    if (hidden) {
        timeSelectionView.frame = CGRectMake(viewFrame.origin.x, self.view.bounds.size.height, viewFrame.size.width, viewFrame.size.height);
    }else{
        timeSelectionView.frame = CGRectMake(viewFrame.origin.x, self.view.bounds.size.height - viewFrame.size.height, viewFrame.size.width, viewFrame.size.height);
    }
}

-(BOOL)isTimeSelectionViewVisible{
    if (timeSelectionView.frame.origin.y >= self.view.bounds.size.height) {
        return YES;
    }else{
        return NO;
    }
}
*/

-(void)setBookmarkButtonStatus{
    if (fromString != nil && fromCoords != nil && toString != nil && toCoords != nil){
        bookmarkRouteButton.enabled = YES;
        //Check if route is saved already
        if([self.reittiDataManager isRouteSaved:fromString andTo:toString]){
            [self setRouteBookmarkedState];
        }else{
            [self setRouteNotBookmarkedState];
        }
    }else{
        bookmarkRouteButton.enabled = NO;
    }
}

- (void)setRouteBookmarkedState{
    [bookmarkRouteButton setImage:[UIImage imageNamed:@"star-filled-white-100.png"] forState:UIControlStateNormal];
    [bookmarkRouteButton asa_bounceAnimateViewByScale:0.2];
    routeBookmarked = YES;
}

- (void)setRouteNotBookmarkedState{
    [bookmarkRouteButton setImage:[UIImage imageNamed:@"star-line-white-100.png"] forState:UIControlStateNormal];
    routeBookmarked = NO;
}

#pragma mark - IBActions
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.viewCycledelegate routeSearchViewControllerDismissed];
    }];
}

- (IBAction)nextRoutesButtonPressed:(id)sender {
    if (localRouteSearchOptions.selectedTimeType == RouteTimeNow)
        localRouteSearchOptions.selectedTimeType = RouteTimeDeparture;
    
    Route *lastRoute;
    NSDate *lastTime;
    
    if (self.routeList.count == 1) {
        lastRoute = [self.routeList objectAtIndex:0];
        if(localRouteSearchOptions.selectedTimeType == RouteTimeArrival){
            lastTime = [lastRoute.getEndingTimeOfRoute dateByAddingTimeInterval:300];
        }else{
            lastTime = [lastRoute.getStartingTimeOfRoute dateByAddingTimeInterval:300];
        }
    }else{
        if(localRouteSearchOptions.selectedTimeType == RouteTimeArrival){
            lastRoute = [self.routeList objectAtIndex:0];
            if (lastRoute == nil)
                return;
            
            localRouteSearchOptions.selectedTimeType = RouteTimeDeparture;
            nextRoutesRequested = YES;
            
            lastTime = lastRoute.getEndingTimeOfRoute;
            
        }else{
            lastRoute = [self.routeList lastObject];
            if (lastRoute == nil)
                return;
            lastTime = lastRoute.getStartingTimeOfRoute;
        }
    }
    
    [self setSelectedTimesForDate:lastTime];
    
    [self searchRouteIfPossible];
}

- (IBAction)currentTimeRoutesButtonPressed:(id)sender {
    localRouteSearchOptions.selectedTimeType = RouteTimeNow;
//    timeTypeSegmentControl.selectedSegmentIndex = (int)RouteTimeNow;
    [self reloadCurrentSearch];
}

- (IBAction)previousRoutesButtonPressed:(id)sender {
    if (localRouteSearchOptions.selectedTimeType == RouteTimeNow)
        localRouteSearchOptions.selectedTimeType = RouteTimeDeparture;
    
    Route *lastRoute;
    NSDate *lastTime;
    if (self.routeList.count == 1) {
        lastRoute = [self.routeList objectAtIndex:0];
        if(localRouteSearchOptions.selectedTimeType == RouteTimeArrival){
            lastTime = [lastRoute.getEndingTimeOfRoute dateByAddingTimeInterval:-300];
        }else{
            lastTime = [lastRoute.getStartingTimeOfRoute dateByAddingTimeInterval:-300];
        }
    }else{
        if(localRouteSearchOptions.selectedTimeType == RouteTimeArrival){
            lastRoute = [self.routeList lastObject];
            if (lastRoute == nil)
                return;
            lastTime = lastRoute.getEndingTimeOfRoute;
        }else{
            lastRoute = [self.routeList objectAtIndex:0];
            if (lastRoute == nil)
                return;
            localRouteSearchOptions.selectedTimeType = RouteTimeArrival;
            prevRoutesRequested = YES;
            
            lastTime = lastRoute.getEndingTimeOfRoute;
        }
    }
    
    [self setSelectedTimesForDate:lastTime];

    [self searchRouteIfPossible];
}

- (IBAction)clearSearchButtonPressed:(id)sender {
    [self clearSearchResults];
}

-(void)clearSearchResults {
    [self clearSearchTexts];
    
    [self.routeList removeAllObjects];
    [self refreshData];
    [routeResultsTableView reloadData];
    
    bookmarkRouteButton.enabled = NO;
    
    if (self.tableViewMode == TableViewModeRouteResults) {
        [self setMainTableViewMode:TableViewModeSuggestions];
        [routeResultsTableView reloadData];
    }
    [self hideToolBar:YES animated:YES];
}

- (IBAction)bookmarkRouteButtonClicked:(id)sender {
    
    if (fromString != nil && fromCoords != nil && toString != nil && toCoords != nil) {
        if (routeBookmarked) {
            //unbookmark
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete your bookmark?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
            actionSheet.tag = 1001;
            [actionSheet showInView:self.view];
        }else{
            [self.reittiDataManager saveRouteToCoreData:fromString fromCoords:fromCoords andToLocation:toString andToCoords:toCoords];
            [self setRouteBookmarkedState];
            
            [delegate routeModified];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionBookmarkedARoute label:@"All" value:nil];
        }
    }
    
    [self setBookmarkButtonStatus];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1001) {
        if (buttonIndex == 0) {
            [self.reittiDataManager deleteSavedRouteForCode:[RettiDataManager generateUniqueRouteNameFor:fromString andToLoc:toString]];
            [self setRouteNotBookmarkedState];
            
            [delegate routeModified];
        }
    }
}

#pragma mark - search bar methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //hide segment control
    if (searchBar.tag == 1001) {
        [self performSegueWithIdentifier: @"searchFromAddress" sender: self];
    }else{
        [self performSegueWithIdentifier: @"searchToAddress" sender: self];
    }
}

#pragma mark - route search delegates
- (void)routeSearchDidComplete:(NSArray *)searchedRouteList{
    if (nextRoutesRequested && searchedRouteList != nil && searchedRouteList.count > 1) {
        if (localRouteSearchOptions.selectedTimeType == RouteTimeDeparture) {
            localRouteSearchOptions.selectedTimeType = RouteTimeArrival;
            
            Route *firstRoute = [searchedRouteList objectAtIndex:0];
            Route *secondRoute = [searchedRouteList objectAtIndex:1];
            
            [self setSelectedTimesForDate:secondRoute.getEndingTimeOfRoute];
            
            [self.routeList removeLastObject];
            [self.routeList removeLastObject];
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.routeList];
            [self.routeList removeAllObjects];
            [self.routeList addObject:secondRoute];
            [self.routeList addObject:firstRoute];
            [self.routeList addObjectsFromArray:temp];
            
        }
        nextRoutesRequested = NO;
    }else if (prevRoutesRequested && searchedRouteList != nil && searchedRouteList.count > 1){
        if (localRouteSearchOptions.selectedTimeType == RouteTimeArrival){
            localRouteSearchOptions.selectedTimeType = RouteTimeDeparture;
            
            Route *firstRoute = [searchedRouteList objectAtIndex:0];
            Route *secondRoute = [searchedRouteList objectAtIndex:1];
            
            [self setSelectedTimesForDate:secondRoute.getStartingTimeOfRoute];
            
            [self.routeList removeLastObject];
            [self.routeList removeLastObject];
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.routeList];
            [self.routeList removeAllObjects];
            [self.routeList addObject:secondRoute];
            [self.routeList addObject:firstRoute];
            [self.routeList addObjectsFromArray:temp];

        }
        prevRoutesRequested = NO;
    } else{
        self.routeList = [NSMutableArray arrayWithArray:searchedRouteList];

    }
    
    [routeResultsTableView reloadData];
//    [self reloadTableViewAnimatedWithInteralSeconds:0.2];
//    [searchActivityIndicator stopAnimating];
//    [SVProgressHUD dismissFromView:self.view];
    [searchActivitySpinner endRefreshing];
    
    [routeResultsTableView setContentOffset:CGPointZero animated:YES];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [self.refreshControl endRefreshing];
    
//    if (!searchOptionSelectionView.hidden) {
//        searchOptionSelectionView.hidden = YES;
//    }
    
    if (![fromSearchBar.text isEqualToString:currentLocationText] || ![toSearchBar.text isEqualToString:currentLocationText]) {
        [self.reittiDataManager saveRouteHistoryToCoreData:fromString fromCoords:fromCoords andToLocation:toString toCoords:toCoords];
    }
    
    [self setBookmarkButtonStatus];
    [self hideToolBar:NO animated:YES];
    
}
- (void)routeSearchDidFail:(NSString *)error{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [self.refreshControl endRefreshing];
    
//    [searchActivityIndicator stopAnimating];
    
    if (error != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error                                                                                      message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
//    [ self clearSearchButtonPressed:self];
    
    if (self.tableViewMode == TableViewModeRouteResults) {
        [self setMainTableViewMode:TableViewModeSuggestions];
        [routeResultsTableView reloadData];
    }
    
    [self hideToolBar:YES animated:NO];
//    [SVProgressHUD dismissFromView:self.view];
    [searchActivitySpinner endRefreshing];
    
    [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:error value:@1];
}
#pragma mark - routeSearchOptionSelection
-(void)optionSelectionDidComplete:(RouteSearchOptions *)routeOptions{
    
//    localRouteSearchOptions = [routeOptions copy];
    
    localRouteSearchOptions.selectedTimeType = routeOptions.selectedTimeType;
    localRouteSearchOptions.selectedRouteSearchOptimization = routeOptions.selectedRouteSearchOptimization;
    
    NSDate *currentTime = [NSDate date];
    
    if(localRouteSearchOptions.selectedTimeType == RouteTimeNow){
        localRouteSearchOptions.date = currentTime;
    }else{
        localRouteSearchOptions.date = routeOptions.date;
    }
    
    localRouteSearchOptions.selectedRouteTrasportTypes = routeOptions.selectedRouteTrasportTypes;
    localRouteSearchOptions.selectedTicketZone = routeOptions.selectedTicketZone;
    localRouteSearchOptions.selectedChangeMargine = routeOptions.selectedChangeMargine;
    localRouteSearchOptions.selectedWalkingSpeed = routeOptions.selectedWalkingSpeed;
    
    [self setSelectedTimesForDate:localRouteSearchOptions.date];
    
    [self setOptionsTextToRouteOptionsLabel];
    [self searchRouteIfPossible];
}

#pragma mark - TableViewMethods
- (void)initRefreshControl{
    
    tableViewController.tableView = routeResultsTableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(tableViewRefreshing) forControlEvents:UIControlEventValueChanged];
//    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Routes"];
    tableViewController.refreshControl = self.refreshControl;
    routeResultsTableView.backgroundView.layer.zPosition -= 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableViewMode == TableViewModeSuggestions) {
        return self.dataToLoad.count;
    }else{
        return self.routeList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (self.tableViewMode == TableViewModeSuggestions) {
        
        if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[GeoCode class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"droppedPinCell"];
            GeoCode *geoCode = [GeoCode alloc];
            if (indexPath.row < self.dataToLoad.count) {
                geoCode = [self.dataToLoad objectAtIndex:indexPath.row];
            }
            
            [(AddressTableViewCell *)cell setupFromGeocode:geoCode];
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
            StopEntity *stopEntity = [self.dataToLoad objectAtIndex:indexPath.row];
            
            if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
                [(StopTableViewCell *)cell setupFromHistoryEntity:(HistoryEntity *)stopEntity];
            }else{
                [(StopTableViewCell *)cell setupFromStopEntity:stopEntity];
            }
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[NamedBookmark class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"namedBookmarkCell"];
            NamedBookmark *namedBookmark = [NamedBookmark alloc];
            if (indexPath.row < self.dataToLoad.count) {
                namedBookmark = [self.dataToLoad objectAtIndex:indexPath.row];
            }
            
            [(NamedBookmarkTableViewCell *)cell setupFromNamedBookmark:namedBookmark];
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteEntity class]]){
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedRouteCell"];
            RouteEntity *routeEntity = [RouteEntity alloc];
            if (indexPath.row < self.dataToLoad.count) {
                routeEntity = [self.dataToLoad objectAtIndex:indexPath.row];
            }
            
            if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]) {
                [(RouteTableViewCell *)cell setupFromHistoryEntity:(RouteHistoryEntity *)routeEntity];
            }else{
                [(RouteTableViewCell *)cell setupFromRouteEntity:routeEntity];
            }
        }
        
        cell.backgroundColor = [UIColor clearColor];
    }else{
        if (indexPath.row < self.routeList.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"routeCell"];
            
            Route *route = [self.routeList objectAtIndex:indexPath.row];
            
            UILabel *leaveTimeLabel = (UILabel *)[cell viewWithTag:2000];
            UILabel *arriveTimeLabel = (UILabel *)[cell viewWithTag:2005];
            
            NSString *leavesString = [NSString stringWithFormat:@"leave %@",
                                      [ReittiStringFormatter formatHourStringFromDate:route.getStartingTimeOfRoute]];
            
            if ([route.getStartingTimeOfRoute timeIntervalSinceNow] < 300) {
                leaveTimeLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:leavesString                                                                         substring:leavesString withNormalFont:leaveTimeLabel.font];
                ;
            }else{
                leaveTimeLabel.text = leavesString;
            }
            
            arriveTimeLabel.text = [NSString stringWithFormat:@"| arrive %@",
                                    [ReittiStringFormatter formatHourStringFromDate:route.getEndingTimeOfRoute]];
            
            //durations
            UILabel *durationLabel = (UILabel *)[cell viewWithTag:2001];
            NSInteger duration = [route.routeDurationInSeconds integerValue];
            durationLabel.attributedText = [ReittiStringFormatter formatAttributedDurationString:duration withFont:durationLabel.font];
            
            CGFloat walkingKm = route.getTotalWalkLength/1000.0;
            
            NSString *numberString = [ReittiStringFormatter formatRoundedNumberFromDouble:walkingKm roundDigits:2 androundUp:YES];
            
            UILabel *moreInfoLebel = (UILabel *)[cell viewWithTag:2002];
            
            if(route.getTimeAtTheFirstStop != nil){
                moreInfoLebel.text = [NSString stringWithFormat:@"%@ from first stop · %@ km walking",
                                      [ReittiStringFormatter formatHourStringFromDate:route.getTimeAtTheFirstStop], numberString];
                
            }else{
                moreInfoLebel.text = [NSString stringWithFormat:@"%@ km walking", numberString];
            }
            
//            walkingDistLabel.text = [NSString stringWithFormat:@"%@ km", numberString];
            
            UIScrollView *transportsScrollView = (UIScrollView *)[cell viewWithTag:2003];
            
            [cell layoutSubviews];
            
            for (UIView * view in transportsScrollView.subviews) {
                if (view.tag == 1987 || view.tag == 4006) {
                    [view removeFromSuperview];
                }
            }
            
            UIView *shortestRouteIndicator = [cell viewWithTag:2099];
            if ([self isShortestRoute:route fromListOfRoutes:routeList]) {
                shortestRouteIndicator.hidden = NO;
            }else{
                shortestRouteIndicator.hidden = YES;
            }
            
            CGFloat totalWidth = self.view.frame.size.width - 75;
            
            CGFloat longestDuration = [route.routeDurationInSeconds floatValue];

            if (totalWidth > 500) {
                NSArray *routes;
                if (routeListCopy != nil && routeListCopy.count > routeList.count) {
                    routes = [NSArray arrayWithArray:routeListCopy];
                }else{
                    routes = [NSArray arrayWithArray:routeList];
                }
                longestDuration = [self adjustedWidthForNoTruncation:&totalWidth forListOfRoutes:routes];
            }
            
            UIView *transportsContainer = [RouteViewManager viewForRoute:route longestDuration:longestDuration width:totalWidth alwaysShowVehicle:YES];
//            [transportsContainer addSubview:routeView];
            
            transportsContainer.frame = CGRectMake(12, 0, transportsContainer.frame.size.width, transportsContainer.frame.size.height);
            [transportsScrollView addSubview:transportsContainer];
            transportsScrollView.contentSize = CGSizeMake(transportsContainer.frame.size.width + 24, transportsScrollView.frame.size.height);
            
            transportsScrollView.userInteractionEnabled = NO;
            [cell.contentView addGestureRecognizer:transportsScrollView.panGestureRecognizer];
            
            //Disruptions
            UIButton *disruptionsButton = (UIButton *)[cell viewWithTag:3001];
            if ([AppManager isProVersion]) {
                BOOL thereAreDisruptions = [self disruptionsForRoute:route] != nil;
                disruptionsButton.hidden = !thereAreDisruptions;
                if (thereAreDisruptions) {
                    disruptionsButton.layer.cornerRadius = disruptionsButton.frame.size.width/2;
                }
            }else{
                disruptionsButton.hidden = YES;
            }
            
        }
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 129.5, self.view.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        line.tag = 4006;
        [cell addSubview:line];
        
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

//- (UIView *)viewForRoute:(Route *)route longestDuration:(CGFloat)longestDuration width:(CGFloat)totalWidth
//{
//    float tWidth  = 70;
//    float x = 0;
//    UIView *transportsContainer = [[UIView alloc] initWithFrame:CGRectMake(12, 0, totalWidth , 36)];
//    transportsContainer.clipsToBounds = YES;
//    transportsContainer.tag = 1987;
//    transportsContainer.layer.cornerRadius = 4;
//    
//    for (RouteLeg *leg in route.routeLegs) {
//        tWidth = totalWidth * (([leg.legDurationInSeconds floatValue])/longestDuration);
//        Transport *transportView = [[Transport alloc] initWithRouteLeg:leg andWidth:tWidth*1];
//        CGRect frame = transportView.frame;
//        transportView.frame = CGRectMake(x, 0, frame.size.width, frame.size.height);
//        transportView.clipsToBounds = YES;
//        [transportsContainer addSubview:transportView];
//        x += frame.size.width;
//        
//        //Append waiting view if exists
//        if (leg.waitingTimeInSeconds > 0) {
//            float waitingWidth = totalWidth * (leg.waitingTimeInSeconds/longestDuration);
//            UIView *waitingView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, waitingWidth, transportView.frame.size.height)];
//            waitingView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
//            waitingView.clipsToBounds = YES;
//            if (waitingWidth > 22) {
//                UIImageView *waitingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sitting-filled-grey-64.png"]];
//                waitingImageView.frame = CGRectMake((waitingView.frame.size.width - 20)/2, (transportsContainer.frame.size.height - 20)/2, 20, 20);
//                [waitingView addSubview:waitingImageView];
//            }
//            [transportsContainer addSubview:waitingView];
//            x += waitingWidth;
//        }
//    }
//    transportsContainer.frame = CGRectMake(12, 0, x, 36);
//    
//    return transportsContainer;
//}

//- (void)viewForRoute:(UIView *)transportsContainer longestDuration:(CGFloat)longestDuration width:(CGFloat)totalWidth route:(Route *)route
//{
//    float tWidth;
//    float x = 0;
//    for (RouteLeg *leg in route.routeLegs) {
//        tWidth = totalWidth * (([leg.legDurationInSeconds floatValue])/longestDuration);
//        Transport *transportView = [[Transport alloc] initWithRouteLeg:leg andWidth:tWidth*1];
//        CGRect frame = transportView.frame;
//        transportView.frame = CGRectMake(x, 0, frame.size.width, frame.size.height);
//        transportView.clipsToBounds = YES;
//        [transportsContainer addSubview:transportView];
//        x += frame.size.width;
//        
//        //Append waiting view if exists
//        if (leg.waitingTimeInSeconds > 0) {
//            float waitingWidth = totalWidth * (leg.waitingTimeInSeconds/longestDuration);
//            UIView *waitingView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, waitingWidth, transportView.frame.size.height)];
//            waitingView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
//            waitingView.clipsToBounds = YES;
//            if (waitingWidth > 22) {
//                UIImageView *waitingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sitting-filled-grey-64.png"]];
//                waitingImageView.frame = CGRectMake((waitingView.frame.size.width - 20)/2, (transportsContainer.frame.size.height - 20)/2, 20, 20);
//                [waitingView addSubview:waitingImageView];
//            }
//            [transportsContainer addSubview:waitingView];
//            x += waitingWidth;
//        }
//    }
//}

- (BOOL)isShortestRoute:(Route *)aRoute fromListOfRoutes:(NSArray *)routes{
    for (Route *route in routes) {
        if ([route.routeDurationInSeconds floatValue] < [aRoute.routeDurationInSeconds floatValue])
            return NO;
    }
    
    return YES;
}

- (CGFloat)adjustedWidthForNoTruncation:(CGFloat *)totalWidth_p forListOfRoutes:(NSArray *)routes
{
    //get longest route duration
    CGFloat longestDuration = 0.0;
    CGFloat totalDuration = 0.0;
    for (Route *route in routes) {
        if ([route.routeDurationInSeconds floatValue] > longestDuration)
            longestDuration = [route.routeDurationInSeconds floatValue];

        totalDuration += [route.routeDurationInSeconds floatValue];
    }
    
    //Adjust so that there is no one long route and the others are made very short to fit the longest.
    CGFloat meanDuration;
    meanDuration = totalDuration/routes.count;
    
    CGFloat scale = longestDuration/meanDuration;
    if (1.5 * meanDuration >= longestDuration > 1.4 * meanDuration) {
        *totalWidth_p = *totalWidth_p * 1.4;
    }else if (1.7 >= scale && scale > 1.5) {
        *totalWidth_p = *totalWidth_p * 1.5;
    }else if (2.0  >= scale && scale > 1.7) {
        *totalWidth_p = *totalWidth_p * 1.7;
    }else if (2.3 >= scale && scale > 2.0) {
        *totalWidth_p = *totalWidth_p * 2.0;
    }else if (2.7  >= scale && scale > 2.3) {
        *totalWidth_p = *totalWidth_p * 2.4;
    }else if (3.2  >= scale && scale > 2.7) {
        *totalWidth_p = *totalWidth_p * 2.8;
    }else if (scale > 3.2) {
        *totalWidth_p = *totalWidth_p * 3.2;
    }
    return longestDuration;
}

-(float)evaluateNeededScalingForRouteList{
    float maxScalling = 0.0;
    double longestDuration = 0;
    for (Route *route in self.routeList) {
        if ([route.routeDurationInSeconds doubleValue] > longestDuration) {
            longestDuration = [route.routeDurationInSeconds doubleValue];
        }
    }
    for (Route *route  in self.routeList) {
        for (RouteLeg *leg in route.routeLegs) {
            float tWidth = (self.view.frame.size.width - 20) * ([leg.legDurationInSeconds floatValue]/longestDuration);
            float scale = 0.0;
            if (leg.legType == LegTypeWalk && tWidth < 38) {
                scale = 38/tWidth;
            }else if(tWidth < 50){
                scale = 50/tWidth;
            }
            if (scale > maxScalling) {
                maxScalling = scale;
            }
        }
    }
    return maxScalling;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewMode == TableViewModeSuggestions) {
        if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]){
            StopEntity *stopEntity = [self.dataToLoad objectAtIndex:indexPath.row];
            
            [self setTextToSearchBar:toSearchBar text:stopEntity.busStopName];
            
            toString = stopEntity.busStopName;
            toCoords = stopEntity.busStopWgsCoords;
            
            [self searchRouteIfPossible];
        }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[GeoCode class]]){
            GeoCode *geoCode = [self.dataToLoad objectAtIndex:indexPath.row];
            
            [self setTextToSearchBar:toSearchBar text:[geoCode getStreetAddressString]];
            
            toString = geoCode.getStreetAddressString;
            toCoords = geoCode.coords;
            
            [self searchRouteIfPossible];
        }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[NamedBookmark class]]){
            NamedBookmark *namedBookmark = [self.dataToLoad objectAtIndex:indexPath.row];
            
            [self setTextToSearchBar:toSearchBar text:namedBookmark.name];
            
            toString = namedBookmark.name;
            toCoords = namedBookmark.coords;
        
            [self searchRouteIfPossible];
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteEntity class]]){
            RouteEntity *routeEntity = [self.dataToLoad objectAtIndex:indexPath.row];
            
            [self setTextToSearchBar:fromSearchBar text:routeEntity.fromLocationName];
            
            fromString = routeEntity.fromLocationName;
            fromCoords = routeEntity.fromLocationCoordsString;
        
            [self setTextToSearchBar:toSearchBar text:routeEntity.toLocationName];
            
            toString = routeEntity.toLocationName;
            toCoords = routeEntity.toLocationCoordsString;
            
            [self searchRouteIfPossible];
        }
        
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSearchedRoute label:@"From saved location" value:nil];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableViewMode == TableViewModeSuggestions) {
        return 60;
    }else{
        return 130;
    }
}

#pragma mark - scroll view delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (routeList.count < 1)
//        return;
//    
//    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height - 100) {
//        [self hideToolBar:NO animated:YES];
//    }
//    if (scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height - 150) {
//        [self hideToolBar:YES animated:YES];
//    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1243) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - address search view controller
- (void)searchResultSelectedAStop:(StopEntity *)stopEntity{
    [self setTextToSearchBar:activeSearchBar text:stopEntity.busStopName];
    
    if (activeSearchBar == fromSearchBar) {
        fromString = stopEntity.busStopName;
        fromCoords = stopEntity.busStopWgsCoords;
    }else if (activeSearchBar == toSearchBar) {
        toString = stopEntity.busStopName;
        toCoords = stopEntity.busStopWgsCoords;
    }
    
    [self searchRouteIfPossible];
}

- (void)searchResultSelectedANamedBookmark:(NamedBookmark *)namedBookmark{
    [self setTextToSearchBar:activeSearchBar text:namedBookmark.name];
    
    if (activeSearchBar == fromSearchBar) {
        fromString = namedBookmark.name;
        fromCoords = namedBookmark.coords;
    }else if (activeSearchBar == toSearchBar) {
        toString = namedBookmark.name;
        toCoords = namedBookmark.coords;
    }
    
    [self searchRouteIfPossible];
}

- (void)searchResultSelectedAGeoCode:(GeoCode *)geoCode{
    [self setTextToSearchBar:activeSearchBar text:geoCode.fullAddressString];
    
    if (activeSearchBar == fromSearchBar) {
        fromString = geoCode.fullAddressString;
        fromCoords = geoCode.coords;
    }else if (activeSearchBar == toSearchBar) {
        toString = geoCode.fullAddressString;
        toCoords = geoCode.coords;
    }
    
    [self searchRouteIfPossible];
}

-(void)searchResultSelectedCurrentLocation{
    if ([self isLocationServiceAvailableWithMessage:YES]) {
        if (activeSearchBar == toSearchBar) {
            [self setCurrentLocationIfAvailableToToSearchBar];
        }else{
            [self setCurrentLocationIfAvailableToFromSearchBar];
        }
    }
}

- (void)searchViewControllerWillBeDismissed:(NSString *)prevSearchTerm{
//    reittiDataManager.routeSearchdelegate = self;
}

-(void)searchViewControllerDismissedToRouteSearch:(NSString *)prevSearchTerm{
    
}

#pragma mark - Disruptions fetching
- (void)fetchDisruptions{
    self.disruptionsList = @[];
    [self.reittiDataManager fetchDisruptionsWithCompletionBlock:^(NSArray *disruption, NSString *errorString){
        if (!errorString) {
            self.disruptionsList = disruption;
            [routeResultsTableView reloadData];
        }else{
            self.disruptionsList = @[];
        }
    }];
}

- (NSArray *)disruptionsForRoute:(Route *)route{
    if (!route || !self.disruptionsList || self.disruptionsList.count < 1)
        return nil;
    
    NSMutableArray *disruptions = [@[] mutableCopy];
    for (RouteLeg *leg in route.routeLegs) {
        if (leg.legType != LegTypeWalk && leg.lineCode){
            for (Disruption *disruption in self.disruptionsList) {
                if ([disruption affectsLineWithFullCode:leg.lineCode])
                    [disruptions addObject:disruption];
            }
        }
    }
    
    return disruptions.count > 0 ? disruptions : nil;
}

#pragma mark - Settings change notifications
-(void)userLocationValueChanged:(NSNotification *)notification{
    [self.reittiDataManager setUserLocationRegion:[self.settingsManager userLocation]];
}

-(void)routeSearchOptionsChanged:(id)sender {
    localRouteSearchOptions = [[self.settingsManager globalRouteOptions] copy];
    localRouteSearchOptions.date = [NSDate date];
    
    [self searchRouteIfPossible];
    
    [self setOptionsTextToRouteOptionsLabel];
}

#pragma mark - helper methods
-(void)searchRouteIfPossible{
    if (fromCoords != nil && toCoords != nil && (![fromSearchBar.text isEqualToString:@""] && fromSearchBar.text != nil) && (![toSearchBar.text isEqualToString:@""] && toSearchBar.text != nil)) {
        if ([fromSearchBar.text isEqualToString:currentLocationText]) {
            fromCoords = [NSString stringWithFormat:@"%f,%f", self.currentUserLocation.coordinate.longitude, self.currentUserLocation.coordinate.latitude];
        }
        if ([toSearchBar.text isEqualToString:currentLocationText]) {
            toCoords = [NSString stringWithFormat:@"%f,%f", self.currentUserLocation.coordinate.longitude, self.currentUserLocation.coordinate.latitude];
        }
        
        if (refreshingRouteTable) {
            refreshingRouteTable = NO;
        }else{
            //[SVProgressHUD showHUDInView:self.view];
            [searchActivitySpinner beginRefreshing];
        }
        
        //Remove previous search result from table
        if (!nextRoutesRequested && !prevRoutesRequested) {
            self.routeList = nil;
            [routeResultsTableView reloadData];
        }
        
        if (self.tableViewMode == TableViewModeSuggestions) {
            [self setMainTableViewMode:TableViewModeRouteResults];
            [routeResultsTableView reloadData];
        }
        
        [reittiDataManager searchRouteForFromCoords:fromCoords andToCoords:toCoords andSearchOption:localRouteSearchOptions andNumberOfResult:nil andCompletionBlock:^(NSArray *result, NSString *error){
            if (!error) {
                [self routeSearchDidComplete:result];
                [self fetchDisruptions];
            }else{
                [self routeSearchDidFail:error];
            }
        }];
    }else{
        if (refreshingRouteTable) {
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
            [self.refreshControl endRefreshing];
            refreshingRouteTable = NO;
        }
    }
}

-(void)searchRouteForFromLocation:(NSString *)fromLoc fromLocationCoords:(NSString *)fromCoordinates andToLocation:(NSString *)toLoc toLocationCoords:(NSString *)toCoordinates{
    fromSearchBar.text = fromLoc;
    toSearchBar.text = toLoc;
    
    fromCoords = fromCoordinates;
    toCoords = toCoordinates;
    
    localRouteSearchOptions.selectedRouteSearchOptimization = RouteSearchOptionFastest;
    localRouteSearchOptions.selectedTimeType = RouteTimeDeparture;
    
    [self setSelectedTimesForDate:[NSDate date]];
    [self searchRouteIfPossible];
}

-(void)tableViewRefreshing{
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Reloading Routes..."];
    refreshingRouteTable = YES;
    [self reloadCurrentSearch];
}

-(void)reloadCurrentSearch{
    NSDate *currentTime = [NSDate date];
    NSDate *myDate;
    if(localRouteSearchOptions.selectedTimeType == RouteTimeNow){
        myDate = currentTime;
        [self setSelectedTimesForDate:currentTime];
    }
    
    [self searchRouteIfPossible];
}

-(void)setSelectedTimesForDate:(NSDate *)date{
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"HHmm"];
//    NSString *time = [dateFormat stringFromDate:date];
//    selectedTimeString = time;
//    
//    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
//    [dateFormat2 setDateFormat:@"yyyyMMdd"];
//    NSString *date1 = [dateFormat2 stringFromDate:date];
//    selectedDateString = date1;
    
    localRouteSearchOptions.date = date;
    
    [self setSelectedTimeToTimeLabel:date andTimeType:localRouteSearchOptions.selectedTimeType];
}


- (void)setSelectedTimeToTimeLabel:(NSDate *)time andTimeType:(RouteTimeType)timeType{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [self isSameDateAsToday:time] ? [dateFormat setDateFormat:@"HH:mm"] : [dateFormat setDateFormat:@"d.MM.yy HH:mm"];
    NSString *prettyVersion = [dateFormat stringFromDate:time];
    
    switch (timeType) {
        case RouteTimeNow:
            selectedTimeLabel.text =[NSString stringWithFormat:@"Departs at: %@", prettyVersion];
            break;
            
        case RouteTimeDeparture:
            selectedTimeLabel.text =[NSString stringWithFormat:@"Departs at: %@", prettyVersion];
            break;
            
        case RouteTimeArrival:
            selectedTimeLabel.text =[NSString stringWithFormat:@"Arrives at: %@", prettyVersion];
            break;
            
        default:
            break;
    }
}

- (void)setOptionsTextToRouteOptionsLabel{
    if ([localRouteSearchOptions isAllTrasportTypesSelected]) {
        routeOptionsLable.text = @"Including All Transport Options";
    }else if ([localRouteSearchOptions isAllTrasportTypesExcluded]){
        routeOptionsLable.text = @"Only Walking Routes";
    }else{
        NSArray *excluded = [localRouteSearchOptions listOfExcludedtransportTypes];
        if (excluded.count > 0) {
            routeOptionsLable.text = [NSString stringWithFormat:@"Excluding: %@", [self formatPrettyDisplayList:excluded]];
        }else{
            routeOptionsLable.text = @"Including All Transport Options";
        }
    }
}

- (void)setTableBackgroundView {
    [routeResultsTableView setBlurredBackgroundWithImageNamed:nil];
}

-(NSString *)formatPrettyDisplayList:(NSArray *)stringArray{
    if (stringArray.count == 0) {
        return @"";
    }else if (stringArray.count == 1){
        return stringArray[0];
    }else if (stringArray.count == 2){
        return [NSString stringWithFormat:@"%@ and %@", stringArray[0], stringArray[1]];
    }else{
        NSString *commadPart = [ReittiStringFormatter commaSepStringFromArray:[stringArray subarrayWithRange:NSMakeRange(0, stringArray.count - 1)] withSeparator:@", "];
        return [NSString stringWithFormat:@"%@ and %@", commadPart, [stringArray lastObject]];
    }
}

-(BOOL)isSameDateAsToday:(NSDate *)date1{
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date1];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    return ([today day] == [otherDay day] &&
            [today month] == [otherDay month] &&
            [today year] == [otherDay year] &&
            [today era] == [otherDay era]);
}

-(void)reloadTableViewAnimatedWithInteralSeconds:(CGFloat)intervalSec{
//    tableReloadAnimatedMode = YES;
//    tableRowNumberForAnimation = 0;
    routeListCopy = [self.routeList mutableCopy];
    [self.routeList removeAllObjects];
    [routeResultsTableView reloadData];
    timerCallCount = 0;
    tableLoadTimer = [NSTimer scheduledTimerWithTimeInterval:intervalSec target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

-(void)timerCallback {
    if (timerCallCount < routeListCopy.count) {
        [self.routeList addObject:[routeListCopy objectAtIndex:timerCallCount]];
        [routeResultsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:timerCallCount inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
//        [routeResultsTableView reloadSections:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationLeft];
//        [routeResultsTableView reloadData];
        timerCallCount++;
    }else{
        [tableLoadTimer invalidate];
    }
}

-(void)setUpMergedBookmarksAndHistory{
    dataToLoad = nil;
    if (droppedPinGeoCode != nil) {
        dataToLoad = [[NSMutableArray alloc] initWithObjects:droppedPinGeoCode, nil];
        [dataToLoad addObjectsFromArray:namedBookmarks];
    }else{
        dataToLoad = [[NSMutableArray alloc] initWithArray:namedBookmarks];
    }
    
    
    NSMutableArray *tempArray1 = [[NSMutableArray alloc] initWithArray:savedStops];
    [tempArray1 addObjectsFromArray:savedRoutes];
    
    [dataToLoad addObjectsFromArray:[self sortDataArray:tempArray1]];
    
    NSMutableArray *tempArray2 = [[NSMutableArray alloc] initWithArray:recentRoutes];
    [tempArray2 addObjectsFromArray:recentStops];
    
    [dataToLoad addObjectsFromArray:[self sortDataArray:tempArray2]];
    
    dataToLoad = [self arrayByRemovingDuplicatesInHistory:dataToLoad];
}

- (NSMutableArray *)sortDataArray:(NSMutableArray *)array{
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        //We can cast all types to ReittiManagedObjectBase since we are only intereted in the date modified property
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

- (NSMutableArray *)arrayByRemovingDuplicatesInHistory:(NSMutableArray *)array{
    
    for (StopEntity *stop in self.savedStops) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"busStopCode == %@", stop.busStopCode];
        NSArray *filteredArray = [self.recentStops filteredArrayUsingPredicate:predicate];
        id firstFoundObject = nil;
        firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
        
        if (firstFoundObject != nil) {
            [array removeObject:firstFoundObject];
        }
    }
    
    for (RouteEntity *route in self.savedRoutes) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"routeUniqueName == %@", route.routeUniqueName];
        NSArray *filteredArray = [self.recentRoutes filteredArrayUsingPredicate:predicate];
        id firstFoundObject = nil;
        firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
        
        if (firstFoundObject != nil) {
            [array removeObject:firstFoundObject];
        }
    }
    
    return array;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userlocationChangedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:routeSearchOptionsChangedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - guesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"searchFromAddress"] || [segue.identifier isEqualToString:@"searchToAddress"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AddressSearchViewController *addressSearchViewController = [[navigationController viewControllers] lastObject];
        
        addressSearchViewController.savedStops = [NSMutableArray arrayWithArray:self.savedStops];
        addressSearchViewController.recentStops = [NSMutableArray arrayWithArray:self.recentStops];
        addressSearchViewController.namedBookmarks = [NSMutableArray arrayWithArray:self.namedBookmarks];
        addressSearchViewController.routeSearchMode = YES;
        addressSearchViewController.simpleSearchMode = YES;
        addressSearchViewController.darkMode = self.darkMode;
        addressSearchViewController.droppedPinGeoCode = self.droppedPinGeoCode;
        
        if ([segue.identifier isEqualToString:@"searchFromAddress"]){
            if (![fromSearchBar.text isEqualToString:currentLocationText]) {
                addressSearchViewController.prevSearchTerm = fromSearchBar.text;
            }
            
            activeSearchBar = fromSearchBar;
        }else if ([segue.identifier isEqualToString:@"searchToAddress"]){
            if (![toSearchBar.text isEqualToString:currentLocationText]) {
                addressSearchViewController.prevSearchTerm = toSearchBar.text;
            }
            
            activeSearchBar = toSearchBar;
        }
        addressSearchViewController.delegate = self;
        addressSearchViewController.reittiDataManager = self.reittiDataManager;;
    }
    
    if ([segue.identifier isEqualToString:@"showDetailedRoute"]) {
        NSIndexPath *selectedRowIndexPath = [routeResultsTableView indexPathForSelectedRow];
        if (selectedRowIndexPath.row < self.routeList.count) {
            Route * selectedRoute = [self.routeList objectAtIndex:selectedRowIndexPath.row];
            
            RouteDetailViewController *destinationViewController = (RouteDetailViewController *)segue.destinationViewController;
            
            [self configureDetailViewControllerWithRoute:selectedRoute andSelectedRouteIndex:(int)selectedRowIndexPath.row routeDetailViewController:destinationViewController];
            
            [self.navigationItem setTitle:@""];
            if (![self isModalMode]) {
                [self.tabBarController.tabBar setHidden:YES];
            }
        }
    }
    
    if ([segue.identifier isEqualToString:@"showSearchOptions"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteOptionsTableViewController *routeOptionsTableViewController = [[navigationController viewControllers] lastObject];

        routeOptionsTableViewController.settingsManager = settingsManager;
        routeOptionsTableViewController.routeSearchOptions = [localRouteSearchOptions copy];
        routeOptionsTableViewController.routeOptionSelectionDelegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"showRouteDisruptions"]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:routeResultsTableView];
        NSIndexPath *selectedRowIndexPath = [routeResultsTableView indexPathForRowAtPoint:buttonPosition];
        if (selectedRowIndexPath.row < self.routeList.count) {
            Route * selectedRoute = [self.routeList objectAtIndex:selectedRowIndexPath.row];
            
            InfoViewController *destinationViewController = (InfoViewController *)segue.destinationViewController;
            destinationViewController.disruptionsList = [self disruptionsForRoute:selectedRoute];
            destinationViewController.viewControllerMode = InfoViewModeStaticRouteDisruptions;
        }
    }
    
    [self.navigationItem setTitle:@""];
}

- (void)configureDetailViewControllerWithRoute:(Route *)selectedRoute andSelectedRouteIndex:(int)index routeDetailViewController:(RouteDetailViewController *)destinationViewController {
    destinationViewController.route = selectedRoute;
    destinationViewController.routeList = self.routeList;
    destinationViewController.selectedRouteIndex = index;
    destinationViewController.toLocation = toString;
    destinationViewController.fromLocation = fromString;
}

#pragma mark === UIViewControllerPreviewingDelegate Methods ===

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    
    NSIndexPath *selectedRowIndexPath = [routeResultsTableView indexPathForRowAtPoint:location];
    if ((selectedRowIndexPath.row < self.routeList.count)) {
        Route * selectedRoute = [self.routeList objectAtIndex:selectedRowIndexPath.row];
        
        UITableViewCell *cell = [routeResultsTableView cellForRowAtIndexPath:selectedRowIndexPath];
        if (cell) {
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionUsed3DTouch label:@"Route Detail Preview" value:nil];
            
            previewingContext.sourceRect = cell.frame;
            RouteDetailViewController *navController = (RouteDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ASARouteDetailViewController"];
            [self configureDetailViewControllerWithRoute:selectedRoute andSelectedRouteIndex:(int)selectedRowIndexPath.row  routeDetailViewController:navController];
            return navController;
        }
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
    [self.navigationItem setTitle:@""];
    if (![self isModalMode]) {
        [self.tabBarController.tabBar setHidden:YES];
    }
}

-(void)registerFor3DTouchIfAvailable{
    // Register for 3D Touch Previewing if available
    if ([self isForceTouchAvailable])
    {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:routeResultsTableView];
    }else{
        NSLog(@"3D Touch is not available on this device.!");
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
