//
//  SingleSelectTableViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 30/11/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "SingleSelectTableViewController.h"
#import "ASA_Helpers.h"

@implementation SingleSelectTableViewController

@synthesize singleSelectTableViewControllerDelegate;
@synthesize viewControllerIndex;

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self.singleSelectTableViewControllerDelegate respondsToSelector:@selector(viewControllerTitleForViewControllerIndex:)]) {
        [self.navigationItem setTitle:[self.singleSelectTableViewControllerDelegate viewControllerTitleForViewControllerIndex:self.viewControllerIndex]];
    }else{
        [self.navigationItem setTitle:@""];
    }
    
    dataToLoad = [singleSelectTableViewControllerDelegate dataListForSelectorForViewControllerIndex:self.viewControllerIndex];
    
    if ([self.singleSelectTableViewControllerDelegate respondsToSelector:@selector(alreadySelectedIndexForViewControllerIndex:)]) {
        selectedIndex = [self.singleSelectTableViewControllerDelegate alreadySelectedIndexForViewControllerIndex:self.viewControllerIndex];
    }else{
        selectedIndex = 0;
    }
    
    [self setTableBackgroundView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return dataToLoad.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    
//    detailCell
    cell.textLabel.text = [dataToLoad[indexPath.row] objectForKey:@"displayText"];
    if ([dataToLoad[indexPath.row] objectForKey:@"picture"] != nil) {
        cell.imageView.image = [UIImage imageNamed:[dataToLoad[indexPath.row] objectForKey:@"picture"]];
        [cell adjustImageViewSize:CGSizeMake(25, 25)];
    }else{
        cell.imageView.image = nil;
    }
    
    if ([dataToLoad[indexPath.row] objectForKey:@"detail"] != nil) {
        cell.detailTextLabel.text = [dataToLoad[indexPath.row] objectForKey:@"detail"];
    }else{
        cell.detailTextLabel.text = nil;
    }
    
    if (selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor blackColor];
        checkedIndexPath = indexPath;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [singleSelectTableViewControllerDelegate selectedIndex:indexPath.row senderViewControllerIndex:self.viewControllerIndex];
    [self.navigationController popViewControllerAnimated:YES];
//    if (![checkedIndexPath isEqual:indexPath]) {
//        if(checkedIndexPath)
//        {
//            UITableViewCell* uncheckCell = [tableView
//                                            cellForRowAtIndexPath:checkedIndexPath];
//            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
//            uncheckCell.textLabel.textColor = [UIColor darkGrayColor];
//        }
//        
//        if([checkedIndexPath isEqual:indexPath])
//        {
//            //            self.checkedIndexPath = nil;
//        }
//        else
//        {
//            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            cell.textLabel.textColor = [UIColor blackColor];
//            checkedIndexPath = indexPath;
//        }
//    }
}

@end
