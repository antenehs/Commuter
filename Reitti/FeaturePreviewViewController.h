//
//  FeaturePreviewViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/27/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FeaturePreviewModeProFeatures = 1,
    FeaturePreviewModeNewInVersion = 2
} FeaturePreviewMode;

@interface FeaturePreviewViewController : UIViewController

+(instancetype)instantiateForMode:(FeaturePreviewMode)mode;

@end
