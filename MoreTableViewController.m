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
#import "MainTabBarController.h"
#import "ASA_Helpers.h"
#import "SwiftHeaders.h"
#import "AppFeatureManager.h"
#import "GoProCarouselTableViewCell.h"
#import "InAppPurchaseViewController.h"

@interface MoreTableViewController ()

@property (strong, nonatomic) RettiDataManager *reittiDataManager;
@property (strong, nonatomic) SettingsManager *settingsManager;
@property (strong, nonatomic) RemoteMessage *remoteMessage;

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTableBackgroundView];
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.remoteMessage = [[ReittiConfigManager sharedManager] moreTabMessage];
    
    [self initDataManager];
    appTranslateUrl = [self appTranslationLink];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GoProCarouselTableViewCell" bundle:nil] forCellReuseIdentifier:@"featurePreviewCell"];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self.navigationItem setTitle:NSLocalizedString(@"MORE", @"MORE")];
    [self.tabBarController.tabBar setHidden:NO];
    
    [self.tableView reloadData];
    
    [self showBadge:[self areThereDisruptions] || self.remoteMessage];
    
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
    MainTabBarController *tabBarController = (MainTabBarController *)self.tabBarController;
    return [tabBarController isShowingBadgeOnMoreTab];
}

- (void)showBadge:(bool)show{
    MainTabBarController *tabBarController = (MainTabBarController *)self.tabBarController;
    [tabBarController showBadgeOnMoreTab:show];
}

-(void)userLocationSettingsValueChanged:(NSNotification *)notification{
//    thereIsDisruptions = [self areThereDisruptions];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (void)setSectionAndRowNumbers{
    
    numberOfSection = 0;
    
    featurePreviewSection = ![AppFeatureManager proFeaturesAvailable] ? numberOfSection++ : -1;
    
    messageSection = ![AppFeatureManager proFeaturesAvailable] && self.remoteMessage ? numberOfSection++ : -1;
    
    numberOfMoreFeatures = 0;
    routinesRow = [AppFeatureManager proFeaturesAvailable] ? numberOfMoreFeatures++ : -1;
    ticketsSalesPointsRow = [AppFeatureManager proFeaturesAvailable] && self.settingsManager.userLocation == HSLRegion ? numberOfMoreFeatures++ : -1;
    icloudBookmarksRow = [AppFeatureManager proFeaturesAvailable] ? numberOfMoreFeatures++ : -1;
    disruptionsRow = self.settingsManager.userLocation == HSLRegion ? numberOfMoreFeatures++ : -1;
    
    moreFeaturesSection = numberOfMoreFeatures > 0 ? numberOfSection++ : -1;
    
    numberOfSettingsRows = 0;
    settingsRow = numberOfSettingsRows++;
    
    settingsSection = numberOfSection++;
    
    numberOfCommuterRows = 0;
    aboutCommuterRow = numberOfCommuterRows++;
    translateRow = appTranslateUrl ? numberOfCommuterRows++ : -1;
    goProRow = -1;
    newInVersionRow = numberOfCommuterRows++;
    contactMeRow = numberOfCommuterRows++;
    rateInAppStoreRow = numberOfCommuterRows++;
    shareRow = numberOfCommuterRows++;;
    
    commuterSection = numberOfSection++;
    
    debugFeaturesSection = -1;
    /*
    numberOfDebugRows = 0;
    useDigiTransitRow = numberOfDebugRows++;
    enableProFeaturesRow = numberOfDebugRows++;
    
    debugFeaturesSection = [AppManagerBase isDebugMode] ? numberOfSection++ : -1;
     */
}
     

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [self setSectionAndRowNumbers];
    return numberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == featurePreviewSection) {
        return 1;
    }else if (section == moreFeaturesSection) {
        return numberOfMoreFeatures;
    }else if (section == settingsSection) {
        return numberOfSettingsRows;
    }else if(section == commuterSection){
        return numberOfCommuterRows;
    }else if(section == debugFeaturesSection){
        return numberOfDebugRows;
    }else if (section == messageSection) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == featurePreviewSection) {
        cell = (GoProCarouselTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"featurePreviewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [(GoProCarouselTableViewCell *)cell setButtonAction:^(){
            [self presentGoProView];
        }];
    }else if (indexPath.section == moreFeaturesSection) {
        if (indexPath.row == routinesRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"remindersCell" forIndexPath:indexPath];
            if (![AppFeatureManager proFeaturesAvailable])
                [self setFeatureCellAsProOnly:cell];
        }else if (indexPath.row == ticketsSalesPointsRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ticketSellPointCell" forIndexPath:indexPath];
            if (![AppFeatureManager proFeaturesAvailable])
                [self setFeatureCellAsProOnly:cell];
        }else if (indexPath.row == icloudBookmarksRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"iCloudBookmarksCell" forIndexPath:indexPath];
            if (![AppFeatureManager proFeaturesAvailable])
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
        if (indexPath.row == useDigiTransitRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"useDigiTransit" forIndexPath:indexPath];
            UISwitch *useSwitch = [cell viewWithTag:1005];
            useSwitch.on = [SettingsManager useDigiTransit];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"enableProFeatures" forIndexPath:indexPath];
            UISwitch *useSwitch = [cell viewWithTag:1005];
            useSwitch.on = [SettingsManager proFeaturesEnabled];
        }
    } else if (indexPath.section == messageSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
        
        UILabel *messageLabel = [cell viewWithTag:1001];
        UIButton *actionButton = [cell viewWithTag:1002];
        
        messageLabel.text = self.remoteMessage.message;
        messageLabel.textColor = [AppManager systemOrangeColor];
        actionButton.hidden = !self.remoteMessage.isActionable;
        if (self.remoteMessage.isActionable) {
            [actionButton setTitle:self.remoteMessage.actionName forState:UIControlStateNormal];
        }
        
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == featurePreviewSection) {
        return 224.0;
    } else if (indexPath.section == messageSection) {
        return self.remoteMessage.isActionable ? 110.0 : 80.0;
    } else {
        return 50.0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == featurePreviewSection) {
        [self presentGoProView];
    }
    
    if (indexPath.section == commuterSection) {
        if (indexPath.row == translateRow) {
            [[UIApplication sharedApplication] openURL:appTranslateUrl];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionTappedTranslateCell label:@"" value:nil];
        }
        
        if (indexPath.row == newInVersionRow) {
            [self presentNewInVersionView];
        }
    }
}

-(void)setFeatureCellAsProOnly:(UITableViewCell *)cell DEPRECATED_MSG_ATTRIBUTE("Not used anymore") {
    /*
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
     */
}

#pragma mark - helpers
- (NSURL *)appTranslationLink {
    NSString *urlString = [[ReittiConfigManager sharedManager] appTranslationLink];
    if (!urlString) return nil;
    
    return [NSURL URLWithString:urlString];
}

#pragma mark - ibactions

- (void)presentGoProView {
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[InAppPurchaseViewController instantiate]]
                       animated:YES
                     completion:nil];
}

- (void)presentNewInVersionView {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[NewInVersionViewController generateNewInVersionVc]];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)contactUsButtonPressed:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Feel free to contact me for anything, even just to say hi!"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {}];
    
    [controller addAction:cancelAction];
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Request A Feature", @"Request A Feature")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [self sendFeatureRequestEmail];
                                                        }];
    
    [controller addAction:firstAction];
    
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Report A Bug", @"Report A Bug")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self sendBugReportEmail];
                                                         }];
    
    [controller addAction:secondAction];
    
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Say Hi!", @"Say Hi!")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [self sendHiEmail];
                                                        }];
    
    [controller addAction:thirdAction];
    
    CGRect contactMeCellRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:contactMeRow inSection:commuterSection]];
    controller.popoverPresentationController.sourceView = self.tableView;
    controller.popoverPresentationController.sourceRect = contactMeCellRect;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)shareButtonPressed:(id)sender {
    CGRect shareCellRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:shareRow inSection:commuterSection]];
    CGRect translated = [self.view convertRect:shareCellRect fromView:self.tableView];
    [[ReittiEmailAndShareManager sharedManager] showShareSheetOnViewController:self atRect:translated];
    
}

- (IBAction)rateInAppStoreButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager appAppstoreRateLink]]];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionTappedRateButton label:[AppManager appFullName] value:nil];
}

- (IBAction)messageActionTapped:(id)sender {
    if (self.remoteMessage.isActionable) {
        NSURL *deeplinkUrl = [NSURL URLWithString:self.remoteMessage.actionDeeplink];
        if (deeplinkUrl)
            [[UIApplication sharedApplication] openURL:deeplinkUrl];
    }
}

#pragma mark - Debug Actions
- (IBAction)apiUseSettingChanged:(UISwitch *)sender {
    [SettingsManager setUseDigiTransit:sender.on];
}

- (IBAction)proFeaturesSettingChanged:(UISwitch *)sender {
    [SettingsManager setProFeaturesEnabled:sender.on];
    
    [self.tableView reloadData];
}

- (IBAction)openMatkakorttiAppButtonPressed:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"matkakorttimonitorapp://?"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"matkakorttimonitorapp://"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager matkakorttiAppAppstoreUrl]]];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSelectedMatkakorttiMonitor label:@"Twitter" value:nil];
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

-(void)goToProVersionInAppStore {
    [self performSegueWithIdentifier:@"viewProFeatures" sender:self];
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    
    if (indexPath && indexPath.section == moreFeaturesSection && ![AppFeatureManager proFeaturesAvailable]) {
        if (indexPath.row == routinesRow || indexPath.row == ticketsSalesPointsRow || indexPath.row == icloudBookmarksRow) {
            return NO;
        }
    }
    
    return YES;
}

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
