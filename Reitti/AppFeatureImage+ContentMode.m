//
//  AppFeature+ContentMode.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/2/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "AppFeatureImage+ContentMode.h"

@implementation AppFeatureImage (ContentMode)

-(UIViewContentMode)featureImageViewContentMode {
    if (self.imageContentMode == FeatureImageContentModeCenter) return UIViewContentModeCenter;
    if (self.imageContentMode == FeatureImageContentModeBottom) return UIViewContentModeBottom;
    if (self.imageContentMode == FeatureImageContentModeTop) return UIViewContentModeTop;
    if (self.imageContentMode == FeatureImageContentModeScaleAspectFit) return UIViewContentModeScaleAspectFit;
    
    NSAssert(false, @"It shouldn't get here");
    return UIViewContentModeScaleAspectFit;
}

@end
