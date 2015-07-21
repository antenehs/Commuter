//
//  EditReminderTableViewController.m
//  
//
//  Created by Anteneh Sahledengel on 11/7/15.
//
//

#import "EditReminderTableViewController.h"
#import "RettiDataManager.h"
#import "RoutineEntity.h"
#import "CoreDataManager.h"
#import "EnumManager.h"
#import "AppManager.h"

@interface EditReminderTableViewController ()

@property (nonatomic, strong)ReittiRemindersManager *remindersManager;

@end

@implementation EditReminderTableViewController

@synthesize toCoords, toString, toDisplayName, fromCoords, fromString, fromDisplayName, repeatString, selectedDaysList, toneName;
@synthesize managedObjectContext;
@synthesize routine;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
    self.remindersManager = [ReittiRemindersManager sharedManger];
    
    addressRequestedForFrom = NO;
    addressRequestedForTo = NO;
    dateSetOnce = NO;
    
    if (self.routine != nil) {
        self.toString = self.routine.toLocationName;
        self.toCoords = self.routine.toLocationCoords;
        self.toDisplayName = self.routine.toDisplayName;
        self.fromString = self.routine.fromLocationName;
        self.fromCoords = self.routine.fromLocationCoords;
        self.fromDisplayName = self.routine.fromDisplayName;
        self.repeatString = self.routine.dayNames;
        self.selectedDaysList = self.routine.repeatDays;
        self.routineDate = self.routine.routeDate;
        self.toneName = self.routine.toneName;
    }else{
        self.selectedDaysList = [self allDayArray];
        self.routineDate = [NSDate date];
        self.toneName = [AppManager defailtToneName];
    }
    
    [doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setDoneButtonState];
    [self setTableBackgroundView];
}

-(void)viewDidAppear:(BOOL)animated{
    if (self.routine != nil) {
        [self.navigationItem setTitle:@"Edit Routine"];
    }else{
        [self.navigationItem setTitle:@"Add Routine"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTableBackgroundView {
    UIView *bluredBackViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    bluredBackViewContainer.backgroundColor = [UIColor whiteColor];
    UIImageView *mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_background.png"]];
    mapImageView.frame = bluredBackViewContainer.frame;
    mapImageView.alpha = 0.5;
    AMBlurView *blurView = [[AMBlurView alloc] initWithFrame:bluredBackViewContainer.frame];
    
    [bluredBackViewContainer addSubview:mapImageView];
    [bluredBackViewContainer addSubview:blurView];
    
    self.tableView.backgroundView = bluredBackViewContainer;
    self.tableView.backgroundColor = [UIColor clearColor];
}

-(void)setDoneButtonState{
    if (self.toString != nil && self.fromString != nil) {
        doneButton.enabled = YES;
    }else{
        doneButton.enabled = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 2;
    }else{
        return 2;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell" forIndexPath:indexPath];
        datePicker = (UIDatePicker *)[cell viewWithTag:1001];
        
        if (!dateSetOnce) {
            [datePicker setDate:self.routineDate animated:YES];
            dateSetOnce = YES;
        }
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"fromCell" forIndexPath:indexPath];
            UILabel *addressLabel = (UILabel *)[cell viewWithTag:1001];
            if (self.fromString != nil) {
                addressLabel.text = self.fromDisplayName != nil ? self.fromDisplayName : self.fromString;
            }else{
                addressLabel.text = @"address";
            }
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"toCell" forIndexPath:indexPath];
            UILabel *addressLabel = (UILabel *)[cell viewWithTag:1001];
            if (self.toString != nil) {
                addressLabel.text = self.toDisplayName != nil ? self.toDisplayName : self.toString;
            }else{
                addressLabel.text = @"address";
            }
        }
    }else{
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"repeatCell" forIndexPath:indexPath];
            cell.detailTextLabel.text = [ReittiRemindersManager displayStringForSeletedDays:self.selectedDaysList];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"soundCell" forIndexPath:indexPath];
            
            if ([self.toneName isEqualToString:UILocalNotificationDefaultSoundName]) {
                cell.detailTextLabel.text = @"Default iOS sound";
            }else{
                cell.detailTextLabel.text = self.toneName;
            }
        }
    }
    
    // Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 200;
    }else{
        return 44;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


#pragma mark - IB Action
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    if (self.toString != nil && self.fromString != nil) {
        if (self.routine == nil) {
            self.routine = (RoutineEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"RoutineEntity" inManagedObjectContext:self.managedObjectContext];
        }
        
        [self.routine setFromDisplayName: self.fromDisplayName != nil ? self.fromDisplayName : self.fromString ] ;
        self.routine.fromLocationName = self.fromString;
        self.routine.fromLocationCoords = self.fromCoords;
        self.routine.toDisplayName = self.toDisplayName != nil ? self.toDisplayName : self.toString;
        self.routine.toLocationName = self.toString;
        self.routine.toLocationCoords = self.toCoords;
        
        self.routine.routeDate = [datePicker date];
        self.routine.dayNames = [ReittiRemindersManager displayStringForSeletedDays:self.selectedDaysList];
        self.routine.repeatDays = [self selectedDaysList];
        self.routine.isEnabled = YES;
        self.routine.toneName = self.toneName;
        
        //TODO: Check if routine does not exist
        [self.remindersManager saveRoutineToCoreData:routine];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - AddressSearchDelegate
- (void)searchResultSelectedAStop:(StopEntity *)stopEntity{
    NSString *address = nil;
    
    address = [NSString stringWithFormat:@"%@ - %@, %@", [stopEntity busStopName], [stopEntity busStopShortCode], [stopEntity busStopCity]];
    
    if (addressRequestedForFrom) {
        self.fromString = address;
        self.fromDisplayName = address;
        self.fromCoords = stopEntity.busStopCoords;
    }else{
        self.toString = address;
        self.toDisplayName = address;
        self.toCoords = stopEntity.busStopCoords;
    }
    
    [self.tableView reloadData];
    [self setDoneButtonState];
}
- (void)searchResultSelectedAGeoCode:(GeoCode *)geoCode{
    NSString *address = @"Unknown Address";
    
    address = [NSString stringWithFormat:@"%@, %@", [geoCode getStreetAddressString], [geoCode city]];
    
    if (addressRequestedForFrom) {
        self.fromString = address;
        self.fromDisplayName = address;
        self.fromCoords = geoCode.coords;
    }else{
        self.toString = address;
        self.toDisplayName = address;
        self.toCoords = geoCode.coords;
    }
    
    [self.tableView reloadData];
    [self setDoneButtonState];
}
- (void)searchResultSelectedANamedBookmark:(NamedBookmark *)namedBookmark{
    NSString *address = @"Unknown Address";
    
    address = [NSString stringWithFormat:@"%@, %@", [namedBookmark streetAddress], [namedBookmark city]];
    
    if (addressRequestedForFrom) {
        self.fromString = address;
        self.fromDisplayName = namedBookmark.name;
        self.fromCoords = namedBookmark.coords;
    }else{
        self.toString = address;
        self.toDisplayName = namedBookmark.name;
        self.toCoords = namedBookmark.coords;
    }
    
    [self.tableView reloadData];
    [self setDoneButtonState];
}
- (void)searchResultSelectedCurrentLocation{
    //TODO: Test this case letter
    if (addressRequestedForFrom) {
        self.fromString = @"Current location";
        self.fromCoords = @"";
    }else{
        self.toString = @"Current location";
        self.toCoords = @"";
    }
    
    [self.tableView reloadData];
    [self setDoneButtonState];
}
- (void)searchViewControllerWillBeDismissed:(NSString *)prevSearchTerm{
    
}
- (void)searchViewControllerDismissedToRouteSearch:(NSString *)prevSearchTerm{
    
}

#pragma mark - multi select table view controller delegate methods
-(NSArray *)dataListForMultiSelector{
    return [self allDayArray];
}

- (NSArray *)alreadySelectedValues{
    NSMutableArray *tempArray = [@[] mutableCopy];
    for (NSNumber *dayNum in self.selectedDaysList) {
        [tempArray addObject:[EnumManager dayNameForWeekDay:[dayNum intValue]]];
    }
    return tempArray;
}

-(void)selectedList:(NSArray *)selectedList{
    NSMutableArray *tempArray = [@[] mutableCopy];
    for (NSString *dayName in selectedList) {
        [tempArray addObject:[NSNumber numberWithInt:[EnumManager weekDayForDayName:dayName]]];
    }
    
    self.selectedDaysList = tempArray;
    [self.tableView reloadData];
}

#pragma mark - tone selector delegate
- (void)selectedTone:(NSString *)selectedTone{
    
    self.toneName = selectedTone;
    [self.tableView reloadData];
}

#pragma mark - Helpers
-(NSArray *)allDayArray{
    return [ReittiRemindersManager allDayNamesArray];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"searchFromAddress"] || [segue.identifier isEqualToString:@"searchToAddress"]) {
        UINavigationController * navigationController = (UINavigationController *)[segue destinationViewController];
        
        AddressSearchViewController *addressSearchViewController = (AddressSearchViewController *)[navigationController.viewControllers lastObject];
        
        RettiDataManager *dataManager = [[RettiDataManager alloc] init];
        
        addressSearchViewController.routeSearchMode = YES;
        addressSearchViewController.simpleSearchMode = YES;
        addressSearchViewController.reittiDataManager = dataManager;
        addressSearchViewController.delegate = self;
        addressSearchViewController.savedStops = [NSMutableArray arrayWithArray:[dataManager fetchAllSavedStopsFromCoreData]];
        addressSearchViewController.namedBookmarks = [NSMutableArray arrayWithArray:[dataManager fetchAllSavedNamedBookmarksFromCoreData]];
        
        if ([segue.identifier isEqualToString:@"searchFromAddress"]) {
            addressRequestedForFrom = YES;
            addressRequestedForTo = NO;
            
            if (self.fromString != nil) {
                addressSearchViewController.prevSearchTerm = self.fromString;
            }
        }else{
            addressRequestedForFrom = NO;
            addressRequestedForTo = YES;
            
            if (self.toString != nil) {
                addressSearchViewController.prevSearchTerm = self.toString;
            }
        }
    }
    if ([segue.identifier isEqualToString:@"selectDays"]){
        MultiSelectTableViewController *multiSelectTableViewController = (MultiSelectTableViewController *)[segue destinationViewController];
        multiSelectTableViewController.multiSelectTableViewControllerDelegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"selectTone"]) {
        ToneSelectorTableViewController *toneSelectorController = (ToneSelectorTableViewController *)[segue destinationViewController];
        toneSelectorController.delegate = self;
        toneSelectorController.selectedTone = self.toneName;
    }
    
    [self.navigationItem setTitle:@""];
}


@end
