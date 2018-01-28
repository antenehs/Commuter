//
//  SettingsViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "SettingsViewController.h"
#import "RettiDataManager.h"
#import "AppManager.h"
#import "ASA_Helpers.h"
#import "WebViewController.h"
#import "ReittiRemindersManager.h"

NSInteger kHistoryCleaningDaysSelectionViewControllerTag = 1001;
NSInteger kUserLocationRegionSelectionViewControllerTag = 2001;

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize settingsManager;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsManager = [SettingsManager sharedManager];
    
    dayNumbers = @[@1, @5, @10, @15, @30, @90, @180, @365];
    dayStrings = @[@"1 day", @"5 days", @"10 days", @"15 days", @"30 days", @"3 months", @"6 months", @"1 year"];
    
    regionOptionNumbers = @[[NSNumber numberWithInt:HSLRegion],[NSNumber numberWithInt:TRERegion],[NSNumber numberWithInt:FINRegion]];
    regionOptionNames = @[@"Helsinki Region", @"Tampere Region", @"Whole Finland"];
    regionIncludingCities = @[@"Helsinki, Espoo, Vantaa, Kauniainen, Kerava, Kirkkonummi and Sipoo.",
                              @"Tampere, Pirkkala, Nokia, Kangasala, Lempäälä, Ylöjärvi, Vesijärvi and Orivesi",
                              @"Everywhere in Finland"];
    
    mainTableView.backgroundColor = [UIColor clearColor];
    [mainTableView setBlurredBackgroundWithImageNamed:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self setUpViewForTheMode];
}

-(void)viewDidAppear:(BOOL)animated{
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

-(void)setRowAndSectionValues{
    //Map section
    NSInteger sectionNumber = 0;
    
    if (!self.advancedSettingsMode) {
        //----------
        mapSectionNumberOfRows = 0;
        mapTypeRow = mapSectionNumberOfRows++;
        walkingRadiusRow = mapSectionNumberOfRows++;
        liveVehiclesRow = mapSectionNumberOfRows++;
        
        mapSettingsSection = sectionNumber++;
        //-----------
//        wigetSectionNumberOfRows = 0;
//        departuresWidgetRow = wigetSectionNumberOfRows++;
//        
//        widgetSettingSection = sectionNumber++;
        
        //-----------
        otherSettingsNumberOfRows = 0;
        routeSearchOptionRow = otherSettingsNumberOfRows++;
        toneSelectorRow = otherSettingsNumberOfRows++;
        clearHistoryRow = otherSettingsNumberOfRows++;
        clearHistoryDaysRow = otherSettingsNumberOfRows++;
        
        otherSettingsSection = sectionNumber++;
        
        //-----------
        startingTabSectionNumberOfRows = 1;
        startingTabRow = 0;
        startingTabSection = sectionNumber++;
        
        //-----------
        advancedSectionNumberOfRows = 0;
        advancedSetttingsRow = advancedSectionNumberOfRows++;
        
        advancedSettingSection = sectionNumber++;
        
        advancedModeNumberOfRows = -1;
    }else{
        advancedModeNumberOfRows = 0;
        locationRow = advancedModeNumberOfRows++;
        trackingOptionRow = advancedModeNumberOfRows++;
        
        advancedModeSection = sectionNumber++;
        mapSettingsSection = otherSettingsSection = startingTabSection = advancedSettingSection = -1;
    }
    
    numberOfSections = sectionNumber;
}

- (void)setUpViewForTheMode{
    if (![self isModalMode]) {
        self.navigationItem.leftBarButtonItem = nil;
    }else{
        if (self.advancedSettingsMode) {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }

    mainTableView.backgroundColor = [UIColor clearColor];
    
    if (self.advancedSettingsMode) {
        self.title = @"ADVANCED";
    }else{
        self.title = @"SETTINGS";
    }
    
    [self setRowAndSectionValues];
    [mainTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isModalMode{
    return self.tabBarController == nil;
}

#pragma - mark table view methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return numberOfSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == mapSettingsSection) {
        return mapSectionNumberOfRows;
    }else if (section == otherSettingsSection) {
        return otherSettingsNumberOfRows;
    }else if (section == startingTabSection){
        return startingTabSectionNumberOfRows;
    }else if (section == advancedSettingSection){
        return advancedSectionNumberOfRows;
    }else if (section == advancedModeSection){
        return advancedModeNumberOfRows;
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;

    if (indexPath.section == mapSettingsSection) {
        if (indexPath.row == mapTypeRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"mapModeCell"];
            UISegmentedControl *segmentCtrl = (UISegmentedControl *)[cell viewWithTag:1001];
            segmentCtrl.selectedSegmentIndex = [self.settingsManager mapMode];
        }else if(indexPath.row == walkingRadiusRow){
            cell = [tableView dequeueReusableCellWithIdentifier:@"walkingRadiusCell"];
            UISwitch *uiSwitch = (UISwitch *)[cell viewWithTag:1001];
            uiSwitch.on = SettingsManager.showWalkingRadius;
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"liveVehicleCell"];
            UISwitch *uiSwitch = (UISwitch *)[cell viewWithTag:1001];
            uiSwitch.on = [settingsManager showLiveVehicles];
        }
    }else if (indexPath.section == otherSettingsSection) {
        if (indexPath.row == routeSearchOptionRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"routeSearchOptionsCell"];
        }else if (indexPath.row == toneSelectorRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"notificationToneCell"];
            UILabel *toneNameLabel = (UILabel *)[cell viewWithTag:1001];
            if ([[settingsManager toneName] isEqualToString:UILocalNotificationDefaultSoundName] || [[settingsManager toneName] isEqualToString:KNotificationDefaultSoundName]) {
                toneNameLabel.text = @"Default iOS sound";
            }else{
                toneNameLabel.text = [settingsManager toneName];
            }
        }else if (indexPath.row == clearHistoryRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"clearHistoryCell"];
            UISwitch *uiSwitch = (UISwitch *)[cell viewWithTag:1001];
            uiSwitch.on = [settingsManager isClearingHistoryEnabled];
        }else if (indexPath.row == clearHistoryDaysRow){
            cell = [tableView dequeueReusableCellWithIdentifier:@"clearHistoryDateCell"];
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:1001];
            UILabel *selectedLabel = (UILabel *)[cell viewWithTag:1002];
            
            int savedValue = [settingsManager numberOfDaysToKeepHistory];
            NSInteger index = [self indexForDayFromDayNumbers:savedValue];
            
            selectedLabel.text = dayStrings[index];
            
            if([settingsManager isClearingHistoryEnabled]){
                cell.userInteractionEnabled = YES;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                titleLabel.textColor = [UIColor darkGrayColor];
                selectedLabel.textColor = [UIColor darkGrayColor];
            }else{
                cell.userInteractionEnabled = NO;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                titleLabel.textColor = [UIColor lightGrayColor];
                selectedLabel.textColor = [UIColor lightGrayColor];
            }
        }
    }else if (indexPath.section == startingTabSection){
        if (indexPath.row == startingTabRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"selectStartTab"];
            UISegmentedControl *segmentCtrl = (UISegmentedControl *)[cell viewWithTag:1001];
            segmentCtrl.selectedSegmentIndex = [SettingsManager startingIndexTab];
        }
    }else if (indexPath.section == advancedSettingSection){
        if (indexPath.row == advancedSetttingsRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"advancedSettingCell"];
        }
    }else if (indexPath.section == advancedModeSection){
        if (indexPath.row == locationRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
            UILabel *label = (UILabel *)[cell viewWithTag:1001];
            Region savedRegion = [settingsManager userLocation];
            NSInteger index = [self indexOfRegion:savedRegion];
            if (index >= 0) {
                label.text = regionOptionNames[index];
            }else{
                label.text = @"Unknown";
            }
        }else if (indexPath.row == trackingOptionRow){
            cell = [tableView dequeueReusableCellWithIdentifier:@"trackingCell"];
            UISwitch *uiSwitch = (UISwitch *)[cell viewWithTag:1001];
            uiSwitch.on = [SettingsManager isAnalyticsEnabled];
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (!self.advancedSettingsMode) {
        if (section == advancedSettingSection)
            return 50;
        else if (section == mapSettingsSection && mapSectionNumberOfRows == liveVehiclesRow + 1)
            return 50;
        else
            return 0;
    }else{
        return 100;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == startingTabSection)
        return @"OPEN TAB WHEN APP STARTS";
    
    return @"";
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == advancedModeSection && trackingOptionRow > -1 && self.advancedSettingsMode) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 50)];
        textLabel.font = [textLabel.font fontWithSize:10];
        textLabel.textColor = [UIColor darkGrayColor];
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.text = @"Help Commuter by providing totally anonymous feature usage data that cannot be linked to you in any way";
        
        UIButton *moreInfoButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, 45, 100, 20)];
        moreInfoButton.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 0);
        [moreInfoButton setTitle:@"Learn more" forState:UIControlStateNormal];
        [moreInfoButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [moreInfoButton addTarget:self action:@selector(showTrackingInfoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        moreInfoButton.tintColor = [AppManager systemGreenColor];
        [moreInfoButton setTitleColor:[AppManager systemGreenColor] forState:UIControlStateNormal];
        [view addSubview:moreInfoButton];
        
        [view addSubview:textLabel];
        
        return view;
    }else if (section == mapSettingsSection && mapSectionNumberOfRows == liveVehiclesRow + 1){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 50)];
        textLabel.font = [textLabel.font fontWithSize:10];
        textLabel.textColor = [UIColor darkGrayColor];
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.text = @"Only disables live vehicles on the 'Map' tab. Live vehicles will still be shown on routes and lines.";
        
        [view addSubview:textLabel];
        
        return view;
    }
    
    return nil;
}

#pragma mark - IBActions
- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [delegate settingsValueChanged];
    }];
}

- (IBAction)showTrackingInfoButtonPressed:(id)sender{
    [self performSegueWithIdentifier:@"showTrackingInfo" sender:self];
}

- (IBAction)mapModeChanged:(id)sender {
    UISegmentedControl *segmentCont = (UISegmentedControl *)sender;
    [settingsManager setMapMode:(MapMode)segmentCont.selectedSegmentIndex];
    [mainTableView reloadData];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionChangedMapMode label:nil value:nil];
}

- (IBAction)startingTabIndexChanged:(id)sender {
    UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
    if (segmentControl) {
        [SettingsManager setStartingIndexTab:segmentControl.selectedSegmentIndex];
        
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionChangedStartingTabOption label:[NSString stringWithFormat:@"%d", (int)segmentControl.selectedSegmentIndex] value:nil];
    }
}

- (IBAction)showWalkingRadiusSwitchValueChanged:(id)sender {
    UISwitch *uiSwith = (UISwitch *)sender;
    SettingsManager.showWalkingRadius = uiSwith.isOn;
    [mainTableView reloadData];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionChangedShowWalkingRadiusOption label:uiSwith.isOn ? @"On" : @"Off" value:nil];
}

- (IBAction)showLiveVehicleSwitchValueChanged:(id)sender {
    UISwitch *uiSwith = (UISwitch *)sender;
    settingsManager.showLiveVehicles = uiSwith.isOn;
    [mainTableView reloadData];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionChangedLiveVehicleOption label:uiSwith.isOn ? @"On" : @"Off" value:nil];
}

- (IBAction)historyClearingSwitchValueChanged:(id)sender {
    UISwitch *uiSwith = (UISwitch *)sender;
    settingsManager.isClearingHistoryEnabled = uiSwith.isOn;
    [mainTableView reloadData];
}

- (IBAction)featureTrackingOptionChanged:(id)sender {
    UISwitch *uiSwith = (UISwitch *)sender;
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionChangedAnalyticsOption label:uiSwith.isOn ? @"On" : @"Off" value:nil];
    
    SettingsManager.isAnalyticsEnabled = uiSwith.isOn;
}

- (IBAction)rateAppCellPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager appAppstoreRateLink]]];
}

#pragma mark - tone selector view controller delegate

-(void)selectedTone:(NSString *)selectedTone{
    [self.settingsManager setToneName:selectedTone];
}

#pragma mark - Single select table view delegate methods

-(NSArray *)dataListForSelectorForViewControllerIndex:(NSInteger)viewControllerIndex{
    if (viewControllerIndex == kHistoryCleaningDaysSelectionViewControllerTag) {
        return [self constructHistoryDatesArray];
    }else{
        return [self constructLocationsArray];
    }
}

-(void)selectedIndex:(NSInteger)selectedIndex senderViewControllerIndex:(NSInteger)viewControllerIndex{
    if (viewControllerIndex == kHistoryCleaningDaysSelectionViewControllerTag) {
        [settingsManager setNumberOfDaysToKeepHistory:[dayNumbers[selectedIndex] intValue]];
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionChangedHistoryCleaningDay label:dayStrings[selectedIndex] value:nil];
    }else{
        NSNumber *selectedRegionNumber = regionOptionNumbers[selectedIndex];
        [settingsManager setUserLocation:(Region)[selectedRegionNumber intValue]];
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionChangedUserLocation label:nil value:nil];
    }
}

-(NSInteger)alreadySelectedIndexForViewControllerIndex:(NSInteger)viewControllerIndex{
    if (viewControllerIndex == kHistoryCleaningDaysSelectionViewControllerTag) {
        int savedValue = [settingsManager numberOfDaysToKeepHistory];
        return [self indexForDayFromDayNumbers:savedValue];
    }else{
        Region savedRegion = [settingsManager userLocation];
        return [self indexOfRegion:savedRegion] >= 0 ? [self indexOfRegion:savedRegion] : 0 ;
    }
    
    return 0;
}

-(NSString *)viewControllerTitleForViewControllerIndex:(NSInteger)viewControllerIndex{
    return @"";
}

#pragma mark - helper methods
-(NSArray *)constructLocationsArray{
    
    NSMutableArray *regionsData = [@[] mutableCopy];
    for (int i = 0; i < regionOptionNumbers.count; i++) {
        [regionsData addObject:[NSMutableDictionary dictionaryWithObjects:@[regionOptionNumbers[i], regionOptionNames[i], regionIncludingCities[i]] forKeys:@[kSSDataValueKey, kSSDataDisplayTextKey,kSSDataSubtitleTextKey]]];
    }
    
    return regionsData;
}

-(NSArray *)constructHistoryDatesArray{
    
    NSMutableArray *daysData = [@[] mutableCopy];
    for (int i = 0; i < dayNumbers.count; i++) {
        [daysData addObject:[NSMutableDictionary dictionaryWithObjects:@[dayNumbers[i], dayStrings[i]] forKeys:@[kSSDataValueKey, kSSDataDisplayTextKey]]];
    }
    
    return daysData;
}

-(NSInteger)indexForDayFromDayNumbers:(int)day{
    for (int i = 0; i < dayNumbers.count; i++) {
        if ([dayNumbers[i] intValue] == day)
            return i;
    }
    
    return 0;
}

-(NSInteger)indexOfRegion:(Region)region{
    for (int i = 0; i < regionOptionNumbers.count; i++) {
        if ([regionOptionNumbers[i] intValue] == region)
            return i;
    }
    
    return -1;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectMaxHistoryDate"]) {
        
        SingleSelectTableViewController *controller = (SingleSelectTableViewController *)[segue destinationViewController];
        
        controller.singleSelectTableViewControllerDelegate = self;
        controller.viewControllerIndex = kHistoryCleaningDaysSelectionViewControllerTag;
    }
    
    if ([segue.identifier isEqualToString:@"selectRegion"]) {
        SingleSelectTableViewController *controller = (SingleSelectTableViewController *)[segue destinationViewController];
        
        controller.singleSelectTableViewControllerDelegate = self;
        controller.viewControllerIndex = kUserLocationRegionSelectionViewControllerTag;
    }
    
//    if ([segue.identifier isEqualToString:@"widgetSettings"]) {
//        WidgetSettingsViewController *controller = (WidgetSettingsViewController *)[segue destinationViewController];
//        
//        controller.savedStops = [NSMutableArray arrayWithArray:[self.settingsManager.reittiDataManager fetchAllSavedStopsFromCoreData]];
//    }
    
    if ([segue.identifier isEqualToString:@"setRouteSearchOptions"]) {
        RouteOptionsTableViewController *controller = (RouteOptionsTableViewController *)[segue destinationViewController];
        controller.globalSettingsMode = YES;
        controller.settingsManager = self.settingsManager;
    }
    
    if ([segue.identifier isEqualToString:@"selectNotificationTone"]) {
        ToneSelectorTableViewController *toneSelectorController = (ToneSelectorTableViewController *)[segue destinationViewController];
        
        toneSelectorController.delegate = self;
        toneSelectorController.selectedTone = [settingsManager toneName];
    }
    
    if ([segue.identifier isEqualToString:@"showAdvancedSettings"]) {
        SettingsViewController *settingsController = (SettingsViewController *)[segue destinationViewController];
        
        settingsController.advancedSettingsMode = YES;
        settingsController.settingsManager = self.settingsManager;
    }
    
    if ([segue.identifier isEqualToString:@"showTrackingInfo"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        WebViewController *webViewController = (WebViewController *)[navController.viewControllers lastObject];
        NSURL *url = [NSURL URLWithString:kFeatureTrackingUrl];
        
        webViewController.modalMode = YES;
        webViewController._url = url;
        webViewController._pageTitle = @"FEATURE TRACKING";
        webViewController.bottomContentOffset = 80.0;
    }
    
    self.title = @"";

}


@end
