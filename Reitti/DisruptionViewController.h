//
//  InfoViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>
#import "RettiDataManager.h"
#import "SettingsManager.h"

typedef enum{
    DisruptionViewModeLiveAllDisruptions = 0,
    DisruptionViewModeStaticRouteDisruptions = 1
}DisruptionViewControllerMode;

@interface DisruptionViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ADBannerViewDelegate>{
    
    IBOutlet UITableView *disruptionsTableView;
    IBOutlet UIScrollView *mainScrollView;
    IBOutlet UILabel *noDisruptionLabel;
    IBOutlet UIButton *checkDisruptionButton;
    IBOutlet UIActivityIndicatorView *refreshActivityIndicator;
    
    IBOutlet UIImageView *titleImageView;
    IBOutlet UILabel *titleLabel;
    
    IBOutlet UIView *aboutContainerView;
    
    CGFloat aboutCommuterCellOriginY;
    
    NSTimer *refreshTimer;
    
    IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
    
    BOOL searchedForDisruptions;
    
    ADBannerView *_bannerView;
}

@property (strong, nonatomic) NSArray * disruptionsList;

@property (nonatomic) DisruptionViewControllerMode viewControllerMode;

@property (strong, nonatomic) SettingsManager *settingsManager;

@end
