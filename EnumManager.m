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

//Matka Api stuff
+ (LineType)lineTypeForMatkaTrasportType:(NSNumber *)trasportType {
    if (!trasportType) return LineTypeBus;
    NSArray *busTypes = @[@1, @8, @9, @10, @11, @15, @16, @17, @19, @21, @23, @25, @27, @28, @29
                          , @31, @32, @33, @34, @35, @37, @38, @39, @42, @43, @44, @45, @48
                          , @49, @50, @51, @52, @53, @54, @55, @56, @57, @58, @59, @60, @61
                          , @62, @63, @64, @65, @66, @67, @68, @69, @70];
    
    NSArray *trainTypes = @[@7, @12, @13, @46];
    NSArray *longdistanceTrainTypes = @[@2, @3, @4, @5, @6, @14, @47];
    NSArray *metroTypes = @[@40];
    NSArray *tramTypes = @[@36];
    NSArray *ferryTypes = @[@41];
    NSArray *airplaneTypes = @[@26];
    NSArray *otherTypes = @[@18, @30];
    
    if ([busTypes containsObject:trasportType]) {
        return LineTypeBus;
    } else if ([trainTypes containsObject:trasportType]) {
        return LineTypeTrain;
    } else if ([longdistanceTrainTypes containsObject:trasportType]) {
        return LineTypeLongDistanceTrain;
    } else if ([metroTypes containsObject:trasportType]) {
        return LineTypeMetro;
    } else if ([tramTypes containsObject:trasportType]) {
        return LineTypeTram;
    } else if ([ferryTypes containsObject:trasportType]) {
        return LineTypeFerry;
    } else if ([airplaneTypes containsObject:trasportType]) {
        return LineTypeAirplane;
    } else if ([otherTypes containsObject:trasportType])  {
        return LineTypeOther;
    } else {
        return LineTypeOther;
    }
}

+ (LegTransportType)legTypeForMatkaTrasportType:(NSNumber *)trasportType {
    LineType lineType = [EnumManager lineTypeForMatkaTrasportType:trasportType];
    return [EnumManager legTrasportTypeForLineType:lineType];
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

@end
