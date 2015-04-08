
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


@interface RouteSearchViewController ()

@end

@implementation RouteSearchViewController

@synthesize savedStops, recentStops, dataToLoad, routeList, prevFromCoords, prevFromLocation, prevToCoords, prevToLocation;
@synthesize reittiDataManager;
@synthesize delegate,viewCycledelegate;
@synthesize darkMode;
@synthesize locationManager, currentUserLocation;
@synthesize refreshControl;

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];
#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    currentLocationText = @"Current location";
    selectedTimeType = SelectedTimeNow;
    selectedTime = [NSDate date];
    selectedSearchOption = RouteSearchOptionFastest;
    refreshingRouteTable = NO;
    nextRoutesRequested = NO;
    prevRoutesRequested = NO;
    
    tableReloadAnimatedMode = NO;
    tableRowNumberForAnimation = 0;
    
    timeSelectionShadeTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetectedOnShade:)];
    timeSelectionShadeTapGestureRecognizer.delegate = self;
    
    [timeSelectionViewShadeView addGestureRecognizer:timeSelectionShadeTapGestureRecognizer];
    
    reittiDataManager.routeSearchdelegate = self;
    
    [self hideToolBar:YES animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    [self initLocationManager];
    [self selectSystemColors];
    [self setUpMainView];
}

-(void)viewWillAppear:(BOOL)animated{
    //Update list of saved stopes in case a new one is saved in the detail view
    if (self.reittiDataManager != nil) {
        NSArray * savedArray = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
        self.savedStops = [NSMutableArray arrayWithArray:savedArray];
    }
    
    [self setUpToolBar];
}

-(void)viewDidAppear:(BOOL)animated{
    //update time to now and reload route.
    if ([[[self.routeList firstObject] getStartingTimeOfRoute] timeIntervalSinceNow] < -300) {
        selectedTime = [NSDate date];
        [self setSelectedTimesForDate:selectedTime];
        [self searchRouteIfPossible];
    }
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

#pragma mark - initializations

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
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSString *time = [dateFormat stringFromDate:[NSDate date]];
    selectedTimeString = time;
    
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"YYYYMMdd"];
    NSString *date = [dateFormat2 stringFromDate:[NSDate date]];
    selectedDateString = date;
    
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:@"HH:mm"];
    NSString *prettyVersion = [dateFormat3 stringFromDate:[NSDate date]];
    
    selectedTimeLabel.text = [NSString stringWithFormat:@"Departes at: %@", prettyVersion];
    
    timeSelectionViewShadeView.frame = self.view.frame;
    timeSelectionViewShadeView.hidden = YES;
    
    searchActivityIndicator.tintColor = systemSubTextColor;
    
    //fromSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    //toSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    
    searchOptionSelectionView.hidden = YES;
    [searchOptionSelectionView setBlurTintColor:systemBackgroundColor];
    
    [self hideTimeSelectionView:YES animated:NO];
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
    routeResultsTableView.layer.borderWidth = 1;
    routeResultsTableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    CGRect tableFrame = routeResultsTableView.frame;
    tableFrame.size.height = self.view.bounds.size.height - routeResultsTableContainerView.frame.origin.y;
    routeResultsTableView.frame = tableFrame;
    
    [self.refreshControl endRefreshing];
    [self initRefreshControl];
    
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
    UIImage *image1 = [UIImage imageNamed:@"previous-gray-64.png"];
    CGRect frame = CGRectMake(0, 0, 25, 25);
    
    UIButton* prevButton = [[UIButton alloc] initWithFrame:frame];
    [prevButton setBackgroundImage:image1 forState:UIControlStateNormal];
    
    [prevButton addTarget:self action:@selector(previousRoutesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* prevBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:prevButton];
    
    
    UIBarButtonItem *firstSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    firstSpace.width = 30;
    
    UIBarButtonItem *nowBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Now" style:UIBarButtonItemStyleDone target:self action:@selector(currentTimeRoutesButtonPressed:)];
    
    UIBarButtonItem *secondSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    secondSpace.width = 30;
    
    UIImage *image2 = [UIImage imageNamed:@"next-gray-64.png"];
    
    UIButton* nextButton = [[UIButton alloc] initWithFrame:frame];
    [nextButton setBackgroundImage:image2 forState:UIControlStateNormal];
    
    [nextButton addTarget:self action:@selector(nextRoutesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* nextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *clearBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleDone target:self action:@selector(clearSearchButtonPressed:)];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:prevBarButtonItem];
    [items addObject:firstSpace];
    [items addObject:nextBarButtonItem];
    [items addObject:secondSpace];
    [items addObject:nowBarButtonItem];
    [items addObject:flexiSpace];
    [items addObject:clearBarButtonItem];
    self.toolbarItems = items;
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
                    searchBarTextField.textColor = SYSTEM_GREEN_COLOR;
                    
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
                    searchBarTextField.textColor = [UIColor whiteColor];
                    
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
    [self dismissViewControllerAnimated:YES completion:^{
        [self.viewCycledelegate routeSearchViewControllerDismissed];
    }];
}

- (IBAction)timeSElectionButtonClicked:(id)sender {
    [self hideTimeSelectionView:![self isTimeSelectionViewVisible] animated:YES];
}

-(IBAction)tapGestureDetectedOnShade:(UIGestureRecognizer *)sender{
   [self hideTimeSelectionView:YES animated:YES];
}

- (IBAction)timeSelectionIsDone:(id)sender {
    /*
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
    */
}

- (IBAction)timeTypeChanged:(id)sender {
    selectedTimeType = (int)timeTypeSegmentControl.selectedSegmentIndex;
    if (timeTypeSegmentControl.selectedSegmentIndex == 0) {
        [datePicker setDate:[NSDate date]];
    }
}

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
    
    datePicker.date = lastTime;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSString *time = [dateFormat stringFromDate:lastTime];
    selectedTimeString = time;
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"YYYYMMdd"];
    NSString *date = [dateFormat2 stringFromDate:lastTime];
    selectedDateString = date;
    
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [self isSameDateAsToday:lastTime] ? [dateFormat3 setDateFormat:@"HH:mm"] : [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
    NSString *prettyVersion = [dateFormat3 stringFromDate:lastTime];
    
    if (selectedTimeType == SelectedTimeArrival) {
        selectedTimeLabel.text =[NSString stringWithFormat:@"Arrives at: %@", prettyVersion];
    }else{
        selectedTimeLabel.text =[NSString stringWithFormat:@"Departes at: %@", prettyVersion];
    }
    
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
    
    
    datePicker.date = lastTime;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSString *time = [dateFormat stringFromDate:lastTime];
    selectedTimeString = time;
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"YYYYMMdd"];
    NSString *date = [dateFormat2 stringFromDate:lastTime];
    selectedDateString = date;
    
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [self isSameDateAsToday:lastTime] ? [dateFormat3 setDateFormat:@"HH:mm"] : [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
    NSString *prettyVersion = [dateFormat3 stringFromDate:lastTime];
    
    if (selectedTimeType == SelectedTimeArrival) {
        selectedTimeLabel.text =[NSString stringWithFormat:@"Arrives at: %@", prettyVersion];
    }else{
        selectedTimeLabel.text =[NSString stringWithFormat:@"Departes at: %@", prettyVersion];
    }
    
    [self searchRouteIfPossible];
}

- (IBAction)clearSearchButtonPressed:(id)sender {
    [self clearSearchTexts];
    
    [self.routeList removeAllObjects];
    [routeResultsTableView reloadData];
    
    //TODO: display saved stops
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
            
            selectedTimeLabel.text =[NSString stringWithFormat:@"Departes at: %@", prettyVersion];
            
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
    
//    [routeResultsTableView reloadData];
    [self reloadTableViewAnimatedWithInteralSeconds:0.2];
    [searchActivityIndicator stopAnimating];
    
    [routeResultsTableView setContentOffset:CGPointZero animated:YES];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [self.refreshControl endRefreshing];
    
    if (!searchOptionSelectionView.hidden) {
        searchOptionSelectionView.hidden = YES;
    }
    
    [self.reittiDataManager saveRouteHistoryToCoreData:fromString fromCoords:fromCoords andToLocation:toString toCoords:toCoords];
    
    [self setBookmarkButtonStatus];
    
}
- (void)routeSearchDidFail:(NSString *)error{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [self.refreshControl endRefreshing];
    
    [searchActivityIndicator stopAnimating];
    
    if (error != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error                                                                                      message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    [self hideToolBar:YES animated:NO];
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
    
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [self isSameDateAsToday:selectedTime] ? [dateFormat3 setDateFormat:@"HH:mm"] : [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
    NSString *prettyVersion = [dateFormat3 stringFromDate:selectedTime];
    
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

#pragma mark - TableViewMethods
- (void)initRefreshControl{
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = routeResultsTableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(tableViewRefreshing) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Routes"];
    tableViewController.refreshControl = self.refreshControl;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"%@",self.routeList);
    return self.routeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row < self.routeList.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"routeCell"];
        
        Route *route = [self.routeList objectAtIndex:indexPath.row];
        
        UILabel *timeIntervalLabel = (UILabel *)[cell viewWithTag:2000];
        
        if ([route.getStartingTimeOfRoute timeIntervalSinceNow] < 300) {
            timeIntervalLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@ - %@",
                                                                                                  [ReittiStringFormatter formatHourStringFromDate:route.getStartingTimeOfRoute],
                                                                                                  [ReittiStringFormatter formatHourStringFromDate:route.getEndingTimeOfRoute]]
                                                                                       substring:[ReittiStringFormatter formatHourStringFromDate:route.getStartingTimeOfRoute]
                                                                                  withNormalFont:timeIntervalLabel.font];
            ;
        }else{
            timeIntervalLabel.text = [NSString stringWithFormat:@"%@ - %@",
             [ReittiStringFormatter formatHourStringFromDate:route.getStartingTimeOfRoute],
             [ReittiStringFormatter formatHourStringFromDate:route.getEndingTimeOfRoute]];
        }
        
        //durations
        UILabel *durationLabel = (UILabel *)[cell viewWithTag:2001];
        durationLabel.text = [NSString stringWithFormat:@"%@", [ReittiStringFormatter formatDurationString:[route.routeDurationInSeconds integerValue]]];
        
        UILabel *moreInfoLebel = (UILabel *)[cell viewWithTag:2002];
        //TODO: Identigy if it only walking route with no stops
        if(route.getTimeAtTheFirstStop != nil){
            moreInfoLebel.text = [NSString stringWithFormat:@"%@ at first stop | %dm walking ",
                                  [ReittiStringFormatter formatHourStringFromDate:route.getTimeAtTheFirstStop],
                                  (int)route.getTotalWalkLength];
        }else{
            moreInfoLebel.text = [NSString stringWithFormat:@"%dm walking ",
                                  (int)route.getTotalWalkLength];
        }
        
        
        UIScrollView *transportsScrollView = (UIScrollView *)[cell viewWithTag:2003];
        
        [cell layoutSubviews];
        
        for (UIView * view in transportsScrollView.subviews) {
            if (view.tag == 1987) {
                [view removeFromSuperview];
            }
        }
        
        UIView *transportsContainer = [[UIView alloc] initWithFrame:CGRectMake(12, 0, self.view.frame.size.width - 40, 36)];
        transportsContainer.clipsToBounds = YES;
        transportsContainer.tag = 1987;
        transportsContainer.layer.cornerRadius = 4;
        
        float tWidth = 70;
        
        //get longest route duration
        double longestDuration = 0;
        if (routeListCopy != nil && routeListCopy.count > routeList.count) {
            for (Route *route in routeListCopy) {
                if ([route.routeDurationInSeconds doubleValue] > longestDuration) {
                    longestDuration = [route.routeDurationInSeconds doubleValue];
                }
            }
        }else{
            for (Route *route in self.routeList) {
                if ([route.routeDurationInSeconds doubleValue] > longestDuration) {
                    longestDuration = [route.routeDurationInSeconds doubleValue];
                }
            }
        }
        
        
        float x = 0;
        //TODO: Check when there is only walking
        for (RouteLeg *leg in route.routeLegs) {
            tWidth = (self.view.frame.size.width - 40) * ([leg.legDurationInSeconds floatValue]/longestDuration);
            Transport *transportView = [[Transport alloc] initWithRouteLeg:leg andWidth:tWidth*1];
            CGRect frame = transportView.frame;
            transportView.frame = CGRectMake(x, 0, frame.size.width, frame.size.height);
            transportView.clipsToBounds = YES;
            [transportsContainer addSubview:transportView];
            x += frame.size.width;
            
            //Append waiting view if exists
            if (leg.waitingTimeInSeconds > 0) {
                float waitingWidth = (self.view.frame.size.width - 40) * (leg.waitingTimeInSeconds/longestDuration);
                UIView *waitingView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, waitingWidth, transportView.frame.size.height)];
                waitingView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
                waitingView.clipsToBounds = YES;
                if (waitingWidth > 22) {
                    UIImageView *waitingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sitting-filled-grey-64.png"]];
                    waitingImageView.frame = CGRectMake((waitingView.frame.size.width - 20)/2, (transportsContainer.frame.size.height - 20)/2, 20, 20);
                    [waitingView addSubview:waitingImageView];
                }
                [transportsContainer addSubview:waitingView];
                x += waitingWidth;
            }
        }
        
        transportsContainer.frame = CGRectMake(transportsContainer.frame.origin.x, transportsContainer.frame.origin.y, x, transportsContainer.frame.size.height);
        [transportsScrollView addSubview:transportsContainer];
        transportsScrollView.contentSize = CGSizeMake(transportsContainer.frame.size.width + 24, transportsScrollView.frame.size.height);
        
        transportsScrollView.userInteractionEnabled = NO;
        [cell.contentView addGestureRecognizer:transportsScrollView.panGestureRecognizer];
     }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
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
    /*
    if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[GeoCode class]]){
        activeSearchBar.text = [[self.dataToLoad objectAtIndex:indexPath.row] name];
        if (activeSearchBar.tag == 1001) {
            fromString = [[self.dataToLoad objectAtIndex:indexPath.row] name];
            fromCoords = [[self.dataToLoad objectAtIndex:indexPath.row] coords];
        }else{
            toString = [[self.dataToLoad objectAtIndex:indexPath.row] name];
            toCoords = [[self.dataToLoad objectAtIndex:indexPath.row] coords];
        }
    }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]){
        StopEntity *selectedStopEntity = (StopEntity *)[self.dataToLoad objectAtIndex:indexPath.row];
        activeSearchBar.text = selectedStopEntity.busStopName;
        if (activeSearchBar.tag == 1001) {
            fromString = selectedStopEntity.busStopName;
            fromCoords = selectedStopEntity.busStopCoords;
        }else{
            toString = selectedStopEntity.busStopName;
            toCoords = selectedStopEntity.busStopCoords;
        }
    }
    
    if (activeSearchBar.tag == 1001) {
        [fromSearchBar resignFirstResponder];
        [toSearchBar becomeFirstResponder];
    }else{
        if ([fromSearchBar.text isEqualToString:@""] || fromSearchBar.text != nil) {
            //search right away
            [self.reittiDataManager searchRouteForFromCoords:fromCoords andToCoords:toCoords];
            [searchActivityIndicator startAnimating];
        }
        [toSearchBar resignFirstResponder];
    }
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.routeList.count) {
        return 60;
    }else{
        return 120;
    }
}

#pragma mark - scroll view delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (routeList.count < 1)
        return;
    
    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height - 100) {
        [self hideToolBar:NO animated:YES];
    }
    if (scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height - 150) {
        [self hideToolBar:YES animated:YES];
    }
}

#pragma mark - address search view controller
- (void)searchResultSelectedAStop:(StopEntity *)stopEntity{
    [self setTextToSearchBar:activeSearchBar text:[NSString stringWithFormat:@"%@ %@", stopEntity.busStopName, stopEntity.busStopShortCode]];
    
    if (activeSearchBar == fromSearchBar) {
        fromString = [NSString stringWithFormat:@"%@ %@", stopEntity.busStopName, stopEntity.busStopShortCode];
        fromCoords = stopEntity.busStopCoords;
    }else if (activeSearchBar == toSearchBar) {
        toString = [NSString stringWithFormat:@"%@ %@", stopEntity.busStopName, stopEntity.busStopShortCode];
        toCoords = stopEntity.busStopCoords;
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
        
        [self hideTimeSelectionView:YES animated:YES];
        if (refreshingRouteTable) {
            refreshingRouteTable = NO;
        }else{
            [searchActivityIndicator startAnimating];
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
        datePicker.date = currentTime;
        
        [self setSelectedTimesForDate:currentTime];
        
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [self isSameDateAsToday:myDate] ? [dateFormat3 setDateFormat:@"HH:mm"] : [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
        NSString *prettyVersion = [dateFormat3 stringFromDate:myDate];
        
        selectedTimeLabel.text =[NSString stringWithFormat:@"Departes at: %@", prettyVersion];
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
    
    datePicker.date = date;
}

-(BOOL)isSameDateAsToday:(NSDate *)date1{
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        addressSearchViewController.routeSearchMode = YES;
        addressSearchViewController.darkMode = self.darkMode;
        
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
            destinationViewController.toLocation = toString;
            destinationViewController.fromLocation = fromString;
            destinationViewController.reittiDataManager = self.reittiDataManager;
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
