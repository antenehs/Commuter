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
        case LegTypeTram:
            return StopTypeTram;
        case LegTypeTrain:
            return StopTypeTrain;
        case LegTypeMetro:
            return StopTypeMetro;
        case LegTypeFerry:
            return StopTypeFerry;
        case LegTypeLongDistanceTrain:
            return StopTypeTrain;
        case LegTypeAirplane:
            return StopTypeAirport;
        case LegTypeOther:
            return StopTypeOther;
        case LegTypeBicycle:
            return StopTypeBikeStation;
        default:
            return StopTypeOther;
    }
}

+(StopType)stopTypeFromLineType:(LineType)lineType {
    
    switch (lineType) {
        case LineTypeBus:
            return StopTypeBus;
        case LineTypeTram:
            return StopTypeTram;
        case LineTypeTrain:
            return StopTypeTrain;
        case LineTypeMetro:
            return StopTypeMetro;
        case LineTypeFerry:
            return StopTypeFerry;
        case LineTypeLongDistanceTrain:
            return StopTypeTrain;
        case LineTypeAirplane:
            return StopTypeAirport;
        case LineTypeOther:
            return StopTypeOther;
        case LineTypeBicycle:
            return StopTypeBikeStation;
        default:
            return StopTypeOther;
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
    }else if ([type isEqualToString:@"airplane"]) {
        return VehicleTypeAirplane;
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
    }else if (lineType == LineTypeLongDistanceTrain) {
        return VehicleTypeLongDistanceTrain;
    }else if (lineType == LineTypeAirplane) {
        return VehicleTypeAirplane;
    }else{
        return VehicleTypeUnknown;
    }
}

+(LineType)lineTypeForHSLLineTypeId:(NSString *)type{
    //    1 = Helsinki internal bus lines // All buses in new API
    //    2 = trams
    //    3 = Espoo internal bus lines
    //    4 = Vantaa internal bus lines
    //    5 = regional bus lines
    //    6 = metro
    //    7 = ferry
    //    8 = U-lines
    //    12 = commuter trains
    //    21 = Helsinki service lines //All neighboring buses in new api
    //    22 = Helsinki night buses
    //    23 = Espoo service lines
    //    24 = Vantaa service lines
    //    25 = region night buses
    //    36 = Kirkkonummi internal bus lines
    //    39 = Kerava internal bus lines
    //    50 = Helsinki city bike
    
    if ([type isEqualToString:@"2"]) {
        return LineTypeTram;
    }else if ([type isEqualToString:@"6"]) {
        return LineTypeMetro;
    }else if ([type isEqualToString:@"7"]) {
        return LineTypeFerry;
    }else if ([type isEqualToString:@"12"]) {
        return LineTypeTrain;
    }else if ([type isEqualToString:@"50"]) {
        return LineTypeBicycle;
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
    }else if (vehicleType == VehicleTypeLongDistanceTrain) {
        return LineTypeLongDistanceTrain;
    }else if (vehicleType == VehicleTypeAirplane) {
        return LineTypeAirplane;
    }else{
        return LineTypeOther;
    }
}

+(LineType)lineTypeForStopType:(StopType)stopType {
    switch (stopType) {
        case StopTypeBus:
            return LineTypeBus;
        case StopTypeTram:
            return LineTypeTram;
        case StopTypeMetro:
            return LineTypeMetro;
        case StopTypeFerry:
            return LineTypeFerry;
        case StopTypeTrain:
            return LineTypeTrain;
        case StopTypeAirport:
            return LineTypeAirplane;
        case StopTypeOther:
            return LineTypeOther;
        case StopTypeBikeStation:
            return LineTypeBicycle;
        default:
            return LineTypeBus;
    }
}

+(NSString *)lineDisplayName:(LegTransportType)legType forLineCode:(NSString *)lineCode {
    switch (legType) {
        case LegTypeBus:
            return [NSString stringWithFormat:@"Bus %@", [lineCode uppercaseString]];
        case LegTypeTram:
            return [NSString stringWithFormat:@"Tram %@", [lineCode uppercaseString]];
        case LegTypeTrain:
            return [NSString stringWithFormat:@"Train %@", [lineCode uppercaseString]];
        case LegTypeLongDistanceTrain:
            return [NSString stringWithFormat:@"Long distance train %@", [lineCode uppercaseString]];
        case LegTypeAirplane:
            return [NSString stringWithFormat:@"Flight %@", [lineCode uppercaseString]];
        case LegTypeFerry:
            return @"Ferry";
        case LegTypeMetro:
            return @"Metro";
        case LegTypeWalk:
            return @"Walk";
        case LegTypeBicycle:
            return @"City Bike";
            
        default:
            return [lineCode uppercaseString];
            break;
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
    }else if (lineType == LineTypeLongDistanceTrain) {
        return LegTypeLongDistanceTrain;
    }else if (lineType == LineTypeAirplane) {
        return LegTypeAirplane;
    }else if (lineType == LineTypeBicycle) {
        return LegTypeBicycle;
    }else{
        return LegTypeOther;
    }
}

+(NSString *)dayNameForWeekDay:(WeekDay)weekDay{
    if (weekDay == WeekDayMonday) {
        return @"Monday";
    }else if (weekDay == WeekDayTuesday) {
        return @"Tuesday";
    }else if (weekDay == WeekDayWedensday) {
        return @"Wedensday";
    }else if (weekDay == WeekDayThursday) {
        return @"Thursday";
    }else if (weekDay == WeekDayFriday) {
        return @"Friday";
    }else if (weekDay == WeekDaySaturday) {
        return @"Saturday";
    }else {
        return @"Sunday";
    }
}

+(NSString *)shortDayNameForWeekDay:(WeekDay)weekDay{
    if (weekDay == WeekDayMonday) {
        return @"Mon";
    }else if (weekDay == WeekDayTuesday) {
        return @"Tue";
    }else if (weekDay == WeekDayWedensday) {
        return @"Wed";
    }else if (weekDay == WeekDayThursday) {
        return @"Thu";
    }else if (weekDay == WeekDayFriday) {
        return @"Fri";
    }else if (weekDay == WeekDaySaturday) {
        return @"Sat";
    }else {
        return @"Sun";
    }
}

+(WeekDay)weekDayForDayName:(NSString *)dayName{
    if ([[dayName lowercaseString]  isEqual: @"monday"]) {
        return WeekDayMonday;
    }else if ([[dayName lowercaseString]  isEqual: @"tuesday"]) {
        return WeekDayTuesday;
    }else if ([[dayName lowercaseString]  isEqual: @"wedensday"]) {
        return WeekDayWedensday;
    }else if ([[dayName lowercaseString]  isEqual: @"thursday"]) {
        return WeekDayThursday;
    }else if ([[dayName lowercaseString]  isEqual: @"friday"]) {
        return WeekDayFriday;
    }else if ([[dayName lowercaseString]  isEqual: @"saturday"]) {
        return WeekDaySaturday;
    }else {
        return WeekDaySunday;
    }
}

//Digi transitType
+ (LineType)lineTypeForDigiLineType:(NSString *)trasportType {
    if (!trasportType) return LineTypeBus;
    
    if ([trasportType.uppercaseString isEqualToString:@"BUS"] ||
        [trasportType.uppercaseString isEqualToString:@"BUSISH"]) {
        return LineTypeBus;
    }else if ([trasportType.uppercaseString isEqualToString:@"RAIL"] ||
              [trasportType.uppercaseString isEqualToString:@"TRAINISH"] ||
              [trasportType.uppercaseString isEqualToString:@"FUNICULAR"]) {
        return LineTypeTrain;
    }else if ([trasportType.uppercaseString isEqualToString:@"TRAM"]) {
        return LineTypeTram;
    }else if ([trasportType.uppercaseString isEqualToString:@"SUBWAY"]) {
        return LineTypeMetro;
    }else if ([trasportType.uppercaseString isEqualToString:@"AIRPLANE"]) {
        return LineTypeAirplane;
    }else if ([trasportType.uppercaseString isEqualToString:@"FERRY"] ||
              [trasportType.uppercaseString isEqualToString:@"GONDOLA"]) {
        return LineTypeFerry;
    }else if ([trasportType.uppercaseString isEqualToString:@"WALK"]) {
        return LineTypeOther;
    }else if ([trasportType.uppercaseString isEqualToString:@"BICYCLE"]) {
        return LineTypeBicycle;
    }else {
        return LineTypeBus;
    }
}

+ (LegTransportType)legTypeForDigiTrasportType:(NSString *)trasportType {
    if ([trasportType.uppercaseString isEqualToString:@"WALK"]) {
        return LegTypeWalk;
    }
    
    LineType lineType = [EnumManager lineTypeForDigiLineType:trasportType];
    return [EnumManager legTrasportTypeForLineType:lineType];
}

+ (BOOL)isNearbyStopAnnotationType:(ReittiAnnotationType)annotType {
    if (annotType == NearByBusStopType ||
        annotType == NearByTramStopType ||
        annotType == NearByTrainStopType ||
        annotType == NearByMetroStopType ||
        annotType == NearByFerryStopType ||
        annotType == NearByAirportType) {
        return YES;
    } else {
        return NO;
    }
}

+ (ReittiAnnotationType)annotTypeForStopType:(StopType)stopType {
    switch (stopType) {
        case StopTypeBus: return NearByBusStopType;
        case StopTypeTram: return NearByTramStopType;
        case StopTypeTrain: return NearByTrainStopType;
        case StopTypeMetro: return NearByMetroStopType;
        case StopTypeFerry: return NearByFerryStopType;
        case StopTypeAirport: return NearByAirportType;
        case StopTypeBikeStation: return BikeStationLocation;
        default: return NearByBusStopType;
    }
}

+(BOOL)isAnnotationType:(ReittiAnnotationType)firstType sameAsAnnotaionType:(ReittiAnnotationType)secondType {
    if (firstType == AllNearByStopType) {
        return [self isNearbyStopAnnotationType:secondType];
    }
    
    if (secondType == AllNearByStopType) {
        return [self isNearbyStopAnnotationType:firstType];
    }
    
    
    
    return firstType == secondType;
}

@end
