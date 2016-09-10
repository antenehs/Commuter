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
#import "ReittiAnalyticsManager.h"
#import "TableViewCells.h"
#import "ContactsManager.h"
#import "ReittiMapkitHelper.h"

@interface AddressSearchViewController ()

@end

@implementation AddressSearchViewController

@synthesize savedStops, recentStops, namedBookmarks, savedRoutes, recentRoutes, dataToLoad,additionalGeoCodeResults, prevSearchTerm, droppedPinGeoCode;
@synthesize reittiDataManager;
@synthesize delegate;
@synthesize routeSearchMode,simpleSearchMode, darkMode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    unRespondedRequestsCount = 0;
    isFinalSearch = NO;
    streetAddressInputMode = NO;
    addressWithoutStreetNum = @"";
    keyboardType = AddressSearchViewControllerKeyBoardTypeText;
    topBoundary = 70.0;
    
    [reittiDataManager resetResponseQueues];
    
    [self setUpMainView];
    
    [searchResultTableView registerNib:[UINib nibWithNibName:@"StopTableViewCell" bundle:nil] forCellReuseIdentifier:@"savedStopCell"];
    [searchResultTableView registerNib:[UINib nibWithNibName:@"RouteTableViewCell" bundle:nil] forCellReuseIdentifier:@"savedRouteCell"];
    [searchResultTableView registerNib:[UINib nibWithNibName:@"NamedBookmarkTableViewCell" bundle:nil] forCellReuseIdentifier:@"poiLocationCell"];
    [searchResultTableView registerNib:[UINib nibWithNibName:@"AddressTableViewCell" bundle:nil] forCellReuseIdentifier:@"addressLocationCell"];
    
    //TODO: Do this after asking user access with a custom popup.
    [ContactsManager sharedManager]; //Initiate filtering
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [addressSearchBar becomeFirstResponder];
    if (![self.prevSearchTerm isEqualToString:@""] && self.prevSearchTerm != nil) {
        addressSearchBar.text = self.prevSearchTerm;
        [self searchAddressForSearchTerm:addressSearchBar.text];
        unRespondedRequestsCount++;
    }
    
    if (!routeSearchMode) {
        savedRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRoutesFromCoreData]];
        [searchResultTableView reloadData];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
    
}

#pragma mark - initializations
-(void)setUpMainView{
    addressSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
      
    CGRect searchBarFrame = addressSearchBar.frame;
    if (routeSearchMode) {
        //width 257 & x = 0
        addressSearchBar.frame = CGRectMake(0, searchBarFrame.origin.y, 257, searchBarFrame.size.height);
        [leftNavBarButton setImage:[UIImage imageNamed:@"current location filled white.png"] forState:UIControlStateNormal];
        [leftNavBarButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }else{
        addressSearchBar.frame = CGRectMake(38, searchBarFrame.origin.y, 219, searchBarFrame.size.height);
        [leftNavBarButton setImage:[UIImage imageNamed:@"up-right-arrow-32.png"] forState:UIControlStateNormal];
    }
    
    [addressSearchBar setImage:[UIImage imageNamed:@"search-icon-25.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    //Set search bar text color
    [addressSearchBar asa_setTextColorAndPlaceholderText:[UIColor whiteColor] placeHolderColor:[UIColor lightTextColor]];
    
    [self setKeyboardType:keyboardType withFeedback:NO];
    
    searchResultTableView.backgroundColor = [UIColor clearColor];
    [searchResultTableView setBlurredBackgroundWithImageNamed:nil];
}

-(void)setUpMergedInitialSearchView:(bool)animated{
    dataToLoad = nil;
    if(self.droppedPinGeoCode != nil && routeSearchMode){
        dataToLoad = [[NSMutableArray alloc] initWithObjects:self.droppedPinGeoCode, nil];
        [dataToLoad addObjectsFromArray:namedBookmarks];
    }else{
        dataToLoad = [[NSMutableArray alloc] initWithArray:namedBookmarks];
    }
    
    [dataToLoad addObjectsFromArray:savedStops];
    [dataToLoad addObjectsFromArray:savedRoutes];
//    dataToLoad = [self sortDataArray:dataToLoad];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:recentRoutes];
    [tempArray addObjectsFromArray:recentStops];
    [dataToLoad addObjectsFromArray:[self sortDataArray:tempArray]];
    dataToLoad = [self arrayByRemovingDuplicatesInHistory:dataToLoad];
    [searchResultTableView reloadData];
    
    isInitialMergedView = YES;
}

#pragma mark - IBActions
- (IBAction)cancelButtonPressed:(id)sender {
    [addressSearchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil ];
}

- (IBAction)currentLocationButtonPressed:(id)sender {
    [addressSearchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        [delegate searchResultSelectedCurrentLocation];
    }];
}

- (IBAction)leftNavBarButtonPressed:(id)sender{
    if (!routeSearchMode) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate searchViewControllerDismissedToRouteSearch:addressSearchBar.text];
        }];
    }else{
        [self currentLocationButtonPressed:sender];
    }
}

- (IBAction)selectAddressForStreetNumberPressed:(AddressTableViewCell *)sender {
    if (sender.geoCode)
    {
        if([sender.geoCode isKindOfClass:[GeoCode class]]){
            GeoCode *selectedGeocode = sender.geoCode;
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
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    isFinalSearch = NO;
    if (searchText.length > 2){
        [self searchAddressForSearchTerm:searchText];
        unRespondedRequestsCount++;
        isInitialMergedView = NO;
    }else if(searchText.length > 0) {
        dataToLoad = [ self searchFromBookmarkHistoryContactForKey:searchText];
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
        [self searchAddressForSearchTerm:searchBar.text];
        unRespondedRequestsCount++;
        searchActivityIndicator.hidden = NO;
        [searchActivityIndicator startAnimating];
    }
    else {
        dataToLoad = [ self searchFromBookmarkHistoryContactForKey:searchBar.text];
        [searchResultTableView reloadData];
        
        //Message that search term is short
        if (isFinalSearch) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"At least 3 letters, that's the rule.", @"To tell atleast 3 letters is required to search") message:NSLocalizedString(@"The search term is too short. Minimum length is 3.", @"The search term is too short. Minimum length is 3.")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

#pragma mark - reitti data manager delegates
- (void)searchAddressForSearchTerm:(NSString *)searchTerm{
    [self.reittiDataManager searchAddressesForKey:searchTerm withCompletionBlock:^(NSArray *response, NSString *searchTerm, NSString *errorString){
        if (!errorString) {
            if (response.count > 0) {
                [self geocodeSearchDidComplete:response isFinalResult:[searchTerm isEqualToString:addressSearchBar.text]];
            }else{
                [self geocodeSearchDidFail:nil forRequest:searchTerm];
            }
        }else{
            [self geocodeSearchDidFail:errorString forRequest:searchTerm];
        }
    }];
}

- (void)geocodeSearchDidComplete:(NSArray *)geocodeList isFinalResult:(BOOL)isFinalResult{
    unRespondedRequestsCount--;
    if (!isInitialMergedView) {
        dataToLoad = [self searchFromBookmarkHistoryContactForKey:addressSearchBar.text];
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
    dataToLoad = [self searchFromBookmarkHistoryContactForKey:addressSearchBar.text];
    [searchResultTableView reloadData];
    if (isFinalSearch && unRespondedRequestsCount == 0) {
        searchActivityIndicator.hidden = YES;
        [searchActivityIndicator stopAnimating];
        //Message that there is no result
        [self showErrorMessage:error];
    }
    
//    [SettingsManager setAskedContactPermission:YES];
//    [[ContactsManager sharedManager] customRequestForAccess];
}

-(void)showErrorMessage:(NSString *)errorMessage {
    UIAlertView *alertView;
    if (errorMessage != nil) {
        alertView = [[UIAlertView alloc] initWithTitle:errorMessage                                                                                      message:nil
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                     otherButtonTitles:nil];
        [alertView show];
        
        [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:errorMessage value:@5];
    }else{
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Looks like there is a free address name.", @"Indicates as search term returned nothing")
                                               message:NSLocalizedString(@"The search returned nothing for that search term.", @"The search returned nothing for that search term.")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                     otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - route Search view controller delegate
- (void)routeSearchViewControllerDismissed {
    [self cancelButtonPressed:self];
}

#pragma mark - TableViewMethods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataToLoad.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {

        StopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
        
        StopEntity *stopEntity = [StopEntity alloc];
        if (indexPath.row < self.dataToLoad.count) {
            stopEntity = [self.dataToLoad objectAtIndex:indexPath.row];
        }
        
        if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
            [cell setupFromHistoryEntity:(HistoryEntity *)stopEntity];
        }else{
            [cell setupFromStopEntity:stopEntity];
        }
        
        cell.stopNameLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:cell.stopNameLabel.text substring:addressSearchBar.text withNormalFont:cell.stopNameLabel.font];
        cell.stopSubtitleLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:cell.stopSubtitleLabel.text substring:addressSearchBar.text withNormalFont:cell.stopSubtitleLabel.font];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]) {
        
        RouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedRouteCell"];
        
        RouteEntity *routeEntity = [RouteEntity alloc];
        if (indexPath.row < self.dataToLoad.count) {
            routeEntity = [self.dataToLoad objectAtIndex:indexPath.row];
        }
        
        if ([routeEntity isKindOfClass:[RouteHistoryEntity class]]) {
            [cell setupFromHistoryEntity:(RouteHistoryEntity *)routeEntity];
        }else{
            [cell setupFromRouteEntity:routeEntity];
        }
        
        cell.toLabel.attributedText = [ReittiStringFormatter highlightSubstringInString: routeEntity.toLocationName substring:addressSearchBar.text withNormalFont:cell.toLabel.font];
        cell.fromLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:[NSString stringWithFormat:@"%@", routeEntity.fromLocationName] substring:addressSearchBar.text withNormalFont:cell.fromLabel.font];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[GeoCode class]]){
        GeoCode *geoCode = [self.dataToLoad objectAtIndex:indexPath.row];

        if (geoCode.getLocationType == LocationTypeStop) {
            StopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
            
            [cell setupFromStopGeocode:geoCode];
            
            cell.stopNameLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:cell.stopNameLabel.text substring:addressSearchBar.text withNormalFont:cell.stopNameLabel.font];
            cell.stopSubtitleLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:cell.stopSubtitleLabel.text substring:addressSearchBar.text withNormalFont:cell.stopSubtitleLabel.font];
            
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }else{
            AddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressLocationCell"];
            [cell setupFromGeocode:geoCode];
            
            cell.nameLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:cell.nameLabel.text substring:addressSearchBar.text withNormalFont:cell.nameLabel.font];
            cell.addressLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:cell.addressLabel.text substring:addressSearchBar.text withNormalFont:cell.addressLabel.font];
            
            if (geoCode.getLocationType  == LocationTypeAddress) {
                [cell addTargetForAddressSelection:self selector:@selector(selectAddressForStreetNumberPressed:)];
            }
            
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    }else if([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[NamedBookmark class]]){
        NamedBookmark *nbookmark = [self.dataToLoad objectAtIndex:indexPath.row];
        
        NamedBookmarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poiLocationCell"];
        
        [cell setupFromNamedBookmark:nbookmark];
        
        cell.nameLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:cell.nameLabel.text substring:addressSearchBar.text withNormalFont:cell.nameLabel.font];
        cell.addressLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:cell.addressLabel.text substring:addressSearchBar.text withNormalFont:cell.addressLabel.font];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        return cell;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.dataToLoad.count)
        return;
    
    id selectedAddress = [self.dataToLoad objectAtIndex:indexPath.row];
    
    if([selectedAddress isKindOfClass:[GeoCode class]]){
        GeoCode *selectedGeocode = selectedAddress;
        if (selectedGeocode.getLocationType == LocationTypeContact) {
            [self userSelectedContactAddress:selectedGeocode];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                [delegate searchResultSelectedAGeoCode:selectedGeocode];
            }];
        }
    }else if([selectedAddress isKindOfClass:[NamedBookmark class]]){
        NamedBookmark *selectedBookmark = selectedAddress;
        [self dismissViewControllerAnimated:YES completion:^{
            [delegate searchResultSelectedANamedBookmark:selectedBookmark];
        }];
    }else if([selectedAddress isKindOfClass:[StopEntity class]] || [selectedAddress isKindOfClass:[HistoryEntity class]]){
        StopEntity *selectedStopEntity = (StopEntity *)selectedAddress;
        [self dismissViewControllerAnimated:YES completion:^{
            [delegate searchResultSelectedAStop:selectedStopEntity];
        }];
    }else if([selectedAddress isKindOfClass:[RouteEntity class]] || [selectedAddress isKindOfClass:[RouteHistoryEntity class]]){
//        [self performSegueWithIdentifier:@"savedRouteSelected" sender:self];
        RouteEntity * selected = selectedAddress;
        [self dismissViewControllerAnimated:NO completion:^{
            if ([delegate respondsToSelector:@selector(searchResultSelectedARoute:)]) {
                [delegate searchResultSelectedARoute:selected];
            }
        }];
    }
}

-(void)userSelectedContactAddress:(GeoCode *)geoCode {
    if (geoCode.getLocationType != LocationTypeContact) {
        return;
    }
    
    [searchActivityIndicator startAnimating];
    [[ContactsManager sharedManager] getCoordsForGeoCode:geoCode withCompletion:^(GeoCode * coordGeoCode, NSString * errorString) {
        CLLocationCoordinate2D coords = [ReittiStringFormatter convertStringTo2DCoord:coordGeoCode.coords];
        BOOL isValid = [ReittiMapkitHelper isValidCoordinate: coords];
        if (!errorString && isValid) {
            [self dismissViewControllerAnimated:YES completion:^{
                [delegate searchResultSelectedAGeoCode:coordGeoCode];
            }];
        } else {
            unRespondedRequestsCount = 1;
            isFinalSearch = YES;
            
            [self showErrorMessage:errorString];
        }
        
        [searchActivityIndicator stopAnimating];
    }];
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row >= self.dataToLoad.count)
//        return 60;
//    
//}

#pragma mark - scroll view delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == searchResultTableView)
        [addressSearchBar resignFirstResponder];
}

#pragma mark - route search view delegate
- (void)routeModified{
    savedRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRoutesFromCoreData]];
}

#pragma mark - helper methods

- (NSMutableArray *)searchFromBookmarkHistoryContactForKey:(NSString *)key{
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
    
    if(key.length > 1)
        [searched addObjectsFromArray:[[ContactsManager sharedManager] getContactsForSearchTerm:key]];
    
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
    if ([segue.identifier isEqualToString:@"savedRouteSelected"]) {
        
        NSIndexPath *selectedRowIndexPath = [searchResultTableView indexPathForSelectedRow];
        RouteEntity * selected = [self.dataToLoad objectAtIndex:selectedRowIndexPath.row];
        
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
        
        routeSearchViewController.prevToLocation = selected.toLocationName;
        routeSearchViewController.prevToCoords = selected.toLocationCoordsString;
        routeSearchViewController.prevFromLocation = selected.fromLocationName;
        routeSearchViewController.prevFromCoords = selected.fromLocationCoordsString;
        routeSearchViewController.reittiDataManager = self.reittiDataManager;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
