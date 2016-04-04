//
//  WelcomeViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RettiDataManager.h"

@interface WelcomeViewController : UIViewController<UIScrollViewDelegate>{
    IBOutlet UIScrollView *mainScrollView;
    
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIButton *doneButton;
    
    IBOutlet UIImageView *logoImageView;
    IBOutlet UILabel *viewTitle;
    
    IBOutlet UIView *scrollingBackView;
    
    float pageWidth;
}

@property (nonatomic)Region region;

@end
