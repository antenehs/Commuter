//
//  AddressSearchViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "AddressSearchViewController.h"
#import "RouteSearchViewController.h"

@interface AddressSearchViewController ()

@end

@implementation AddressSearchViewController

@synthesize savedStops, recentStops, savedRoutes, recentRoutes, dataToLoad, prevSearchTerm;
@synthesize reittiDataManager;
@synthesize delegate;
@synthesize routeSearchMode, darkMode;

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    unRespondedRequestsCount = 0;
    isFinalSearch = NO;
    topBoundary = 70.0;
    
    reittiDataManager.geocodeSearchdelegate = self;
    
    [self selectSystemColors];
    [self setUpMainView];
    //[self setUpInitialSearchView:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    reittiDataManager.geocodeSearchdelegate = self;
    
    [addressSearchBar becomeFirstResponder];
    if (![self.prevSearchTerm isEqualToString:@""] && self.prevSearchTerm != nil) {
        addressSearchBar.text = self.prevSearchTerm;
        [reittiDataManager searchAddressesForKey:addressSearchBar.text];
        unRespondedRequestsCount++;
    }
    
    if (!routeSearchMode) {
        savedRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRoutesFromCoreData]];
        [searchResultTableView reloadData];
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
    [backView setBlurTintColor:systemBackgroundColor];
    if (self.darkMode) {
        addressSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    }else{
        addressSearchBar.keyboardAppearance = UIKeyboardAppearanceDefault;
    }
    
    
    CGRect searchBarFrame = addressSearchBar.frame;
    if (routeSearchMode) {
        //width 257 & x = 0
        addressSearchBar.frame = CGRectMake(0, searchBarFrame.origin.y, 257, searchBarFrame.size.height);
        routeSearchButton.hidden = YES;
    }else{
        //width = 219 & x = 38
        addressSearchBar.frame = CGRectMake(38, searchBarFrame.origin.y, 219, searchBarFrame.size.height);
        routeSearchButton.hidden = NO;
    }
    
    //Set search bar text color
    for (UIView *subView in addressSearchBar.subviews)
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
    
    searchResultTableView.backgroundColor = [UIColor clearColor];
    currentLocationContainerView.hidden = !routeSearchMode;
}

//When there is no search term and displays bookmarks
-(void)setUpInitialSearchView:(bool)animated{
    [self hideSegmentControl:NO animated:animated];
    
    if (listSegmentControl.selectedSegmentIndex == 0){
        dataToLoad = [[NSMutableArray alloc] initWithArray:savedStops];
        [dataToLoad addObjectsFromArray:savedRoutes];
        if (dataToLoad.count == 0) {
            searchResultTableViewContainer.hidden = YES;
        }else{
            searchResultTableViewContainer.hidden = NO;
        }
    }else{
        dataToLoad = [[NSMutableArray alloc] initWithArray:recentStops];
        [dataToLoad addObjectsFromArray:recentRoutes];
        searchResultTableViewContainer.hidden = NO;
    }
    
    [searchResultTableView reloadData];
}

-(void)setUpMergedInitialSearchView:(bool)animated{
    [self hideSegmentControl:YES animated:animated];
    dataToLoad = nil;
    dataToLoad = [[NSMutableArray alloc] initWithArray:savedStops];
    [dataToLoad addObjectsFromArray:savedRoutes];
    [dataToLoad addObjectsFromArray:recentRoutes];
    [dataToLoad addObjectsFromArray:recentStops];
    searchResultTableViewContainer.hidden = NO;
    [searchResultTableView reloadData];
}

#pragma mark - view methods
-(void)moveTableViewUp:(BOOL)up{
    
    CGRect tableContainerFrame = searchResultTableViewContainer.frame;
    CGRect tableFrame = searchResultTableView.frame;
    
    if (up) {
        [searchResultTableViewContainer setFrame:CGRectMake(tableContainerFrame.origin.x, topBoundary, tableContainerFrame.size.width, self.view.bounds.size.height - topBoundary - 5)];
    }else{
        [searchResultTableViewContainer setFrame:CGRectMake(tableContainerFrame.origin.x, 100, tableContainerFrame.size.width, self.view.bounds.size.height - 100 - 5)];
    }
    
    tableFrame.size.height = searchResultTableViewContainer.frame.size.height;
    searchResultTableView.frame = tableFrame;
    tableViewBackGroundBlurView.frame = tableFrame;
}

-(void)moveTableViewDown:(BOOL)down{
    
    CGRect tableContainerFrame = searchResultTableViewContainer.frame;
    CGRect tableFrame = searchResultTableView.frame;
    
    if (down) {
        [searchResultTableViewContainer setFrame:CGRectMake(tableContainerFrame.origin.x, topBoundary + 50, tableContainerFrame.size.width, self.view.bounds.size.height - topBoundary + 55 - 5)];
    }else{
        [searchResultTableViewContainer setFrame:CGRectMake(tableContainerFrame.origin.x, 100, tableContainerFrame.size.width, self.view.bounds.size.height - 100 - 5)];
    }
    
    tableFrame.size.height = searchResultTableViewContainer.frame.size.height;
    searchResultTableView.frame = tableFrame;
    tableViewBackGroundBlurView.frame = tableFrame;
}

- (void)hideSegmentControl:(bool)hidden animated:(bool)anim{
    
    if (anim) {
        if (hidden){
            listSegmentControl.hidden = hidden;
//            currentLocationContainerView.hidden = !hidden;
        }
        [UIView transitionWithView:backView duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            if (routeSearchMode) {
                [self moveTableViewDown:hidden];
                currentLocationContainerView.hidden = !hidden;
            }else{
                [self moveTableViewUp:hidden];
            }
            
        } completion:^(BOOL finished) {
            if (!hidden){
                listSegmentControl.hidden = hidden;
//                currentLocationContainerView.hidden = !hidden;
            }
        }];
    }else{
        if (routeSearchMode) {
            [self moveTableViewDown:hidden];
            currentLocationContainerView.hidden = !hidden;
        }else{
            [self moveTableViewUp:hidden];
        }
        
        listSegmentControl.hidden = hidden;
        
    }
    
}

#pragma mark - IBActions
- (IBAction)cancelButtonPressed:(id)sender {
    [addressSearchBar resignFirstResponder];
    [delegate searchViewControllerWillBeDismissed:@""];
    [self dismissViewControllerAnimated:YES completion:nil ];
}

- (IBAction)listSegmentControlValueChanged:(id)sender {
    [self setUpInitialSearchView:NO];
}

- (IBAction)currentLocationButtonPressed:(id)sender {
    [addressSearchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismiss completed");
        [delegate searchResultSelectedCurrentLocation];
    }];
}

#pragma mark - search bar methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //hide segment control
    if (searchBar.text.length == 0) {
        [self setUpMergedInitialSearchView:YES];
    }else{
        [self hideSegmentControl:YES animated:YES];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)thisSearchBar {
    //Show segment control if there is no text in seach field
    if (thisSearchBar.text == nil || [thisSearchBar.text isEqualToString:@""]){
        if (savedStops.count == 0 && recentStops.count == 0) {
            listSegmentControl.selectedSegmentIndex = 0;
        }else if(savedStops.count == 0){
            listSegmentControl.selectedSegmentIndex = 1;
        }else if (recentStops.count == 0){
            listSegmentControl.selectedSegmentIndex = 0;
        }
        [self setUpInitialSearchView:YES];
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    isFinalSearch = NO;
    if (searchText.length > 2){
        [reittiDataManager searchAddressesForKey:searchText];
        unRespondedRequestsCount++;
    }else if(searchText.length > 0) {
        dataToLoad = [ self searchFromBookmarkAndHistoryForKey:searchText];
        [searchResultTableView reloadData];
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
        searchActivityIndicator.hidden = NO;
        [searchActivityIndicator startAnimating];
    }
    else {
        dataToLoad = [ self searchFromBookmarkAndHistoryForKey:searchBar.text];
        [searchResultTableView reloadData];
        
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

#pragma mark - reitti data manager delegates
- (void)geocodeSearchDidComplete:(NSArray *)geocodeList forRequest:(NSString *)requestedKey{
    unRespondedRequestsCount--;
    dataToLoad = [self searchFromBookmarkAndHistoryForKey:addressSearchBar.text];
    [dataToLoad addObjectsFromArray:geocodeList];
    [searchResultTableView reloadData];
    if (isFinalSearch && unRespondedRequestsCount == 0) {
        searchActivityIndicator.hidden = YES;
        [searchActivityIndicator stopAnimating];
    }
}
- (void)geocodeSearchDidFail:(NSString *)error forRequest:(NSString *)requestedKey{
    unRespondedRequestsCount--;
    dataToLoad = [self searchFromBookmarkAndHistoryForKey:addressSearchBar.text];
    [searchResultTableView reloadData];
    if (isFinalSearch && unRespondedRequestsCount == 0) {
        searchActivityIndicator.hidden = YES;
        [searchActivityIndicator stopAnimating];
        //Message that there is no result
        UIAlertView *alertView;
        if (error != nil) {
            alertView = [[UIAlertView alloc] initWithTitle:error                                                                                      message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }else{
             alertView = [[UIAlertView alloc] initWithTitle:@"Looks like there is a free street name."                                                                                      message:@"The search returned nothing for that search term."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    }
}

#pragma mark - route Search view controller delegate
//- (void)routeSearchViewControllerWillBeDismissed:(NSString *)prevSearchTerm{
//    
//}

#pragma mark - TableViewMethods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%@",self.dataToLoad);
    return self.dataToLoad.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
        if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"recentViewedCell"];
        }
        
        StopEntity *stopEntity = [StopEntity alloc];
        if (indexPath.row < self.dataToLoad.count) {
            stopEntity = [self.dataToLoad objectAtIndex:indexPath.row];
        }
        
        UILabel *title = (UILabel *)[cell viewWithTag:2002];
        UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        title.text = stopEntity.busStopName;
        subTitle.text = [NSString stringWithFormat:@"%@ - %@", stopEntity.busStopShortCode, stopEntity.busStopCity];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]) {
        if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteEntity class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedRouteCell"];
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"recentViewedRouteCell"];
        }
                
        RouteEntity *routeEntity = [RouteEntity alloc];
        if (indexPath.row < self.dataToLoad.count) {
            routeEntity = [self.dataToLoad objectAtIndex:indexPath.row];
        }
        
        UILabel *title = (UILabel *)[cell viewWithTag:2002];
        UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        title.text = routeEntity.toLocationName;
        subTitle.text = [NSString stringWithFormat:@"%@", routeEntity.fromLocationName];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[GeoCode class]]){
        GeoCode *geoCode = [self.dataToLoad objectAtIndex:indexPath.row];

        if (geoCode.getLocationType == LocationTypePOI) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"poiLocationCell"];
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.text = geoCode.name;
            subTitle.text = [NSString stringWithFormat:@"%@", geoCode.city];
        }else if (geoCode.getLocationType  == LocationTypeAddress) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressLocationCell"];
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.text = [NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber];
            subTitle.text = [NSString stringWithFormat:@"%@", geoCode.city];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"stopLocationCell"];
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.text = [NSString stringWithFormat:@"%@ (%@)", geoCode.name, geoCode.getStopShortCode];
            subTitle.text = [NSString stringWithFormat:@"%@, %@", geoCode.getAddress ,geoCode.city];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else{
        return nil;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate searchViewControllerWillBeDismissed:addressSearchBar.text];
    if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[GeoCode class]]){
        [addressSearchBar resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Dismiss completed");
            [delegate searchResultSelectedAGeoCode:[self.dataToLoad objectAtIndex:indexPath.row]];
        }];
    }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]){
        StopEntity *selectedStopEntity = (StopEntity *)[self.dataToLoad objectAtIndex:indexPath.row];
        [addressSearchBar resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Dismiss completed");
            [delegate searchResultSelectedAStop:selectedStopEntity];
        }];
    }
}

#pragma mark - scroll view delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == searchResultTableView)
        [addressSearchBar resignFirstResponder];
}

#pragma mark - route search view delegate
- (void)routeModified{
    //Fetch saved route list again
    savedRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRoutesFromCoreData]];
}

#pragma mark - helper methods

- (NSMutableArray *)searchFromBookmarkAndHistoryForKey:(NSString *)key{
    NSMutableArray * searched = [[NSMutableArray alloc] init];
    for (StopEntity *stopEntity in savedStops) {
        if ([stopEntity.busStopName containsString:key]) {
            [searched addObject:stopEntity];
        }else if ([stopEntity.busStopShortCode containsString:key]) {
            [searched addObject:stopEntity];
        }else if ([stopEntity.busStopCity containsString:key]) {
            [searched addObject:stopEntity];
        }
    }
    
    for (RouteEntity *routeEntity in savedRoutes) {
        if ([routeEntity.fromLocationName containsString:key]) {
            [searched addObject:routeEntity];
        }else if ([routeEntity.toLocationName containsString:key]) {
            [searched addObject:routeEntity];
        }
    }
    
    for (RouteHistoryEntity *routeHistoryEntity in recentRoutes) {
        if ([routeHistoryEntity.fromLocationName containsString:key]) {
            [searched addObject:routeHistoryEntity];
        }else if ([routeHistoryEntity.toLocationName containsString:key]) {
            [searched addObject:routeHistoryEntity];
        }
    }
    
    for (HistoryEntity *historyEntity in recentStops) {
        if ([historyEntity.busStopName containsString:key]) {
            [searched addObject:historyEntity];
        }else if ([historyEntity.busStopShortCode containsString:key]) {
            [searched addObject:historyEntity];
        }else if ([historyEntity.busStopCity containsString:key]) {
            [searched addObject:historyEntity];
        }
    }
    
    return searched;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"routeSearchController"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
        
        routeSearchViewController.savedStops = self.savedStops;
        routeSearchViewController.recentStops = self.recentStops;
        routeSearchViewController.prevToLocation = addressSearchBar.text;
        routeSearchViewController.darkMode = self.darkMode;
        //routeSearchViewController.delegate = self;
        routeSearchViewController.reittiDataManager = self.reittiDataManager;
    }
    
    if ([segue.identifier isEqualToString:@"savedRouteSelected"] || [segue.identifier isEqualToString:@"historyRouteSelected"]) {
        
        NSIndexPath *selectedRowIndexPath = [searchResultTableView indexPathForSelectedRow];
        RouteEntity * selected = [self.dataToLoad objectAtIndex:selectedRowIndexPath.row];
        
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
        
        routeSearchViewController.savedStops = self.savedStops;
        routeSearchViewController.recentStops = self.recentStops;
        routeSearchViewController.prevToLocation = selected.toLocationName;
        routeSearchViewController.prevToCoords = selected.toLocationCoordsString;
        routeSearchViewController.prevFromLocation = selected.fromLocationName;
        routeSearchViewController.prevFromCoords = selected.fromLocationCoordsString;
        
        routeSearchViewController.darkMode = self.darkMode;
//        routeSearchViewController.delegate = self;
        routeSearchViewController.reittiDataManager = self.reittiDataManager;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
