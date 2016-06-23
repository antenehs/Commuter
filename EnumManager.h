//
//  EnumManager.h
//  
//
//  Created by Anteneh Sahledengel on 15/6/15.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
    StopTypeBus = 0,
    StopTypeTram = 1,
    StopTypeTrain = 2,
    StopTypeMetro = 3,
    StopTypeFerry = 4,
    StopTypeOther = 5,
    StopTypeAirport = 6,
    StopTypeBikeStation = 7
} StopType;

typedef enum
{
    VehicleTypeTram = 0,
    VehicleTypeTrain = 1,
    VehicleTypeMetro = 2,
    VehicleTypeBus = 3,
    VehicleTypeLongDistanceTrain = 4,
    VehicleTypeFerry = 5,
    VehicleTypeOther = 6,
    VehicleTypeAirplane = 7
} VehicleType;

typedef enum{
    LineTypeBus = 0,
    LineTypeTram = 1,
    LineTypeTrain = 2,
    LineTypeMetro = 3,
    LineTypeFerry = 4,
    LineTypeOther = 5,
    LineTypeLongDistanceTrain = 6,
    LineTypeAirplane = 7,
    LineTypeBicycle = 8
}LineType;

typedef enum
{
    LegTypeWalk = 1,
    LegTypeBus = 2,
    LegTypeTrain = 3,
    LegTypeMetro = 4,
    LegTypeTram = 5,
    LegTypeFerry = 6,
    LegTypeService = 7,
    LegTypeOther = 8,
    LegTypeLongDistanceTrain = 10,
    LegTypeAirplane = 11,
    LegTypeBicycle = 12
    
} LegTransportType;

typedef enum
{
    WeekDayMonday = 1,
    WeekDayTuesday = 2,
    WeekDayWedensday = 3,
    WeekDayThursday = 4,
    WeekDayFriday = 5,
    WeekDaySaturday = 6,
    WeekDaySunday = 7
} WeekDay;

@interface EnumManager : NSObject

+(StopType)stopTypeForGDTypeString:(NSString *)type;
+(StopType)stopTypeForPubTransStopType:(NSString *)type;
+(StopType)stopTypeFromLegType:(LegTransportType)type;

+(VehicleType)vehicleTypeForTypeName:(NSString *)type;
+(VehicleType)vehicleTypeForLineType:(LineType)lineType;

+(LineType)lineTypeForHSLLineTypeId:(NSString *)type;
+(LineType)lineTypeForVehicleType:(VehicleType)vehicleType;
+(LineType)lineTypeForStopType:(StopType)stopType;

+(LegTransportType)legTrasportTypeForLineType:(LineType)lineType;

+(NSString *)dayNameForWeekDay:(WeekDay)weekDay;
+(NSString *)shortDayNameForWeekDay:(WeekDay)weekDay;
+(WeekDay)weekDayForDayName:(NSString *)dayName;

+ (LineType)lineTypeForMatkaTrasportType:(NSNumber *)trasportType;
+ (LegTransportType)legTypeForMatkaTrasportType:(NSNumber *)trasportType;

+ (LineType)lineTypeForDigiLineType:(NSString *)trasportType;
+ (LegTransportType)legTypeForDigiTrasportType:(NSString *)trasportType;

@end
