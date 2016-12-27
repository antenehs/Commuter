//
//  InfoViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "DisruptionViewController.h"
#import "Disruption.h"
#import <Social/Social.h>
#import "CoreDataManager.h"
#import "SettingsManager.h"
#import "ASA_Helpers.h"
#import "AppManager.h"

@interface DisruptionViewController ()

@end

@implementation DisruptionViewController

@synthesize disruptionsList;
@synthesize reittiDataManager;
@synthesize settingsManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.settingsManager = [SettingsManager sharedManager];
    
    if (self.reittiDataManager == nil) {
        self.reittiDataManager = [[RettiDataManager alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
    
    CGRect scrollVFrame = mainScrollView.frame;
    scrollVFrame.size.height = self.view.frame.size.height - scrollVFrame.origin.y;
    mainScrollView.frame = scrollVFrame;
    mainScrollView.delegate = self;
    
    searchedForDisruptions = NO;
    
    disruptionsTableView.rowHeight = UITableViewAutomaticDimension;
    disruptionsTableView.estimatedRowHeight = 44.0;
    [disruptionsTableView reloadData];
    disruptionsTableView.backgroundColor = [UIColor clearColor];
    
    if (self.viewControllerMode != DisruptionViewModeStaticRouteDisruptions) {
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:900 target:self selector:@selector(checkDisruptionsButtonPressed:) userInfo:nil repeats:YES];
        if ([settingsManager userLocation] == HSLRegion) {
            [self fetchDisruptions];
        }else{
            [self disruptionFetchDidFail:nil];
        }
    }
    
    [self.navigationController setToolbarHidden:YES];
//    [self initAdBannerView];
}

-(void)viewDidAppear:(BOOL)animated{
    [self layoutAnimated:NO];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self layoutAnimated:NO];
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
        titleLabel.text = NSLocalizedString(@"About Commuter", @"About Commuter");
        [titleImageView setImage:[UIImage imageNamed:@"appIconRounded.png"]];
    }
    
    if (scrollView.contentOffset.y - 30 < aboutCommuterCellOriginY) {
        titleLabel.text = NSLocalizedString(@"Disruptions", @"Disruptions");
        [titleImageView setImage:[UIImage imageNamed:@"warningIconRounded.png"]];
    }
    
}

#pragma mark - table view methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (disruptionsList.count > 0) {
        return disruptionsList.count ;
    }else{
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    if (disruptionsList.count > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"disruptionsCell"];
        
        Disruption *disruption = [disruptionsList objectAtIndex:indexPath.row];
        //Setup info label
        UILabel *infoLabel = (UILabel *)[cell viewWithTag:1001];
        infoLabel.attributedText = [disruption formattedLocalizedTextWithFont:infoLabel.font];
        
        //Setup lines view
        UIView *linesContainerView = [cell viewWithTag:1002];
        NSLayoutConstraint *bottomConstraint;
        
        for (NSLayoutConstraint *constraint in linesContainerView.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeBottom) {
                bottomConstraint = constraint;
                break;
            }
        }

        if (disruption.disruptionLines && disruption.disruptionLines.count != 0 && disruption.disruptionLineNames.count != 0) {
            linesContainerView.hidden = NO;
            bottomConstraint.active = YES;
            
            UIImageView *imageView = (UIImageView *)[linesContainerView viewWithTag:2001];
            UILabel *linesLabel = (UILabel *)[linesContainerView viewWithTag:2002];
            
            imageView.image = [AppManager lineIconForLineType:[disruption.disruptionLines[0] parsedLineType]];
            linesLabel.text = [ReittiStringFormatter commaSepStringFromArray:disruption.disruptionLineNames withSeparator:@", "];
            
        } else {
            linesContainerView.hidden = YES;
            bottomConstraint.active = NO;
        }
    }else if (!searchedForDisruptions){
        cell = [tableView dequeueReusableCellWithIdentifier:@"noDisruptionsCell"];
        
        checkDisruptionButton = (UIButton *)[cell viewWithTag:1002];
        UILabel *label = (UILabel *)[cell viewWithTag:1001];
        
        checkDisruptionButton.hidden = YES;
        label.text = NSLocalizedString(@"Getting disruptions...", @"Getting disruptions...");
        
        refreshActivityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:1003];
        [refreshActivityIndicator startAnimating];
    }else{
        if ([settingsManager userLocation] == HSLRegion) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"noDisruptionsCell"];
            
            checkDisruptionButton = (UIButton *)[cell viewWithTag:1002];
            refreshActivityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:1003];
            
            UILabel *label = (UILabel *)[cell viewWithTag:1001];
            
            checkDisruptionButton.hidden = YES;
            label.text = NSLocalizedString(@"No Traffic Disruptions", @"No Traffic Disruptions");
            [refreshActivityIndicator stopAnimating];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"noDisruptionInfoCell"];
        }
        
    }
    
//    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (disruptionsList.count > 0) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"disruptionsCell"];
//        UILabel *infoLabel = (UILabel *)[cell viewWithTag:1001];
//        infoLabel.frame = CGRectMake(infoLabel.frame.origin.x, infoLabel.frame.origin.y, self.view.frame.size.width - 180, infoLabel.frame.size.height);
//        Disruption *disruption = [disruptionsList objectAtIndex:indexPath.row];
//        
//        CGSize maxSize = CGSizeMake(infoLabel.bounds.size.width, CGFLOAT_MAX);
//        
//        CGRect labelSize = [[disruption localizedText] boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
//                                                                attributes:@{
//                                                                             NSFontAttributeName :infoLabel.font
//                                                                             }
//                                                                   context:nil];;
//        if (labelSize.size.height < 40) {
//            labelSize.size.height = 40;
//        }
//        return labelSize.size.height + 20;
//    }else{
//        if (indexPath.row == 0) {
//            return 65;
//        }
//    }
//    
//    return 44;
//}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int aboutCellLoc = disruptionsList.count > 0 ? (int)disruptionsList.count : 1;
    if (indexPath.row == aboutCellLoc) {
        aboutCommuterCellOriginY = cell.frame.origin.y;
    }
}

#pragma mark - Disruptions fetching
- (void)fetchDisruptions{
    [self.reittiDataManager fetchDisruptionsWithCompletionBlock:^(NSArray *disruption, NSString *errorString){
        if (!errorString) {
            [self disruptionFetchDidComplete:disruption];
        }else{
            [self disruptionFetchDidFail:errorString];
        }
        
        searchedForDisruptions = YES;
    }];
}

- (void)disruptionFetchDidComplete:(NSArray *)disList{
    //Filter out disruptions with no info text
    NSMutableArray *tempArray = [@[] mutableCopy];
    for (Disruption *disruption in disList) {
        if (disruption.localizedText != nil) {
            [tempArray addObject:disruption];
        }
    }
    
    self.disruptionsList = tempArray;
    
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
//- (IBAction)DoneButtonPressed:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
- (IBAction)checkDisruptionsButtonPressed:(id)sender {
    [self fetchDisruptions];
    [checkDisruptionButton setHidden:YES];
    [refreshActivityIndicator startAnimating];
}

#pragma mark - Notifications
-(void)userLocationSettingsValueChanged:(NSNotification *)notification{
    [self.reittiDataManager setUserLocationRegion:[settingsManager userLocation]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - iAd methods
-(void)initAdBannerView{
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else {
        _bannerView = [[ADBannerView alloc] init];
    }
    _bannerView.delegate = self;
    
    CGRect bannerFrame = _bannerView.frame;
    bannerFrame.origin.y = self.view.bounds.size.height;
    _bannerView.frame = bannerFrame;
    
    [self.view addSubview:_bannerView];
}

- (void)layoutAnimated:(BOOL)animated
{
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    CGRect contentFrame = self.view.bounds;
//    if (contentFrame.size.width < contentFrame.size.height) {
//        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
//    } else {
//        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
//    }
    
    CGRect bannerFrame = _bannerView.frame;
    bannerFrame.origin.y = contentFrame.size.height;
    _bannerView.frame = bannerFrame;
    if (_bannerView.bannerLoaded) {
        contentFrame.size.height -= _bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        //cardView.frame = contentFrame;
        _bannerView.frame = bannerFrame;
    }];
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES ;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
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
