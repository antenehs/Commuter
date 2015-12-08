//
//  AddressSearchViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "AddressSearchViewController.h"
#import "RouteSearchViewController.h"
#import "CacheManager.h"
#import "AppManager.h"
#import "ASA_Helpers.h"

@interface AddressSearchViewController ()

@end

@implementation AddressSearchViewController

@synthesize savedStops, recentStops, namedBookmarks, savedRoutes, recentRoutes, dataToLoad,additionalGeoCodeResults, prevSearchTerm, droppedPinGeoCode;
@synthesize reittiDataManager;
@synthesize delegate;
@synthesize routeSearchMode,simpleSearchMode, darkMode;

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    unRespondedRequestsCount = 0;
    isFinalSearch = NO;
    streetAddressInputMode = NO;
    addressWithoutStreetNum = @"";
    keyboardType = AddressSearchViewControllerKeyBoardTypeText;
    topBoundary = 70.0;
    
    reittiDataManager.geocodeSearchdelegate = self;
    [reittiDataManager resetResponseQueues];
    
    [self selectSystemColors];
    [self setUpMainView];
    //[self setUpInitialSearchView:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
//    [backView setBlurTintColor:systemBackgroundColor];
    addressSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
      
    CGRect searchBarFrame = addressSearchBar.frame;
    if (routeSearchMode) {
        //width 257 & x = 0
        addressSearchBar.frame = CGRectMake(0, searchBarFrame.origin.y, 257, searchBarFrame.size.height);
        [leftNavBarButton setImage:[UIImage imageNamed:@"current-location-100.png"] forState:UIControlStateNormal];
    }else{
        //width = 219 & x = 38
        addressSearchBar.frame = CGRectMake(38, searchBarFrame.origin.y, 219, searchBarFrame.size.height);
        [leftNavBarButton setImage:[UIImage imageNamed:@"up-right-arrow-32.png"] forState:UIControlStateNormal];
    }
    
    [addressSearchBar setImage:[UIImage imageNamed:@"search-icon-25.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    //Set search bar text color
    [addressSearchBar asa_setTextColorAndPlaceholderText:[UIColor whiteColor] placeHolderColor:[UIColor lightTextColor]];
    
    [self setKeyboardType:keyboardType withFeedback:NO];
    
    searchResultTableView.backgroundColor = [UIColor clearColor];
}

//When there is no search term and displays bookmarks
-(void)setUpInitialSearchView:(bool)animated{
    [self hideSegmentControl:NO animated:animated];
    
    if (listSegmentControl.selectedSegmentIndex == 0){
        dataToLoad = [[NSMutableArray alloc] initWithArray:namedBookmarks];
        [dataToLoad addObjectsFromArray:savedStops];
        [dataToLoad addObjectsFromArray:savedRoutes];
        dataToLoad = [self sortDataArray:dataToLoad];
        if (dataToLoad.count == 0) {
            searchResultTableViewContainer.hidden = YES;
        }else{
            searchResultTableViewContainer.hidden = NO;
        }
    }else{
        dataToLoad = [[NSMutableArray alloc] initWithArray:recentRoutes];
        [dataToLoad addObjectsFromArray:recentStops];
        dataToLoad = [self sortDataArray:dataToLoad];
        searchResultTableViewContainer.hidden = NO;
    }
    
    [searchResultTableView reloadData];
}

-(void)setUpMergedInitialSearchView:(bool)animated{
    [self hideSegmentControl:YES animated:animated];
    dataToLoad = nil;
    if(self.droppedPinGeoCode != nil && routeSearchMode){
        dataToLoad = [[NSMutableArray alloc] initWithObjects:self.droppedPinGeoCode, nil];
        [dataToLoad addObjectsFromArray:namedBookmarks];
    }else{
        dataToLoad = [[NSMutableArray alloc] initWithArray:namedBookmarks];
    }
    
    [dataToLoad addObjectsFromArray:savedStops];
    [dataToLoad addObjectsFromArray:savedRoutes];
    dataToLoad = [self sortDataArray:dataToLoad];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:recentRoutes];
    [tempArray addObjectsFromArray:recentStops];
    [dataToLoad addObjectsFromArray:[self sortDataArray:tempArray]];
    dataToLoad = [self arrayByRemovingDuplicatesInHistory:dataToLoad];
    searchResultTableViewContainer.hidden = NO;
    [searchResultTableView reloadData];
    
    isInitialMergedView = YES;
}

#pragma mark - view methods
-(void)moveTableViewUp:(BOOL)up{
    
    CGRect tableContainerFrame = searchResultTableViewContainer.frame;
    CGRect tableFrame = searchResultTableView.frame;
    
    if (up) {
        [searchResultTableViewContainer setFrame:CGRectMake(tableContainerFrame.origin.x, topBoundary, tableContainerFrame.size.width, self.view.bounds.size.height - topBoundary - 5)];
    }else{
        [searchResultTableViewContainer setFrame:CGRectMake(tableContainerFrame.origin.x, topBoundary + listSegmentControl.frame.size.height + 10, tableContainerFrame.size.width, self.view.bounds.size.height - 100 - 5)];
    }
    
    tableFrame.size.height = searchResultTableViewContainer.frame.size.height;
    searchResultTableView.frame = tableFrame;
    tableViewBackGroundBlurView.frame = tableFrame;
    
    [self.view layoutSubviews];
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
            
            /*
             if (routeSearchMode) {
                [self moveTableViewDown:hidden];
                currentLocationContainerView.hidden = !hidden;
            }else{
                [self moveTableViewUp:hidden];
            }
            */
            [self moveTableViewUp:hidden];
        } completion:^(BOOL finished) {
            if (!hidden){
                listSegmentControl.hidden = hidden;
//                currentLocationContainerView.hidden = !hidden;
            }
        }];
    }else{
        /*
        if (routeSearchMode) {
            [self moveTableViewDown:hidden];
            currentLocationContainerView.hidden = !hidden;
        }else{
            [self moveTableViewUp:hidden];
        }
        */
        [self moveTableViewUp:hidden];
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

- (IBAction)leftNavBarButtonPressed:(id)sender{
    if (!routeSearchMode) {
//        [self performSegueWithIdentifier:@"routeSearchController" sender:nil];
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate searchViewControllerDismissedToRouteSearch:addressSearchBar.text];
        }];
    }else{
        [self currentLocationButtonPressed:sender];
    }
}

- (IBAction)selectAddressForStreetNumberPressed:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:searchResultTableView];
    NSIndexPath *indexPath = [searchResultTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[GeoCode class]]){
            GeoCode *selectedGeocode = [self.dataToLoad objectAtIndex:indexPath.row];
            //Set address of the geocode to the search bar and change keyboard
            addressSearchBar.text = [NSString stringWithFormat:@"%@ ", [selectedGeocode name]];
            [self setKeyboardType:AddressSearchViewControllerKeyBoardTypeNumber withFeedback:YES];
        }
    }
}

- (void)setKeyboardType:(AddressSearchViewControllerKeyBoardType)searchbarKeyboardType withFeedback:(BOOL)feedback{
    keyboardType = searchbarKeyboardType;
    if (searchbarKeyboardType == AddressSearchViewControllerKeyBoardTypeText) {
        addressSearchBar.keyboardType = UIKeyboardTypeDefault;
        streetAddressInputMode = NO;
        addressWithoutStreetNum = @"";
    }else{
        addressSearchBar.keyboardType = UIKeyboardTypeNumberPad;
        streetAddressInputMode = YES;
        addressWithoutStreetNum = [addressSearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    [addressSearchBar resignFirstResponder];
    [addressSearchBar becomeFirstResponder];
    
    if (feedback && !streetAddressInputMode) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
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
        if (savedStops.count == 0 && recentStops.count == 0 && namedBookmarks.count == 0) {
            listSegmentControl.selectedSegmentIndex = 0;
        }else if(savedStops.count == 0 || namedBookmarks.count == 0){
            listSegmentControl.selectedSegmentIndex = 1;
        }else if (recentStops.count == 0){
            listSegmentControl.selectedSegmentIndex = 0;
        }
        if (!simpleSearchMode) {
            [self setUpInitialSearchView:YES];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    isFinalSearch = NO;
    if (searchText.length > 2){
        [reittiDataManager searchAddressesForKey:searchText];
        unRespondedRequestsCount++;
        isInitialMergedView = NO;
    }else if(searchText.length > 0) {
        dataToLoad = [ self searchFromBookmarkAndHistoryForKey:searchText];
        [searchResultTableView reloadData];
        isInitialMergedView = NO;
    }else {
        //Load bookmarks and history
        [self setUpMergedInitialSearchView:YES];
    }
    
    if (streetAddressInputMode) {
        if ([searchText isEqualToString:addressWithoutStreetNum]) {
            [self setKeyboardType:AddressSearchViewControllerKeyBoardTypeText withFeedback:YES];
        }
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
- (void)geocodeSearchDidComplete:(NSArray *)geocodeList  isFinalResult:(BOOL)isFinalResult{
    unRespondedRequestsCount--;
    if (!isInitialMergedView) {
        dataToLoad = [self searchFromBookmarkAndHistoryForKey:addressSearchBar.text];
        [dataToLoad addObjectsFromArray:geocodeList];
        [searchResultTableView reloadData];
    }
    if (isFinalSearch && unRespondedRequestsCount == 0) {
        searchActivityIndicator.hidden = YES;
        [searchActivityIndicator stopAnimating];
    }
}

- (void)geocodeSearchAddedResults:(NSArray *)geocodeList  isFinalResult:(BOOL)isFinalResult{
    self.additionalGeoCodeResults = [NSMutableArray arrayWithArray:geocodeList];
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
- (void)routeSearchViewControllerDismissed {
    [self cancelButtonPressed:self];
}

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
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:2004];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:2005];
        imageView.image = [AppManager stopAnnotationImageForStopType:stopEntity.stopType];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
            dateLabel.hidden = NO;
            dateLabel.text = [ReittiStringFormatter formatPrittyDate:stopEntity.dateModified];
        }else{
            dateLabel.hidden = YES;
        }
        
        title.attributedText = [ReittiStringFormatter highlightSubstringInString:stopEntity.busStopName substring:addressSearchBar.text withNormalFont:title.font];
        subTitle.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@ - %@", stopEntity.busStopShortCode, stopEntity.busStopCity] substring:addressSearchBar.text withNormalFont:subTitle.font];
        
//        StaticStop *sStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", stopEntity.busStopCode]];
//        if (sStop != nil) {
//            
//        }else{
//            imageView.image = [AppManager stopAnnotationImageForStopType:StopTypeBus];
//        }
        
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
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:2004];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]) {
            dateLabel.hidden = NO;
            dateLabel.text = [ReittiStringFormatter formatPrittyDate:routeEntity.dateModified];
        }else{
            dateLabel.hidden = YES;
        }
        
        title.attributedText = [ReittiStringFormatter highlightSubstringInString: routeEntity.toLocationName substring:addressSearchBar.text withNormalFont:title.font];
        subTitle.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@", routeEntity.fromLocationName] substring:addressSearchBar.text withNormalFont:subTitle.font];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[GeoCode class]]){
        GeoCode *geoCode = [self.dataToLoad objectAtIndex:indexPath.row];

        if (geoCode.getLocationType == LocationTypePOI) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"poiLocationCell"];
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:2001];
            [imageView setImage:[UIImage imageNamed:@"location-75.png"]];
            
            title.attributedText = [ReittiStringFormatter highlightSubstringInString:geoCode.name substring:addressSearchBar.text withNormalFont:title.font];
            subTitle.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@", geoCode.city] substring:addressSearchBar.text withNormalFont:subTitle.font];
        }else if (geoCode.getLocationType  == LocationTypeAddress) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressLocationCell"];
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber] substring:addressSearchBar.text withNormalFont:title.font] ;
            subTitle.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@", geoCode.city] substring:addressSearchBar.text withNormalFont:subTitle.font] ;
        }else if (geoCode.getLocationType  == LocationTypeDroppedPin) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"droppedPinCell"];
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.attributedText = [ReittiStringFormatter highlightSubstringInString:@"Dropped pin" substring:addressSearchBar.text withNormalFont:title.font] ;
            subTitle.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber] substring:addressSearchBar.text withNormalFont:subTitle.font] ;
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"stopLocationCell"];
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:2005];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@ (%@)", geoCode.name, geoCode.getStopShortCode] substring:addressSearchBar.text withNormalFont:title.font];
            subTitle.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@, %@", geoCode.getAddress ,geoCode.city] substring:addressSearchBar.text withNormalFont:subTitle.font];
            
           imageView.image = [AppManager stopAnnotationImageForStopType:[geoCode getStopType]];
    
        }
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[NamedBookmark class]]){
        NamedBookmark *nbookmark = [self.dataToLoad objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"poiLocationCell"];
        UILabel *title = (UILabel *)[cell viewWithTag:2002];
        UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:2001];
        [imageView setImage:[UIImage imageNamed:nbookmark.iconPictureName]];
        
        title.attributedText = [ReittiStringFormatter highlightSubstringInString:nbookmark.name substring:addressSearchBar.text withNormalFont:title.font];
        subTitle.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@, %@", nbookmark.streetAddress, nbookmark.city] substring:addressSearchBar.text withNormalFont:subTitle.font];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        return cell;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate searchViewControllerWillBeDismissed:addressSearchBar.text];
    if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[GeoCode class]]){
        GeoCode *selectedGeocode = [self.dataToLoad objectAtIndex:indexPath.row];
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Dismiss completed");
            [delegate searchResultSelectedAGeoCode:selectedGeocode];
//            [addressSearchBar resignFirstResponder];
        }];
    }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[NamedBookmark class]]){
        NamedBookmark *selectedBookmark = [self.dataToLoad objectAtIndex:indexPath.row];
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Dismiss completed");
            [delegate searchResultSelectedANamedBookmark:selectedBookmark];
//            [addressSearchBar resignFirstResponder];
        }];
    }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]){
        StopEntity *selectedStopEntity = (StopEntity *)[self.dataToLoad objectAtIndex:indexPath.row];
//        [addressSearchBar resignFirstResponder];
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
    key = [key lowercaseString];
    
    if (self.droppedPinGeoCode != nil && routeSearchMode) {
        if ([[droppedPinGeoCode.name lowercaseString] containsString:key]) {
            [searched addObject:droppedPinGeoCode];
        }else if ([[droppedPinGeoCode.getStreetAddressString lowercaseString] containsString:key]) {
            [searched addObject:droppedPinGeoCode];
        }else if ([[droppedPinGeoCode.city lowercaseString] containsString:key]) {
            [searched addObject:droppedPinGeoCode];
        }else if ([[@"Dropped pin" lowercaseString] containsString:key]) {
            [searched addObject:droppedPinGeoCode];
        }
    }
    
    for (NamedBookmark *namedBookmark in namedBookmarks) {
        if ([[namedBookmark.name lowercaseString] containsString:key]) {
            [searched addObject:namedBookmark];
        }else if ([[namedBookmark.streetAddress lowercaseString] containsString:key]) {
            [searched addObject:namedBookmark];
        }else if ([[namedBookmark.city lowercaseString] containsString:key]) {
            [searched addObject:namedBookmark];
        }else if ([[namedBookmark.searchedName lowercaseString] containsString:key]) {
            [searched addObject:namedBookmark];
        }else if ([[namedBookmark.notes lowercaseString] containsString:key]) {
            [searched addObject:namedBookmark];
        }
    }
    
    for (RouteEntity *routeEntity in savedRoutes) {
        if ([[routeEntity.fromLocationName lowercaseString] containsString:key]) {
            [searched addObject:routeEntity];
        }else if ([[routeEntity.toLocationName lowercaseString] containsString:key]) {
            [searched addObject:routeEntity];
        }
    }
    
    for (StopEntity *stopEntity in savedStops) {
        if ([[stopEntity.busStopName lowercaseString] containsString:key]) {
            [searched addObject:stopEntity];
        }else if ([[stopEntity.busStopShortCode lowercaseString] containsString:key]) {
            [searched addObject:stopEntity];
        }else if ([[stopEntity.busStopCity lowercaseString] containsString:key]) {
            [searched addObject:stopEntity];
        }
    }
    
    for (RouteHistoryEntity *routeHistoryEntity in recentRoutes) {
        if ([[routeHistoryEntity.fromLocationName lowercaseString] containsString:key ]) {
            [searched addObject:routeHistoryEntity];
        }else if ([[routeHistoryEntity.toLocationName lowercaseString] containsString:key]) {
            [searched addObject:routeHistoryEntity];
        }
    }
    
    for (HistoryEntity *historyEntity in recentStops) {
        if ([[historyEntity.busStopName lowercaseString] containsString:key]) {
            [searched addObject:historyEntity];
        }else if ([[historyEntity.busStopShortCode lowercaseString] containsString:key]) {
            [searched addObject:historyEntity];
        }else if ([[historyEntity.busStopCity lowercaseString] containsString:key]) {
            [searched addObject:historyEntity];
        }
    }
    
    return searched;
}

- (NSMutableArray *)sortDataArray:(NSMutableArray *)array{
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        //We can cast all types to ReittiManagedObjectBase since we are only intereted in the date modified property
        if ([a isKindOfClass:ReittiManagedObjectBase.class] && [b isKindOfClass:ReittiManagedObjectBase.class]) {
            NSDate *first = [(ReittiManagedObjectBase*)a dateModified];
            NSDate *second = [(ReittiManagedObjectBase*)b dateModified];
            
            if (first == nil) {
                return NSOrderedDescending;
            }
            
            //Decending by date - latest to earliest
            return [second compare:first];
        }else if ([a isKindOfClass: GeoCode.class]) {
            return NSOrderedAscending;
        }else if ([b isKindOfClass: GeoCode.class]) {
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"routeSearchController"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
        
        routeSearchViewController.savedStops = self.savedStops;
        routeSearchViewController.recentStops = self.recentStops;
        routeSearchViewController.savedRoutes = self.savedRoutes;
        routeSearchViewController.recentRoutes = self.recentRoutes;
        routeSearchViewController.namedBookmarks = self.namedBookmarks;
        routeSearchViewController.prevToLocation = addressSearchBar.text;
//        routeSearchViewController.droppedPinGeoCode = self.droppedPinGeoCode;
//        routeSearchViewController.darkMode = self.darkMode;
//        routeSearchViewController.viewCycledelegate = self;
        routeSearchViewController.reittiDataManager = self.reittiDataManager;
    }
    
    if ([segue.identifier isEqualToString:@"savedRouteSelected"] || [segue.identifier isEqualToString:@"historyRouteSelected"]) {
        
        NSIndexPath *selectedRowIndexPath = [searchResultTableView indexPathForSelectedRow];
        RouteEntity * selected = [self.dataToLoad objectAtIndex:selectedRowIndexPath.row];
        
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
        
        routeSearchViewController.savedStops = self.savedStops;
        routeSearchViewController.recentStops = self.recentStops;
        routeSearchViewController.savedRoutes = self.savedRoutes;
        routeSearchViewController.recentRoutes = self.recentRoutes;
        routeSearchViewController.namedBookmarks = self.namedBookmarks;
        routeSearchViewController.prevToLocation = selected.toLocationName;
        routeSearchViewController.prevToCoords = selected.toLocationCoordsString;
        routeSearchViewController.prevFromLocation = selected.fromLocationName;
        routeSearchViewController.prevFromCoords = selected.fromLocationCoordsString;
//        routeSearchViewController.droppedPinGeoCode = self.droppedPinGeoCode;
        
//        routeSearchViewController.darkMode = self.darkMode;
//        routeSearchViewController.delegate = self;
        routeSearchViewController.reittiDataManager = self.reittiDataManager;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
