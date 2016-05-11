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
- (void)asa_springAnimationWithDuration:(NSTimeInterval)duration animation:(void (^ _Nonnull)(void))animation completion:(void (^ __nullable)(BOOL finished))completion;
- (UIImage * _Nonnull)asa_convertToImage;

- (void)asa_SetBlurredBackgroundWithImageNamed:(NSString * __nullable)imageName;
@end
