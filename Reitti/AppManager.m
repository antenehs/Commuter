//
//  AppManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "AppManager.h"

@implementation AppManager

+(int)getAndIncrimentAppOpenCountForRating{
    int appOpenCount = [AppManager getAppOpenCountForRating];
    
    [AppManager setAppOpenCountForRating:appOpenCount + 1];
    
    return appOpenCount;
}

+(int)getAppOpenCountForRating{
    NSNumber *appOpenCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppOpenCountForRating"];
    if (appOpenCount != nil) {
        return [appOpenCount intValue];
    }
    
    [AppManager setAppOpenCountForRating:0];
    return 0;
}

+(void)setAppOpenCountForRating:(int)count{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithInt:count] forKey:@"AppOpenCountForRating"];
        [standardUserDefaults synchronize];
    }
}

+(int)getAndIncrimentAppOpenCountForGoingPro{
    int appOpenCount = [AppManager getAppOpenCountForGoingPro];
    
    [AppManager setAppOpenCountForGoingPro:appOpenCount + 1];
    
    return appOpenCount;
}

+(int)getAppOpenCountForGoingPro{
    NSNumber *appOpenCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppOpenCountForGoingPro"];
    if (appOpenCount != nil) {
        return [appOpenCount intValue];
    }
    
    [AppManager setAppOpenCountForRating:0];
    return 0;
}

+(void)setAppOpenCountForGoingPro:(int)count{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithInt:count] forKey:@"AppOpenCountForGoingPro"];
        [standardUserDefaults synchronize];
    }
}


+(UIColor *)colorForLegType:(LegTransportType)legTransportType{
    switch (legTransportType) {
        case LegTypeWalk:
            return [UIColor darkGrayColor];
        case LegTypeFerry:
            return [AppManager systemCyanColor];
        case LegTypeTrain:
        case LegTypeLongDistanceTrain:
            return [AppManager systemRedColor];
        case LegTypeBus:
            return [AppManager systemBlueColor];
        case LegTypeTram:
            return [AppManager systemGreenColor];
        case LegTypeMetro:
            return [AppManager systemOrangeColor];
        case LegTypeAirplane:
            return [AppManager systemPurpleColor];
        case LegTypeBicycle:
            return [AppManager systemYellowColor];
            
        default:
            return [UIColor darkGrayColor];
    }
}

+(UIColor *)colorForLineType:(LineType)lineType{
    switch (lineType) {
        case LineTypeFerry:
            return [AppManager systemCyanColor];
        case LineTypeTrain:
        case LineTypeLongDistanceTrain:
            return [AppManager systemRedColor];
        case LineTypeBus:
            return [AppManager systemBlueColor];
        case LineTypeTram:
            return [AppManager systemGreenColor];
        case LineTypeMetro:
            return [AppManager systemOrangeColor];
        case LineTypeAirplane:
            return [AppManager systemPurpleColor];
        case LineTypeBicycle:
            return [AppManager systemYellowColor];
        default:
            return [AppManager systemBlueColor];
            break;
    }
}

+(UIColor *)colorForStopType:(StopType)stopType{
    switch (stopType) {
        case StopTypeFerry:
            return [AppManager systemCyanColor];
        case StopTypeTrain:
            return [AppManager systemRedColor];
        case StopTypeBus:
            return [AppManager systemBlueColor];
        case StopTypeTram:
            return [AppManager systemGreenColor];
        case StopTypeMetro:
            return [AppManager systemOrangeColor];
        case StopTypeAirport:
            return [AppManager systemPurpleColor];
        case StopTypeBikeStation:
            return [AppManager systemYellowColor];
            
        default:
            return [AppManager systemBlueColor];
            break;
    }
}

#pragma mark - device related

#ifndef APPLE_WATCH
+(NSString *)iosDeviceName{
    return [[UIDevice currentDevice] name];
}

+(NSString *)iosDeviceModel{
    return [[UIDevice currentDevice] model];
}

+(NSString *)iosVersionNumber{
    return [[UIDevice currentDevice] systemVersion];
}

//+(NSString *)iosDeviceUniqueIdentifier{
//    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//}
#endif

#pragma mark - system images
+(UIImage *)stopAnnotationImageForStopType:(StopType)stopType{
    return [UIImage imageNamed:[AppManager stopAnnotationImageNameForStopType:stopType]];
}

+(NSString *)stopAnnotationImageNameForStopType:(StopType)stopType{
    if (stopType == StopTypeBus) {
        return @"BusAnnotationFlat";
    }else if (stopType == StopTypeTrain) {
        return @"TrainAnnotationFlat";
    }else if (stopType == StopTypeTram) {
        return @"TramAnnotationFlat";
    }else if (stopType == StopTypeFerry) {
        return @"FerryAnnotationFlat";
    }else if (stopType == StopTypeMetro) {
        return @"MetroAnnotationFlat";
    }else if (stopType == StopTypeAirport) {
        return @"AirportAnnotationFlat";
    }else if (stopType == StopTypeBikeStation) {
        return @"BikeStation-100";
    }else{
        return @"BusAnnotationFlat";
    }
}

+(UIImage *)stopIconForStopType:(StopType)stopType {
    LineType lineType = [EnumManager lineTypeForStopType:stopType];
    return [self lineIconForLineType:lineType];
}

+(NSString *)stopIconNameForStopType:(StopType)stopType {
    LineType lineType = [EnumManager lineTypeForStopType:stopType];
    return [self lineIconNameForLineType:lineType];
}

+(UIImage *)vehicleImageForVehicleType:(VehicleType)type{
    if (type == VehicleTypeTram) {
        return [UIImage imageNamed:@"tramVAnnot.png"];
    }else if (type == VehicleTypeTrain) {
        return [UIImage imageNamed:@"trainVAnnot.png"];
    }else if (type == VehicleTypeMetro) {
        return [UIImage imageNamed:@"metroVAnnot.png"];
    }else if (type == VehicleTypeBus) {
        return [UIImage imageNamed:@"BusVAnnot.png"];
    }else if (type == VehicleTypeLongDistanceTrain) {
        return [UIImage imageNamed:@"trainVAnnot.png"];
    }else {
        return [UIImage imageNamed:@"tramVAnnot.png"];
    }
}

+(UIImage *)vehicleImageWithNoBearingForVehicleType:(VehicleType)type{
    if (type == VehicleTypeTram) {
        return [UIImage imageNamed:@"tramVAnnot-no-bearing.png"];
    }else if (type == VehicleTypeTrain) {
        return [UIImage imageNamed:@"trainVAnnot-no-bearing.png"];
    }else if (type == VehicleTypeMetro) {
        return [UIImage imageNamed:@"metroVAnnot-no-bearing.png"];
    }else if (type == VehicleTypeBus) {
        return [UIImage imageNamed:@"BusVAnnot-no-bearing.png"];
    }else if (type == VehicleTypeLongDistanceTrain) {
        return [UIImage imageNamed:@"trainVAnnot-no-bearing.png"];
    }else {
        return [UIImage imageNamed:@"tramVAnnot-no-bearing.png"];
    }
}

+(UIImage *)vehicleImageForLegTrasnportType:(LegTransportType)type{
    switch (type) {
        case LegTypeWalk:
            return [UIImage imageNamed:@"walking-gray-64.png"];
        case LegTypeFerry:
            return [UIImage imageNamed:@"ferry-filled-cyan-100.png"];
        case LegTypeTrain:
            return [UIImage imageNamed:@"train-filled-red-100.png"];
        case LegTypeBus:
            return [UIImage imageNamed:@"bus-filled-blue-100.png"];
        case LegTypeTram:
            return [UIImage imageNamed:@"tram-filled-green-100.png"];
        case LegTypeMetro:
            return [UIImage imageNamed:@"metro-logo-orange.png"];
        case LegTypeLongDistanceTrain:
            return [UIImage imageNamed:@"longDistTrainColor"];
        case LegTypeAirplane:
            return [UIImage imageNamed:@"airplaneColor"];
        case LegTypeBicycle:
            return [UIImage imageNamed:@"bikeYellow"];
            
        default:
            return [UIImage imageNamed:@"bus-filled-blue-100.png"];
            break;
    }
}

+(UIImage *)lightColorImageForLegTransportType:(LegTransportType)type{
    switch (type) {
        case LegTypeBus:
            return [UIImage imageNamed:@"bus-filled-light-100"];
        case LegTypeTrain:
            return [UIImage imageNamed:@"train-filled-light-64"];
        case LegTypeMetro:
            return [UIImage imageNamed:@"metro-logo-orange"];
        case LegTypeTram:
            return [UIImage imageNamed:@"tram-filled-light-64"];
        case LegTypeFerry:
            return [UIImage imageNamed:@"boat-filled-light-100"];
        case LegTypeService:
            return [UIImage imageNamed:@"service-bus-filled-purple"];
        case LegTypeWalk:
            return [UIImage imageNamed:@"walking-gray-64"];
        case LegTypeLongDistanceTrain:
            return [UIImage imageNamed:@"longDistTrainLight"];
        case LegTypeAirplane:
            return [UIImage imageNamed:@"airplaneLight"];
        case LegTypeBicycle:
            return [UIImage imageNamed:@"bikeYellow"];
            
        default:
            return [UIImage imageNamed:@"bus-filled-light-100.png"];
            break;
    }
}

+(NSString *)complicationImageNameForLegTransportType:(LegTransportType)type{
    switch (type) {
        case LegTypeBus:
            return @"Utilitarian-bus";
        case LegTypeTrain:
            return @"Utilitarian-train";
        case LegTypeMetro:
            return @"Utilitarian-metro";
        case LegTypeTram:
            return @"Utilitarian-tram";
        case LegTypeFerry:
            return @"Utilitarian-ferry";
        case LegTypeAirplane:
            return @"Utilitarian-airplane";
            
        default:
            return @"Utilitarian-bus";
            break;
    }
}

+(UIImage *)vehicleImageForLineType:(LineType)type{
    return [AppManager vehicleImageForLegTrasnportType:[EnumManager legTrasportTypeForLineType:type]];
}

+(UIImage *)lineIconForLineType:(LineType)type {
    return [UIImage imageNamed:[self lineIconNameForLineType:type]];
}

+(NSString *)lineIconNameForLineType:(LineType)type {
    if (type == LineTypeBus) {
        return @"busStopIcon";
    }else if (type == LineTypeTrain || type == LineTypeLongDistanceTrain) {
        return @"trainStopIcon";
    }else if (type == LineTypeTram) {
        return @"tramStopIcon";
    }else if (type == LineTypeFerry) {
        return @"ferryStopIcon";
    }else if (type == LineTypeMetro) {
        return @"metroStationIcon";
    }else if (type == LineTypeAirplane) {
        return @"airportIcon";
    }else if (type == LineTypeBicycle) {
        return @"bikeStationIcon";
    }else{
        return @"busStopIcon";
    }
}

#ifndef APPLE_WATCH
+(NSString *)stationAnnotionImageNameForBikeStation:(BikeStation *)bikeStation {
    if (bikeStation.bikeAvailability == NotAvailable) {
        return @"BikeStation-0";
    } else if (bikeStation.bikeAvailability == LowAvailability) {
        return @"BikeStation-25";
    } else if (bikeStation.bikeAvailability == HalfAvailability) {
        return @"BikeStation-50";
    } else if (bikeStation.bikeAvailability == HighAvailability) {
        return @"BikeStation-75";
    } else {
        return @"BikeStation-100";
    }
}
#endif

@end
