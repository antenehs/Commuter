//
//  AppManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteLeg.h"
#import "AppManagerBase.h"

#ifndef APPLE_WATCH
#import "BikeStation.h"
#import "NearByStop.h"
#endif

@interface AppManager : AppManagerBase

+(int)getAndIncrimentAppOpenCountForRating;
+(int)getAppOpenCountForRating;
+(void)setAppOpenCountForRating:(int)count;
+(int)getAndIncrimentAppOpenCountForGoingPro;
+(int)getAppOpenCountForGoingPro;
+(void)setAppOpenCountForGoingPro:(int)count;

+(UIColor *)colorForLegType:(LegTransportType)legTransportType;
+(UIColor *)colorForLineType:(LineType)lineType;
+(UIColor *)colorForStopType:(StopType)stopType;

+(NSString *)iosDeviceName;
+(NSString *)iosDeviceModel;
+(NSString *)iosVersionNumber;
+(NSString *)iosDeviceUniqueIdentifier;

//App images
+(UIImage *)stopAnnotationImageForStopType:(StopType)stopType;
+(NSString *)stopAnnotationImageNameForStopType:(StopType)stopType;
+(UIImage *)stopIconForStopType:(StopType)stopType;
+(NSString *)stopIconNameForStopType:(StopType)stopType;
+(UIImage *)vehicleImageForVehicleType:(VehicleType)type;
+(UIImage *)vehicleImageWithNoBearingForVehicleType:(VehicleType)type;
+(UIImage *)vehicleImageForLineType:(LineType)type;
+(UIImage *)lineIconForLineType:(LineType)type;
+(NSString *)lineIconNameForLineType:(LineType)type;
+(UIImage *)vehicleImageForLegTrasnportType:(LegTransportType)type;
+(UIImage *)lightColorImageForLegTransportType:(LegTransportType)type;
+(NSString *)complicationImageNameForLegTransportType:(LegTransportType)type;

#ifndef APPLE_WATCH
+(NSString *)stationAnnotionImageNameForBikeStation:(BikeStation *)bikeStation;
#endif

@end
