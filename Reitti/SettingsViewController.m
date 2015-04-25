//
//  SettingsViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "SettingsViewController.h"
#import "RettiDataManager.h"
#import "WidgetSettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize mapRegion;
@synthesize settingsManager;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self InitMap];
    mainTableView.backgroundColor = [UIColor clearColor];
    
    historyTimeInDays = [self constructHistoryDatesArray];
    regions = [self constructLocationsArray];
    
    [mainTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [mainTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - mapView methods
-(void)InitMap{
    
    if (self.mapRegion.center.latitude == 0) {
        CLLocationCoordinate2D coord = {.latitude =  60.1674322, .longitude =  24.9137306};
        MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
        MKCoordinateRegion region = {coord, span};
        mapRegion = region;
    }
    
    [backgroundMapView setRegion:mapRegion animated:NO];
}


#pragma - mark table view methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        return 1;
    }else if (section == 2) {
        return 1;
    }else if (section == 3) {
        return 2;
    }else if (section == 4) {
        return 1;
    }else{
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    //mapModeCell;clearHistoryCell;clearHistoryDateCell;locationCell;widgetSettingCell
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"mapModeCell"];
        UISegmentedControl *segmentCtrl = (UISegmentedControl *)[cell viewWithTag:1001];
        segmentCtrl.selectedSegmentIndex = [self.settingsManager getMapMode];
    }else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"widgetSettingCell"];
    }else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
        NSDictionary *dict = [regions objectAtIndex:[settingsManager userLocation]];
        UILabel *label = (UILabel *)[cell viewWithTag:1001];
        label.text = [dict objectForKey:@"DisplayText"];
    }else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"clearHistoryCell"];
            UISwitch *uiSwitch = (UISwitch *)[cell viewWithTag:1001];
            uiSwitch.on = [settingsManager isClearingHistoryEnabled];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"clearHistoryDateCell"];
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:1001];
            UILabel *selectedLabel = (UILabel *)[cell viewWithTag:1002];
            
            switch ([settingsManager numberOfDaysToKeepHistory]) {
                case 30:
                    selectedLabel.text = @"30 days";
                    break;
                    
                case 90:
                    selectedLabel.text = @"3 month";
                    break;
                    
                case 180:
                    selectedLabel.text = @"6 month";
                    break;
                    
                case 360:
                    selectedLabel.text = @"1 year";
                    break;
                default:
                    break;
            }
            
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
    }else if (indexPath.section == 4){
        cell = [tableView dequeueReusableCellWithIdentifier:@"rateAppCell"];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"versionInfoCell"];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1 || section == 2) {
        return 70;
    }else if(section == 4){
        return 50;
    }else
        return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, mainTableView.frame.size.width - 20, 35)];
        label.text = @"Restricts address searches to the selected area. Will be updated automatically when moving to another area.";
        label.numberOfLines = 3;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-light" size:12];
        
        return label;
    }else if (section == 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, mainTableView.frame.size.width - 20, 55)];
        label.text = @"Setup the stops that will be displayed in the Departures Widget in notification center. Note that this feature is available only in iOS 8 and above.";
        label.numberOfLines = 4;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-light" size:12];
        
        return label;
    }else if (section == 4) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, mainTableView.frame.size.width - 20, 55)];
        label.text = @"The gift of 5 little starts is satisfying for both of us more than you think. ";
        label.numberOfLines = 4;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-light" size:12];
        
        return label;
    }else{
        return nil;
    }
}

#pragma mark - IBOutlets
- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [delegate settingsValueChanged];
    }];
}

- (IBAction)mapModeChanged:(id)sender {
    UISegmentedControl *segmentCont = (UISegmentedControl *)sender;
    [settingsManager setMapMode:(MapMode)segmentCont.selectedSegmentIndex];
    [mainTableView reloadData];
   
    switch ([settingsManager getMapMode]) {
        case StandartMapMode:
            backgroundMapView.mapType = MKMapTypeStandard;
            break;
            
        case HybridMapMode:
            backgroundMapView.mapType = MKMapTypeHybrid;
            break;
            
        case SateliteMapMode:
            backgroundMapView.mapType = MKMapTypeSatellite;
            break;
            
        default:
            break;
    }
}

- (IBAction)historyClearingSwitchValueChanged:(id)sender {
    UISwitch *uiSwith = (UISwitch *)sender;
    [settingsManager enableClearingOldHistory:uiSwith.isOn];
    [mainTableView reloadData];
}

- (IBAction)rateAppCellPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id861274235"]];
}


#pragma mark - helper methods
-(NSArray *)constructLocationsArray{
    
    NSMutableDictionary *hslRegion = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:HSLRegion] forKey:@"region"];
    [hslRegion setObject:@"Helsinki Region" forKey:@"DisplayText"];
    [hslRegion setObject:@"Includes municipalities Helsinki, Espoo, Vantaa, Kauniainen, Kerava, Kirkkonummi and Sipoo." forKey:@"FooterText"];
    
    NSMutableDictionary *treRegion = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:TRERegion] forKey:@"region"];
    [treRegion setObject:@"Tampere Region" forKey:@"DisplayText"];
    [treRegion setObject:@"Includes municipalities Tampere, Pirkkala, Nokia, Kangasala, Lempäälä, Ylöjärvi, Vesijärvi and Orivesi" forKey:@"FooterText"];
    
    return [NSArray arrayWithObjects:hslRegion,treRegion, nil];
    
}

-(NSArray *)constructHistoryDatesArray{
    
    NSMutableDictionary *days_30 = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:30] forKey:@"numOfDays"];
    [days_30 setObject:@"30 days" forKey:@"DisplayText"];
    
    NSMutableDictionary *days_90 = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:90] forKey:@"numOfDays"];
    [days_90 setObject:@"3 months" forKey:@"DisplayText"];
    
    NSMutableDictionary *days_180 = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:180] forKey:@"numOfDays"];
    [days_180 setObject:@"6 months" forKey:@"DisplayText"];
    
    NSMutableDictionary *days_360 = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:360] forKey:@"numOfDays"];
    [days_360 setObject:@"1 year" forKey:@"DisplayText"];
    
    return [NSArray arrayWithObjects:days_30,days_90,days_180,days_360, nil];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectMaxHistoryDate"]) {
        
        SettingDetailedViewController *controller = (SettingDetailedViewController *)[segue destinationViewController];
        
        controller.dataToLoad = historyTimeInDays;
        controller.viewControllerMode = ViewControllerModeSelectHistoryTime;
        controller.mapRegion = self.mapRegion;
        
        int selectedIndex = 0;
        if ([settingsManager numberOfDaysToKeepHistory] == 30) {
            selectedIndex = 0;
        }else if ([settingsManager numberOfDaysToKeepHistory] == 90) {
            selectedIndex = 1;
        }else if ([settingsManager numberOfDaysToKeepHistory] == 180) {
            selectedIndex = 2;
        }else{
            selectedIndex = 3;
        }
        
        controller.selectedIndex = selectedIndex;
        controller.settingsManager = settingsManager;
    }
    
    if ([segue.identifier isEqualToString:@"selectRegion"]) {
        SettingDetailedViewController *controller = (SettingDetailedViewController *)[segue destinationViewController];
        
        controller.dataToLoad = regions;
        controller.viewControllerMode = ViewControllerModeRegionSelection;
        controller.mapRegion = self.mapRegion;
        controller.selectedIndex = [settingsManager userLocation];
        controller.settingsManager = settingsManager;
    }
    
    if ([segue.identifier isEqualToString:@"widgetSettings"]) {
        WidgetSettingsViewController *controller = (WidgetSettingsViewController *)[segue destinationViewController];
        
        controller.savedStops = [NSMutableArray arrayWithArray:[self.settingsManager.reittiDataManager fetchAllSavedStopsFromCoreData]];
    }
}


@end
