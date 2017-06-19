//
//  DetailAnnotationSettings.h
//  CustomCallout
//
//  Created by Selvin on 12/04/15.
//  Copyright (c) 2015 S3lvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DetailCalloutAnimation) {
    DetailCalloutAnimationNone,
    DetailCalloutAnimationFadeIn,
    DetailCalloutAnimationZoomIn
};

@interface DetailAnnotationSettings : NSObject

@property(nonatomic, assign) CGFloat calloutOffset;

@property(nonatomic, assign) BOOL shouldRoundifyCallout;
@property(nonatomic, assign) CGFloat calloutCornerRadius;

@property(nonatomic, assign) BOOL shouldAddCalloutBorder;
@property(nonatomic, strong) UIColor *calloutBorderColor;
@property(nonatomic, assign) CGFloat calloutBorderWidth;

@property(nonatomic, assign) DetailCalloutAnimation showAnimationType;
@property(nonatomic, assign) DetailCalloutAnimation hideAnimationType;
@property(nonatomic, assign) NSTimeInterval animationDuration;

+ (instancetype)defaultSettings;

@end
