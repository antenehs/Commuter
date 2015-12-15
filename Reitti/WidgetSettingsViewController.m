//
//  WidgetSettingsViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/11/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "WidgetSettingsViewController.h"
#import "StopEntity.h"
#import "AppManager.h"

@interface WidgetSettingsViewController ()

@end

@implementation WidgetSettingsViewController

@synthesize savedStops, selectedStops, unselectedStops;
@synthesize tableView;
@synthesize widgetUserDefaults;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.toolbar.hidden = YES;
//    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    
    if (![self isModalMode]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if (self.savedStops == nil || self.savedStops.count < 1) {
        infoLabel.hidden = NO;
        tableView.hidden = YES;
    }else{
        infoLabel.hidden = YES;
        tableView.hidden = NO;
        
        [bluredBackView setFrame:self.tableView.frame];
        self.tableView.backgroundView = bluredBackView;
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.rowHeight = 56;
        
        selectedStops = [@[] mutableCopy];
        unselectedStops = [@[] mutableCopy];
        [self initUserDefaults];
        [self readSelectedStops];
    }
}

-(BOOL)isModalMode{
    return self.tabBarController == nil;
}

- (void)initUserDefaults{
//    self.widgetUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ewketApps.commuterDepartures"];
    self.widgetUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuitNameForDeparturesWidget];
}

-(void)readSelectedStops{
    if (self.savedStops == nil) {
        return;
    }
    
    [selectedStops removeAllObjects];
    [unselectedStops removeAllObjects];
    
    NSString *selectedCodes = [self.widgetUserDefaults objectForKey:@"SelectedStopCodes"];
    
    BOOL thereIsSelectedStops = selectedCodes != nil;
    
    if (selectedCodes == nil || [selectedCodes isEqualToString:@""]) {
        selectedCodes = [self.widgetUserDefaults objectForKey:@"StopCodes"];
    }
    
    if (selectedCodes == nil || self.savedStops == nil || [selectedCodes isEqualToString:@""])
        return;
    
    NSArray *codes = [selectedCodes componentsSeparatedByString:@","];
    NSArray *selected = [codes subarrayWithRange:NSMakeRange(0, codes.count >= 3 ? 3 : codes.count)];
    
    NSMutableArray * tempArr = [NSMutableArray arrayWithArray:self.savedStops];
    
    for (NSString * code  in selected){
        NSUInteger idx = [tempArr indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
            return [[(StopEntity *)obj busStopCode] intValue] == [code intValue];
        }];
        if (idx != NSNotFound){
            [self.selectedStops addObject:[tempArr objectAtIndex:idx]];
            [tempArr removeObjectAtIndex:idx];
        }
        
    }
    
    if (thereIsSelectedStops && self.selectedStops.count == 0) {
        [self.selectedStops addObject:[tempArr firstObject]];
        [tempArr removeObjectAtIndex:0];
    }
    
    [self.unselectedStops addObjectsFromArray:tempArr];
    
    [self updateUserDefaultsForSelectedStops:self.selectedStops];
    
}

-(void)updateUserDefaultsForSelectedStops:(NSArray *)selected{
    NSString *codes = [[NSString alloc] init];
    
    BOOL firstElement = YES;
    for (StopEntity *stop in selected) {
        if (firstElement) {
            codes = [NSString stringWithFormat:@"%d",[stop.busStopCode intValue]];
            firstElement = NO;
        }else{
            codes = [NSString stringWithFormat:@"%@,%d",codes, [stop.busStopCode intValue]];
        }
    }
    
    [self.widgetUserDefaults setObject:codes forKey:@"SelectedStopCodes"];
    [self.widgetUserDefaults synchronize];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ibactions
- (IBAction)addRemoveButtonPressed:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        if (indexPath.section == 0) {
            //Remove from selected
            [unselectedStops addObject:[selectedStops objectAtIndex:indexPath.row]];
            [selectedStops removeObjectAtIndex:indexPath.row];
        }else{
            //Add to selected
            [selectedStops addObject:[unselectedStops objectAtIndex:indexPath.row]];
            [unselectedStops removeObjectAtIndex:indexPath.row];
        }
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
        [self updateUserDefaultsForSelectedStops:self.selectedStops];
    }
}
- (IBAction)doneButtonSelected:(id)sender {
    [self updateUserDefaultsForSelectedStops:self.selectedStops];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - table view methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return selectedStops.count;
    }else{
        return unselectedStops.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [thisTableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
    
    StopEntity *stop;
    if (indexPath.section == 0) {
        stop = [selectedStops objectAtIndex:indexPath.row];
        UIButton *button = (UIButton *)[cell viewWithTag:1003];
        [button setImage:[UIImage imageNamed:@"removeIcon-red.png"] forState:UIControlStateNormal];
        
        if (selectedStops.count < 2) {
            button.enabled = NO;
        }else{
            button.enabled = YES;
        }
        
    }else{
        stop = [unselectedStops objectAtIndex:indexPath.row];
        UIButton *button = (UIButton *)[cell viewWithTag:1003];
        [button setImage:[UIImage imageNamed:@"addIcon-green.png"] forState:UIControlStateNormal];
        
        if (selectedStops.count > 2) {
            button.enabled = NO;
        }else{
            button.enabled = YES;
        }
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1001];
    titleLabel.text = stop.busStopName;
    
    UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:1002];
    subtitleLabel.text = [NSString stringWithFormat:@"%@ - %@",stop.busStopShortCode, stop.busStopCity];
    
//    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 50;
    }else
        return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 50;
    }else
        return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 20)];
        label.text = @"  NOT SELECTED STOPS";
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-regular" size:16];
        
        return label;
    }
    
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.tableView.frame.size.width - 20, 45)];
        label.text = @"Departures from these stops will be displayed in the widget. Please note that this feature is available only in iOS 8 and above.";
        label.numberOfLines = 4;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-light" size:12];
        
        return label;
    }else{
        return nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
