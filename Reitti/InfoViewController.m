//
//  InfoViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "InfoViewController.h"
#import "Disruption.h"
#import <Social/Social.h>

@interface InfoViewController ()

@end

@implementation InfoViewController

@synthesize disruptionsList;
@synthesize reittiDataManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    mainScrollView.contentSize = CGSizeMake(320, 505);
    
    self.reittiDataManager.disruptionFetchDelegate = self;
    
    CGRect scrollVFrame = mainScrollView.frame;
    scrollVFrame.size.height = self.view.frame.size.height - scrollVFrame.origin.y;
    mainScrollView.frame = scrollVFrame;
    mainScrollView.delegate = self;
    [disruptionsTableView reloadData];
    disruptionsTableView.backgroundColor = [UIColor clearColor];
    
//    [self setupScrollView];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:900 target:self selector:@selector(checkDisruptionsButtonPressed:) userInfo:nil repeats:YES];
    [self.reittiDataManager fetchDisruptions];
    
}

#pragma mark - view methods
-(void)setupScrollView{
    float yPos = 5;
    if (self.disruptionsList != nil) {
        disruptionsTableView.hidden = NO;
        noDisruptionLabel.hidden = YES;
        checkDisruptionButton.hidden = YES;
        
        CGSize tableContent = disruptionsTableView.contentSize;
        
        CGRect tableRect = disruptionsTableView.frame;
        tableRect.size.height = tableContent.height;
        disruptionsTableView.frame = tableRect;
        tableViewHeightConstraint.constant = tableRect.size.height;
        
        [mainScrollView addSubview:disruptionsTableView];
        yPos += disruptionsTableView.frame.size.height + 5;
    }else{
        tableViewHeightConstraint.constant = 44;
        disruptionsTableView.hidden = YES;
        noDisruptionLabel.hidden = NO;
        checkDisruptionButton.hidden = NO;
        yPos += 44;
    }
    
    CGRect aboutCont =  aboutContainerView.frame;
    aboutCont.origin.y = yPos;
    aboutContainerView.frame = aboutCont;
    
    yPos += aboutContainerView.frame.size.height + 220;
    
    mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width, yPos);
    [mainScrollView setNeedsDisplay];
    
    [self.view layoutSubviews];
    [mainScrollView layoutSubviews];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"offset : %f and origin: %f",scrollView.contentOffset.y ,aboutContainerView.frame.origin.y);
    if (scrollView.contentOffset.y - 30> aboutCommuterCellOriginY) {
        titleLabel.text = @"About Commuter";
        [titleImageView setImage:[UIImage imageNamed:@"appIconRounded.png"]];
    }
    
    if (scrollView.contentOffset.y - 30 < aboutCommuterCellOriginY) {
        titleLabel.text = @"Disruptions";
        [titleImageView setImage:[UIImage imageNamed:@"warningIconRounded.png"]];
    }
    
}

#pragma mark - table view methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (disruptionsList.count > 0) {
        return disruptionsList.count + 2 ;
    }else{
        return 3;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    if (disruptionsList.count > 0) {
        if (indexPath.row < disruptionsList.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"disruptionsCell"];
            
            Disruption *disruption = [disruptionsList objectAtIndex:indexPath.row];
            
            UILabel *infoLabel = (UILabel *)[cell viewWithTag:1001];
            infoLabel.text = disruption.disruptionInfo;
            
            CGSize maxSize = CGSizeMake(infoLabel.bounds.size.width, CGFLOAT_MAX);
            
            CGRect labelSize = [disruption.disruptionInfo boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{
                                                                                 NSFontAttributeName : infoLabel.font
                                                                                 }
                                                                       context:nil];;
            
            infoLabel.frame = CGRectMake(infoLabel.frame.origin.x, infoLabel.frame.origin.y, labelSize.size.width, labelSize.size.height);
        }
        
    }else{
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"noDisruptionsCell"];
            
            checkDisruptionButton = (UIButton *)[cell viewWithTag:1002];
            refreshActivityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:1003];
        }
        
    }
    
    if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCommuterCell"];
    }
    
    if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"poweredByCell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (disruptionsList.count > 0) {
        if (indexPath.row < disruptionsList.count) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"disruptionsCell"];
            UILabel *infoLabel = (UILabel *)[cell viewWithTag:1001];
            infoLabel.frame = CGRectMake(infoLabel.frame.origin.x, infoLabel.frame.origin.y, self.view.frame.size.width - 60, infoLabel.frame.size.height);
            Disruption *disruption = [disruptionsList objectAtIndex:indexPath.row];
            
            CGSize maxSize = CGSizeMake(infoLabel.bounds.size.width, CGFLOAT_MAX);
            
            CGRect labelSize = [disruption.disruptionInfo boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{
                                                                                 NSFontAttributeName :infoLabel.font
                                                                                 }
                                                                       context:nil];;
            
            return labelSize.size.height + 20;
        }
    }else{
        if (indexPath.row == 0) {
            return 65;
        }
    }
    
    if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCommuterCell"];
        UILabel *aboutText = (UILabel *)[cell viewWithTag:1001];
        aboutText.frame = CGRectMake(aboutText.frame.origin.x, aboutText.frame.origin.y, self.view.frame.size.width - 60, aboutText.frame.size.height);
        CGSize maxSize = CGSizeMake(aboutText.bounds.size.width, CGFLOAT_MAX);
        
        CGRect labelSize = [aboutText.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{
                                                                             NSFontAttributeName :aboutText.font
                                                                             }
                                                                   context:nil];;
        return 175 + labelSize.size.height;
    }
    
    if (indexPath.row == 2) {
        return 290;
    }
    
    return 44;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        aboutCommuterCellOriginY = cell.frame.origin.y;
    }
}

#pragma mark - Disruptions delegate
- (void)disruptionFetchDidComplete:(NSArray *)disList{
    self.disruptionsList = disList;
    
    [disruptionsTableView reloadData];
    
    [checkDisruptionButton setHidden:NO];
    [refreshActivityIndicator stopAnimating];
}

- (void)disruptionFetchDidFail:(NSString *)error{
    self.disruptionsList = nil;
    
    [disruptionsTableView reloadData];
    
    [checkDisruptionButton setHidden:NO];
    [refreshActivityIndicator stopAnimating];
    
}

#pragma mark - ibactions
- (IBAction)DoneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)checkDisruptionsButtonPressed:(id)sender {
    [self.reittiDataManager fetchDisruptions];
    [checkDisruptionButton setHidden:YES];
    [refreshActivityIndicator startAnimating];
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

- (IBAction)postToFAcebookButtonPressed:(id)sender {
}

- (IBAction)rateInAppStoreButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id861274235"]];
}

- (IBAction)openHSLSiteButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://developer.reittiopas.fi/pages/en/home.php"];

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


#pragma mark - helper methods
- (void)postToFacebook {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Easy way to get HSL timetables and routes!Check Commuter out."];
        [controller addURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id861274235"]];
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
        [tweetSheet addURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id861274235"]];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
