//
//  AppManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "AppManager.h"

@implementation AppManager

+(UIColor *)colorForLegType:(LegTransportType)legTransportType{
    switch (legTransportType) {
        case LegTypeWalk:
            return [UIColor darkGrayColor];
            break;
        case LegTypeFerry:
            return [AppManager systemCyanColor];
            break;
        case LegTypeTrain:
            return [AppManager systemRedColor];
            break;
        case LegTypeBus:
            return [AppManager systemBlueColor];
            break;
        case LegTypeTram:
            return [AppManager systemGreenColor];
            break;
        case LegTypeMetro:
            return [AppManager systemOrangeColor];
            break;
            
        default:
            return [UIColor darkGrayColor];
            break;
    }
}

+(UIColor *)colorForLineType:(LineType)lineType{
    switch (lineType) {
        case LineTypeFerry:
            return [AppManager systemCyanColor];
            break;
        case LineTypeTrain:
            return [AppManager systemRedColor];
            break;
        case LineTypeBus:
            return [AppManager systemBlueColor];
            break;
        case LineTypeTram:
            return [AppManager systemGreenColor];
            break;
        case LineTypeMetro:
            return [AppManager systemOrangeColor];
            break;
            
        default:
            return [AppManager systemBlueColor];
            break;
    }
}

#pragma mark - system images
+(UIImage *)stopAnnotationImageForStopType:(StopType)stopType{
    return [UIImage imageNamed:[AppManager stopAnnotationImageNameForStopType:stopType]];
}

+(NSString *)stopAnnotationImageNameForStopType:(StopType)stopType{
    
    if (stopType == StopTypeBus) {
        return @"busAnnotation3_2.png";
    }else if (stopType == StopTypeTrain) {
        return @"trainAnnotation3_2.png";
    }else if (stopType == StopTypeTram) {
        return @"tramAnnotation3_2.png";
    }else if (stopType == StopTypeFerry) {
        return @"ferryAnnotation3_2.png";
    }else if (stopType == StopTypeMetro) {
        return @"metroAnnotation3_2.png";
    }else{
        return @"busAnnotation3_2.png";
    }
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

+(UIImage *)vehicleImageForLegTrasnportType:(LegTransportType)type{
    switch (type) {
        case LegTypeWalk:
            return [UIImage imageNamed:@"walking-gray-64.png"];
            break;
        case LegTypeFerry:
            return [UIImage imageNamed:@"ferry-filled-cyan-100.png"];
            break;
        case LegTypeTrain:
            return [UIImage imageNamed:@"train-filled-red-100.png"];
            break;
        case LegTypeBus:
            return [UIImage imageNamed:@"bus-filled-blue-100.png"];
            break;
        case LegTypeTram:
            return [UIImage imageNamed:@"tram-filled-green-100.png"];
            break;
        case LegTypeMetro:
            return [UIImage imageNamed:@"metro-logo-orange.png"];
            break;
            
        default:
            return [UIImage imageNamed:@"bus-filled-blue-100.png"];
            break;
    }
}

+(UIImage *)lightColorImageForLegTransportType:(LegTransportType)type{
    switch (type) {
        case LegTypeBus:
            return [UIImage imageNamed:@"bus-filled-light-100.png"];
            break;
        case LegTypeTrain:
            return [UIImage imageNamed:@"train-filled-light-64.png"];
            break;
        case LegTypeMetro:
            return [UIImage imageNamed:@"metro-logo-orange.png"];
            break;
        case LegTypeTram:
            return [UIImage imageNamed:@"tram-filled-light-64.png"];
            break;
        case LegTypeFerry:
            return [UIImage imageNamed:@"boat-filled-light-100.png"];
            break;
        case LegTypeService:
            return [UIImage imageNamed:@"service-bus-filled-purple.png"];
            break;
        case LegTypeWalk:
            return [UIImage imageNamed:@"walking-gray-64.png"];
            break;
            
        default:
            return [UIImage imageNamed:@"bus-filled-light-100.png"];
            break;
    }
}


+(UIImage *)vehicleImageForLineType:(LineType)type{
    return [AppManager vehicleImageForLegTrasnportType:[EnumManager legTrasportTypeForLineType:type]];
}

@end
