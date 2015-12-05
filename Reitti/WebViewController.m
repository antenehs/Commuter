//
//  WebViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

@synthesize _webView;
@synthesize _url;
@synthesize _pageTitle;
@synthesize darkMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self selectSystemColors];
//    [self setUpTopBarApearance];
//    [self initAdBannerView];
    
    _webView.delegate = self;
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:_url];
    [_webView loadRequest:requestObj];
    
//    CGRect webVFrame = _webView.frame;
//    webVFrame.size.height = self.view.bounds.size.height - topBarView.frame.size.height;
//    _webView.frame = webVFrame;
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self layoutAnimated:NO];
    
//    CGSize contentSize = _webView.scrollView.contentSize;
//    CGSize viewSize = self.view.frame.size;
//    
//    float rw = viewSize.width / contentSize.width;
//    
//    _webView.scrollView.minimumZoomScale = rw;
//    _webView.scrollView.maximumZoomScale = rw;
//    [_webView.scrollView setZoomScale:rw animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [self layoutAnimated:NO];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setToolbarHidden:YES animated:NO];
}

#pragma mark - View methods
- (void)selectSystemColors{
    if (self.darkMode) {
        systemBackgroundColor = [UIColor clearColor];
        systemTextColor = SYSTEM_GREEN_COLOR;
        systemSubTextColor = [UIColor lightGrayColor];
    }else{
        systemBackgroundColor = nil;
        systemTextColor = SYSTEM_GREEN_COLOR;
        systemSubTextColor = [UIColor darkGrayColor];
    }
}

- (void)setUpTopBarApearance{
//    topBarView.layer.borderWidth = 0.5;
//    topBarView.layer.borderColor = [[UIColor blackColor] CGColor];
//    [topBarView setBlurTintColor:systemBackgroundColor];
    
    if (_pageTitle != nil) {
        titleLabel.text = _pageTitle;
    }else{
        titleLabel.text = @"";
    }
}

-(void)timerCallback {
    if (doneLoading) {
        if (loadProgressView.progress >= 1) {
            loadProgressView.hidden = YES;
            [myTimer invalidate];
        
        }
        else {
            loadProgressView.progress += 0.1;
        }
    }
    else {
        if (loadProgressView.progress >= 0.9) {
            loadProgressView.progress = 0.9;
        }else if (0.9 > loadProgressView.progress >= 0.4){
            loadProgressView.progress += 0.01;
        }else{
            loadProgressView.progress += 0.05;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)openInSafari:(id)sender {
    if (![[UIApplication sharedApplication] openURL:_url])
        NSLog(@"%@%@",@"Failed to open url:",[_url description]);
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil ];
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    loadProgressView.hidden = NO;
    loadProgressView.progress = 0;
    doneLoading = false;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    doneLoading = true;
    
    CGSize contentSize = webView.scrollView.contentSize;
    CGSize viewSize = self.view.frame.size;
    
    float rw = viewSize.width / contentSize.width;
    
    webView.scrollView.minimumZoomScale = rw;
    webView.scrollView.maximumZoomScale = rw;
    [webView.scrollView setZoomScale:rw animated:YES];
    
//    webView.scrollView.contentSize = CGSizeMake(webView.scrollView.contentSize.width, webView.scrollView.contentSize.width + 70);
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
        contentFrame.size.height -= _bannerView.frame.size.height + self.navigationController.toolbar.frame.size.height;
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
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
