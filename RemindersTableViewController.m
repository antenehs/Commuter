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
#import "ReittiDateHelper.h"
#import "Notifications.h"
#import "UITableView+Helper.h"
#import "ASA_Helpers.h"

@interface RemindersTableViewController ()

@property (nonatomic) BOOL isNotificationsEnabled;

@end

@implementation RemindersTableViewController

@synthesize savedRoutines;
@synthesize remindersManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNotificationsEnabled = YES;
    
    [self initManager];
//    [self.remindersManager deleteAllSavedRoutines];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 65.0;
    
    [self.tableView setBlurredBackgroundWithImageNamed:nil];
    
    
    [self updateTableData];
    
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIImage *image1 = [UIImage imageNamed:@"add-button-white.png"];
    UIButton *addbutton = [[UIButton alloc] initWithFrame:frame];
    [addbutton setBackgroundImage:image1 forState:UIControlStateNormal];

    [addbutton addTarget:self action:@selector(addReminderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [addbutton.widthAnchor constraintEqualToConstant:30].active = YES;
    [addbutton.heightAnchor constraintEqualToConstant:30].active = YES;

    UIBarButtonItem* addBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addbutton];
    
    
    self.navigationItem.rightBarButtonItem = addBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationItem setTitle:@"REMINDERS"];
    
    [self updateTableData];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

-(void)updateTableData {
    [self updateNotifEnabledStatus];
    
    [self fetchSavedDataWithCompletion:^{
        [self.tableView reloadData];
    }];
}

- (void)updateSectionNumber {
    routinesSection = departureNotifSection = routeNotifSection = -1;
    routinesSection = 0;
    
    NSInteger index = 0;
    
    departureNotifSection = self.departureNotifications.count > 0 ? ++index : -1;
    routeNotifSection = self.routeNotifications.count > 0 ? ++index : -1;
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    [self updateNotifEnabledStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initManager{
    self.remindersManager = [ReittiRemindersManager sharedManger];
}

-(void)fetchSavedDataWithCompletion:(ActionBlock)completion {
    self.savedRoutines = [[remindersManager fetchAllSavedRoutinesFromCoreData] mutableCopy];
    if (self.savedRoutines == nil) {
        self.savedRoutines = [@[] mutableCopy];
    }
    
    GroupDispatchBlock departureNotifBlock = ^(ActionBlock completed) {
        [remindersManager getAllDepartureNotificationsWithCompletion:^(NSArray *notifs){
            self.departureNotifications = [notifs mutableCopy];
            completed();
        }];
    };
    
    GroupDispatchBlock routeNotifBlock = ^(ActionBlock completed) {
        [remindersManager getAllRouteNotificationsWithCompletion:^(NSArray *notifs){
            self.routeNotifications = [notifs mutableCopy];
            completed();
        }];
    };
    
    [self asa_ExecuteBlocks:@[departureNotifBlock, routeNotifBlock] withCompletion:^{
        completion();
    }];
    
    
    /*
    __block NSInteger requestCalls = 2;
    
    [remindersManager getAllDepartureNotificationsWithCompletion:^(NSArray *notifs){
        requestCalls--;
        
        self.departureNotifications = [notifs mutableCopy];
        
        if (requestCalls == 0)
            completion();
    }];
    
    [remindersManager getAllRouteNotificationsWithCompletion:^(NSArray *notifs){
        requestCalls--;
        
        self.routeNotifications = [notifs mutableCopy];
        
        if (requestCalls == 0)
            completion();
    }];
     */
}

#pragma mark - view methods
- (void)setUpToolbar{
    NSArray *toolbarItems =
    [NSArray arrayWithObjects:self.editButtonItem,nil];
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = toolbarItems;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1 + (self.departureNotifications.count > 0 ? 1 : 0) + (self.routeNotifications.count > 0 ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    [self updateSectionNumber];
    if (section == routinesSection) {
        if ([self isNotificationsEnabled]) {
            return savedRoutines.count > 0 ? savedRoutines.count : 1;
        }else{
            return savedRoutines.count > 0 ? savedRoutines.count + 1 : 2;
        }
    } else if ( section == departureNotifSection) {
        return self.departureNotifications.count;
    } else {
        return self.routeNotifications.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    BOOL notifEnabled = [self isNotificationsEnabled];
    
    if (indexPath.section == routinesSection) {
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
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"routineCell" forIndexPath:indexPath];
            UILabel *toLabel = (UILabel *)[cell viewWithTag:2002];
            UILabel *fromLabel = (UILabel *)[cell viewWithTag:2003];
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:2004];
            UILabel *repeatsLabel = (UILabel *)[cell viewWithTag:2005];
            UISwitch *enableSwitch = (UISwitch *)[cell viewWithTag:2006];
            
            toLabel.text = routine.toDisplayName;
            fromLabel.text = routine.fromDisplayName;
            timeLabel.text = [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:routine.routeDate];
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
    } else if (indexPath.section == departureNotifSection || indexPath.section == routeNotifSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"departureReminderCell" forIndexPath:indexPath];
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:2001];
        UILabel *codeLabel = (UILabel *)[cell viewWithTag:2002];
        UILabel *stopLabel = (UILabel *)[cell viewWithTag:2003];
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:2004];
        
        if (indexPath.section == departureNotifSection) {
            DepartureNotification *notification = self.departureNotifications[indexPath.row];
            
            codeLabel.text = notification.departureLine;
            stopLabel.text = notification.stopName;
            timeLabel.text = [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:notification.fireDate];
            
            if (notification.stopIconName) {
                UIImage *image = [UIImage imageNamed:notification.stopIconName];
                if (image) [imageView setImage:image];
            }
        } else {
            RouteNotification *notification = self.routeNotifications[indexPath.row];
            
            codeLabel.text = notification.title;
            stopLabel.text = [NSString stringWithFormat:@"To %@", notification.routeToLocation];
            timeLabel.text = [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:notification.fireDate];
            
            UIImage *image = [UIImage imageNamed:@"routeIcon2"];
            if (image) [imageView setImage:image];
        }
    }
    
    // Configure the cell...
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == routinesSection && self.savedRoutines.count > 0) {
        return @"ROUTINES";
    } else if ( section == departureNotifSection) {
        return @"STOP DEPARTURE REMINDERS";
    } else if ( section == routeNotifSection){
        return @"ROUTE REMINDERS";
    } else {
        return nil;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return self.savedRoutines.count > 0;
    } else {
        return YES;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == routinesSection) {
            [remindersManager deleteSavedRoutine:[savedRoutines objectAtIndex:[self dataIndexRowForTableIndexPath:indexPath]]];
            [savedRoutines removeObjectAtIndex:[self dataIndexRowForTableIndexPath:indexPath]];
            if (savedRoutines.count != 0) {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                [self.tableView reloadData];
            }
        } else if (indexPath.section == departureNotifSection) {
            [remindersManager cancelUserNotifications:@[self.departureNotifications[indexPath.row]]];
            [self.departureNotifications removeObjectAtIndex:indexPath.row];
            if (self.departureNotifications.count == 0) {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:departureNotifSection] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        } else {
            [remindersManager cancelUserNotifications:@[self.routeNotifications[indexPath.row]]];
            [self.routeNotifications removeObjectAtIndex:indexPath.row];
            if (self.routeNotifications.count == 0) {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:routeNotifSection] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
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

- (void)updateNotifEnabledStatus {
    [[ReittiRemindersManager sharedManger] isUserNotificationEnabledWithCompletion:^(BOOL granted){
        self.isNotificationsEnabled = granted;
        [self.tableView reloadData];
    }];
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
