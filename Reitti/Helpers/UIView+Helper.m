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

- (UIImage *)asa_convertToImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

@end
