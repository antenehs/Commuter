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
#import "ReittiConfigManager.h"

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
    appTranslateUrl = [self appTranslationLink];
    
//    thereIsDisruptions = [self areThereDisruptions];
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
    
//    if (thereIsDisruptions != [self areThereDisruptions] ) {
//        thereIsDisruptions = [self areThereDisruptions];
//        [self.tableView reloadData];
//    }
//    thereIsDisruptions = [self areThereDisruptions];
    [self.tableView reloadData];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init
- (void)initDataManager {
    if (self.settingsManager == nil) {
        self.settingsManager = [SettingsManager sharedManager];
    }
    
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] init];
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

-(void)userLocationSettingsValueChanged:(NSNotification *)notification{
//    thereIsDisruptions = [self areThereDisruptions];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (void)setSectionAndRowNumbers{
    
    numberOfSection = 0;
    
    numberOfDebugRows = 0;
    useDigiTransitRow = numberOfDebugRows++;
    
    debugFeaturesSection = [AppManagerBase isDebugMode] ? numberOfSection++ : -1;
    
    numberOfMoreFeatures = 0;
    routinesRow = numberOfMoreFeatures++;
    ticketsSalesPointsRow = self.settingsManager.userLocation == HSLRegion ? numberOfMoreFeatures++ : -1;
    icloudBookmarksRow = numberOfMoreFeatures++;
    disruptionsRow = self.settingsManager.userLocation == HSLRegion ? numberOfMoreFeatures++ : -1;
    
    moreFeaturesSection = numberOfMoreFeatures > 0 ? numberOfSection++ : -1;
    
    numberOfSettingsRows = 0;
    settingsRow = numberOfSettingsRows++;
    
    settingsSection = numberOfSection++;
    
    numberOfCommuterRows = 0;
    aboutCommuterRow = numberOfCommuterRows++;
    translateRow = appTranslateUrl ? numberOfCommuterRows++ : -1;
    goProRow = ![AppManager isProVersion] ? numberOfCommuterRows++ : -1;
    newInVersionRow = numberOfCommuterRows++;
    contactMeRow = numberOfCommuterRows++;
    rateInAppStoreRow = numberOfCommuterRows++;
    shareRow = numberOfCommuterRows++;;
    
    commuterSection = numberOfSection++;
    
    numberOfDebugRows = 0;
    useDigiTransitRow = numberOfDebugRows++;
    
    debugFeaturesSection = [AppManagerBase isDebugMode] ? numberOfSection++ : -1;
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
    }else if(section == debugFeaturesSection){
        return numberOfDebugRows;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == moreFeaturesSection) {
        if (indexPath.row == routinesRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"remindersCell" forIndexPath:indexPath];
            if (![AppManager isProVersion])
                [self setFeatureCellAsProOnly:cell];
        }else if (indexPath.row == ticketsSalesPointsRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ticketSellPointCell" forIndexPath:indexPath];
            if (![AppManager isProVersion])
                [self setFeatureCellAsProOnly:cell];
        }else if (indexPath.row == icloudBookmarksRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"iCloudBookmarksCell" forIndexPath:indexPath];
            if (![AppManager isProVersion])
                [self setFeatureCellAsProOnly:cell];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"disruptionsCell" forIndexPath:indexPath];
            
            UIView *disruptionsView = [cell viewWithTag:1003];
            disruptionsView.layer.cornerRadius = 10;
            
            disruptionsView.hidden = ![self areThereDisruptions];
        }
    } else if (indexPath.section == settingsSection){
        cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    } else if (indexPath.section == commuterSection){
        if (indexPath.row == aboutCommuterRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCommuterCell" forIndexPath:indexPath];
        }else if (indexPath.row == goProRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"goProCell" forIndexPath:indexPath];
        }else if (indexPath.row == translateRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"helpTranslateCell" forIndexPath:indexPath];
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
    } else if (indexPath.section == debugFeaturesSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"useDigiTransit" forIndexPath:indexPath];
        UISwitch *useSwitch = [cell viewWithTag:1005];
        useSwitch.on = [SettingsManager useDigiTransit];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == commuterSection) {
        if (indexPath.row == translateRow) {
            [[UIApplication sharedApplication] openURL:appTranslateUrl];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionTappedTranslateCell label:@"" value:nil];
        }
    }
}

-(void)setFeatureCellAsProOnly:(UITableViewCell *)cell {
    if ([cell viewWithTag:1987]) [[cell viewWithTag:1987] removeFromSuperview];
    
    UIButton *overlayButton = [[UIButton alloc] initWithFrame:cell.contentView.frame];
    overlayButton.titleLabel.text = nil;
    overlayButton.backgroundColor = [UIColor whiteColor];
    overlayButton.alpha = 0.45;
    overlayButton.tag = 1987;
    [overlayButton addTarget:self action:@selector(goToProVersionInAppStore) forControlEvents:UIControlEventTouchUpInside];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    UIImage *lockImage = [[UIImage imageNamed:@"lock-50"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    imageView.image = lockImage;
    imageView.tintColor = [UIColor lightGrayColor];
    cell.accessoryView = imageView;
    
    [cell.contentView addSubview:overlayButton];
}

#pragma mark - helpers
- (NSURL *)appTranslationLink {
    NSString *urlString = [[ReittiConfigManager sharedManager] appTranslationLink];
    if (!urlString) return nil;
    
    return [NSURL URLWithString:urlString];
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

#pragma mark - Debug Actions
- (IBAction)apiUseSettingChanged:(UISwitch *)sender {
    [SettingsManager setUseDigiTrnsit:sender.on];
}


- (IBAction)openMatkakorttiAppButtonPressed:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"matkakorttimonitorapp://?"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"matkakorttimonitorapp://"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager matkakorttiAppAppstoreUrl]]];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSelectedMatkakorttiMonitor label:@"Twitter" value:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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

-(void)goToProVersionInAppStore {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kProAppAppstoreLink]];
//    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionGoToProVersionAppStore label:@"More View" value:nil];
    
    [self performSegueWithIdentifier:@"viewProFeatures" sender:self];
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
