//
//  WelcomeViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController<UIScrollViewDelegate>{
    IBOutlet UIScrollView *mainScrollView;
    
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIButton *doneButton;
    
    IBOutlet UIImageView *logoImageView;
    IBOutlet UILabel *viewTitle;
    
    float pageWidth;
}

@end
