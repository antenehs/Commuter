//
//  RouteOptionsTableViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "RouteOptionsTableViewController.h"
#import "AppManager.h"
#import "ASA_Helpers.h"
#import "RouteSearchOptions.h"
#import "ReittiNotificationHelper.h"
#import "RettiDataManager.h"
#import "CoreDataManager.h"

@interface RouteOptionsTableViewController ()

@property RettiDataManager *reittiDataManager;

@end

@implementation RouteOptionsTableViewController

@synthesize checkedIndexPath;
@synthesize routeSearchOptions;
@synthesize datePicker, timeTypeSegmentControl;
@synthesize routeOptionSelectionDelegate;
@synthesize globalSettingsMode, settingsManager;

- (void)viewDidLoad {
    [super viewDidLoad];
//    selectedSearchOption = RouteSearchOptionFastest;
    
    settingsChanged = NO;
    
    if (self.settingsManager == nil) {
        self.settingsManager = [SettingsManager sharedManager];
    }
    
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] init];
    }
    
    ticketZoneSelectorViewIndex = 4000, changeMargineSelectorViewIndex = 4001, walkingSpeedSelectorViewIndex = 4002;
    
    if (globalSettingsMode){
        routeSearchOptions = [settingsManager globalRouteOptions];
    }
    
    if (routeSearchOptions == nil)
        routeSearchOptions = [RouteSearchOptions defaultOptions];
    
    if (routeSearchOptions.selectedRouteTrasportTypes == nil)
        routeSearchOptions.selectedRouteTrasportTypes = [routeSearchOptions allTrasportTypeNames];

    [self setSectionAndRowNumbers];
    
    trasportTypes = [routeSearchOptions getTransportTypeOptions];
    
//    self.tableView.separatorColor = [UIColor clearColor];
    [self setTableBackgroundView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
}

- (void)setSectionAndRowNumbers {
    int sectionNumber = 0;
    if (globalSettingsMode) {
        dateAndTimeSection = saveSettingsSections = -1;
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        dateAndTimeSection = sectionNumber++;
    }
    
    transportTypeSection = [routeSearchOptions getTransportTypeOptions] != nil ? sectionNumber++ : -1;
    searchOptionSection = sectionNumber++;
    
    int advancedOptionRow = 0;
    ticketZoneRow = [routeSearchOptions getTicketZoneOptions] != nil ? advancedOptionRow++ : -1;
    changeMargineRow = [routeSearchOptions getChangeMargineOptions] != nil ? advancedOptionRow++ : -1;
    walkingSpeedRow = [routeSearchOptions getWalkingSpeedOptions] != nil ? advancedOptionRow++ : -1;
    
    numberOfAdvancedOptions = advancedOptionRow;
    
    advancedOptionsSection = numberOfAdvancedOptions > 0 ? sectionNumber++ : -1;
    
    if (!globalSettingsMode)
        saveSettingsSections = sectionNumber++;
    
    resetSettingsSections = sectionNumber++;
    
    numberOfSections = sectionNumber;
}

- (void)viewDidAppear:(BOOL)animated{
    [self.navigationItem setTitle:@"ROUTE OPTIONS"];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self saveOpitionsToGlobalSettings];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self setTableBackgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTableBackgroundView {
    [self.tableView setBlurredBackgroundWithImageNamed:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == dateAndTimeSection) {
        return 1;
    }else if (section == transportTypeSection){
        return trasportTypes.count;
    }else if (section == searchOptionSection){
        return 3;
    }else if (section == advancedOptionsSection){
        return numberOfAdvancedOptions;
    }else if (section == saveSettingsSections){
        return 1;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section == dateAndTimeSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"timePickerCell"];
        self.datePicker = (UIDatePicker *)[cell viewWithTag:1002];
        [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        if (routeSearchOptions.selectedTimeType == RouteTimeNow) {
            [datePicker setDate:[NSDate date]];
        }else{
            [datePicker setDate:routeSearchOptions.date];
        }
        
        self.timeTypeSegmentControl = (UISegmentedControl *)[cell viewWithTag:1003];
        [self.timeTypeSegmentControl addTarget:self action:@selector(timeTypeChanged:) forControlEvents:UIControlEventValueChanged];
        self.timeTypeSegmentControl.selectedSegmentIndex = (int)self.routeSearchOptions.selectedTimeType;
    }else if (indexPath.section == transportTypeSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell"];
        NSString *transName = [trasportTypes[indexPath.row] objectForKey:displayTextOptionKey];
        cell.textLabel.text = transName;
        cell.imageView.image = [UIImage imageNamed:[trasportTypes[indexPath.row] objectForKey:pictureOptionKey]];
        
        CGSize itemSize = CGSizeMake(25, 25);
        [cell adjustImageViewSize:itemSize];
        
        if ([self isTransportTypeSelected:transName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.textLabel.textColor = [UIColor blackColor];
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }else if (indexPath.section == searchOptionSection){
        cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell"];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Fastest";
            cell.imageView.image = [UIImage imageNamed:@"rabbit-light-100.png"];
            if (routeSearchOptions.selectedRouteSearchOptimization == RouteSearchOptionFastest) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                checkedIndexPath = indexPath;
                cell.textLabel.textColor = [UIColor blackColor];
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textColor = [UIColor grayColor];
            }
        }else if (indexPath.row == 1) {
            cell.textLabel.text = @"Least transfer";
            cell.imageView.image = [UIImage imageNamed:@"transfer-arrows-100.png"];
            if (routeSearchOptions.selectedRouteSearchOptimization == RouteSearchOptionLeastTransfer) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                checkedIndexPath = indexPath;
                cell.textLabel.textColor = [UIColor blackColor];
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textColor = [UIColor grayColor];
            }
        }else if (indexPath.row == 2) {
            cell.textLabel.text = @"Least walking";
            cell.imageView.image = [UIImage imageNamed:@"Walking-light-100.png"];
            if (routeSearchOptions.selectedRouteSearchOptimization == RouteSearchOptionLeastWalking) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                checkedIndexPath = indexPath;
                cell.textLabel.textColor = [UIColor blackColor];
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textColor = [UIColor grayColor];
            }
        }
        
        CGSize itemSize = CGSizeMake(25, 25);
        [cell adjustImageViewSize:itemSize];
    }else  if (indexPath.section == advancedOptionsSection){
        cell = [tableView dequeueReusableCellWithIdentifier:@"advanceOptionCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == ticketZoneRow) {
            cell.textLabel.text = @"Ticket Zone";
            [self setDetailForAdvancedOptionCell:cell detailText:routeSearchOptions.selectedTicketZone selectedIndex:[routeSearchOptions getSelectedTicketZoneIndex] defaultOptionIndex:[routeSearchOptions getDefaultValueIndexForTicketZoneOptions]];
        }else if (indexPath.row == changeMargineRow) {
            cell.textLabel.text = @"Change margin";
            [self setDetailForAdvancedOptionCell:cell detailText:routeSearchOptions.selectedChangeMargine selectedIndex:[routeSearchOptions getSelectedChangeMargineIndex] defaultOptionIndex:[routeSearchOptions getDefaultValueIndexForChangeMargineOptions]];
        }else{
            cell.textLabel.text = @"Walking Speed";
            [self setDetailForAdvancedOptionCell:cell detailText:routeSearchOptions.selectedWalkingSpeed selectedIndex:[routeSearchOptions getSelectedWalkingSpeedIndex] defaultOptionIndex:[routeSearchOptions getDefaultValueIndexForWalkingSpeedOptions]];
        }
    }else if (indexPath.section == saveSettingsSections){
        cell = [tableView dequeueReusableCellWithIdentifier:@"saveSettingsCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        rememberOptionsButton = (UIButton *)[cell viewWithTag:1001];
        rememberOptionsButton.enabled = settingsChanged;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"resetSettingsCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        resetOptionsButton = (UIButton *)[cell viewWithTag:1001];
    }
    
    // Configure the cell...
//    [cell addSubview:line];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == dateAndTimeSection) {
        return @"DATE AND TIME";
    }else if (section == transportTypeSection) {
        return @"PREFERRED TRANSPORT TYPES";
    }else if (section == searchOptionSection) {
        return @"OPTIMIZE ROUTE FOR";
    }else if (section == advancedOptionsSection) {
        return @"ADVANCED OPTIONS";
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == saveSettingsSections) {
        return 70;
    }else
        return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == saveSettingsSections) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.tableView.frame.size.width - 30, 35)];
        label.text = @"Remembered route search options can be modified from 'Settings -> Route search options' later.";
        label.numberOfLines = 3;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-light" size:12];
        
        return label;
    }else{
        return nil;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == dateAndTimeSection) {
        return 248.0;
    }else{
        return 50.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == transportTypeSection) {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        NSMutableArray *toBeModified = [routeSearchOptions.selectedRouteTrasportTypes mutableCopy];
        if (toBeModified == nil)
            toBeModified = [[routeSearchOptions allTrasportTypeNames] mutableCopy];
        
        if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            selectedCell.accessoryType = UITableViewCellAccessoryNone;
            selectedCell.textLabel.textColor = [UIColor grayColor];
            [toBeModified removeObject:selectedCell.textLabel.text];
        }else if (selectedCell.accessoryType == UITableViewCellAccessoryNone){
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            selectedCell.textLabel.textColor = [UIColor blackColor];
            [toBeModified addObject:selectedCell.textLabel.text];
        }
        
        routeSearchOptions.selectedRouteTrasportTypes = toBeModified;
//        [self saveOpitionsToGlobalSettings];
        [self optionsChanged];
    }
    
    if (indexPath.section == searchOptionSection && ![self.checkedIndexPath isEqual:indexPath]) {
        if(self.checkedIndexPath)
        {
            UITableViewCell* uncheckCell = [tableView
                                            cellForRowAtIndexPath:self.checkedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
            uncheckCell.textLabel.textColor = [UIColor grayColor];
        }
        if([self.checkedIndexPath isEqual:indexPath])
        {
//            self.checkedIndexPath = nil;
        }
        else
        {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.textLabel.textColor = [UIColor blackColor];
            self.checkedIndexPath = indexPath;
            
            routeSearchOptions.selectedRouteSearchOptimization = (RouteSearchOptimization)indexPath.row;
//            [self saveOpitionsToGlobalSettings];
            [self optionsChanged];
        }
    }
    
//    if (indexPath.section == saveSettingsSections) {
//        [self rememberOptionsButtonPressed:self];
//    }
}

#pragma mark - IBActions

- (IBAction)doneButtonPressed:(id)sender {
    /* not neccessary but do it anyways */
    routeSearchOptions.date = datePicker.date;
    
    [self saveOpitionsToGlobalSettings];
    
    //optionSelectionDidComplete should be called in completion block because route search view reloads data when view apears.
    [self dismissViewControllerAnimated:YES completion:^{
        [self returnRouteOptionsToDelegate];
    }];
}

- (IBAction)timeTypeChanged:(id)sender {
    routeSearchOptions.selectedTimeType = (int)self.timeTypeSegmentControl.selectedSegmentIndex;
    if (timeTypeSegmentControl.selectedSegmentIndex == 0) {
        [datePicker setDate:[NSDate date]];
    }
}

-(IBAction)dateChanged:(id)sender{
    if (routeSearchOptions.selectedTimeType == RouteTimeNow) {
        routeSearchOptions.selectedTimeType = RouteTimeDeparture;
    }
    
    timeTypeSegmentControl.selectedSegmentIndex = (int)routeSearchOptions.selectedTimeType;
    routeSearchOptions.date = self.datePicker.date;
}

- (IBAction)rememberOptionsButtonPressed:(id)sender {
    [settingsManager setGlobalRouteOptions:routeSearchOptions];
    rememberOptionsButton.enabled = NO;
    [ReittiNotificationHelper showSuccessBannerMessage:@"Options saved!" andContent:nil];
}

- (IBAction)resetOptionsButtonPressed:(id)sender {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Hold On! Do you really want to loose your settings and reset to default?"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {}];
    
    [controller addAction:cancelAction];
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Reset"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [settingsManager setGlobalRouteOptions:[RouteSearchOptions defaultOptions]];
                                                            routeSearchOptions = [RouteSearchOptions defaultOptions];
                                                            resetOptionsButton.enabled = NO;
                                                            [self.tableView reloadData];
                                                        }];
    
    [controller addAction:firstAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Settings change notifications
-(void)userLocationValueChanged:(NSNotification *)notification{
    [self setSectionAndRowNumbers];
    [self.tableView reloadData];
}

#pragma mark - helpers
- (void)optionsChanged{
    settingsChanged = YES;
    rememberOptionsButton.enabled = YES;
    resetOptionsButton.enabled = YES;
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionChangedRouteSearchOption label:@"All" value:nil];
}
- (void)saveOpitionsToGlobalSettings {
    if (globalSettingsMode && settingsChanged) {
        [settingsManager setGlobalRouteOptions:routeSearchOptions];
    }
}

- (void)returnRouteOptionsToDelegate {
    [self.routeOptionSelectionDelegate optionSelectionDidComplete:[routeSearchOptions copy]];
}

- (BOOL)isTransportTypeSelected:(NSString *)typeName {
    NSArray *selectedTypes = routeSearchOptions.selectedRouteTrasportTypes != nil
                                                            ? routeSearchOptions.selectedRouteTrasportTypes
                                                            : routeSearchOptions.getDefaultTransportTypeNames;
    return [selectedTypes containsObject:typeName];
}

- (void)setDetailForAdvancedOptionAtRow:(NSInteger)row detailText:(NSString *)detail selectedIndex:(NSInteger)selectedIndex defaultOptionIndex:(NSInteger)defaultIndex{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:advancedOptionsSection]];
    [self setDetailForAdvancedOptionCell:cell detailText:detail selectedIndex:selectedIndex defaultOptionIndex:defaultIndex];
}

- (void)setDetailForAdvancedOptionCell:(UITableViewCell *)cell detailText:(NSString *)detail selectedIndex:(NSInteger)selectedIndex defaultOptionIndex:(NSInteger)defaultIndex{
    if (selectedIndex != defaultIndex) {
        cell.detailTextLabel.text = detail;
    }else{
        cell.detailTextLabel.text = @"Default";
    }
}

#pragma mark - SingleSelectTableViewControllerDelegate implementation

- (NSArray *)dataListForSelectorForViewControllerIndex:(NSInteger)viewControllerIndex {
    if (viewControllerIndex == ticketZoneSelectorViewIndex) {
        return [routeSearchOptions getTicketZoneOptions];
    }else if (viewControllerIndex == changeMargineSelectorViewIndex) {
        return [routeSearchOptions getChangeMargineOptions];
    }else if (viewControllerIndex == walkingSpeedSelectorViewIndex) {
        return [routeSearchOptions getWalkingSpeedOptions];
    }
    
    return nil;
}

- (void)selectedIndex:(NSInteger)selectedIndex senderViewControllerIndex:(NSInteger)viewControllerIndex {
    if (viewControllerIndex == ticketZoneSelectorViewIndex) {
        routeSearchOptions.selectedTicketZone = [[routeSearchOptions getTicketZoneOptions][selectedIndex] objectForKey:@"displayText"];

        [self setDetailForAdvancedOptionAtRow:ticketZoneRow detailText:routeSearchOptions.selectedTicketZone selectedIndex:selectedIndex defaultOptionIndex:[routeSearchOptions getDefaultValueIndexForTicketZoneOptions]];
    }else if (viewControllerIndex == changeMargineSelectorViewIndex) {
        routeSearchOptions.selectedChangeMargine = [[routeSearchOptions getChangeMargineOptions][selectedIndex] objectForKey:@"displayText"];

        [self setDetailForAdvancedOptionAtRow:changeMargineRow detailText:routeSearchOptions.selectedChangeMargine selectedIndex:selectedIndex defaultOptionIndex:[routeSearchOptions getDefaultValueIndexForChangeMargineOptions]];
    }else if (viewControllerIndex == walkingSpeedSelectorViewIndex) {
        routeSearchOptions.selectedWalkingSpeed = [[routeSearchOptions getWalkingSpeedOptions][selectedIndex] objectForKey:@"displayText"];
        [self setDetailForAdvancedOptionAtRow:walkingSpeedRow detailText:routeSearchOptions.selectedWalkingSpeed selectedIndex:selectedIndex defaultOptionIndex:[routeSearchOptions getDefaultValueIndexForWalkingSpeedOptions]];
    }
    
//    [self saveOpitionsToGlobalSettings];
    [self optionsChanged];
}

- (NSInteger)alreadySelectedIndexForViewControllerIndex:(NSInteger)viewControllerIndex {
    if (viewControllerIndex == ticketZoneSelectorViewIndex) {
        return [routeSearchOptions getSelectedTicketZoneIndex];
    }else if (viewControllerIndex == changeMargineSelectorViewIndex) {
        return [routeSearchOptions getSelectedChangeMargineIndex];
    }else if (viewControllerIndex == walkingSpeedSelectorViewIndex) {
        return [routeSearchOptions getSelectedWalkingSpeedIndex];
    }
    
    return 0;
}

- (NSString *)viewControllerTitleForViewControllerIndex:(NSInteger)viewControllerIndex {
    if (viewControllerIndex == ticketZoneSelectorViewIndex) {
        return @"TICKET ZONE";
    }else if (viewControllerIndex == changeMargineSelectorViewIndex) {
        return @"CHANGE MARGIN";
    }else if (viewControllerIndex == walkingSpeedSelectorViewIndex) {
        return @"WALKING SPEED";
    }
    
    return nil;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userlocationChangedNotificationName object:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectValue"]) {
        //Get selected table view cell index
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        SingleSelectTableViewController *selectorViewController = (SingleSelectTableViewController *)segue.destinationViewController;
        selectorViewController.singleSelectTableViewControllerDelegate = self;
        
        if (indexPath.row == ticketZoneRow) {
            selectorViewController.viewControllerIndex = ticketZoneSelectorViewIndex;
        }else if (indexPath.row == changeMargineRow) {
            selectorViewController.viewControllerIndex = changeMargineSelectorViewIndex;
        }else {
            selectorViewController.viewControllerIndex = walkingSpeedSelectorViewIndex;
        }
        
    }
    
    [self.navigationItem setTitle:@""];
}

@end
