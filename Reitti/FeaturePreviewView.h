//
//  FeaturePreviewView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppFeature.h"

@interface FeaturePreviewView : UIView

-(void)updateWithFeature:(AppFeature *)feature;

@end
