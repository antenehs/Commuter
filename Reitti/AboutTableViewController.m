//
//  AboutTableViewController.m
//  
//
//  Created by Anteneh Sahledengel on 23/6/15.
//
//

#import "AboutTableViewController.h"
#import "CoreDataManager.h"
#import <Social/Social.h>
#import "ReittiEmailAndShareManager.h"
#import "AppManager.h"
#import "ReittiNotificationHelper.h"

@interface AboutTableViewController ()

@property (strong, nonatomic) RettiDataManager *reittiDataManager;

@end

@implementation AboutTableViewController

@synthesize settingsManager, reittiDataManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] init];
    }
    
    self.settingsManager = [SettingsManager sharedManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
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
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCommuterCell"];
    }
    
    if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"poweredByCell"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCommuterCell"];
        UILabel *aboutText = (UILabel *)[cell viewWithTag:1001];
        aboutText.frame = CGRectMake(aboutText.frame.origin.x, aboutText.frame.origin.y, self.view.frame.size.width - 45, aboutText.frame.size.height);
        CGSize maxSize = CGSizeMake(aboutText.bounds.size.width, CGFLOAT_MAX);
        
        CGRect labelSize = [aboutText.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{
                                                                  NSFontAttributeName :aboutText.font
                                                                  }
                                                        context:nil];
        return 175 + labelSize.size.height;
    }
    
    if (indexPath.row == 1) {
        return 290;
    }
    
    return 44;
}

#pragma mark - ibactions
- (IBAction)DoneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)contactUsButtonPressed:(UIButton *)sender {
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
    
    UITableViewCell *contactMeCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect translated = [self.tableView convertRect:sender.frame fromView:contactMeCell];
    controller.popoverPresentationController.sourceView = self.tableView;
    controller.popoverPresentationController.sourceRect = translated;
    
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (IBAction)requestAFeatureButtonPressed:(id)sender {
    [self sendEmailWithSubject:NSLocalizedString(@"[Feature Request] - ", @"[Feature Request] - ")];
}

- (IBAction)tweetorFacebookAboutThisAppPressed:(id)sender {
    UIButton *shareButton = (UIButton *)sender;
    
    UITableViewCell *shareCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect translated = [self.view convertRect:shareButton.frame fromView:shareCell];
    [[ReittiEmailAndShareManager sharedManager] showShareSheetOnViewController:self atRect:translated];
}

- (IBAction)postToFacebookButtonPressed:(id)sender {
}

- (IBAction)rateInAppStoreButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager appAppstoreRateLink]]];
}

- (IBAction)openHSLSiteButtonPressed:(id)sender {
    NSURL *url;
    if ([settingsManager userLocation] == TRERegion) {
        url = [NSURL URLWithString:@"http://developer.publictransport.tampere.fi/pages/en/http-get-interface.php"];
    }else{
        url = [NSURL URLWithString:@"http://developer.reittiopas.fi/pages/en/home.php"];
    }
    
    
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)openIcons8SiteButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://icons8.com"];
    
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Notifications
-(void)userLocationSettingsValueChanged:(NSNotification *)notification{
    [self.reittiDataManager setUserLocationRegion:[settingsManager userLocation]];
}

#pragma mark - helper methods
- (void)postToFacebook {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [[ReittiEmailAndShareManager sharedManager] slComposeVcForFacebook];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    }else{
        [ReittiNotificationHelper showSimpleMessageWithTitle:NSLocalizedString(@"Sorry", @"Sorry")
                                                  andContent:NSLocalizedString(@"You can't post to Facebook right now. Make sure your device has an internet connection and you have at least one Facebook account setup", nil)
                                                inController:self];
    }
}

- (void)postToTwitter {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [[ReittiEmailAndShareManager sharedManager] slComposeVcForTwitter];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        [ReittiNotificationHelper showSimpleMessageWithTitle:NSLocalizedString(@"Sorry", @"Sorry")
                                                  andContent:NSLocalizedString(@"You can't send a tweet right now. Make sure your device has an internet connection and you have at least one Twitter account setup", nil)
                                                inController:self];
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
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userlocationChangedNotificationName object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
