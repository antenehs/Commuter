//
//  UIView+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "UIView+Helper.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Helper)

- (void)asa_bounceAnimateViewByScale:(double)scale{
    CGRect origFrame = self.frame;
    CGFloat widthDiff = origFrame.size.width * scale;
    CGFloat heightDiff = origFrame.size.height * scale;
    CGFloat scaledWidth = origFrame.size.width + widthDiff;
    CGFloat scaledHeight = origFrame.size.height + heightDiff;
    CGRect scaledFrame = CGRectMake(origFrame.origin.x - widthDiff/2, origFrame.origin.y - heightDiff/2, scaledWidth , scaledHeight);
    
    [UIView transitionWithView:self duration:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = scaledFrame;
    } completion:^(BOOL finished) {
        //                centerLocatorView.frame = CGRectMake(self.mapView.center.x - 10, self.mapView.center.y + 10, 20, 20);
        [UIView transitionWithView:self duration:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = origFrame;
        } completion:^(BOOL finished) {}];
    }];
}

- (void)asa_growHorizontalAnimationFromZero:(NSTimeInterval)animationSeconds{
    CGRect origFrame = self.frame;
    self.frame = CGRectMake(origFrame.origin.x, origFrame.origin.y, 0, origFrame.size.width);
    
    [UIView transitionWithView:self duration:animationSeconds options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = origFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)asa_springAnimationWithDuration:(NSTimeInterval)duration animation:(void (^)(void))animation completion:(void (^ __nullable)(BOOL finished))completion {
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:1.1
                        options:0
                     animations:animation completion:completion];
}

- (UIImage *)asa_convertToImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

- (void)asa_SetBlurredBackgroundWithImageNamed:(NSString *)imageName{
    if (imageName == nil) {
        imageName = @"launch-screen-bkgrnd-3.png";
    }
    
    UIView *bluredBackViewContainer = [[UIView alloc] initWithFrame:self.bounds];
    bluredBackViewContainer.backgroundColor = [UIColor whiteColor];
    UIImageView *pictureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    pictureView.frame = bluredBackViewContainer.frame;
    pictureView.alpha = 0.9;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.alpha = 0.98;
    
    [bluredBackViewContainer addSubview:pictureView];
    [bluredBackViewContainer addSubview:blurEffectView];
    
    [self insertSubview:bluredBackViewContainer atIndex:0];
}
@end
