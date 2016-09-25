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

NSString *kImageKey = @"ImageKey";
NSString *kTitleKey = @"TitleKey";
NSString *kDescKey = @"DescKey";

@interface WelcomeViewController ()

@property (nonatomic, strong)NSArray *featuresWithImage;
@property (nonatomic, strong)NSArray *featuresCompact;

//@property (nonatomic, strong)NSMutableArray *imagesArray;
//@property (nonatomic, strong)NSMutableArray *titleArray;
//@property (nonatomic, strong)NSMutableArray *descArray;

@end

@implementation WelcomeViewController

@synthesize region;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initContentArrays];
    
    doneButton.layer.cornerRadius = 6;
    doneButton.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    doneButton.titleLabel.textColor = [UIColor greenColor];
    
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
    backViewFrame.size.width = (((self.featuresWithImage.count + 1) * backViewFrame.size.width)/2) + backViewFrame.size.width;
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
    
    NSDictionary *appleWatchApp = @{kImageKey: @"newAppleWatch", kTitleKey: @"Apple Watch App", kDescKey: @"New Apple Watch app that is actually useful. See your departure time on complications or search for routes right from the app."};
    NSDictionary *realtimeDeparture = @{kImageKey: @"newRealtimeDeparture", kTitleKey: @"Real-time Departures", kDescKey: @"Get real-time departure times. Don't wait for a canceled train."};
    NSDictionary *newWidgetsPro = @{kImageKey: @"newWidgetsPro", kTitleKey: @"Re-designed Widgets", kDescKey: @"Widgets are now redesigned for iOS 10. Also get route to a relevant destination right from the home screen."};
    NSDictionary *newWidgetsFree = @{kImageKey: @"newWidgetFree", kTitleKey: @"Re-desinged Widget", kDescKey: @"Departures widget is redesigned for iOS 10. Also get departures right from the home screen."};
    NSDictionary *newDisruptions = @{kImageKey: @"newDisruptions", kTitleKey: @"Revamped Disruptions", kDescKey: @"Easily see lines affected by disruption including cause and validity time."};
    NSDictionary *newReminders = @{kImageKey: @"newReminders", kTitleKey: @"Reminders", kDescKey: @"New reminders manager to easily create, see and cancel reminders from stops and routes."};
    NSDictionary *newWholeFinland = @{kImageKey: @"newWholeFinland", kTitleKey: @"Everywhere In Finland", kDescKey: @"Commuter now works everywhere in Finland. Get routes, timetables and lines info where ever you live."};
    NSDictionary *newContacts = @{kImageKey: @"newContacts", kTitleKey: @"Search Your Contacts", kDescKey: @"No need to save all of your friends' addresses anymore. Search right from Contacts."};
    NSDictionary *newStopFilter = @{kImageKey: @"newStopFilter", kTitleKey: @"Stops Filter", kDescKey: @"You feel the map view is a bit crouded with stops you are not interested in? Filter away!"};
    
    
    if ([AppManager isProVersion]) {
        self.featuresWithImage = @[appleWatchApp, realtimeDeparture, newWidgetsPro, newDisruptions, newReminders, newStopFilter, newContacts];
        self.featuresCompact = @[];
    } else {
        self.featuresWithImage = @[newWholeFinland, newWidgetsFree, newContacts];
        self.featuresCompact = @[];
    }
}

- (void)setUpScrollView{
    
    float xPosition = 0;
    
    CGRect vFrame = CGRectMake(0, 0, mainScrollView.frame.size.width, mainScrollView.frame.size.height);
    pageWidth = vFrame.size.width;
    for (NSDictionary *feature in self.featuresWithImage) {
        DetailImageView* iView = [[DetailImageView alloc] initFromNib];
        
        UIImageView *imageView = (UIImageView *)[iView viewWithTag:1001];
        [imageView setImage:[UIImage imageNamed:feature[kImageKey]]];
        
        UILabel *titleLabel = (UILabel *)[iView viewWithTag:1002];
        titleLabel.text = feature[kTitleKey];
        titleLabel.textColor = [UIColor whiteColor];
        
        UILabel *descLabel = (UILabel *)[iView viewWithTag:1003];
        descLabel.text = feature[kDescKey];
        descLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        
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
    
    pageControl.numberOfPages = self.featuresWithImage.count + 1;
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
