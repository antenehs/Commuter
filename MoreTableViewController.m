//
//  MoreTableViewController.m
//  
//
//  Created by Anteneh Sahledengel on 23/6/15.
//
//

#import "MoreTableViewController.h"
#import "AMBlurView.h"
#import "RettiDataManager.h"
#import "SettingsManager.h"
#import "CoreDataManager.h"

@interface MoreTableViewController ()

@property (strong, nonatomic) RettiDataManager *reittiDataManager;
@property (strong, nonatomic) SettingsManager *settingsManager;

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTableBackgroundView];
    self.clearsSelectionOnViewWillAppear = YES;
    
    [self initDataManager];
    
    thereIsDisruptions = [self areThereDisruptions];
    canShowDisruptions = YES;
    
    [self checkForDisruptionAvailability];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.navigationItem setTitle:@"MORE"];
    [self.tabBarController.tabBar setHidden:NO];
    
    if (thereIsDisruptions != [self areThereDisruptions] ) {
        thereIsDisruptions = [self areThereDisruptions];
        [self.tableView reloadData];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setTableBackgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init
- (void)initDataManager {
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:[[CoreDataManager sharedManager] managedObjectContext]];
        
        if (self.settingsManager == nil) {
            self.settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        }
        
        [self.reittiDataManager setUserLocationToRegion:[self.settingsManager userLocation]];
    }
}

#pragma mark - view methods
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

- (BOOL)areThereDisruptions {
    UITabBarItem *moreTabBarItem = [self.tabBarController.tabBar.items objectAtIndex:4];
    
    return moreTabBarItem.badgeValue != nil;
}

- (void)checkForDisruptionAvailability {
    if (([self.settingsManager userLocation] != HSLRegion)) {
        canShowDisruptions = NO;
    }else{
        canShowDisruptions = YES;
    }
}

-(void)userLocationSettingsValueChanged:(NSNotification *)notification{
    [self checkForDisruptionAvailability];
    
    thereIsDisruptions = [self areThereDisruptions];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return canShowDisruptions ? 3 : 2;
    }else if (section == 1) {
        return 1;
    }else{
        return 3;
        /* Return 4 to add new in this version
        return 4;
         */
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"remindersCell" forIndexPath:indexPath];
        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"matkakorttiCell" forIndexPath:indexPath];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"disruptionsCell" forIndexPath:indexPath];
            
            UIView *disruptionsView = [cell viewWithTag:1003];
            disruptionsView.layer.cornerRadius = 12.5;
            
            disruptionsView.hidden = !thereIsDisruptions || !canShowDisruptions;
        }
    }else if (indexPath.section == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    }else{
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCommuterCell" forIndexPath:indexPath];
        }
//        else if (indexPath.row == 1) {
//            cell = [tableView dequeueReusableCellWithIdentifier:@"newInVersionCell" forIndexPath:indexPath];
//        }
        else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"contactMeCell" forIndexPath:indexPath];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"rateCell" forIndexPath:indexPath];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


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

#pragma mark - ibactions

- (IBAction)contactUsButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Feel free to contact me for anything, even just to say hi!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Request A Feature",@"Report A Bug",@"Say Hi!", nil];
    //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
    actionSheet.tag = 1002;
    [actionSheet showInView:self.view];
}

- (IBAction)rateInAppStoreButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1023398868"]];
}

- (IBAction)openMatkakorttiAppButtonPressed:(id)sender {
    //TODO: Check if the app exists locally and open it with a url
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1036411677"]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1002){
        switch (buttonIndex) {
            case 0:
                [self sendEmailWithSubject:@"[Feature Request] - "];
                break;
            case 1:
                [self sendEmailWithSubject:@"[Bug Report] - "];
                break;
            case 2:
                [self sendEmailWithSubject:@"Hi - "];
                break;
            default:
                break;
        }
    }
}

- (void)sendEmailWithSubject:(NSString *)subject{
    // Email Subject
    NSString *emailTitle = subject;
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"ewketapps@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            //            [self.reittiDataManager setAppOpenCountValue:-100];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [self.navigationItem setTitle:@""];
    [self.tabBarController.tabBar setHidden:YES];
}


@end
