//
//  EditAddressTableViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "EditAddressTableViewController.h"

@interface EditAddressTableViewController ()

@end

@implementation EditAddressTableViewController

@synthesize addressDictionary;
@synthesize isNewAddress;
@synthesize name, address;
@synthesize reittiDataManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hasAddress = false;
    self.tableView.separatorColor = [UIColor clearColor];
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
    if (hasAddress) {
        return 3;
    }
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
        
        UIView * imageViewContainer = [cell viewWithTag:1001];
        imageViewContainer.layer.cornerRadius = imageViewContainer.frame.size.width/2;
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1002];
        [imageView setImage:[UIImage imageNamed:[self.addressDictionary objectForKey:@"Picture"]]];
        
        UITextView *nameTextView = (UITextView *)[cell viewWithTag:1003];
        [nameTextView setText:[self.addressDictionary objectForKey:@"Name"]];
    }
    
    if (indexPath.row == 1) {
        if (hasAddress) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell" forIndexPath:indexPath];
            UILabel *addressLabel = (UILabel *)[cell viewWithTag:2001];
            addressLabel.text = self.address;
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"editAddressCell" forIndexPath:indexPath];
            UIButton *editAddressButton = (UIButton *)[cell viewWithTag:3001];
            [editAddressButton setTitle:@"Set Address" forState:UIControlStateNormal];
        }
    }
    
    if (indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"editAddressCell" forIndexPath:indexPath];
        UIButton *editAddressButton = (UIButton *)[cell viewWithTag:3001];
        [editAddressButton setTitle:@"Change Address" forState:UIControlStateNormal];
    }
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(20, cell.frame.size.height - 0.5, cell.frame.size.width - 20, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:line];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 120;
    }else if(indexPath.row == 1){
        if (hasAddress)
            return 100;
        else
            return 54;
    }else{
        return 54;
    }
}

#pragma mark - address search delegates
-(void)searchResultSelectedAGeoCode:(GeoCode *)geoCode{
    self.address = [NSString stringWithFormat:@"%@,\n%@, Finland", [geoCode getStreetAddressString], [geoCode city]];
    hasAddress = YES;
    [self.tableView reloadData];
}

-(void)searchResultSelectedAStop:(StopEntity *)stopEntity{
    //TODO - Do a reverse GEO from coordinates
    hasAddress = YES;
    [self.tableView reloadData];
}

-(void)searchResultSelectedCurrentLocation{
    //TODO - Do a reverse GEO from coordinates
    hasAddress = YES;
    [self.tableView reloadData];
}

-(void)searchViewControllerWillBeDismissed:(NSString *)prevSearchTerm{
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"setAddress"]) {
        UINavigationController * navigationController = (UINavigationController *)[segue destinationViewController];
        
        AddressSearchViewController *addressSearchViewController = (AddressSearchViewController *)[navigationController.viewControllers lastObject];
        
        addressSearchViewController.routeSearchMode = YES;
        addressSearchViewController.darkMode = YES;
        addressSearchViewController.reittiDataManager = self.reittiDataManager;
        addressSearchViewController.delegate = self;
    }
}


@end
