//
//  AppFeatureManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/20/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppFeature.h"

@interface AppFeatureManager : NSObject

+(instancetype)sharedManager;

+(BOOL)proFeaturesAvailable;

@property (nonatomic, strong, readonly)NSArray *proOnlyFeatures;

@end
