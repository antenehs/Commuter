//
//  LinesTableViewController.m
//  
//
//  Created by Anteneh Sahledengel on 21/6/15.
//
//

#import "LinesTableViewController.h"
#import "AMBlurView.h"
#import "CacheManager.h"
#import "EnumManager.h"
#import "AppManager.h"
#import "LineDetailViewController.h"
#import "CoreDataManager.h"
#import "ASA_Helpers.h"
#import "Line.h"
#import "LinesManager.h"
#import "ReittiStringFormatter.h"

@interface LinesTableViewController ()

@property (nonatomic, strong) NSArray *lineCodesFromSavedStops;
@property (nonatomic, strong) NSArray *lineCodesFromNearbyStops;

@end

@implementation LinesTableViewController

//@synthesize busLines, trainLines, tramLines, ferryLines, metroLines, allLines;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    linesFromStopsRequested = linesFromNearByStopsRequested = wasShowingLineDetail = NO;
    
    [self initDataManagers];
    
    self.searchedLines = [@[] mutableCopy];
    self.linesFromSavedStops = [@[] mutableCopy];
    self.linesFromNearStops = [@[] mutableCopy];
    
//    [self fetchInitialData];
    isSearching = NO;
    [self setUpMainView];
    
    scrollingShouldResignFirstResponder = YES;
    tableIsScrolling = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    if (!wasShowingLineDetail) {
        [self fetchInitialData];
        
        [self.tableView reloadData];
    }else{
        wasShowingLineDetail = NO;
    }
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setTableBackgroundView];
    [self setNavBarSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)lineCodesFromSavedStops{
    return [[LinesManager sharedManager] getLineCodesFromSavedStops];
}

#pragma mark - init components methods
-(void)initDataManagers{
    self.reittiDataManager = [[RettiDataManager alloc] init];
    
    SettingsManager *settingManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
    [self.reittiDataManager setUserLocationToRegion:[settingManager userLocation]];
}

#pragma mark - view methods
-(void)setUpMainView{
    [self setTitle:@"Lines"];
    
    [self setTableBackgroundView];
    
    [self setNavBarSize];
    
    //Set search bar text color
    [addressSearchBar asa_setTextColorAndPlaceholderText:[UIColor whiteColor] placeHolderColor:[UIColor lightTextColor]];
    [addressSearchBar setImage:[UIImage imageNamed:@"search-icon-25.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];

    addressSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    
    searchActivityIndicator.circleLayer.lineWidth = 1.5;
    searchActivityIndicator.circleLayer.strokeColor = [UIColor lightTextColor].CGColor;
    searchActivityIndicator.alternatingColors = nil;
    
    [self.tableView reloadData];
}

- (void)setNavBarSize {
    CGSize navigationBarSize = self.navigationController.navigationBar.frame.size;
    UIView *titleView = self.navigationItem.titleView;
    CGRect titleViewFrame = titleView.frame;
    titleViewFrame.size.width = navigationBarSize.width;
    self.navigationItem.titleView.frame = titleViewFrame;
}

- (void)setTableBackgroundView {
    
    [self.tableView setBlurredBackgroundWithImageNamed:nil];
}

#pragma mark - search bar methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //set a variable to prevent scrolling to dismiss it until scrolling stops
    if (tableIsScrolling) {
        scrollingShouldResignFirstResponder = NO;
    }else{
        scrollingShouldResignFirstResponder = YES;
    }
    
    if (searchBar.text.length == 0) {
        isSearching = NO;
        self.searchedLines = [@[] mutableCopy];
        [self.tableView reloadData];
    }else{
        isSearching = YES;
    }
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)thisSearchBar {
    //Show segment control if there is no text in seach field
    if (thisSearchBar.text == nil || [thisSearchBar.text isEqualToString:@""]){
        //TODO: Setup initial view
    }
    
    [thisSearchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    NSMutableArray *searched = [self searchForLinesForString:searchText];
//    [self groupLinesByType:searched];
    if(searchText.length > 0){
       [self searchLinesForSearchtext:searchText];
        isSearching = YES;
        [searchBar setShowsCancelButton:YES animated:YES];
    }else{
        isSearching = NO;
        self.searchedLines = [@[] mutableCopy];
        [self.tableView reloadData];
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    isSearching = NO;
    self.searchedLines = [@[] mutableCopy];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
}

#pragma mark - search methods

- (void)searchLinesForSearchtext:(NSString *)searchText{
    
    [searchActivityIndicator beginRefreshing];
    [self.reittiDataManager fetchLinesForSearchTerm:searchText withCompletionBlock:^(NSArray *lines, NSString* searchTerm, NSString *error){
        if (!error) {
            self.searchedLines = [lines mutableCopy];
            [self.tableView reloadData];
        }else{
            self.searchedLines = [@[] mutableCopy];
            [self.tableView reloadData];
        }
        
        if ([searchTerm isEqualToString:addressSearchBar.text])
            [searchActivityIndicator endRefreshing];
    }];
}

-(void)fetchInitialData{
    if (self.lineCodesFromSavedStops.count > 0) {
        linesFromStopsRequested = YES;
        
//        NSString *codes = [ReittiStringFormatter commaSepStringFromArray:self.lineCodesFromSavedStops withSeparator:@"|"];
//        
//        [self.reittiDataManager fetchLinesForSearchTerm:codes withCompletionBlock:^(NSArray *lines, NSString *searchTerm, NSString *errorString){
//            if (!errorString) {
//                self.linesFromSavedStops = [[self filterInvalidLines:lines] mutableCopy];
//            }else{
//                self.linesFromSavedStops = [@[] mutableCopy];
//            }
//            
//            linesFromStopsRequested = NO;
//            [self.tableView reloadData];
//        }];
        
        [self fetchLinesForCodes:self.lineCodesFromSavedStops WithCompletionBlock:^(NSArray *lines){
            self.linesFromSavedStops = [lines mutableCopy];
            
            linesFromStopsRequested = NO;
            [self.tableView reloadData];
        }];
    }
    
    linesFromNearByStopsRequested = YES;
    [[LinesManager sharedManager] getLineCodesFromNearByStopsWithCompletionBlock:^(NSArray *lineCodes){
        if (lineCodes.count > 0) {
            [self fetchLinesForCodes:lineCodes WithCompletionBlock:^(NSArray *lines){
                self.linesFromNearStops = [lines mutableCopy];
                
                linesFromNearByStopsRequested = NO;
                [self.tableView reloadData];
            }];
        }
    }];
}

-(void)fetchLinesForCodes:(NSArray *)lineCodes WithCompletionBlock:(ActionBlock)completionBlock{
    NSString *codes = [ReittiStringFormatter commaSepStringFromArray:lineCodes withSeparator:@"|"];
    
    [self.reittiDataManager fetchLinesForSearchTerm:codes withCompletionBlock:^(NSArray *lines, NSString *searchTerm, NSString *errorString){
        if (!errorString) {
            completionBlock([[self filterInvalidLines:lines] mutableCopy]);
        }else{
            completionBlock([@[] mutableCopy]);
        }
    }];
}

#pragma mark - Table view data source
-(void)setSectionAndRowNumbers{
    NSInteger sectionNumber = 0;
    
    numberOfSearchedLines = self.searchedLines.count > 0 ? self.searchedLines.count : 0;
    searchedLinesSection = numberOfSearchedLines > 0 ? sectionNumber++ : -1;
    
    numberOfLinesFromSavedStops = self.linesFromSavedStops.count > 0 ? self.linesFromSavedStops.count : 0;
    linesFromSavedStopsSection = (numberOfLinesFromSavedStops > 0 || linesFromStopsRequested) && !isSearching ? sectionNumber++ : -1;
    
    numberOfLinesFromNearbyStops = self.linesFromNearStops.count > 0 ? self.linesFromNearStops.count : 0;
    linesFromNearbyStopsSection = (numberOfLinesFromNearbyStops > 0 || linesFromNearByStopsRequested) && !isSearching ? sectionNumber++ : -1;
    
    numberOfSections = sectionNumber;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    [self setSectionAndRowNumbers];
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == linesFromSavedStopsSection) {
        if (numberOfLinesFromSavedStops == 0 && linesFromStopsRequested)
            return 1;
        
        return numberOfLinesFromSavedStops;
    }else if (section == linesFromNearbyStopsSection) {
        if (numberOfLinesFromNearbyStops == 0 && linesFromNearByStopsRequested)
            return 1;
        
        return numberOfLinesFromNearbyStops;
    }else if (section == searchedLinesSection) {
        return numberOfSearchedLines;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if ((indexPath.section == linesFromSavedStopsSection && numberOfLinesFromSavedStops == 0 && linesFromStopsRequested) ||
        (indexPath.section == linesFromNearbyStopsSection && numberOfLinesFromNearbyStops == 0 && linesFromNearByStopsRequested)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell" forIndexPath:indexPath];
        
        JTMaterialSpinner *spinner = (JTMaterialSpinner *)[cell viewWithTag:1001];
        spinner.circleLayer.lineWidth = 1.5;
        [spinner beginRefreshing];
        
        cell.backgroundColor = [UIColor clearColor];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"lineCell" forIndexPath:indexPath];
        Line *lineForCell = [self lineForIndexPath:indexPath];
        
        UILabel *numberLabel = (UILabel *)[cell viewWithTag:1001];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1002];
        UIView *imageContainerView = [cell viewWithTag:1003];
        UIImageView *imageView = [imageContainerView viewWithTag:1004];
        
        numberLabel.text = lineForCell.codeShort;
        nameLabel.text = [NSString stringWithFormat:@"%@ - %@", lineForCell.lineStart, lineForCell.lineEnd];
        
        imageContainerView.layer.cornerRadius = imageContainerView.frame.size.width/2;
        imageContainerView.layer.borderWidth = 0.5;
        imageContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageContainerView.backgroundColor = [UIColor whiteColor];
        [imageView setImage:[AppManager vehicleImageForLineType:lineForCell.lineType]];
        
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0 && trainLines.count != 0) {
//        return 30;
//    }else if (section == 1 && tramLines.count != 0){
//        return 30;
//    }else if (section == 2 && metroLines.count != 0){
//        return 30;
//    }else if (section == 3 && ferryLines.count != 0){
//        return 30;
//    }else if (section == 4 && busLines.count != 0){
//        return 30;
//    }
    
//    if ([self dataSourceForSection:section].count != 0) {
//        return 30;
//    }
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UIImageView *typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 6, 18, 18)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 60, 30)];
    titleLabel.font = [titleLabel.font fontWithSize:14];
    titleLabel.textColor = [UIColor darkGrayColor];
    if (section == linesFromSavedStopsSection) {
        titleLabel.text = @"    LINES FROM SAVED STOPS";
//        typeImageView.image = [AppManager vehicleImageForLineType:LineTypeTrain];
    }else if (section == linesFromNearbyStopsSection){
        titleLabel.text = @"    LINES FROM STOPS NEAR YOU";
//        typeImageView.image = [AppManager vehicleImageForLineType:LineTypeTram];
    }else if (section == searchedLinesSection){
        titleLabel.text = @"    SEARCHED LINES";
//        typeImageView.image = [AppManager vehicleImageForLineType:LineTypeMetro];
    }else{
        return nil;
    }
    
    [view addSubview:typeImageView];
    [view addSubview:titleLabel];
    
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    return view;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if (section == linesFromSavedStopsSection) {
//        return @"LINES FROM SAVED STOPS";
//    }else if (section == linesFromNearbyStopsSection) {
//        return @"LINES FROM STOPS NEAR YOU";
//    }else if (section == searchedLinesSection) {
//        return @"SEARCHED LINES";
//    }
//    
//    return nil;
//}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

#pragma mark - scroll view delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    tableIsScrolling = YES;
    if(scrollView == self.tableView && scrollingShouldResignFirstResponder){
        [addressSearchBar resignFirstResponder];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    tableIsScrolling = NO;
    scrollingShouldResignFirstResponder = YES;
}

#pragma mark - helper methods
- (NSMutableArray *)dataSourceForSection:(NSInteger)section{
    switch (section) {
        case 0:
            return self.linesFromSavedStops;
            break;
            
        default:
            return self.searchedLines;
            break;
    }
}

//- (void)groupLinesByType:(NSArray *)lines{
//    [self.busLines removeAllObjects];
//    [self.ferryLines removeAllObjects];
//    [self.metroLines removeAllObjects];
//    [self.tramLines removeAllObjects];
//    [self.trainLines removeAllObjects];
//    
//    for (StaticRoute *route in lines) {
//        if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeBus) {
//            [self.busLines addObject:route];
//        }else if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeFerry) {
//            [self.ferryLines addObject:route];
//        }else if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeMetro) {
//            [self.metroLines addObject:route];
//        }else if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeTram) {
//            [self.tramLines addObject:route];
//        }else if ([EnumManager lineTypeForHSLLineTypeId:route.routeType] == LineTypeTrain) {
//            [self.trainLines addObject:route];
//        }
//    }
//    
//    self.busLines = [self sortRouteArray:self.busLines];
//    self.ferryLines = [self sortRouteArray:self.ferryLines];
//    self.metroLines = [self sortRouteArray:self.metroLines];
//    self.tramLines = [self sortRouteArray:self.tramLines];
//    self.trainLines = [self sortRouteArray:self.trainLines];
//}

- (NSArray *)filterInvalidLines:(NSArray *)lines{
    NSMutableArray *filteredLines = [@[] mutableCopy];
    for (Line *line in lines) {
        if (line.isValidNow) {
            [filteredLines addObject:line];
        }
    }
    
    return filteredLines;
}

- (NSMutableArray *)sortRouteArray:(NSMutableArray *)array{
    NSArray *sortedArray;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"shortName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return [NSMutableArray arrayWithArray:sortedArray];
}

- (NSMutableArray *)searchForLinesForString:(NSString *)key{
//    NSMutableArray * searched = [[NSMutableArray alloc] init];
//    key = [key lowercaseString];
//    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    
//    if (key == nil || [key isEqualToString:@""]) {
//        return self.allLines;
//    }
//    
//    for (StaticRoute *route in self.allLines) {
//        if ([[route.shortName lowercaseString] containsString:key]) {
//            [searched addObject:route];
//        }else if ([[route.longName lowercaseString] containsString:key]) {
//            [searched addObject:route];
//        }
//    }
//    
//    return searched;
    return nil;
}

- (Line *)lineForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == linesFromSavedStopsSection) {
        if (indexPath.row < self.linesFromSavedStops.count)
            return self.linesFromSavedStops[indexPath.row];
        else
            return nil;
    }else if (indexPath.section == linesFromNearbyStopsSection) {
        if (indexPath.row < self.linesFromNearStops.count)
            return self.linesFromNearStops[indexPath.row];
        else
            return nil;
    }else if (indexPath.section == searchedLinesSection) {
        if (indexPath.row < self.searchedLines.count)
            return self.searchedLines[indexPath.row];
        else
            return nil;
    }
    
    return nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLineDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        LineDetailViewController * lineDetailViewController = (LineDetailViewController *)[segue destinationViewController];
        
        lineDetailViewController.line = [self lineForIndexPath:indexPath];
        wasShowingLineDetail = YES;
    }
}

@end
