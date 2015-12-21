//
//  UIButton+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "UIButton+Helper.h"

NSInteger const kNormalCurrentLocationButtonTag = 1234;
NSInteger const kCenteredCurrentLocationButtonTag = 1235;
NSInteger const kCompasModeCurrentLocationButtonTag = 1236;

@implementation UIButton (Helper)

+(UIButton *)asa_currentLocationButtonWithFrame:(CGRect)frame andBorderColor:(UIColor *)borderColor{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button asa_updateAsCurrentLocationButtonWithBorderColor:borderColor animated:NO];
    
    return button;
}

-(void)asa_updateAsCurrentLocationButtonWithBorderColor:(UIColor *)borderColor animated:(BOOL)animated{
    self.tag = kNormalCurrentLocationButtonTag;
    
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^(){
        CGFloat xInset = self.frame.size.width/2;
        CGFloat yInset = self.frame.size.height/2;
        [self setImageEdgeInsets:UIEdgeInsetsMake(yInset, xInset, yInset, xInset)];
        //This should be called for the inset to be animated
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animated ? 0.2 : 0 animations:^(){
            [self setImage:[UIImage imageNamed:@"current location filled green.png"] forState:UIControlStateNormal];
            [self setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            self.layer.masksToBounds = YES;
            self.backgroundColor = [UIColor whiteColor];
            self.layer.borderColor = borderColor.CGColor;
            self.layer.borderWidth = 1.0f;
            self.layer.cornerRadius = 4.0;
            //This should be called for the inset to be animated
            [self layoutSubviews];
        } completion:^(BOOL finished) {}];
    }];
}

-(void)asa_updateAsCenteredAtCurrentLocationWithBackgroundColor:(UIColor *)backgroundColor animated:(BOOL)animated{
    self.tag = kCenteredCurrentLocationButtonTag;
    
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^(){
        CGFloat xInset = self.frame.size.width/2;
        CGFloat yInset = self.frame.size.height/2;
        [self setImageEdgeInsets:UIEdgeInsetsMake(yInset, xInset, yInset, xInset)];
        //This should be called for the inset to be animated
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animated ? 0.2 : 0 animations:^(){
            [self setImage:[UIImage imageNamed:@"current location filled white.png"] forState:UIControlStateNormal];
            [self setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            self.layer.masksToBounds = YES;
            self.backgroundColor = backgroundColor;
            self.layer.cornerRadius = 4.0;
            //This should be called for the inset to be animated
            [self layoutSubviews];
        } completion:^(BOOL finished) {}];
    }];
}

-(void)asa_updateAsCompassModeCurrentLocationWithBackgroundColor:(UIColor *)backgroundColor animated:(BOOL)animated{
    //Always do this outside of the animation
    self.tag = kCompasModeCurrentLocationButtonTag;
    
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^(){
        CGFloat xInset = self.frame.size.width/2;
        CGFloat yInset = self.frame.size.height/2;
        [self setImageEdgeInsets:UIEdgeInsetsMake(yInset, xInset, yInset, xInset)];
        //This should be called for the inset to be animated
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animated ? 0.2 : 0 animations:^(){
            [self setImage:[UIImage imageNamed:@"map compas mode white.png"] forState:UIControlStateNormal];
            [self setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
            self.layer.masksToBounds = YES;
            self.backgroundColor = backgroundColor;
            self.layer.cornerRadius = 4.0;
            //This should be called for the inset to be animated
            [self layoutSubviews];
        } completion:^(BOOL finished) {}];
    }];
}


@end
