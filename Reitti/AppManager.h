//
//  AppManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearByStop.h"
#import "RouteLeg.h"

@interface AppManager : NSObject

+(BOOL)isNewInstallOrNewVersion;
+(void)setCurrentAppVersion;

//App theme
+(UIColor *)systemGreenColor;
+(UIColor *)systemOrangeColor;
+(UIColor *)systemBlueColor;
+(UIColor *)systemRedColor;
+(UIColor *)systemCyanColor;

+(UIColor *)colorForLegType:(LegTransportType)legTransportType;

//App images
+(UIImage *)stopAnnotationImageForStopType:(StopType)stopType;

@end
