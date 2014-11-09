
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
@synthesize delegate;
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
    selectedSearchOption = RouteSearchOptionFastest;
    refreshingRouteTable = NO;
    nextRoutesRequested = NO;
    prevRoutesRequested = NO;
    
    timeSelectionShadeTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetectedOnShade:)];
    timeSelectionShadeTapGestureRecognizer.delegate = self;
    
    [timeSelectionViewShadeView addGestureRecognizer:timeSelectionShadeTapGestureRecognizer];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self initLocationManager];
    reittiDataManager.routeSearchdelegate = self;
    [self selectSystemColors];
    [self setUpMainView];
}

-(void)viewWillAppear:(BOOL)animated{
    //this is to get the blue color
//    if ([fromSearchBar.text isEqualToString:currentLocationText]) {
//        [self setTextToSearchBar:fromSearchBar text:currentLocationText currentLocation:YES];
//    }
//    if ([toSearchBar.text isEqualToString:currentLocationText]) {
//        [self setTextToSearchBar:toSearchBar text:currentLocationText currentLocation:YES];
//    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (darkMode) {
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
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
    //self.view.backgroundColor = [UIColor whiteColor];
//    [searchBarsView setBlurTintColor:systemBackgroundColor];
    //searchBarsView.layer.borderWidth = 0.5;
    //searchBarsView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    fromFieldBackView.layer.borderWidth = 0.5;
    fromFieldBackView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    fromFieldBackView.layer.cornerRadius = 5;
    
    toFieldBackView.layer.borderWidth = 0.5;
    toFieldBackView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
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
    [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
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
                    searchBarTextField.textColor = systemSubTextColor;
                    
                    break;
                }
            }
        }
    }
    
    searchBar.text = text;
    
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
    [bookmarkRouteButton setImage:[UIImage imageNamed:@"star-orange-128.png"] forState:UIControlStateNormal];
    routeBookmarked = YES;
}

- (void)setRouteNotBookmarkedState{
    [bookmarkRouteButton setImage:[UIImage imageNamed:@"star-128.png"] forState:UIControlStateNormal];
    routeBookmarked = NO;
}

#pragma mark - IBActions
- (IBAction)cancelButtonPressed:(id)sender {
//    [toSearchBar resignFirstResponder];
//    [fromSearchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil ];
}

- (IBAction)timeSElectionButtonClicked:(id)sender {
    [self hideTimeSelectionView:![self isTimeSelectionViewVisible] animated:YES];
}

-(IBAction)tapGestureDetectedOnShade:(UIGestureRecognizer *)sender{
   [self hideTimeSelectionView:YES animated:YES];
}

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
        selectedTimeType = SelectedTimeDeparture;
        nextRoutesRequested = YES;
        
        lastTime = lastRoute.getEndingTimeOfRoute;
        
    }else{
        lastRoute = [self.routeList lastObject];
        
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
    [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
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
        
        lastTime = lastRoute.getEndingTimeOfRoute;
    }else{
        lastRoute = [self.routeList objectAtIndex:0];
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
    [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
    NSString *prettyVersion = [dateFormat3 stringFromDate:lastTime];
    
    if (selectedTimeType == SelectedTimeArrival) {
        selectedTimeLabel.text =[NSString stringWithFormat:@"Arrives at: %@", prettyVersion];
    }else{
        selectedTimeLabel.text =[NSString stringWithFormat:@"Departes at: %@", prettyVersion];
    }
    
    [self searchRouteIfPossible];
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
            [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
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
            [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
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
    
    [routeResultsTableView reloadData];
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
    NSLog(@"%@",self.routeList);
    if (self.routeList.count > 0) {
        return self.routeList.count + 1;
    }else{
        return self.routeList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row < self.routeList.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"routeCell"];
        
        Route *route = [self.routeList objectAtIndex:indexPath.row];
        
        UILabel *startTimeLabel = (UILabel *)[cell viewWithTag:2000];
        startTimeLabel.text = [ReittiStringFormatter formatHourStringFromDate:route.getStartingTimeOfRoute];
        
        UILabel *endTimeLabel = (UILabel *)[cell viewWithTag:2001];
        [endTimeLabel setText:[ReittiStringFormatter formatHourStringFromDate:route.getEndingTimeOfRoute]];
        
        //durations
        UILabel *durationLabel = (UILabel *)[cell viewWithTag:2002];
        durationLabel.text = [NSString stringWithFormat:@"%d min", (int)([route.routeDurationInSeconds intValue]/60)];
        
        UILabel *walkLengthLabel = (UILabel *)[cell viewWithTag:2003];
        walkLengthLabel.text = [NSString stringWithFormat:@"%dm", (int)route.getTotalWalkLength];
        
        UIView *transportsContainer = (UIView *)[cell viewWithTag:2004];
        
        UIImageView *walkingView = (UIImageView *)[cell viewWithTag:2005];
        
        for (UIView * view in transportsContainer.subviews) {
            [view removeFromSuperview];
        }
        
        if (route.isOnlyWalkingRoute) {
            transportsContainer.hidden = YES;
            walkingView.hidden = NO;
        }else{
            transportsContainer.hidden = NO;
            walkingView.hidden = YES;
        }
        
        int totalLegsToShow = route.getNumberOfNoneWalkLegs;
        float tWidth = 45;
        float space = 11;
        float total;
        do{
            space--;
            total = (totalLegsToShow * tWidth) + ((totalLegsToShow -1) * space);
        }while (total < transportsContainer.frame.size.width && space > 0);
        
        float x = (transportsContainer.frame.size.width - total)/2;
        //TODO: Check when there is only walking
        for (RouteLeg *leg in route.routeLegs) {
            if (leg.legType != LegTypeWalk) {
                Transport *transportView = [[Transport alloc] initWithRouteLeg:leg];
                CGRect frame = transportView.frame;
                transportView.frame = CGRectMake(x, 0, frame.size.width, frame.size.height);
                [transportsContainer addSubview:transportView];
                x += frame.size.width + space;
            }
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"nextAndPrevCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
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
        return 95;
    }
}

#pragma mark - scroll view delegates
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if(scrollView == searchSuggestionsTableView)
//        [fromSearchBar resignFirstResponder];
//        [toSearchBar resignFirstResponder];
//}

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
    [self setTextToSearchBar:activeSearchBar text:[[NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    if (activeSearchBar == fromSearchBar) {
        fromString = [[NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        fromCoords = geoCode.coords;
    }else if (activeSearchBar == toSearchBar) {
        toString = [[NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Reloading Routes..."];
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
        [dateFormat3 setDateFormat:@"d.MM.yy HH:mm"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//            stopViewController.darkMode = self.darkMode;
//            stopViewController.reittiDataManager = self.reittiDataManager;
//            stopViewController.backButtonText = self.title;
//            stopViewController.delegate = self;
        }
    }
    
}


@end
