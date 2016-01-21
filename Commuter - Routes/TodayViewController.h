//
//  TodayViewController.h
//  Commuter - Routes
//
//  Created by Anteneh Sahledengel on 8/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBPopupBubbleView.h"
#import "JTMaterialSpinner.h"

@interface TodayViewController : UIViewController <UIScrollViewDelegate>{
    
//    IBOutlet UIView *bookmarksContainerView;
    IBOutlet UIScrollView *bookmarksScrollView;
    IBOutlet UIView *detailContainerView;
    
    IBOutlet UIButton *rightScrollViewButton;
    IBOutlet UIButton *leftScrollViewButton;
    
    IBOutlet JTMaterialSpinner *activityIndicator;
    
    IBOutlet UILabel *infoLabel;
    IBOutlet UIButton *addBookmarkButton;
    
    IBOutlet UILabel *bookmarkNameLabel;
    
    
    IBOutlet UIView *routeInfoContainerView;
    IBOutlet UIScrollView *routeViewScrollView;
    IBOutlet UILabel *routeLeaveAtLabel;
    IBOutlet UILabel *routeArriveAtLabel;
    IBOutlet UILabel *routeMoreDetailLabel;
    
    NSTimer *userLocationWaitTimer;
    
}

@end
