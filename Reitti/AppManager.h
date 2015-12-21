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
#import "AppManagerBase.h"

@interface AppManager : AppManagerBase

+(UIColor *)colorForLegType:(LegTransportType)legTransportType;
+(UIColor *)colorForLineType:(LineType)lineType;
+(UIColor *)colorForStopType:(StopType)stopType;

//App images
+(UIImage *)stopAnnotationImageForStopType:(StopType)stopType;
+(NSString *)stopAnnotationImageNameForStopType:(StopType)stopType;
+(UIImage *)vehicleImageForVehicleType:(VehicleType)type;
+(UIImage *)vehicleImageForLineType:(LineType)type;
+(UIImage *)vehicleImageForLegTrasnportType:(LegTransportType)type;
+(UIImage *)lightColorImageForLegTransportType:(LegTransportType)type;

@end
