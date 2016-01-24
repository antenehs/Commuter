//
//  UIView+Helper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (Helper)

- (void)asa_bounceAnimateViewByScale:(double)scale;
- (void)asa_growHorizontalAnimationFromZero:(NSTimeInterval)animationSeconds;
- (UIImage *)asa_convertToImage;

- (void)asa_SetBlurredBackgroundWithImageNamed:(NSString *)imageName;
@end
