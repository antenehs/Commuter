//
//  WelcomeViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "WelcomeViewController.h"
#import "DetailImageView.h"
#import "AppManager.h"
#import "ASA_Helpers.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

@synthesize region;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    doneButton.layer.cornerRadius = 10;
    
    [self.view asa_SetBlurredBackgroundWithImageNamed:nil];
    
//    logoImageView.alpha = 0;
//    viewTitle.alpha = 0;
//    pageControl.alpha = 0;
//    doneButton.alpha = 0;
//    mainScrollView.alpha = 0;
    
    logoImageView.image = [AppManager roundedAppLogoSmall];
    viewTitle.text = [NSString stringWithFormat:@"New in Commuter %@", [AppManager currentAppVersion]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self setUpScrollView];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    for (UIView * view in mainScrollView.subviews) {
        [view removeFromSuperview];
    }
    [self setUpScrollView];
    mainScrollView.contentOffset = CGPointMake(0,0);
}

-(void)presentViewAnimated:(BOOL)animated{
    [self setUpScrollView];
    CGRect finalFrame = logoImageView.frame;
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    CGFloat origWidth = 180;
    CGFloat origHeight = 180;
    
    CGRect origFrame = CGRectMake(viewWidth/2 - origWidth/2, viewHeight/3 - origHeight/2, origWidth, origHeight);
    
    logoImageView.frame = origFrame;
    viewTitle.alpha = 0;
    pageControl.alpha = 0;
    doneButton.alpha = 0;
    mainScrollView.alpha = 0;
    logoImageView.alpha = 1;
    [UIView animateWithDuration:animated? 0.5 : 0 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        logoImageView.frame = finalFrame;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:animated? 2 : 0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            viewTitle.alpha = 1;
            pageControl.alpha = 1;
            doneButton.alpha = 1;
            mainScrollView.alpha = 1;
        }completion:^(BOOL finished) {}];
    }];
}

- (void)setUpScrollView{
    
    NSMutableArray *imagesArray = [NSMutableArray arrayWithObjects:@"newRoutesWidget.png",
                            @"newNearbyDepartures.png",
                            @"new3dTouchShortcuts.png",
                            @"new3dPeekandPop.png",
                            @"newLiveVehiclesInLines.png",
                            @"routeDisruptions.png",
                            @"newAutomaticDepartures.png",
                            @"newServicePoints.png",
                            @"newLinesView.png",
                            nil];
    NSMutableArray *titleArray = [NSMutableArray arrayWithObjects:@"Routes Widget",
                           @"Nearby Departures",
                           @"App Shortcuts",
                           @"Peek and Pop",
                           @"Live Lines",
                           @"Disruptions",
                           @"Automatic Departures",
                           @"HSL Sales Points",
                           @"Redesigned Lines",
                           nil];
    NSMutableArray *descArray = [NSMutableArray arrayWithObjects:@"New Routes Widget for quick route suggestions to your saved addresses. Just swipe down from top, and you are set to go.",
                          @"Another easy way to see departures from stops near you. #Not-doing-much",
                          @"Even more way for a quick access for routes to your saved addresses. Are you seeing the pattern? #Not-doing-much",
                          @"To scared to leave the route view, but still want to see the timetable at some stop? Well, now you can just peek at it without leaving.",
                          @"Lines view has gotten live. See where exactly the tram or train is on the line.(Only in Helsinki region)",
                          @"Get disruption info that affects your searched routes only. We didn't think you'd care about a canceled train 30kms away.",
                          @"In another #Not-doing-much edition, you only need to open the bookmarks view to see departures from your favourite stops.",
                          @"Let's say hypothetically you woke up on a saturday somewhere you never been before, with no value on your travel card. Don't worry.",
                          @"Lines view is redesigned to automatically suggest lines from stops near you and your favourite stops.",
                          nil];
    
    if (![AppManager isProVersion]) {
        //Remove backwards to prevent changing of indexes
        
        [imagesArray removeObjectAtIndex:7];
        [imagesArray removeObjectAtIndex:5];
        [imagesArray removeObjectAtIndex:4];
        [imagesArray removeObjectAtIndex:0];
        
        [titleArray removeObjectAtIndex:7];
        [titleArray removeObjectAtIndex:5];
        [titleArray removeObjectAtIndex:4];
        [titleArray removeObjectAtIndex:0];
        
        [descArray removeObjectAtIndex:7];
        [descArray removeObjectAtIndex:5];
        [descArray removeObjectAtIndex:4];
        [descArray removeObjectAtIndex:0];
    }
    
    float xPosition = 0;
//    float width = 0.8 * self.view.frame.size.width;
//    float height = 0.8 * self.view.frame.size.height;
    
    CGRect vFrame = CGRectMake(0, 0, mainScrollView.frame.size.width, mainScrollView.frame.size.height);
    pageWidth = vFrame.size.width;
    for (int i = 0; i < imagesArray.count; i++) {
        DetailImageView* iView = [[DetailImageView alloc] initFromNib];
        
        UIImageView *imageView = (UIImageView *)[iView viewWithTag:1001];
        [imageView setImage:[UIImage imageNamed:[imagesArray objectAtIndex:i]]];
        
        UILabel *titleLabel = (UILabel *)[iView viewWithTag:1002];
        titleLabel.text = [titleArray objectAtIndex:i];
        titleLabel.textColor = [UIColor whiteColor];
        
        UILabel *descLabel = (UILabel *)[iView viewWithTag:1003];
        descLabel.text = [descArray objectAtIndex:i];
        descLabel.textColor = [UIColor whiteColor];
        
        [iView setBackgroundColor:[UIColor clearColor]];
        
        vFrame.origin.x = xPosition;
        iView.frame = vFrame;
        [mainScrollView addSubview:iView];
        xPosition += vFrame.size.width;
        
    }
    NSArray* allTheViewsInMyNIB = [[NSBundle mainBundle] loadNibNamed:@"Features" owner:self options:nil];
    UIView *moreView = allTheViewsInMyNIB[0];
    [moreView setBackgroundColor:[UIColor clearColor]];
    
    vFrame.origin.x = xPosition;
    moreView.frame = vFrame;
    
    [mainScrollView addSubview:moreView];
    xPosition += vFrame.size.width;
    
    [mainScrollView layoutIfNeeded];
    
    mainScrollView.contentSize = CGSizeMake(xPosition, vFrame.size.height);
    
    pageControl.numberOfPages = imagesArray.count + 1;
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float currentPos = scrollView.contentOffset.x;
    pageControl.currentPage = lround(currentPos/pageWidth);
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pageControlValueChanged:(id)sender {
    [mainScrollView setContentOffset:CGPointMake(lround(pageWidth * pageControl.currentPage), 0) animated:YES];
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
