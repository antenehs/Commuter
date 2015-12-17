//
//  UIButton+Helper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSInteger const kNormalCurrentLocationButtonTag;
extern NSInteger const kCenteredCurrentLocationButtonTag;
extern NSInteger const kCompasModeCurrentLocationButtonTag;

@interface UIButton (Helper)

+(UIButton *)asa_currentLocationButtonWithFrame:(CGRect)frame andBorderColor:(UIColor *)borderColor;

-(void)asa_updateAsCurrentLocationButtonWithBorderColor:(UIColor *)borderColor animated:(BOOL)animated;
-(void)asa_updateAsCenteredAtCurrentLocationWithBackgroundColor:(UIColor *)backgroundColor animated:(BOOL)animated;
-(void)asa_updateAsCompassModeCurrentLocationWithBackgroundColor:(UIColor *)backgroundColor animated:(BOOL)animated;
@end
