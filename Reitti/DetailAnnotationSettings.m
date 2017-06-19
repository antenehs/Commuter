//
//  DetailAnnotationSettings.m
//  CustomCallout
//
//  Created by Selvin on 12/04/15.
//  Copyright (c) 2015 S3lvin. All rights reserved.
//

#import "DetailAnnotationSettings.h"

@implementation DetailAnnotationSettings

+ (instancetype)defaultSettings {
    DetailAnnotationSettings *newSettings = [[super alloc] init];
    if (newSettings) {
        newSettings.calloutOffset = 15.0f;

        newSettings.shouldRoundifyCallout = YES;
        newSettings.calloutCornerRadius = 10.0f;

        newSettings.shouldAddCalloutBorder = YES;
        newSettings.calloutBorderColor = [UIColor lightGrayColor];
        newSettings.calloutBorderWidth = 0.5;

        newSettings.showAnimationType = DetailCalloutAnimationFadeIn;
        newSettings.hideAnimationType = DetailCalloutAnimationFadeIn;
        newSettings.animationDuration = 0.1;
    }
    return newSettings;
}

@end
