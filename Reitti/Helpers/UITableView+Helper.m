//
//  UITableView+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 30/11/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "UITableView+Helper.h"

@implementation UITableView (Helper)

- (void)setBlurredBackgroundWithImageNamed:(NSString *)imageName{
    if (imageName == nil) {
        imageName = @"map_background.png";
    }
    
    UIView *bluredBackViewContainer = [[UIView alloc] initWithFrame:self.bounds];
    bluredBackViewContainer.backgroundColor = [UIColor whiteColor];
    UIImageView *mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    mapImageView.frame = bluredBackViewContainer.frame;
    mapImageView.alpha = 0.5;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [bluredBackViewContainer addSubview:mapImageView];
    [bluredBackViewContainer addSubview:blurEffectView];
    
    self.backgroundView = bluredBackViewContainer;
    self.backgroundColor = [UIColor clearColor];
}

@end
