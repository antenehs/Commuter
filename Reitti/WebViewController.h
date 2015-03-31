//
//  WebViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBlurView.h"

@interface WebViewController : UIViewController<UIWebViewDelegate>{
    
    IBOutlet UILabel *titleLabel;
    IBOutlet UIView *topBarView;
    IBOutlet UIProgressView *loadProgressView;
    
    BOOL doneLoading;
    NSTimer *myTimer;
    
    UIColor *systemBackgroundColor;
    UIColor *systemTextColor;
    UIColor *systemSubTextColor;
}

@property (strong, nonatomic) NSURL *_url;
@property (strong, nonatomic) NSString *_pageTitle;
@property (strong, nonatomic) IBOutlet UIWebView *_webView;

@property (nonatomic) bool darkMode;

@end
