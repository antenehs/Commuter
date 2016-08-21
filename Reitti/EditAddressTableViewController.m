//
//  EditAddressTableViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "EditAddressTableViewController.h"
#import "UIScrollView+APParallaxHeader.h"
#import "StopAnnotation.h"
#import "SettingsManager.h"
#import "CoreDataManager.h"

@interface EditAddressTableViewController ()

@end

@implementation EditAddressTableViewController

@synthesize addressTypeDictionary, preSelectType, namedBookmark, geoCode;
@synthesize currentUserLocation, currentLocationGeoCode;
@synthesize iconName;
@synthesize name, streetAddress, fullAddress;
@synthesize reittiDataManager;
@synthesize city, searchedName, coords;
@synthesize viewControllerMode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataManagerIfNull];
    
    self.iconName = @"location-75-red.png";
    self.monochromeIconName = @"location-black-50.png";
    mapView = [[MKMapView alloc] init];
    if (viewControllerMode == ViewControllerModeAddNewAddress) {
        showMap = false;
    }else{
        showMap = YES;
    }
    
    if (viewControllerMode == ViewControllerModeAddNewAddress) {
        //Check if there is a preset address type
        if (preSelectType != nil) {
            self.addressTypeDictionary = [self getTypeDictionaryForName:preSelectType];
            if (self.addressTypeDictionary != nil) {
                self.iconName = [self.addressTypeDictionary objectForKey:@"Picture"] == nil ? @"location-75-red.png" : [self.addressTypeDictionary objectForKey:@"Picture"];
                self.monochromeIconName = [self.addressTypeDictionary objectForKey:@"MonochromePicture"] == nil ? @"location-black-50.png" : [self.addressTypeDictionary objectForKey:@"MonochromePicture"];
            }else{
                [self performSegueWithIdentifier:@"chooseType" sender:self];
            }
        }else
            [self performSegueWithIdentifier:@"chooseType" sender:self];
    }
    
    requestedForSaving = NO;
    [self searchReverseGeocodeForCoordinate:self.currentUserLocation.coordinate];
    
    [self updateViewData];
    
    [self setUpMainView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    [self.tableView reloadData];
//    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, 160);
//    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
//    [self.tableView removeParallaxWithView];
    [self.tableView reloadData];
    [self setUpMapView];
}

- (void)initDataManagerIfNull {
    // Do any additional setup after loading the view.
    
    if (self.reittiDataManager == nil) {
        self.managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
        
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        
        SettingsManager * settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        
        [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
        
//        self.reittiDataManager.reverseGeocodeSearchdelegate = self;
    }
}

- (void)updateViewData {
    if (viewControllerMode == ViewControllerModeAddNewAddress) {
        self.name = [self.addressTypeDictionary objectForKey:@"Name"];
        self.iconName = [self.addressTypeDictionary objectForKey:@"Picture"] == nil ? @"location-75-red.png" : [self.addressTypeDictionary objectForKey:@"Picture"];
        self.monochromeIconName = [self.addressTypeDictionary objectForKey:@"MonochromePicture"] == nil ? @"location-black-50.png" : [self.addressTypeDictionary objectForKey:@"MonochromePicture"];
    }else if (viewControllerMode == ViewControllerModeViewNamedBookmark){
        self.name = self.namedBookmark.name;
        self.streetAddress = self.namedBookmark.streetAddress;
        self.city = self.namedBookmark.city;
        self.coords = self.namedBookmark.coords;
        self.iconName = self.namedBookmark.iconPictureName;
        self.monochromeIconName = self.namedBookmark.monochromeIconName;
        self.searchedName = self.namedBookmark.searchedName;
        
        //In some cases street address could already contain the city name
        if ([self.streetAddress containsString:self.city])
            self.fullAddress = self.streetAddress;
        else
            self.fullAddress = [NSString stringWithFormat:@"%@,\n%@", [self.namedBookmark streetAddress], [self.namedBookmark city]];
    }else if (viewControllerMode == ViewControllerModeViewGeoCode){
        if (self.geoCode.getLocationType == LocationTypePOI)
            self.name = self.geoCode.name;
        else if (self.geoCode.getLocationType == LocationTypeAddress)
            self.name = self.geoCode.name;
        else
            self.name = self.geoCode.name;
        
        self.streetAddress = self.geoCode.getStreetAddressString;
        self.city = self.geoCode.city;
        self.coords = self.geoCode.coords;
        self.iconName = @"location-75-red.png";
        self.monochromeIconName = @"location-black-50.png";
        
        //In some cases street address could already contain the city name
        if ([self.streetAddress containsString:self.city])
            self.fullAddress = self.streetAddress;
        else
            self.fullAddress = [NSString stringWithFormat:@"%@,\n%@", self.streetAddress, self.city];
    }
}

- (void)setUpMainView {
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
    if (viewControllerMode == ViewControllerModeAddNewAddress || viewControllerMode == ViewControllerModeEditAddress) {
        self.navigationItem.rightBarButtonItem.style = UIBarButtonSystemItemDone;
        self.navigationItem.rightBarButtonItem.title = @"Done";
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (viewControllerMode == ViewControllerModeAddNewAddress){
            self.navigationController.navigationBar.topItem.title = @"Add bookmark";
        }else{
            self.navigationController.navigationBar.topItem.title = @"Edit bookmark";
        }
        
        //this is to prevent showing map in at first before setting an address
        if (showMap)
            [self setUpMapView];
        
    }else if(viewControllerMode == ViewControllerModeViewNamedBookmark) {
        self.navigationItem.rightBarButtonItem.title = @"Edit";
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationController.navigationBar.topItem.title = self.name;
        [self setUpMapView];
    }else{
        self.navigationItem.rightBarButtonItem.title = @"Edit";
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationController.navigationBar.topItem.title = self.name;
        [self setUpMapView];
    }
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    if (self.streetAddress == nil) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [self.tableView reloadData];
}

#pragma mark - mapView methods

- (void)setUpMapView{
    
    [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:self.coords]];
    [self plotAnnotation];
    
    [mapView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
//    self.tableView.tableHeaderView = nil;
//    [self.tableView reloadData];
    [self.tableView addParallaxWithView:mapView andHeight:160];
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate{
    
    BOOL toReturn = YES;
    
    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    MKCoordinateRegion region = {coordinate, span};
    
    [mapView setRegion:region animated:YES];
    
    return toReturn;
}

-(void)plotAnnotation{
    
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[StopAnnotation class]]) {
            [mapView removeAnnotation:annotation];
        }
    }
    
    CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:self.coords];
    
    
    StopAnnotation *newAnnotation = [[StopAnnotation alloc] initWithTitle:self.name andSubtitle:self.streetAddress andCoordinate:coordinate];
    
    [mapView addAnnotation:newAnnotation];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *selectedIdentifier = @"selectedLocation";
    if ([annotation isKindOfClass:[StopAnnotation class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:selectedIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:selectedIdentifier];
            annotationView.enabled = YES;
            annotationView.image = [UIImage imageNamed:@"busStopAnnotation.png"];
            [annotationView setFrame:CGRectMake(0, 0, 50, 54)];
            annotationView.centerOffset = CGPointMake(0,-27);
            
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
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
    if (viewControllerMode == ViewControllerModeAddNewAddress) {
        return 2;
    }else if (viewControllerMode == ViewControllerModeEditAddress){
        return 3;
    }else if (viewControllerMode == ViewControllerModeViewNamedBookmark){
        return 3;
    }else if (viewControllerMode == ViewControllerModeViewGeoCode){
        return 4;
    }
    
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(20, cell.frame.size.height - 0.5, cell.frame.size.width - 20, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
        
        //Add top border line
        UIImageView *sepLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 0.5)];
        sepLine.backgroundColor = [UIColor lightGrayColor];
        sepLine.tag = 4003;
        [cell addSubview:sepLine];
        
        UIView * imageViewContainer = [cell viewWithTag:1001];
        imageViewContainer.layer.cornerRadius = imageViewContainer.frame.size.width/2;
        UIButton *button = (UIButton *)[cell viewWithTag:1002];
        [button setImage:[UIImage imageNamed:self.iconName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:self.iconName] forState:UIControlStateDisabled];
        
        if (viewControllerMode == ViewControllerModeAddNewAddress || viewControllerMode == ViewControllerModeEditAddress) {
            button.enabled = YES;
        }else{
            button.enabled = NO;
        }
        
        nameTextView = (UITextField *)[cell viewWithTag:1003];
        nameTextView.delegate = self;
        [nameTextView addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        nameLabel = (UILabel *)[cell viewWithTag:1004];
        
        if (viewControllerMode == ViewControllerModeAddNewAddress || viewControllerMode == ViewControllerModeEditAddress) {
            nameTextView.hidden = NO;
            nameLabel.hidden = YES;
            
            [nameTextView setText:self.name];
            
        }else{
            nameTextView.hidden = YES;
            nameLabel.hidden = NO;
            
            nameLabel.text = self.name;
        }
        //set line frame after cell is dequed
        line.frame = CGRectMake(20, cell.frame.size.height - 0.5, cell.frame.size.width - 20, 0.5);
    }
    
    if (indexPath.row == 1) {
        if (self.fullAddress != nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell" forIndexPath:indexPath];
            UILabel *cellTitle = (UILabel *)[cell viewWithTag:2002];
            cellTitle.hidden = NO;
            UILabel *addressLabel = (UILabel *)[cell viewWithTag:2001];
            addressLabel.hidden = NO;
            addressLabel.text = self.fullAddress;
            
            UIButton *editAddressButton = (UIButton *)[cell viewWithTag:2003];
            editAddressButton.hidden = YES;
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell" forIndexPath:indexPath];
            UILabel *cellTitle = (UILabel *)[cell viewWithTag:2002];
            cellTitle.hidden = YES;
            UILabel *addressLabel = (UILabel *)[cell viewWithTag:2001];
            addressLabel.hidden = YES;
            
            UIButton *editAddressButton = (UIButton *)[cell viewWithTag:3001];
            editAddressButton.hidden = NO;
            [editAddressButton setTitle:@"Set Address" forState:UIControlStateNormal];
        }
        
        if (self.viewControllerMode == ViewControllerModeEditAddress || self.viewControllerMode == ViewControllerModeAddNewAddress) {
            tableView.allowsSelection = YES;
        }else{
            tableView.allowsSelection = NO;
        }
        
        //remove previously added line
        for (UIView *view in [cell subviews]) {
            if (view.tag == 4001) {
                [view removeFromSuperview];
            }
        }
        
        //set line frame after cell is dequed
        line.frame = CGRectMake(20, cell.frame.size.height - 0.5, cell.frame.size.width - 20, 0.5);
    }
    
    if (indexPath.row == 2) {
        if (viewControllerMode == ViewControllerModeEditAddress) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"deleteBookmarkCell" forIndexPath:indexPath];
            
            //Add separator line
            UIImageView *sepLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, cell.frame.size.width, 0.5)];
            sepLine.backgroundColor = [UIColor lightGrayColor];
            sepLine.tag = 4002;
            [cell addSubview:sepLine];
            
            line.frame = CGRectMake(0, cell.frame.size.height - 0.5, cell.frame.size.width, 0.5);
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"routesCell" forIndexPath:indexPath];
            line.frame = CGRectMake(20, cell.frame.size.height - 0.5, cell.frame.size.width - 20, 0.5);
        }
    }
    
    if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"addBookmarkCell" forIndexPath:indexPath];
        //set line frame after cell is dequed
        line.frame = CGRectMake(20, cell.frame.size.height - 0.5, cell.frame.size.width - 20, 0.5);
    }
    
    line.tag = 4001;
    [cell addSubview:line];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 100;
    }else if(indexPath.row == 1){
        if (self.fullAddress != nil)
            return 100;
        else
            return 54;
    }else if(indexPath.row == 2){
        if (viewControllerMode == ViewControllerModeEditAddress)
            return 90;
        else
            return 54;
    }else if(indexPath.row == 3){
        return 54;
    }else{
        return 54;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        
    }
    
    if (indexPath.row == 3) {
        [self bookmarkAddressButtonPressed:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((viewControllerMode == ViewControllerModeViewGeoCode || viewControllerMode == ViewControllerModeViewNamedBookmark) && indexPath.row == 1) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.fullAddress;
    }
}

#pragma mark - IB Actions
- (IBAction)routeFromHerePressed:(id)sender {
}

- (IBAction)routeToHerePressed:(id)sender {
}

-(IBAction)bookmarkAddressButtonPressed:(id)sender{
    if (self.viewControllerMode == ViewControllerModeViewGeoCode && self.geoCode != nil) {
        self.viewControllerMode = ViewControllerModeAddNewAddress;
        [self setUpMainView];
        [self performSegueWithIdentifier:@"chooseType" sender:self];
    }
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneOrEditButtonPressed:(id)sender {
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Edit"]) {
        if (viewControllerMode == ViewControllerModeViewNamedBookmark) {
            self.viewControllerMode = ViewControllerModeEditAddress;
            
            [self setUpMainView];
        }
    }else{
        if ([nameTextView.text isEqualToString:@""]){
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"Name field cannot be empty" andContent:nil];
            return;
        }
        
        NamedBookmark *newBookmark = [[NamedBookmark alloc] initWithEntity:[NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.reittiDataManager.managedObjectContext] insertIntoManagedObjectContext:nil];
        newBookmark.name = [nameTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        newBookmark.streetAddress = self.streetAddress;
        newBookmark.city = self.city;
        newBookmark.coords = self.coords;
        newBookmark.iconPictureName = self.iconName;
        newBookmark.monochromeIconName = self.monochromeIconName;
        newBookmark.searchedName = self.searchedName;
        
        BOOL dataSaved = NO;
        
        if (viewControllerMode == ViewControllerModeAddNewAddress) {
            if (![self.reittiDataManager doesNamedBookmarkExistWithName:newBookmark.name]) {
                self.namedBookmark = [self.reittiDataManager saveNamedBookmarkToCoreData:newBookmark];
                dataSaved = YES;
                [self dismissViewControllerAnimated:YES completion:^(){
                    NSArray *allBookmarks = [self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData];
                    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionCreatedNewNamedBookmark label:newBookmark.name value:allBookmarks ? [NSNumber numberWithInteger:allBookmarks.count] : @0];
                }];
            }else{
                [ReittiNotificationHelper showSimpleMessageWithTitle:@"Bookmark with the name exists already" andContent:@"Please give another name."];
            }
        }else if (viewControllerMode == ViewControllerModeEditAddress){
            
            if (self.geoCode != nil) { //IS creating a new named bookmark from GEOCODE
                if ([self.reittiDataManager doesNamedBookmarkExistWithName:newBookmark.name]){
                    [ReittiNotificationHelper showSimpleMessageWithTitle:@"Bookmark with the name exists already" andContent:@"Please give another name."];
                }else{
                    [self.reittiDataManager saveNamedBookmarkToCoreData:newBookmark];
                    dataSaved = YES;
                }
            }else if (self.namedBookmark != nil){ //IS editing an existing named bookmark
                //IF name is not modified, save it silently
                if ([self.namedBookmark.name isEqualToString:newBookmark.name]) {
                    [self.reittiDataManager saveNamedBookmarkToCoreData:newBookmark];
                    self.namedBookmark = newBookmark;
                    dataSaved = YES;
                }else{
                    //name is modified, ask for overwrite confirmation
                    if ([self.reittiDataManager doesNamedBookmarkExistWithName:newBookmark.name]){
                        [ReittiNotificationHelper showSimpleMessageWithTitle:@"Bookmark with the name exists already" andContent:@"Please give another name."];
                    }else{
                        self.namedBookmark = [self.reittiDataManager updateNamedBookmarkToCoreDataWithID:self.namedBookmark.objectLID withNamedBookmark:newBookmark];
                        dataSaved = YES;
                    }
                }
            }
        }
        if (dataSaved) {
            self.viewControllerMode = ViewControllerModeViewNamedBookmark;
            [self updateViewData];
            [self setUpMainView];
        }
    }
}

- (IBAction)deleteBookmarkButtonPressed:(id)sender {
    if (viewControllerMode == ViewControllerModeEditAddress){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete your bookmark?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        actionSheet.tag = 1001;
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1001) {
        if (buttonIndex == 0) {
            if (self.namedBookmark != nil) {
                [self.reittiDataManager deleteNamedBookmarkForName:self.namedBookmark.name];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }else{
        
    }
}

#pragma mark - address search delegates
- (void)setValuesFromGeoCode:(GeoCode *)selectedGeoCode {
    self.fullAddress = [NSString stringWithFormat:@"%@", [selectedGeoCode fullAddressString]];
    self.streetAddress = [selectedGeoCode getStreetAddressString];
    self.city = [selectedGeoCode city];
    self.coords = [selectedGeoCode coords];
    self.searchedName = [selectedGeoCode matchedName];
    //    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    showMap = YES;
    [self setUpMainView];
}

-(void)searchResultSelectedAGeoCode:(GeoCode *)selectedGeoCode{
    [self setValuesFromGeoCode:selectedGeoCode];
}

-(void)searchResultSelectedAStop:(StopEntity *)stopEntity{
    self.fullAddress = [NSString stringWithFormat:@"%@ - %@,\n%@", [stopEntity busStopName], [stopEntity busStopShortCode], [stopEntity busStopCity]];
    self.streetAddress = [NSString stringWithFormat:@"%@ - %@", [stopEntity busStopName], [stopEntity busStopShortCode]];
    self.city = [stopEntity busStopCity];
    self.coords = [stopEntity busStopWgsCoords];
    self.searchedName = [stopEntity busStopName];
//    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    showMap = YES;
    [self setUpMainView];
}

-(void)searchResultSelectedCurrentLocation{
    if (self.currentLocationGeoCode != nil) {
        [self setValuesFromGeoCode:currentLocationGeoCode];
    }else{
        [self searchReverseGeocodeForCoordinate:self.currentUserLocation.coordinate];
        //TODO: Do some indication
        requestedForSaving = YES;
    }
    
    [self.tableView reloadData];
//    self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(void)searchViewControllerDismissedToRouteSearch:(NSString *)prevSearchTerm{
    
}

-(void)searchResultSelectedANamedBookmark:(NamedBookmark *)namedBookmark{
    
}

#pragma mark - reverse geocode search handler methods
- (void)searchReverseGeocodeForCoordinate:(CLLocationCoordinate2D)coordinate{
    [self.reittiDataManager searchAddresseForCoordinate:coordinate withCompletionBlock:^(GeoCode *geocode, NSString *errorString){
        if (!errorString && geocode) {
            [self reverseGeocodeSearchDidComplete:geocode];
        }else{
            [self reverseGeocodeSearchDidFail:errorString];
        }
    }];
}

- (void)reverseGeocodeSearchDidComplete:(GeoCode *)_geoCode{
    currentLocationGeoCode = _geoCode;
    if (requestedForSaving) {
        [self setValuesFromGeoCode:currentLocationGeoCode];
    }
}

- (void)reverseGeocodeSearchDidFail:(NSString *)error{
    if (requestedForSaving)
        [ReittiNotificationHelper showErrorBannerMessage:@"Current location cannot be determined." andContent:nil];
}

#pragma mark - uitextview delegate methods
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

-(void)textFieldDidChange:(UITextField *)textField{
    self.name = textField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Address type selection delegate
-(void)selectedAddressType:(NSDictionary *)stopEntity{
    self.addressTypeDictionary = stopEntity;
    if (viewControllerMode == ViewControllerModeEditAddress) {
        self.iconName = [self.addressTypeDictionary objectForKey:@"Picture"] == nil ? @"location-75-red.png" : [self.addressTypeDictionary objectForKey:@"Picture"];
        self.monochromeIconName = [self.addressTypeDictionary objectForKey:@"MonochromePicture"] == nil ? @"location-black-50.png" : [self.addressTypeDictionary objectForKey:@"MonochromePicture"];
    }else{
        [self updateViewData];
    }
    
    [self.tableView reloadData];
}

-(NSDictionary *)getTypeDictionaryForName:(NSString *)typeName{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"AddressTypeList" ofType:@"plist"];
    NSArray *tempArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    for (NSDictionary *dict in tempArray) {
        if ([[dict objectForKey:@"Name"] isEqualToString:typeName]) {
            return dict;
        }
    }
    
    return nil;
}

- (void)dealloc{
    NSLog(@"EditAddressController:This ARC deleted my UIView.");
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"setAddress"]) {
        UINavigationController * navigationController = (UINavigationController *)[segue destinationViewController];
        
        AddressSearchViewController *addressSearchViewController = (AddressSearchViewController *)[navigationController.viewControllers lastObject];
        
        addressSearchViewController.routeSearchMode = YES;
        addressSearchViewController.simpleSearchMode = YES;
        addressSearchViewController.darkMode = YES;
        addressSearchViewController.reittiDataManager = self.reittiDataManager;
        addressSearchViewController.delegate = self;
        if (self.fullAddress != nil) {
            addressSearchViewController.prevSearchTerm = self.streetAddress;
        }
    }
    
    if ([segue.identifier isEqualToString:@"chooseType"]) {
        UINavigationController * navigationController = (UINavigationController *)[segue destinationViewController];
        
        AddressTypeTableViewController *addressTypeTableViewController = (AddressTypeTableViewController *)[navigationController.viewControllers lastObject];
        
        addressTypeTableViewController.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"routeToHere"] || [segue.identifier isEqualToString:@"routeFromHere"]) {
        UINavigationController * navigationController = (UINavigationController *)[segue destinationViewController];
        
        RouteSearchViewController *routeSearchViewController = (RouteSearchViewController *)[navigationController.viewControllers lastObject];
        
        NSArray * savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
        NSArray * savedRoutes = [self.reittiDataManager fetchAllSavedRoutesFromCoreData];
        NSArray * recentStops = [self.reittiDataManager fetchAllSavedStopHistoryFromCoreData];
        NSArray * recentRoutes = [self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData];
        
        NSArray * namedBookmarks = [self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData];
        
        routeSearchViewController.savedStops = [NSMutableArray arrayWithArray:savedStops];
        routeSearchViewController.recentStops = [NSMutableArray arrayWithArray:recentStops];
        routeSearchViewController.savedRoutes = [NSMutableArray arrayWithArray:savedRoutes];
        routeSearchViewController.recentRoutes = [NSMutableArray arrayWithArray:recentRoutes];
        routeSearchViewController.namedBookmarks = [NSMutableArray arrayWithArray:namedBookmarks];
//        routeSearchViewController.droppedPinGeoCode = self.droppedPinGeoCode;
        if ([segue.identifier isEqualToString:@"routeToHere"]) {
            routeSearchViewController.prevToLocation = self.name;
            routeSearchViewController.prevToCoords = self.coords;
        }
        if ([segue.identifier isEqualToString:@"routeFromHere"]) {
            routeSearchViewController.prevFromLocation = self.name;
            routeSearchViewController.prevFromCoords = self.coords;
        }
        
        routeSearchViewController.reittiDataManager = self.reittiDataManager;
        //        routeSearchViewController.reittiDataManager = self.reittiDataManager;
    }
}


@end
