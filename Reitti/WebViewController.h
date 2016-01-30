//
//  WebViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBlurView.h"
#import <iAd/iAd.h>

typedef void (^ActionBlock)();

@interface WebViewController : UIViewController<UIWebViewDelegate,ADBannerViewDelegate, UIScrollViewDelegate>{
    
    IBOutlet UILabel *titleLabel;
    IBOutlet UIView *topBarView;
    IBOutlet UIProgressView *loadProgressView;
    
    BOOL doneLoading;
    NSTimer *myTimer;
    
    IBOutlet UIButton *actionButton;
    IBOutlet AMBlurView *actionBottomView;
    
    ADBannerView *_bannerView;
}

@property (strong, nonatomic) NSURL *_url;
@property (strong, nonatomic) NSString *_pageTitle;
@property (strong, nonatomic) IBOutlet UIWebView *_webView;

@property (nonatomic) bool darkMode;
@property (nonatomic) bool modalMode;

@property (nonatomic, strong) NSString *actionButtonTitle;
@property (nonatomic, strong) ActionBlock action;

//Used to hide some content on the bottom.
@property (nonatomic) CGFloat bottomContentOffset;

@end
