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

@interface NSString (LineCodeHelper)
- (NSComparisonResult)asa_recentLineIsEarlierthan:(NSString *)string;
@end

@implementation NSString (LineCodeHelper)

- (NSComparisonResult)asa_recentLineIsEarlierthan:(NSString *)string{
    return NSOrderedAscending;
}

@end

@interface LinesTableViewController ()

@end

@implementation LinesTableViewController

//@synthesize busLines, trainLines, tramLines, ferryLines, metroLines, allLines;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    linesForRecentLinesRequested = linesFromStopsRequested = linesFromNearByStopsRequested = wasShowingLineDetail = NO;
    
    [self initDataManagers];
    
    self.recentLines = [@[] mutableCopy];
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
    }else{
        wasShowingLineDetail = NO;
    }
    
    [self.tableView reloadData];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

-(void)viewWillAppear:(BOOL)animated{
    self.title = @"Lines";
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

#pragma mark - init components methods
-(void)initDataManagers{
    self.reittiDataManager = [[RettiDataManager alloc] init];
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
    [searchBar resignFirstResponder];
//    self.searchedLines = [@[] mutableCopy];
    [searchBar setShowsCancelButton:NO animated:YES];
//    [self.tableView reloadData];
}

#pragma mark - search methods

- (void)searchLinesForSearchtext:(NSString *)searchText{
    
    [searchActivityIndicator beginRefreshing];
    [self.reittiDataManager fetchLinesForSearchTerm:searchText withCompletionBlock:^(NSArray *lines, NSString* searchTerm, NSString *error, ReittiApi usedApi){
        if (![searchTerm isEqualToString:addressSearchBar.text]) return;
        if (!error) {
            self.searchedLines = [[[LinesManager sharedManager] filterInvalidLines:lines] mutableCopy];
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
    linesForRecentLinesRequested = YES;
    [[LinesManager sharedManager] getLinesForRecentLineCodesWithCompletionBlock:^(NSArray *lines){
        self.recentLines = [lines mutableCopy];
        
        linesForRecentLinesRequested = NO;
        [self.tableView reloadData];
    }];
    
    linesFromStopsRequested = YES;
    [[LinesManager sharedManager] getLinesFromSavedStopsWithCompletionBlock:^(NSArray *lines){
        self.linesFromSavedStops = [lines mutableCopy];
        
        linesFromStopsRequested = NO;
        [self.tableView reloadData];
    }];
    
    linesFromNearByStopsRequested = YES;
    [[LinesManager sharedManager] getLinesFromNearByStopsWithCompletionBlock:^(NSArray *lines){
        self.linesFromNearStops = [lines mutableCopy];
        
        linesFromNearByStopsRequested = NO;
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source
-(void)setSectionAndRowNumbers{
    NSInteger sectionNumber = 0;
    
    numberOfSearchedLines = self.searchedLines.count > 0 ? self.searchedLines.count : 0;
    searchedLinesSection = numberOfSearchedLines > 0 ? sectionNumber++ : -1;
    
    numberOfRecentLines = self.recentLines.count > 0 ? self.recentLines.count : 0;
    recentLinesSection = (numberOfRecentLines > 0 || linesForRecentLinesRequested) && !isSearching ? sectionNumber++ : -1;
    
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
    if (section == recentLinesSection) {
        if (numberOfRecentLines == 0 && linesForRecentLinesRequested)
            return 1;
        
        return numberOfRecentLines;
    }else if (section == linesFromSavedStopsSection) {
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
    
    if ((indexPath.section == recentLinesSection && numberOfRecentLines == 0 && linesForRecentLinesRequested) ||
        (indexPath.section == linesFromSavedStopsSection && numberOfLinesFromSavedStops == 0 && linesFromStopsRequested) ||
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
        UIImageView *imageView = [cell viewWithTag:1004];
        
        numberLabel.text = lineForCell.codeShort;
        if (lineForCell.lineStart && lineForCell.lineEnd) {
            nameLabel.text = [NSString stringWithFormat:@"%@ - %@", lineForCell.lineStart, lineForCell.lineEnd];
        } else {
            nameLabel.text = lineForCell.name;
        }
        
        imageView.image = [AppManager lineIconForLineType:lineForCell.lineType];
        
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UIImageView *typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 6, 18, 18)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 60, 30)];
    titleLabel.font = [titleLabel.font fontWithSize:13];
    titleLabel.textColor = [UIColor darkGrayColor];
    if (section == recentLinesSection) {
        titleLabel.text = @"    RECENT LINES";
    }else if (section == linesFromSavedStopsSection) {
        titleLabel.text = @"    LINES FROM SAVED STOPS";
    }else if (section == linesFromNearbyStopsSection){
        titleLabel.text = @"    LINES FROM STOPS NEAR YOU";
    }else if (section == searchedLinesSection){
        titleLabel.text = @"    SEARCHED LINES";
    }else{
        return nil;
    }
    
    [view addSubview:typeImageView];
    [view addSubview:titleLabel];
    
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    return view;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

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

- (Line *)lineForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == recentLinesSection) {
        if (indexPath.row < self.recentLines.count)
            return self.recentLines[indexPath.row];
        else
            return nil;
    }else if (indexPath.section == linesFromSavedStopsSection) {
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
        
        Line *selectedLine = [self lineForIndexPath:indexPath];
        
        lineDetailViewController.line = selectedLine;
        wasShowingLineDetail = YES;
        
        //Add the line to the recent list
        for (int i = 0 ; i < self.recentLines.count ; i++) {
            Line *line = self.recentLines[i];
            if ([line.code isEqualToString:selectedLine.code]) {
                [self.recentLines removeObject:line];
            }
        }
        
        [self.recentLines insertObject:selectedLine atIndex:0];
    }
    
    [self.navigationItem setTitle:@""];
}

@end
