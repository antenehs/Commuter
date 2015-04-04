//
//  RouteOptionsTableViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "RouteOptionsTableViewController.h"

@interface RouteOptionsTableViewController ()

@end

@implementation RouteOptionsTableViewController

@synthesize checkedIndexPath;
@synthesize selectedTimeType, selectedSearchOption, selectedDate;
@synthesize datePicker, timeTypeSegmentControl;
@synthesize routeOptionSelectionDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
//    selectedSearchOption = RouteSearchOptionFastest;
    
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor lightGrayColor];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"timePickerCell"];
        self.datePicker = (UIDatePicker *)[cell viewWithTag:1002];
        [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [datePicker setDate:selectedDate];
        self.timeTypeSegmentControl = (UISegmentedControl *)[cell viewWithTag:1003];
        [self.timeTypeSegmentControl addTarget:self action:@selector(timeTypeChanged:) forControlEvents:UIControlEventValueChanged];
        self.timeTypeSegmentControl.selectedSegmentIndex = (int)selectedTimeType;
    }else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchOptionTitleCell"];
        topLine.frame = CGRectMake(0, 0, cell.frame.size.width, 0.5);
        [cell addSubview:topLine];
        line.frame = CGRectMake(20.0, cell.frame.size.height - 0.5, cell.frame.size.width - 20.0, 0.5);
    }else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchOptionCell"];
        line.frame = CGRectMake(35.0, cell.frame.size.height - 0.5, cell.frame.size.width - 35.0, 0.5);
        cell.textLabel.text = @"    Fastest";
        if (selectedSearchOption == RouteSearchOptionFastest) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            checkedIndexPath = indexPath;
            cell.textLabel.textColor = [UIColor blackColor];
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchOptionCell"];
        line.frame = CGRectMake(35.0, cell.frame.size.height - 0.5, cell.frame.size.width - 35.0, 0.5);
        cell.textLabel.text = @"    Least transfer";
        if (selectedSearchOption == RouteSearchOptionLeastTransfer) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            checkedIndexPath = indexPath;
            cell.textLabel.textColor = [UIColor blackColor];
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }else if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchOptionCell"];
        line.frame = CGRectMake(0.0, cell.frame.size.height - 0.5, cell.frame.size.width, 0.5);
        cell.textLabel.text = @"    Least walking";
        if (selectedSearchOption == RouteSearchOptionLeastWalking) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            checkedIndexPath = indexPath;
            cell.textLabel.textColor = [UIColor blackColor];
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }
    
    // Configure the cell...
    [cell addSubview:line];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        return 248.0;
    }else{
        return 50.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0 && indexPath.row != 1 && ![self.checkedIndexPath isEqual:indexPath]) {
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
            if (indexPath.row == 2) {
                selectedSearchOption = RouteSearchOptionFastest;
            }else if (indexPath.row == 3) {
                selectedSearchOption = RouteSearchOptionLeastTransfer;
            }else if (indexPath.row == 4) {
                selectedSearchOption = RouteSearchOptionLeastWalking;
            }
        }
    }
}
/*
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 10.0;
    }else if (indexPath.row == 2) {
        return 10.0;
    }else{
        return 40.0;
    }
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - IBActions
- (IBAction)doneButtonPressed:(id)sender {
    RouteSearchOptions *searchOptions = [[RouteSearchOptions alloc] init];
    searchOptions.date = datePicker.date;
    searchOptions.selectedTimeType = selectedTimeType;
    searchOptions.routeSearchOption = selectedSearchOption;
    [self dismissViewControllerAnimated:YES completion:^{
            [self.routeOptionSelectionDelegate optionSelectionDidComplete:searchOptions];
    }];
}

- (IBAction)timeTypeChanged:(id)sender {
    selectedTimeType = (int)self.timeTypeSegmentControl.selectedSegmentIndex;
    if (timeTypeSegmentControl.selectedSegmentIndex == 0) {
        [datePicker setDate:[NSDate date]];
    }
}

-(IBAction)dateChanged:(id)sender{
    if (selectedTimeType == SelectedTimeNow) {
        selectedTimeType = SelectedTimeDeparture;
    }
    
    timeTypeSegmentControl.selectedSegmentIndex = (int)selectedTimeType;
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
