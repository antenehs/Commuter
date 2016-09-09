//
//  TodayViewController.h
//  Commuter - Departures
//
//  Created by Anteneh Sahledengel on 30/10/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    
    IBOutlet UIButton *routesButton;
    IBOutlet UIButton *bookmarksButton;
    IBOutlet UILabel *infoLabel;
    IBOutlet UITableView *departuresTable;
    
    UIButton *moreButton;
    IBOutlet UILabel *loadingLabel;
    
    IBOutlet NSLayoutConstraint *routeButtonTopConstraint;
    IBOutlet NSLayoutConstraint *bookmarkButtonTopConstraint;
    
    IBOutlet UIView *firstStopView;
    IBOutlet UIView *secondStopView;
    IBOutlet UIView *thirdStopView;
    
    IBOutlet UIButton *firstViewButton;
    IBOutlet UIButton *secondViewButton;
    IBOutlet UIButton *thirdViewButton;
    
    
    IBOutlet UIButton *footerButton;
    
    BOOL isIOS10;
}

@end
