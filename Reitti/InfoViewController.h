//
//  InfoViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "RettiDataManager.h"
#import "SettingsManager.h"

@interface InfoViewController : UIViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ReittiDisruptionFetchDelegate>{
    
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
    
}

@property (strong, nonatomic) NSArray * disruptionsList;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;

@property (strong, nonatomic) SettingsManager *settingsManager;

@end
