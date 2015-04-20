//
//  SettingDetailedViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "SettingDetailedViewController.h"

@interface SettingDetailedViewController ()

@end

@implementation SettingDetailedViewController

@synthesize mapRegion;
@synthesize selectedIndex;
@synthesize viewControllerMode;
@synthesize dataToLoad;
@synthesize settingsManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self InitMap];
    mainTableView.backgroundColor = [UIColor clearColor];
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

#pragma mark - tableview methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (viewControllerMode == ViewControllerModeRegionSelection) {
        return dataToLoad.count;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (viewControllerMode == ViewControllerModeRegionSelection) {
        return 1;
    }else{
        return dataToLoad.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectionCell"];
    UILabel *title = (UILabel *)[cell viewWithTag:1001];
    
    NSDictionary *itemDict;
    
    if (viewControllerMode == ViewControllerModeRegionSelection) {
        itemDict = [dataToLoad objectAtIndex:indexPath.section];
        if (selectedIndex == indexPath.section) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            checkedIndexPath = indexPath;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else{
        itemDict = [dataToLoad objectAtIndex:indexPath.row];
        if (selectedIndex == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            checkedIndexPath = indexPath;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    title.text = [itemDict objectForKey:@"DisplayText"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![checkedIndexPath isEqual:indexPath]) {
        if(checkedIndexPath)
        {
            UITableViewCell* uncheckCell = [tableView
                                            cellForRowAtIndexPath:checkedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if([checkedIndexPath isEqual:indexPath])
        {
            //            self.checkedIndexPath = nil;
        }
        else
        {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            checkedIndexPath = indexPath;
            if (viewControllerMode == ViewControllerModeRegionSelection) {
                [settingsManager setUserLocation:(Region)indexPath.section];
            }else{
                NSDictionary *itemDict = [dataToLoad objectAtIndex:indexPath.row];
                [settingsManager setNumberOfDaysToKeepHistory:[[itemDict objectForKey:@"numOfDays"] intValue]];
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (viewControllerMode == ViewControllerModeRegionSelection) {
        return 50;
    }else
        return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (viewControllerMode == ViewControllerModeRegionSelection) {
        NSDictionary *dict = [dataToLoad objectAtIndex:section ];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, mainTableView.frame.size.width - 20, 35)];
        label.text = [dict objectForKey:@"FooterText"];
        label.numberOfLines = 3;
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
