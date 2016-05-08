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

@property (nonatomic, strong)NSMutableArray *imagesArray;
@property (nonatomic, strong)NSMutableArray *titleArray;
@property (nonatomic, strong)NSMutableArray *descArray;

@end

@implementation WelcomeViewController

@synthesize region;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initContentArrays];
    
    doneButton.layer.cornerRadius = 10;
    
    scrollingBackView = [[UIView alloc] initWithFrame:self.view.frame];
    
    logoImageView.image = [AppManager roundedAppLogoSmall];
    viewTitle.text = [NSString stringWithFormat:@"New in Commuter %@", [AppManager currentAppVersion]];
}

-(void)viewWillAppear:(BOOL)animated {
    [self setupScrollingBackView];
    [self updateBackScrollViewPosition];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setupScrollingBackView];
    
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
    
    [self setupScrollingBackView];
    [self updateBackScrollViewPosition];
}

-(void)setupScrollingBackView {
    CGRect backViewFrame = self.view.frame;
    backViewFrame.size.height = backViewFrame.size.height > backViewFrame.size.width ? backViewFrame.size.height : backViewFrame.size.width;
    backViewFrame.size.width = ((self.imagesArray.count * backViewFrame.size.width)/2) + backViewFrame.size.width;
    scrollingBackView.frame = backViewFrame;
    
    if (!scrollingBackView.superview) {
        [scrollingBackView asa_SetBlurredBackgroundWithImageNamed:nil];
        
        [self.view addSubview:scrollingBackView];
        [self.view sendSubviewToBack:scrollingBackView];
    }
}

-(void)updateBackScrollViewPosition {
    CGRect backViewFrame = scrollingBackView.frame;
    CGFloat scrollViewX = mainScrollView.contentOffset.x;
    
    CGFloat xposition = 0 - scrollViewX/4;
    
    backViewFrame.origin.x = xposition;
    
    scrollingBackView.frame = backViewFrame;
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

- (void)initContentArrays {
    self.imagesArray = [NSMutableArray arrayWithObjects:@"newBikeStations",
                                   @"newWholeFinland",
                                   nil];
    self.titleArray = [NSMutableArray arrayWithObjects:@"Helsinki City Bikes",
                                  @"Everywhere In Finland",
                                  nil];
    self.descArray = [NSMutableArray arrayWithObjects:@"Now you can see HSL's city bikes on the map with a realtime update of available bikes and return spaces.",
                                 @"Commuter now works everywhere in Finland. Get routes, timetables and lines info where ever you live.",
                                 nil];
    /* Save for free version
     self.imagesArray = [NSMutableArray arrayWithObjects:@"new-icloudSync",
     @"new-tre-live",
     nil];
     self.titleArray = [NSMutableArray arrayWithObjects:@"iCloud Sync",
     @"Live Vehicles in Tampere",
     nil];
     self.descArray = [NSMutableArray arrayWithObjects:@"Easily sync your bookmarks in all your devices using iCloud. No registration. No separate login.",
     @"Finally live vehicles tracking in Tampere. See all bus locations from the map or specific vehicles from the line views.",
     nil];
     */
}

- (void)setUpScrollView{
    
    if (![AppManager isProVersion]) {
        //Remove backwards to prevent changing of indexes
     
//        [imagesArray removeObjectAtIndex:7];
//        [imagesArray removeObjectAtIndex:5];
//        [imagesArray removeObjectAtIndex:4];
//        [imagesArray removeObjectAtIndex:0];
//        
//        [titleArray removeObjectAtIndex:7];
//        [titleArray removeObjectAtIndex:5];
//        [titleArray removeObjectAtIndex:4];
//        [titleArray removeObjectAtIndex:0];
//        
//        [descArray removeObjectAtIndex:7];
//        [descArray removeObjectAtIndex:5];
//        [descArray removeObjectAtIndex:4];
//        [descArray removeObjectAtIndex:0];
    }
    
    float xPosition = 0;
//    float width = 0.8 * self.view.frame.size.width;
//    float height = 0.8 * self.view.frame.size.height;
    
    CGRect vFrame = CGRectMake(0, 0, mainScrollView.frame.size.width, mainScrollView.frame.size.height);
    pageWidth = vFrame.size.width;
    for (int i = 0; i < self.imagesArray.count; i++) {
        DetailImageView* iView = [[DetailImageView alloc] initFromNib];
        
        UIImageView *imageView = (UIImageView *)[iView viewWithTag:1001];
        [imageView setImage:[UIImage imageNamed:[self.imagesArray objectAtIndex:i]]];
        
        UILabel *titleLabel = (UILabel *)[iView viewWithTag:1002];
        titleLabel.text = [self.titleArray objectAtIndex:i];
        titleLabel.textColor = [UIColor whiteColor];
        
        UILabel *descLabel = (UILabel *)[iView viewWithTag:1003];
        descLabel.text = [self.descArray objectAtIndex:i];
        descLabel.textColor = [UIColor whiteColor];
        
        [iView setBackgroundColor:[UIColor clearColor]];
        
        vFrame.origin.x = xPosition;
        iView.frame = vFrame;
        [mainScrollView addSubview:iView];
        xPosition += vFrame.size.width;
        
    }
//    NSArray* allTheViewsInMyNIB = [[NSBundle mainBundle] loadNibNamed:@"Features" owner:self options:nil];
//    UIView *moreView = allTheViewsInMyNIB[0];
//    [moreView setBackgroundColor:[UIColor clearColor]];
//    
//    vFrame.origin.x = xPosition;
//    moreView.frame = vFrame;
//    
//    [mainScrollView addSubview:moreView];
//    xPosition += vFrame.size.width;
    
    [mainScrollView layoutIfNeeded];
    
    mainScrollView.contentSize = CGSizeMake(xPosition, vFrame.size.height);
    
    pageControl.numberOfPages = self.imagesArray.count /* + 1 */;
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float currentPos = scrollView.contentOffset.x;
    pageControl.currentPage = lround(currentPos/pageWidth);
    
    if (currentPos > 0 && currentPos < (scrollView.contentSize.width - pageWidth))
        [self updateBackScrollViewPosition];
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
