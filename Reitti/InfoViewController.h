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
    InfoViewModeLiveAllDisruptions = 0,
    InfoViewModeStaticRouteDisruptions = 1
}InfoViewControllerMode;

@interface InfoViewController : UIViewController<UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ADBannerViewDelegate>{
    
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
    
    ADBannerView *_bannerView;
}

@property (strong, nonatomic) NSArray * disruptionsList;

@property (nonatomic) InfoViewControllerMode viewControllerMode;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;

@property (strong, nonatomic) SettingsManager *settingsManager;

@end
