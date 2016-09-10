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
#import "ReittiEmailAndShareManager.h"
#import "AppManager.h"
#import "WebViewController.h"

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
//    canShowDisruptions = YES;
    
//    [self checkForDisruptionAvailability];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self.navigationItem setTitle:NSLocalizedString(@"MORE", @"MORE")];
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
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setBlurredBackgroundWithImageNamed:nil];
}

- (BOOL)areThereDisruptions {
    UITabBarItem *moreTabBarItem = [self.tabBarController.tabBar.items objectAtIndex:4];
    
    return moreTabBarItem.badgeValue != nil;
}

//- (void)checkForDisruptionAvailability {
//    if (([self.settingsManager userLocation] != HSLRegion)) {
//        canShowDisruptions = NO;
//    }else{
//        canShowDisruptions = YES;
//    }
//}

-(void)userLocationSettingsValueChanged:(NSNotification *)notification{
    thereIsDisruptions = [self areThereDisruptions];
    
    
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (void)setSectionAndRowNumbers{
    
    numberOfSection = 0;
    
    numberOfMoreFeatures = 0;
    routinesRow = [AppManager isProVersion] ? numberOfMoreFeatures++ : -1;
    ticketsSalesPointsRow = self.settingsManager.userLocation == HSLRegion && [AppManager isProVersion] ? numberOfMoreFeatures++ : -1;
    icloudBookmarksRow = [AppManager isProVersion] ? numberOfMoreFeatures++ : -1;
    disruptionsRow = self.settingsManager.userLocation == HSLRegion ? numberOfMoreFeatures++ : -1;
    
    moreFeaturesSection = numberOfMoreFeatures > 0 ? numberOfSection++ : -1;
    
    numberOfSettingsRows = 0;
    settingsRow = numberOfSettingsRows++;
    
    settingsSection = numberOfSection++;
    
    numberOfCommuterRows = 0;
    aboutCommuterRow = numberOfCommuterRows++;
    goProRow = ![AppManager isProVersion] ? numberOfCommuterRows++ : -1;
    newInVersionRow = numberOfCommuterRows++;
    contactMeRow = numberOfCommuterRows++;
    rateInAppStoreRow = numberOfCommuterRows++;
    shareRow = numberOfCommuterRows++;;
    
    commuterSection = numberOfSection++;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [self setSectionAndRowNumbers];
    return numberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == moreFeaturesSection) {
        return numberOfMoreFeatures;
    }else if (section == settingsSection) {
        return numberOfSettingsRows;
    }else if(section == commuterSection){
        return numberOfCommuterRows;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == moreFeaturesSection) {
        if (indexPath.row == routinesRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"remindersCell" forIndexPath:indexPath];
        }else if (indexPath.row == ticketsSalesPointsRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ticketSellPointCell" forIndexPath:indexPath];
        }else if (indexPath.row == icloudBookmarksRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"iCloudBookmarksCell" forIndexPath:indexPath];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"disruptionsCell" forIndexPath:indexPath];
            
            UIView *disruptionsView = [cell viewWithTag:1003];
            disruptionsView.layer.cornerRadius = 10;
            
            disruptionsView.hidden = !thereIsDisruptions;
        }
    }else if (indexPath.section == settingsSection){
        cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    }else{
        if (indexPath.row == aboutCommuterRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCommuterCell" forIndexPath:indexPath];
            
//            UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
//            imageView.image = [AppManager roundedAppLogoSmall];
        }else if (indexPath.row == goProRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"goProCell" forIndexPath:indexPath];
        }else if (indexPath.row == newInVersionRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"newInVersionCell" forIndexPath:indexPath];
            
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
            imageView.image = [AppManager appVersionPicture];
        }else if (indexPath.row == contactMeRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"contactMeCell" forIndexPath:indexPath];
        }else if (indexPath.row == rateInAppStoreRow){
            cell = [tableView dequeueReusableCellWithIdentifier:@"rateCell" forIndexPath:indexPath];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"shareCell" forIndexPath:indexPath];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - ibactions

- (IBAction)contactUsButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Feel free to contact me for anything, even just to say hi!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Request A Feature", @"Request A Feature"), NSLocalizedString(@"Report A Bug", @"Report A Bug"), NSLocalizedString(@"Say Hi!", @"Say Hi!"), nil];
    //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
    actionSheet.tag = 1002;
    [actionSheet showInView:self.view];
}

- (IBAction)shareButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"They say sharing is caring, right?." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Facebook",@"Share on Twitter", nil];
    //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
    actionSheet.tag = 1001;
    [actionSheet showInView:self.view];
}

- (IBAction)rateInAppStoreButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager appAppstoreRateLink]]];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionTappedRateButton label:[AppManager appFullName] value:nil];
}

- (IBAction)openMatkakorttiAppButtonPressed:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"matkakorttimonitorapp://?"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"matkakorttimonitorapp://"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager matkakorttiAppAppstoreUrl]]];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSelectedMatkakorttiMonitor label:@"Twitter" value:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1002){
        switch (buttonIndex) {
            case 0:
                [self sendFeatureRequestEmail];
                break;
            case 1:
                [self sendBugReportEmail];
                break;
            case 2:
                [self sendHiEmail];
                break;
            default:
                break;
        }
    }else{
        switch (buttonIndex) {
            case 0:
                [self postToFacebook];
                [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionTappedShareButton label:@"Facebook" value:nil];
                break;
            case 1:
                [self postToTwitter];
                [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionTappedShareButton label:@"Twitter" value:nil];
                break;
            default:
                break;
        }
    }
}

- (void)sendFeatureRequestEmail{
    MFMailComposeViewController *mc = [[ReittiEmailAndShareManager sharedManager] mailComposeVcForFeatureRequestEmail];
    mc.mailComposeDelegate = self;
    
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)sendBugReportEmail{
    MFMailComposeViewController *mc = [[ReittiEmailAndShareManager sharedManager] mailComposeVcForBugReportEmail];
    mc.mailComposeDelegate = self;
    
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)sendHiEmail{
    MFMailComposeViewController *mc = [[ReittiEmailAndShareManager sharedManager] mailComposeVcForHiEmail];
    mc.mailComposeDelegate = self;
    
    [self presentViewController:mc animated:YES completion:NULL];
}

//- (void)sendEmailWithSubject:(NSString *)subject{
//    // Email Subject
//    NSString *emailTitle = subject;
//    // Email Content
//    NSString *messageBody = @"";
//    // To address
//    NSArray *toRecipents = [NSArray arrayWithObject:@"ewketapps@gmail.com"];
//    
//    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
//    mc.mailComposeDelegate = self;
//    [mc setSubject:emailTitle];
//    [mc setMessageBody:messageBody isHTML:NO];
//    [mc setToRecipients:toRecipents];
//    
//    // Present mail view controller on screen
//    [self presentViewController:mc animated:YES completion:NULL];
//    
//}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)postToFacebook {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [[ReittiEmailAndShareManager sharedManager] slComposeVcForFacebook];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't post to Facebook right now. Make sure your device has an internet connection and you have at least one Facebook account setup"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)postToTwitter {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [[ReittiEmailAndShareManager sharedManager] slComposeVcForTwitter];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't send a tweet right now. Make sure your device has an internet connection and you have at least one Twitter account setup"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"viewProFeatures"]) {
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        NSURL *url = [NSURL URLWithString:kGoProDetailUrl];
        
        webViewController.modalMode = NO;
        webViewController._url = url;
        webViewController._pageTitle = @"COMMUTER PRO";
        
        webViewController.actionButtonTitle = @"Go to AppStore";
        webViewController.action = ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kProAppAppstoreLink]];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionGoToProVersionAppStore label:@"More View" value:nil];
        };
        webViewController.bottomContentOffset = 60.0;
        
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionViewedGoProDetail label:@"More View" value:nil];
    }
    
    [self.navigationItem setTitle:@""];
//    [self.tabBarController.tabBar setHidden:YES];
}


@end
