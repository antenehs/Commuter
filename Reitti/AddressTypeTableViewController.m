//
//  AddAddressTableViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "AddressTypeTableViewController.h"

@interface AddressTypeTableViewController ()

@property(nonatomic, strong)NSArray * addressTypeList;

@end

@implementation AddressTypeTableViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"AddressTypeList" ofType:@"plist"];
    self.addressTypeList = [NSArray arrayWithContentsOfFile:plistPath];
    
    self.navigationController.toolbar.hidden = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.addressTypeList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressTypeCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
    UILabel *mainLabel = (UILabel *)[cell viewWithTag:1002];
    
    if (indexPath.row < self.addressTypeList.count) {
        NSDictionary *address = [self.addressTypeList objectAtIndex:indexPath.row];
        NSString *imageName = [address objectForKey:@"Picture"];
        NSString *displayName = [address objectForKey:@"Name"];
        
        [imageView setImage:[UIImage imageNamed:imageName]];
        [mainLabel setText:displayName];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismiss completed");
        [delegate selectedAddressType:[self.addressTypeList objectAtIndex:indexPath.row]];
    }];
}

#pragma mark - Actions
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editAddress"]) {
        EditAddressTableViewController *editAddressViewController = (EditAddressTableViewController *)[segue destinationViewController];
        
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        
        editAddressViewController.addressDictionary = [self.addressTypeList objectAtIndex:selectedPath.row];
        editAddressViewController.reittiDataManager = self.reittiDataManager;
    }
}
*/

@end
