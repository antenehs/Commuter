//
//  RemindersTableViewController.m
//  
//
//  Created by Anteneh Sahledengel on 11/7/15.
//
//

#import "RemindersTableViewController.h"
#import "ReittiStringFormatter.h"
#import "ReittiNotificationHelper.h"
#import "AMBlurView.h"
#import "EditReminderTableViewController.h"

@interface RemindersTableViewController ()

@end

@implementation RemindersTableViewController

@synthesize savedRoutines;
@synthesize remindersManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initManager];
//    [self.remindersManager deleteAllSavedRoutines];
    [self fetchSavedData];
    [self.tableView reloadData];
    
    [self setTableBackgroundView];
    
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIImage *image1 = [UIImage imageNamed:@"add-button-white.png"];
    UIButton *addbutton = [[UIButton alloc] initWithFrame:frame];
    [addbutton setBackgroundImage:image1 forState:UIControlStateNormal];

    [addbutton addTarget:self action:@selector(addReminderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem* addBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addbutton];
    
    self.navigationItem.rightBarButtonItem = addBarButtonItem;
    
    notificationIsAllowed = [self isNotificationsEnabled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [self fetchSavedData];
    
    [self.navigationItem setTitle:@"ROUTINES"];
    
    notificationIsAllowed = [self isNotificationsEnabled];
    [self.tableView reloadData];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    notificationIsAllowed = [self isNotificationsEnabled];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initManager{
    self.remindersManager = [ReittiRemindersManager sharedManger];
}

-(void)fetchSavedData{
    self.savedRoutines = [[remindersManager fetchAllSavedRoutinesFromCoreData] mutableCopy];
    if (self.savedRoutines == nil) {
        self.savedRoutines = [@[] mutableCopy];
    }
}

#pragma mark - view methods
- (void)setUpToolbar{
    NSArray *toolbarItems =
    [NSArray arrayWithObjects:self.editButtonItem,nil];
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = toolbarItems;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([self isNotificationsEnabled]) {
        return savedRoutines.count > 0 ? savedRoutines.count : 1;
    }else{
        return savedRoutines.count > 0 ? savedRoutines.count + 1 : 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
//    if (indexPath.section == 0) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"addReminderCell" forIndexPath:indexPath];
//    }else{
//        
//    }
    BOOL notifEnabled = [self isNotificationsEnabled];
    
    NSInteger indexRow = [self dataIndexRowForTableIndexPath:indexPath];
    
    if (!notifEnabled && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"notificationDiabledCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if (savedRoutines.count == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"addRoutinesCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        RoutineEntity *routine = [self.savedRoutines objectAtIndex:indexRow];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"reminderCell" forIndexPath:indexPath];
        UILabel *toLabel = (UILabel *)[cell viewWithTag:2002];
        UILabel *fromLabel = (UILabel *)[cell viewWithTag:2003];
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:2004];
        UILabel *repeatsLabel = (UILabel *)[cell viewWithTag:2005];
        UISwitch *enableSwitch = (UISwitch *)[cell viewWithTag:2006];
        
        toLabel.text = routine.toDisplayName;
        fromLabel.text = routine.fromDisplayName;
        timeLabel.text = [ReittiStringFormatter formatHourStringFromDate:routine.routeDate];
        repeatsLabel.text = [NSString stringWithFormat:@"%@", routine.dayNames];
        enableSwitch.on = routine.isEnabled;
        if (enableSwitch.on) {
            cell.backgroundColor = [UIColor whiteColor];
            enableSwitch.layer.borderWidth = 0;
        }else{
            cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            enableSwitch.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            enableSwitch.layer.borderWidth = 2;
            enableSwitch.layer.cornerRadius = 15.5;
        }
    }
    
    // Configure the cell...
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self isNotificationsEnabled] && indexPath.row == 0) {
        return 80;
    }
    return 120;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return self.savedRoutines.count > 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [remindersManager deleteSavedRoutine:[savedRoutines objectAtIndex:[self dataIndexRowForTableIndexPath:indexPath]]];
        [savedRoutines removeObjectAtIndex:[self dataIndexRowForTableIndexPath:indexPath]];
        if (savedRoutines.count != 0) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [self.tableView reloadData];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - IB Actions
- (IBAction)enableReminderSwitchChanged:(id)sender {
    UISwitch *enableSwitch = (UISwitch *)sender;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    RoutineEntity *affectedRoutine = [savedRoutines objectAtIndex:[self dataIndexRowForTableIndexPath:indexPath]];
    [self setEnabledRoutine:affectedRoutine enabled:enableSwitch.on];
    
    [self.tableView reloadData];
}

- (IBAction)addReminderButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"addReminder" sender:self];
}

- (IBAction)openSettingsButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - Private helpers
- (void)setEnabledRoutine:(RoutineEntity *)routine enabled:(bool)enabled{
    routine.isEnabled = enabled;
    [remindersManager saveRoutineToCoreData:routine];
}

- (BOOL)isNotificationsEnabled {
    return [[ReittiRemindersManager sharedManger] isLocalNotificationEnabled];
}

-(NSInteger)dataIndexRowForTableIndexPath:(NSIndexPath *)indexPath{
    return [self isNotificationsEnabled] ? indexPath.row : indexPath.row - 1;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"editReminder"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        
        EditReminderTableViewController *editViewController = (EditReminderTableViewController *)[navController.viewControllers lastObject];
        
        NSIndexPath *selectedCellPath = [self.tableView indexPathForSelectedRow];
        
        editViewController.routine = [self.savedRoutines objectAtIndex:selectedCellPath.row];
    }
    
    [self.navigationItem setTitle:@""];
}


@end
