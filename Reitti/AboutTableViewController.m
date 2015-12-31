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

@interface AboutTableViewController ()

@end

@implementation AboutTableViewController

@synthesize settingsManager, reittiDataManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:[[CoreDataManager sharedManager] managedObjectContext]];
        
        self.settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        
        [self.reittiDataManager setUserLocationToRegion:[self.settingsManager userLocation]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
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

- (IBAction)contactUsButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Feel free to contact me for anything, even just to say hi!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Request A Feature",@"Report A Bug",@"Say Hi!", nil];
    //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
    actionSheet.tag = 1002;
    [actionSheet showInView:self.view];
}

- (IBAction)requestAFeatureButtonPressed:(id)sender {
    [self sendEmailWithSubject:@"[Feature Request] - "];
}

- (IBAction)tweetorFacebookAboutThisAppPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"They say sharing is caring, right?." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Facebook",@"Share on Twitter", nil];
    //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
    actionSheet.tag = 1001;
    [actionSheet showInView:self.view];
}

- (IBAction)postToFacebookButtonPressed:(id)sender {
}

- (IBAction)rateInAppStoreButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1023398868"]];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (actionSheet.tag == 1001) {
        switch (buttonIndex) {
            case 0:
                [self postToFacebook];
                break;
            case 1:
                [self postToTwitter];
                //                [self sendEmailWithSubject:@"[Feature Request] - "];
                break;
            default:
                break;
        }
        
        if (buttonIndex == 0) {
            
        }
        
    }else if (actionSheet.tag == 1002){
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

#pragma mark - Notifications
-(void)userLocationSettingsValueChanged:(NSNotification *)notification{
    [self.reittiDataManager setUserLocationRegion:[settingsManager userLocation]];
}

#pragma mark - helper methods
- (void)postToFacebook {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Easy way to get HSL timetables and routes!Check Commuter out."];
        [controller addURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1023398868"]];
        [controller addImage:[UIImage imageNamed:@"app-icon-v-2.4.png"]];
        
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
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Easy way to get HSL timetables and routes!Check Commuter out."];
        [tweetSheet addURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1023398868"]];
        [tweetSheet addImage:[UIImage imageNamed:@"app-icon-v-2.4.png"]];
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
