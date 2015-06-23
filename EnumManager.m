//
//  EnumManager.m
//  
//
//  Created by Anteneh Sahledengel on 15/6/15.
//
//

#import "EnumManager.h"

@implementation EnumManager

+(StopType)stopTypeForGDTypeString:(NSString *)type{
    //    typedef enum
    //    {
    //        StopTypeBus = 0,
    //        StopTypeTram = 1,
    //        StopTypeTrain = 2,
    //        StopTypeMetro = 3,
    //        StopTypeFerry = 4,
    //        StopTypeOther = 5
    //    } StopType;
    
    //    1 = Helsinki internal bus lines
    //    2 = trams
    //    3 = Espoo internal bus lines
    //    4 = Vantaa internal bus lines
    //    5 = regional bus lines
    //    6 = metro
    //    7 = ferry
    //    8 = U-lines
    //    12 = commuter trains
    //    21 = Helsinki service lines
    //    22 = Helsinki night buses
    //    23 = Espoo service lines
    //    24 = Vantaa service lines
    //    25 = region night buses
    //    36 = Kirkkonummi internal bus lines
    //    39 = Kerava internal bus lines
    
    if ([type isEqualToString:@"2"]) {
        return StopTypeTram;
    }else if ([type isEqualToString:@"6"]) {
        return StopTypeMetro;
    }else if ([type isEqualToString:@"12"]) {
        return StopTypeTrain;
    }else if ([type isEqualToString:@"3"]) {
        return StopTypeBus;
    }else if ([type isEqualToString:@"7"]) {
        return StopTypeFerry;
    }else{
        return StopTypeBus;
    }
}


+(StopType)stopTypeForPubTransStopType:(NSString *)type{
    if ([type isEqualToString:@"tram"]) {
        return StopTypeTram;
    }else if ([type isEqualToString:@"train"]) {
        return StopTypeTrain;
    }else if ([type isEqualToString:@"metro"]) {
        return StopTypeMetro;
    }else if ([type isEqualToString:@"bus"]) {
        return StopTypeBus;
    }else if ([type isEqualToString:@"ferry"]) {
        return StopTypeFerry;
    }else {
        return StopTypeBus;
    }
}

+(StopType)stopTypeFromLegType:(LegTransportType)type{

    switch (type) {
        case LegTypeBus:
            return StopTypeBus;
            break;
            
        case LegTypeTram:
            return StopTypeTram;
            break;
            
        case LegTypeTrain:
            return StopTypeTrain;
            break;
            
        case LegTypeMetro:
            return StopTypeMetro;
            break;
            
        case LegTypeFerry:
            return StopTypeFerry;
            break;
            
        case LegTypeOther:
            return StopTypeOther;
            break;
            
        default:
            return StopTypeOther;
            break;
    }
}

+(VehicleType)vehicleTypeForTypeName:(NSString *)type{
    if ([type isEqualToString:@"tram"]) {
        return VehicleTypeTram;
    }else if ([type isEqualToString:@"train"]) {
        return VehicleTypeTrain;
    }else if ([type isEqualToString:@"metro"]) {
        return VehicleTypeMetro;
    }else if ([type isEqualToString:@"bus"]) {
        return VehicleTypeBus;
    }else if ([type isEqualToString:@"longdistancetrain"]) {
        return VehicleTypeLongDistanceTrain;
    }else {
        return VehicleTypeOther;
    }
}

+(VehicleType)vehicleTypeForLineType:(LineType)lineType{
    if (lineType == LineTypeTram) {
        return VehicleTypeTram;
    }else if (lineType == LineTypeMetro) {
        return VehicleTypeMetro;
    }else if (lineType == LineTypeFerry) {
        return VehicleTypeFerry;
    }else if (lineType == LineTypeTrain) {
        return VehicleTypeTrain;
    }else if (lineType == LineTypeBus) {
        return VehicleTypeBus;
    }else{
        return VehicleTypeOther;
    }
}

+(LineType)lineTypeForHSLLineTypeId:(NSString *)type{
    //    1 = Helsinki internal bus lines
    //    2 = trams
    //    3 = Espoo internal bus lines
    //    4 = Vantaa internal bus lines
    //    5 = regional bus lines
    //    6 = metro
    //    7 = ferry
    //    8 = U-lines
    //    12 = commuter trains
    //    21 = Helsinki service lines
    //    22 = Helsinki night buses
    //    23 = Espoo service lines
    //    24 = Vantaa service lines
    //    25 = region night buses
    //    36 = Kirkkonummi internal bus lines
    //    39 = Kerava internal bus lines
    
    if ([type isEqualToString:@"2"]) {
        return LineTypeTram;
    }else if ([type isEqualToString:@"6"]) {
        return LineTypeMetro;
    }else if ([type isEqualToString:@"7"]) {
        return LineTypeFerry;
    }else if ([type isEqualToString:@"12"]) {
        return LineTypeTrain;
    }else{
        return LineTypeBus;
    }
}

+(LineType)lineTypeForVehicleType:(VehicleType)vehicleType{
    if (vehicleType == VehicleTypeTram) {
        return LineTypeTram;
    }else if (vehicleType == VehicleTypeMetro) {
        return LineTypeMetro;
    }else if (vehicleType == VehicleTypeFerry) {
        return LineTypeFerry;
    }else if (vehicleType == VehicleTypeTrain) {
        return LineTypeTrain;
    }else if (vehicleType == VehicleTypeBus) {
        return LineTypeBus;
    }else{
        return LineTypeOther;
    }
}

+(LegTransportType)legTrasportTypeForLineType:(LineType)lineType{
    if (lineType == LineTypeTram) {
        return LegTypeTram;
    }else if (lineType == LineTypeMetro) {
        return LegTypeMetro;
    }else if (lineType == LineTypeFerry) {
        return LegTypeFerry;
    }else if (lineType == LineTypeTrain) {
        return LegTypeTrain;
    }else if (lineType == LineTypeBus) {
        return LegTypeBus;
    }else{
        return LegTypeOther;
    }
}

@end
