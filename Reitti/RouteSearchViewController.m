
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
#import "SVProgressHUD.h"
#import "RouteViewManager.h"
#import "SearchController.h"
#import "AppDelegate.h"
#import "AppManager.h"
#import "CoreDataManager.h"
#import "DroppedPinManager.h"

typedef enum
{
    TableViewModeSuggestions = 1,
    TableViewModeRouteResults = 2
} TableViewMode;

@interface RouteSearchViewController ()

@property (nonatomic)TableViewMode tableViewMode;

@end

@implementation RouteSearchViewController

@synthesize savedStops, recentStops,savedRoutes, recentRoutes, namedBookmarks, dataToLoad, routeList, prevFromCoords, prevFromLocation, prevToCoords, prevToLocation, droppedPinGeoCode;
@synthesize reittiDataManager, settingsManager;
@synthesize delegate,viewCycledelegate;
@synthesize darkMode, isRootViewController;
@synthesize locationManager, currentUserLocation;
@synthesize refreshControl;
@synthesize managedObjectContext;

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
    selectedTimeType = SelectedTimeNow;
    selectedTime = [NSDate date];
    selectedSearchOption = RouteSearchOptionFastest;
    refreshingRouteTable = NO;
    nextRoutesRequested = NO;
    prevRoutesRequested = NO;
    
    tableReloadAnimatedMode = NO;
    tableRowNumberForAnimation = 0;
    
    tableViewController = [[UITableViewController alloc] init];
    
    [self setMainTableViewMode:TableViewModeSuggestions];
    [self setUpMergedBookmarksAndHistory];
    
    reittiDataManager.routeSearchdelegate = self;
    
    [self hideToolBar:YES animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    [self initLocationManager];
    [self selectSystemColors];
    [self setUpMainView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationItem setTitle:@"PLANNER"];
    [self setUpToolBar];
    
    [self refreshData];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    NSLog(@"will enter foreground notification");
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
}

-(BOOL)isModalMode{
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationValueChanged:)
                                                 name:[SettingsManager userlocationChangedNotificationName] object:nil];
}


- (void)refreshData {
    //update time to now and reload route.
    if ([[[self.routeList firstObject] getStartingTimeOfRoute] timeIntervalSinceNow] < -300) {
        selectedTime = [NSDate date];
        [self setSelectedTimesForDate:selectedTime];
        [self searchRouteIfPossible];
    }
    
    [self loadData];
    self.droppedPinGeoCode = [[DroppedPinManager sharedManager] droppedPin];
    [self setUpMergedBookmarksAndHistory];
    
    if (self.tableViewMode == TableViewModeSuggestions) {
        selectedTime = [NSDate date];
        [self setSelectedTimesForDate:selectedTime];
        
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
    
    [timeSelectionView setBlurTintColor:[UIColor whiteColor]];
    timeSelectionView.layer.borderWidth = 0.5;
    timeSelectionView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    datePicker.tintColor = systemSubTextColor;
    timeTypeSegmentControl.tintColor = [UIColor darkGrayColor];
    
    timeTypeSegmentControl.selectedSegmentIndex = (int)selectedTimeType;
    
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"HHmm"];
//    NSString *time = [dateFormat stringFromDate:[NSDate date]];
//    selectedTimeString = time;
//    
//    
//    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
//    [dateFormat2 setDateFormat:@"YYYYMMdd"];
//    NSString *date = [dateFormat2 stringFromDate:[NSDate date]];
//    selectedDateString = date;
    
//    [self setSelectedTimeToTimeLabel:[NSDate date] andTimeType:SelectedTimeDeparture];
    
//    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
//    [dateFormat3 setDateFormat:@"HH:mm"];
//    NSString *prettyVersion = [dateFormat3 stringFromDate:[NSDate date]];
//    
//    selectedTimeLabel.text = [NSString stringWithFormat:@"Departs at: %@", prettyVersion];
    
    selectedTimeType = SelectedTimeDeparture;
    [self setSelectedTimesForDate:[NSDate date]];
    
    timeSelectionViewShadeView.frame = self.view.frame;
    timeSelectionViewShadeView.hidden = YES;
    
//    searchActivityIndicator.tintColor = systemSubTextColor;
    
    //fromSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    //toSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    
    searchOptionSelectionView.hidden = YES;
    [searchOptionSelectionView setBlurTintColor:systemBackgroundColor];
    
//    [self hideTimeSelectionView:YES animated:NO];
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
    routeResultsTableView.backgroundColor = [UIColor clearColor];
//    routeResultsTableView.layer.borderWidth = 1;
//    routeResultsTableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    CGRect tableFrame = routeResultsTableView.frame;
    tableFrame.size.height = self.view.bounds.size.height - routeResultsTableContainerView.frame.origin.y;
    routeResultsTableView.frame = tableFrame;
    
    [self.refreshControl endRefreshing];
//    [self initRefreshControl];
    
    [self searchRouteIfPossible];
    
    
    for (UIView *firstSubView in fromSearchBar.subviews)
    {
        for (UIView *subview in firstSubView.subviews) {
            // Remove the default background
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [subview removeFromSuperview];
            }
            
            // Remove the rounded corners
            if ([subview isKindOfClass:NSClassFromString(@"UITextField")]) {
                UITextField *textField = (UITextField *)subview;
                [textField setBackgroundColor:[UIColor clearColor]];
                textField.layer.borderColor =[[UIColor lightGrayColor] CGColor];
                textField.clearButtonMode = UITextFieldViewModeNever;
                for (UIView *subsubview in textField.subviews) {
                    if ([subsubview isKindOfClass:NSClassFromString(@"_UISearchBarSearchFieldBackgroundView")]) {
                        [subsubview removeFromSuperview];
                    }
                }
            }
             
        }
    }
    
    [fromSearchBar setImage:[UIImage imageNamed:@"location-light-25.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    for (UIView *firstSubView in toSearchBar.subviews)
    {
        for (UIView *subview in firstSubView.subviews) {
            // Remove the default background
            
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [subview removeFromSuperview];
            }
            
            // Remove the rounded corners
            if ([subview isKindOfClass:NSClassFromString(@"UITextField")]) {
                UITextField *textField = (UITextField *)subview;
                [textField setBackgroundColor:[UIColor clearColor]];
                textField.layer.borderColor =[[UIColor lightGrayColor] CGColor];
                textField.clearButtonMode = UITextFieldViewModeNever;
                for (UIView *subsubview in textField.subviews) {
                    if ([subsubview isKindOfClass:NSClassFromString(@"_UISearchBarSearchFieldBackgroundView")]) {
                        [subsubview removeFromSuperview];
                    }
                }
            }
        }
    }
    
    [toSearchBar setImage:[UIImage imageNamed:@"finish_flag-light-50.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [self setBookmarkButtonStatus];
}

-(void)setUpToolBar{
    UIImage *image1 = [UIImage imageNamed:@"previous-green-64.png"];
    CGRect frame = CGRectMake(0, 0, 22, 22);
    
    UIButton* prevButton = [[UIButton alloc] initWithFrame:frame];
    [prevButton setBackgroundImage:image1 forState:UIControlStateNormal];
    
    [prevButton addTarget:self action:@selector(previousRoutesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* prevBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:prevButton];
    prevBarButtonItem.tintColor = SYSTEM_GREEN_COLOR;
    
    UIBarButtonItem *firstSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    firstSpace.width = 30;
    
    UIBarButtonItem *nowBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Now" style:UIBarButtonItemStylePlain target:self action:@selector(currentTimeRoutesButtonPressed:)];
    nowBarButtonItem.tintColor = SYSTEM_GREEN_COLOR;
    
    UIBarButtonItem *secondSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    secondSpace.width = 30;
    
    UIImage *image2 = [UIImage imageNamed:@"next-green-100.png"];
    
    UIButton* nextButton = [[UIButton alloc] initWithFrame:frame];
    [nextButton setBackgroundImage:image2 forState:UIControlStateNormal];
    
    [nextButton addTarget:self action:@selector(nextRoutesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* nextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *clearBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearSearchButtonPressed:)];
    clearBarButtonItem.tintColor = SYSTEM_GREEN_COLOR;
    
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
    NSLog(@"%d",[CLLocationManager authorizationStatus]);
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServicesEnabled) {
        if(showMessage){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Looks like location services is not enabled"
                                                                message:@"Enable it from Settings/Privacy/Location Services to get route searches from current location (which makes your life way easier BTW)."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        return NO;
    }
    
    if (!accessGranted) {
        if(showMessage){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Looks like access is not granted to this app for location services."
                                                                message:@"Grant access from Settings/Privacy/Location Services to get route searches from current location (which makes your life way easier BTW)."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
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
    routeBookmarked = YES;
}

- (void)setRouteNotBookmarkedState{
    [bookmarkRouteButton setImage:[UIImage imageNamed:@"star-line-white-100.png"] forState:UIControlStateNormal];
    routeBookmarked = NO;
}

#pragma mark - IBActions
- (IBAction)cancelButtonPressed:(id)sender {
//    [toSearchBar resignFirstResponder];
//    [fromSearchBar resignFirstResponder];
//    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.viewCycledelegate routeSearchViewControllerDismissed];
    }];
}
/*
- (IBAction)timeSElectionButtonClicked:(id)sender {
//    [self hideTimeSelectionView:![self isTimeSelectionViewVisible] animated:YES];
}

-(IBAction)tapGestureDetectedOnShade:(UIGestureRecognizer *)sender{
//   [self hideTimeSelectionView:YES animated:YES];
}
*/

/*
- (IBAction)timeSelectionIsDone:(id)sender {
    
    [self hideTimeSelectionView:YES animated:YES];
    NSDate *currentTime = [NSDate date];
    NSDate *myDate;
    if(selectedTimeType == SelectedTimeNow){
        myDate = currentTime;
        datePicker.date = currentTime;
    }else{
        myDate = datePicker.date;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSString *time = [dateFormat stringFromDate:myDate];
    selectedTimeString = time;
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"YYYYMMdd"];
    NSString *date = [dateFormat2 stringFromDate:myDate];
    selectedDateString = date;
    
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
    NSString *prettyVersion = [dateFormat3 stringFromDate:myDate];
    
    switch (selectedTimeType) {
        case SelectedTimeNow:
            selectedTimeLabel.text =[NSString stringWithFormat:@"Departes at: %@", prettyVersion];
            break;
            
        case SelectedTimeDeparture:
            selectedTimeLabel.text =[NSString stringWithFormat:@"Departes at: %@", prettyVersion];
            break;
            
        case SelectedTimeArrival:
            selectedTimeLabel.text =[NSString stringWithFormat:@"Arrives at: %@", prettyVersion];
            break;
            
        default:
            break;
    }
    
    [self searchRouteIfPossible];
}
*/

/*
- (IBAction)timeTypeChanged:(id)sender {
    selectedTimeType = (int)timeTypeSegmentControl.selectedSegmentIndex;
    if (timeTypeSegmentControl.selectedSegmentIndex == 0) {
        [datePicker setDate:[NSDate date]];
    }
}
*/

/*
- (IBAction)datePickerValueChanged:(id)sender {
    if (selectedTimeType == SelectedTimeNow) {
        selectedTimeType = SelectedTimeDeparture;
    }
    
    timeTypeSegmentControl.selectedSegmentIndex = (int)selectedTimeType;
}

- (IBAction)routeOptionButtonClicked:(id)sender {
    searchOptionSelectionView.hidden = !searchOptionSelectionView.hidden;
}

- (IBAction)routeOptionSegmentControlValueChanged:(id)sender {
    selectedSearchOption = (int)searchOptionSegmentControl.selectedSegmentIndex;
    [self searchRouteIfPossible];
    searchOptionSelectionView.hidden = YES;
}
 */

- (IBAction)nextRoutesButtonPressed:(id)sender {
    if (selectedTimeType == SelectedTimeNow) {
        selectedTimeType = SelectedTimeDeparture;
        timeTypeSegmentControl.selectedSegmentIndex = (int)selectedTimeType;
    }
    
    Route *lastRoute;
    NSDate *lastTime;
    if(selectedTimeType == SelectedTimeArrival){
        lastRoute = [self.routeList objectAtIndex:0];
        if (lastRoute == nil)
            return;
        
        selectedTimeType = SelectedTimeDeparture;
        nextRoutesRequested = YES;
        
        lastTime = lastRoute.getEndingTimeOfRoute;
        
    }else{
        lastRoute = [self.routeList lastObject];
        if (lastRoute == nil)
            return;
        lastTime = lastRoute.getStartingTimeOfRoute;
    }
    
    [self setSelectedTimesForDate:lastTime];
    
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"HHmm"];
//    NSString *time = [dateFormat stringFromDate:lastTime];
//    selectedTimeString = time;
//    
//    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
//    [dateFormat2 setDateFormat:@"YYYYMMdd"];
//    NSString *date = [dateFormat2 stringFromDate:lastTime];
//    selectedDateString = date;
//    
//    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
//    [self isSameDateAsToday:lastTime] ? [dateFormat3 setDateFormat:@"HH:mm"] : [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
//    NSString *prettyVersion = [dateFormat3 stringFromDate:lastTime];
//    
//    if (selectedTimeType == SelectedTimeArrival) {
//        selectedTimeLabel.text =[NSString stringWithFormat:@"Arrives at: %@", prettyVersion];
//    }else{
//        selectedTimeLabel.text =[NSString stringWithFormat:@"Departs at: %@", prettyVersion];
//    }
    
    [self searchRouteIfPossible];
}

- (IBAction)currentTimeRoutesButtonPressed:(id)sender {
    selectedTimeType = SelectedTimeNow;
    timeTypeSegmentControl.selectedSegmentIndex = (int)SelectedTimeNow;
    [self reloadCurrentSearch];
}

- (IBAction)previousRoutesButtonPressed:(id)sender {
    if (selectedTimeType == SelectedTimeNow) {
        selectedTimeType = SelectedTimeDeparture;
        timeTypeSegmentControl.selectedSegmentIndex = (int)selectedTimeType;

    }
    
    Route *lastRoute;
    NSDate *lastTime;
    if(selectedTimeType == SelectedTimeArrival){
        lastRoute = [self.routeList lastObject];
        if (lastRoute == nil)
            return;
        lastTime = lastRoute.getEndingTimeOfRoute;
    }else{
        lastRoute = [self.routeList objectAtIndex:0];
        if (lastRoute == nil)
            return;
        selectedTimeType = SelectedTimeArrival;
        prevRoutesRequested = YES;
        
        lastTime = lastRoute.getEndingTimeOfRoute;
    }
    
    [self setSelectedTimesForDate:lastTime];
    
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"HHmm"];
//    NSString *time = [dateFormat stringFromDate:lastTime];
//    selectedTimeString = time;
//    
//    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
//    [dateFormat2 setDateFormat:@"YYYYMMdd"];
//    NSString *date = [dateFormat2 stringFromDate:lastTime];
//    selectedDateString = date;
//    
//    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
//    [self isSameDateAsToday:lastTime] ? [dateFormat3 setDateFormat:@"HH:mm"] : [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
//    NSString *prettyVersion = [dateFormat3 stringFromDate:lastTime];
//    
//    if (selectedTimeType == SelectedTimeArrival) {
//        selectedTimeLabel.text =[NSString stringWithFormat:@"Arrives at: %@", prettyVersion];
//    }else{
//        selectedTimeLabel.text =[NSString stringWithFormat:@"Departs at: %@", prettyVersion];
//    }
    
    [self searchRouteIfPossible];
}

- (IBAction)clearSearchButtonPressed:(id)sender {
    [self clearSearchTexts];
    
    [self.routeList removeAllObjects];
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
        }
    }
    
    [self setBookmarkButtonStatus];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
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
/*
- (void)searchBarTextDidEndEditing:(UISearchBar *)thisSearchBar {
    //Show segment control if there is no text in seach field
    if (thisSearchBar.text == nil || [thisSearchBar.text isEqualToString:@""]){
        //[self hideSuggestionTableView:YES animated:YES];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    isFinalSearch = NO;
    if (searchText.length > 2){
        [reittiDataManager searchAddressesForKey:searchText];
        unRespondedRequestsCount++;
    }else if(searchText.length > 0) {
        dataToLoad = [self searchFromBookmarkAndHistoryForKey:searchText];
        [searchSuggestionsTableView reloadData];
    }else {
        //Load bookmarks and history
        [self setUpMergedInitialSearchView:YES];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    isFinalSearch = YES;
    if (searchBar.text.length > 2){
        [reittiDataManager searchAddressesForKey:searchBar.text];
        unRespondedRequestsCount++;
        [searchActivityIndicator startAnimating];
    }
    else {
        dataToLoad = [ self searchFromBookmarkAndHistoryForKey:searchBar.text];
        [searchSuggestionsTableView reloadData];
        
        //Message that search term is short
        if (isFinalSearch) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"At least 3 letters, that's the rule."                                                                                      message:@"The search term is too short. Minimum length is 3."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}
*/

#pragma mark - route search delegates
- (void)routeSearchDidComplete:(NSArray *)searchedRouteList{
    if (nextRoutesRequested) {
        if (selectedTimeType == SelectedTimeDeparture) {
            selectedTimeType = SelectedTimeArrival;
            
            Route *firstRoute = [searchedRouteList objectAtIndex:0];
            Route *secondRoute = [searchedRouteList objectAtIndex:1];
            
            [self setSelectedTimesForDate:secondRoute.getEndingTimeOfRoute];
            
            NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
            [self isSameDateAsToday:secondRoute.getEndingTimeOfRoute] ? [dateFormat3 setDateFormat:@"HH:mm"] : [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
            NSString *prettyVersion = [dateFormat3 stringFromDate:secondRoute.getEndingTimeOfRoute];
            
            selectedTimeLabel.text =[NSString stringWithFormat:@"Arrives at: %@", prettyVersion];
            
            [self.routeList removeLastObject];
            [self.routeList removeLastObject];
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.routeList];
            [self.routeList removeAllObjects];
            [self.routeList addObject:secondRoute];
            [self.routeList addObject:firstRoute];
            [self.routeList addObjectsFromArray:temp];
            
        }
        nextRoutesRequested = NO;
    }else if (prevRoutesRequested){
        if (selectedTimeType == SelectedTimeArrival){
            selectedTimeType = SelectedTimeDeparture;
            
            Route *firstRoute = [searchedRouteList objectAtIndex:0];
            Route *secondRoute = [searchedRouteList objectAtIndex:1];
            
            [self setSelectedTimesForDate:secondRoute.getStartingTimeOfRoute];
            
            NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
            [self isSameDateAsToday:secondRoute.getStartingTimeOfRoute] ? [dateFormat3 setDateFormat:@"HH:mm"] : [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
            NSString *prettyVersion = [dateFormat3 stringFromDate:secondRoute.getStartingTimeOfRoute];
            
            selectedTimeLabel.text =[NSString stringWithFormat:@"Departs at: %@", prettyVersion];
            
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
    [SVProgressHUD dismissFromView:self.view];
    
    [routeResultsTableView setContentOffset:CGPointZero animated:YES];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [self.refreshControl endRefreshing];
    
    if (!searchOptionSelectionView.hidden) {
        searchOptionSelectionView.hidden = YES;
    }
    
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
    [SVProgressHUD dismissFromView:self.view];
}
#pragma mark - routeSearchOptionSelection
-(void)optionSelectionDidComplete:(RouteSearchOptions *)routeOptions{
    selectedTimeType = routeOptions.selectedTimeType;
    selectedSearchOption = routeOptions.routeSearchOption;
    
    NSDate *currentTime = [NSDate date];
    
    if(selectedTimeType == SelectedTimeNow){
        selectedTime = currentTime;
    }else{
        selectedTime = routeOptions.date;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSString *time = [dateFormat stringFromDate:selectedTime];
    selectedTimeString = time;
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"YYYYMMdd"];
    NSString *date = [dateFormat2 stringFromDate:selectedTime];
    selectedDateString = date;
    
    [self setSelectedTimeToTimeLabel:selectedTime andTimeType:selectedTimeType];
    
    [self searchRouteIfPossible];
}

- (void)setSelectedTimeToTimeLabel:(NSDate *)time andTimeType:(SelectedTimeType)timeType{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [self isSameDateAsToday:time] ? [dateFormat setDateFormat:@"HH:mm"] : [dateFormat setDateFormat:@"d.MM.yy HH:mm"];
    NSString *prettyVersion = [dateFormat stringFromDate:time];
    
    switch (timeType) {
        case SelectedTimeNow:
            selectedTimeLabel.text =[NSString stringWithFormat:@"Departs at: %@", prettyVersion];
            break;
            
        case SelectedTimeDeparture:
            selectedTimeLabel.text =[NSString stringWithFormat:@"Departs at: %@", prettyVersion];
            break;
            
        case SelectedTimeArrival:
            selectedTimeLabel.text =[NSString stringWithFormat:@"Arrives at: %@", prettyVersion];
            break;
            
        default:
            break;
    }
}

#pragma mark - TableViewMethods
- (void)initRefreshControl{
    
    tableViewController.tableView = routeResultsTableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(tableViewRefreshing) forControlEvents:UIControlEventValueChanged];
//    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Routes"];
    tableViewController.refreshControl = self.refreshControl;
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
            
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            
            title.text = @"Dropped pin";
            subTitle.text = [geoCode getStreetAddressString];
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
            StopEntity *stopEntity = [self.dataToLoad objectAtIndex:indexPath.row];
            
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            UILabel *dateLabel = (UILabel *)[cell viewWithTag:2004];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:2005];
            imageView.image = [AppManager stopAnnotationImageForStopType:stopEntity.stopType];
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.text = stopEntity.busStopName;
            //stopName.font = CUSTOME_FONT_BOLD(23.0f);
            
            subTitle.text = [NSString stringWithFormat:@"%@ - %@", stopEntity.busStopShortCode, stopEntity.busStopCity];
            //cityName.font = CUSTOME_FONT_BOLD(19.0f);
            if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
                dateLabel.hidden = NO;
                dateLabel.text = [ReittiStringFormatter formatPrittyDate:stopEntity.dateModified];
            }else{
                dateLabel.hidden = YES;
            }
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[NamedBookmark class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"namedBookmarkCell"];
            NamedBookmark *namedBookmark = [NamedBookmark alloc];
            if (indexPath.row < self.dataToLoad.count) {
                namedBookmark = [self.dataToLoad objectAtIndex:indexPath.row];
            }
            
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:2001];
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            [imageView setImage:[UIImage imageNamed:namedBookmark.iconPictureName]];
            
            title.text = namedBookmark.name;
            subTitle.text = [NSString stringWithFormat:@"%@, %@", namedBookmark.streetAddress, namedBookmark.city];
            
            
            //cityName.font = CUSTOME_FONT_BOLD(19.0f);
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteEntity class]]){
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedRouteCell"];
            RouteEntity *routeEntity = [RouteEntity alloc];
            if (indexPath.row < self.dataToLoad.count) {
                routeEntity = [self.dataToLoad objectAtIndex:indexPath.row];
            }
            
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            UILabel *dateLabel = (UILabel *)[cell viewWithTag:2004];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.text = routeEntity.toLocationName;
            //stopName.font = CUSTOME_FONT_BOLD(23.0f);
            
            subTitle.text = [NSString stringWithFormat:@"%@", routeEntity.fromLocationName];
            
            if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]) {
                dateLabel.hidden = NO;
                dateLabel.text = [ReittiStringFormatter formatPrittyDate:routeEntity.dateModified];
            }else{
                dateLabel.hidden = YES;
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
            durationLabel.attributedText = [ReittiStringFormatter formatAttributedDurationString:[route.routeDurationInSeconds integerValue] withFont:durationLabel.font];
//            durationLabel.text = [NSString stringWithFormat:@"%d", (int)([route.routeDurationInSeconds integerValue]/60)];
            
//            UILabel *walkingDistLabel = (UILabel *)[cell viewWithTag:2004];
            CGFloat walkingKm = route.getTotalWalkLength/1000.0;
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            
            [formatter setMaximumFractionDigits:2];
            
            [formatter setRoundingMode: NSNumberFormatterRoundUp];
            
            NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:walkingKm]];
            
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
            
            CGFloat totalWidth = self.view.frame.size.width - 75;
            
//            UIView *transportsContainer = [[UIView alloc] initWithFrame:CGRectMake(12, 0, totalWidth , 36)];
//            transportsContainer.clipsToBounds = YES;
//            transportsContainer.tag = 1987;
//            transportsContainer.layer.cornerRadius = 4;
            
//            float tWidth = 70;
            
            CGFloat longestDuration;
            NSArray *routes;
            if (routeListCopy != nil && routeListCopy.count > routeList.count) {
                routes = [NSArray arrayWithArray:routeListCopy];
            }else{
                routes = [NSArray arrayWithArray:routeList];
            }
            longestDuration = [self adjustedWidthForNoTruncation:&totalWidth forListOfRoutes:routes];
            
//            float x;
//            [self viewForRoute:transportsContainer longestDuration:longestDuration width:totalWidth route:route];
            UIView *transportsContainer = [RouteViewManager viewForRoute:route longestDuration:longestDuration width:totalWidth];
//            [transportsContainer addSubview:routeView];
            
            transportsContainer.frame = CGRectMake(12, 0, transportsContainer.frame.size.width, transportsContainer.frame.size.height);
            [transportsScrollView addSubview:transportsContainer];
            transportsScrollView.contentSize = CGSizeMake(transportsContainer.frame.size.width + 24, transportsScrollView.frame.size.height);
            
            transportsScrollView.userInteractionEnabled = NO;
            [cell.contentView addGestureRecognizer:transportsScrollView.panGestureRecognizer];
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

- (CGFloat)adjustedWidthForNoTruncation:(CGFloat *)totalWidth_p forListOfRoutes:(NSArray *)routes
{
    //get longest route duration
    CGFloat longestDuration = 0.0;
    CGFloat totalDuration = 0.0;
    for (Route *route in routes) {
        if ([route.routeDurationInSeconds floatValue] > longestDuration) {
            longestDuration = [route.routeDurationInSeconds floatValue];
        }
        totalDuration += [route.routeDurationInSeconds floatValue];
    }
    
    /*
    //Adjust so that each none walking leg is longer than 30
    CGFloat largestMultiplier = 1.0;
    for (Route *route in routes) {
        for (RouteLeg *leg in route.routeLegs) {
            if (leg.legType != LegTypeWalk) {
                CGFloat tWidth = *totalWidth_p * (([leg.legDurationInSeconds floatValue] - leg.waitingTimeInSeconds)/longestDuration);
                if (tWidth < 30) {
                    if (largestMultiplier < 30/tWidth) {
                        largestMultiplier = 30/tWidth;
                    }
                }
            }
        }
    }
    
    *totalWidth_p = *totalWidth_p * largestMultiplier;
    
    */
    
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
            
            [self setTextToSearchBar:toSearchBar text:[NSString stringWithFormat:@"%@ %@", stopEntity.busStopName, stopEntity.busStopShortCode]];
            
            toString = [NSString stringWithFormat:@"%@ %@", stopEntity.busStopName, stopEntity.busStopShortCode];
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

#pragma mark - address search view controller
- (void)searchResultSelectedAStop:(StopEntity *)stopEntity{
    [self setTextToSearchBar:activeSearchBar text:[NSString stringWithFormat:@"%@ %@", stopEntity.busStopName, stopEntity.busStopShortCode]];
    
    if (activeSearchBar == fromSearchBar) {
        fromString = [NSString stringWithFormat:@"%@ %@", stopEntity.busStopName, stopEntity.busStopShortCode];
        fromCoords = stopEntity.busStopWgsCoords;
    }else if (activeSearchBar == toSearchBar) {
        toString = [NSString stringWithFormat:@"%@ %@", stopEntity.busStopName, stopEntity.busStopShortCode];
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
    [self setTextToSearchBar:activeSearchBar text:geoCode.FullAddressString];
    
    if (activeSearchBar == fromSearchBar) {
        fromString = geoCode.FullAddressString;
        fromCoords = geoCode.coords;
    }else if (activeSearchBar == toSearchBar) {
        toString = geoCode.FullAddressString;
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
    reittiDataManager.routeSearchdelegate = self;
}

#pragma mark - Settings change notifications
-(void)userLocationValueChanged:(NSNotification *)notification{
    [self.reittiDataManager setUserLocation:[self.settingsManager userLocation]];
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
        NSString *timeType;
        if (selectedTimeType == SelectedTimeNow || selectedTimeType == SelectedTimeDeparture) {
            timeType = @"departure";
        }else{
            timeType = @"arrival";
        }
        
        [reittiDataManager searchRouteForFromCoords:fromCoords andToCoords:toCoords time:selectedTimeString andDate:selectedDateString andTimeType:timeType andSearchOption:selectedSearchOption];
        //Remove previous search result from table
        if (!nextRoutesRequested && !prevRoutesRequested) {
            self.routeList = nil;
//            [self.view layoutSubviews];
            [routeResultsTableView reloadData];
        }
        
//        [self hideTimeSelectionView:YES animated:YES];
        if (refreshingRouteTable) {
            refreshingRouteTable = NO;
        }else{
//            [searchActivityIndicator startAnimating];
            [SVProgressHUD showHUDInView:self.view];
        }
        
        if (self.tableViewMode == TableViewModeSuggestions) {
            [self setMainTableViewMode:TableViewModeRouteResults];
            [routeResultsTableView reloadData];
        }
    }else{
        if (refreshingRouteTable) {
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
            [self.refreshControl endRefreshing];
            refreshingRouteTable = NO;
        }
    }
}

-(void)tableViewRefreshing{
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Reloading Routes..."];
    refreshingRouteTable = YES;
    [self reloadCurrentSearch];
}

-(void)reloadCurrentSearch{
    NSDate *currentTime = [NSDate date];
    NSDate *myDate;
    if(selectedTimeType == SelectedTimeNow){
        myDate = currentTime;
//        datePicker.date = currentTime;
        
        [self setSelectedTimesForDate:currentTime];
        
//        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
//        [self isSameDateAsToday:myDate] ? [dateFormat3 setDateFormat:@"HH:mm"] : [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
//        NSString *prettyVersion = [dateFormat3 stringFromDate:myDate];
//        
//        selectedTimeLabel.text =[NSString stringWithFormat:@"Departs at: %@", prettyVersion];
    }
    
    [self searchRouteIfPossible];
}

-(void)setSelectedTimesForDate:(NSDate *)date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSString *time = [dateFormat stringFromDate:date];
    selectedTimeString = time;
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"YYYYMMdd"];
    NSString *date1 = [dateFormat2 stringFromDate:date];
    selectedDateString = date1;
    
    [self setSelectedTimeToTimeLabel:date andTimeType:selectedTimeType];
    
//    datePicker.date = date;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[SettingsManager userlocationChangedNotificationName] object:nil];
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
            
            destinationViewController.route = selectedRoute;
            destinationViewController.routeList = self.routeList;
            destinationViewController.selectedRouteIndex = (int)selectedRowIndexPath.row;
            destinationViewController.toLocation = toString;
            destinationViewController.fromLocation = fromString;
//            destinationViewController.reittiDataManager = self.reittiDataManager;
            
            [self.navigationItem setTitle:@""];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showSearchOptions"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteOptionsTableViewController *routeOptionsTableViewController = [[navigationController viewControllers] lastObject];
        
        routeOptionsTableViewController.selectedDate = selectedTime;
        routeOptionsTableViewController.selectedTimeType = selectedTimeType;
        routeOptionsTableViewController.selectedSearchOption = selectedSearchOption;
        
        routeOptionsTableViewController.routeOptionSelectionDelegate = self;
    }
    
}


@end
