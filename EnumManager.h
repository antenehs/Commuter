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
    StopTypeUnknown = 0,
    StopTypeBus = 1,
    StopTypeTram = 2,
    StopTypeTrain = 3,
    StopTypeMetro = 4,
    StopTypeFerry = 5,
    StopTypeOther = 6,
    StopTypeAirport = 7,
    StopTypeBikeStation = 8
} StopType;

typedef enum
{
    VehicleTypeUnknown = 0,
    VehicleTypeTram = 1,
    VehicleTypeTrain = 2,
    VehicleTypeMetro = 3,
    VehicleTypeBus = 4,
    VehicleTypeLongDistanceTrain = 5,
    VehicleTypeFerry = 6,
    VehicleTypeOther = 7,
    VehicleTypeAirplane = 8
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

typedef enum {
    WeekDayMonday = 1,
    WeekDayTuesday = 2,
    WeekDayWedensday = 3,
    WeekDayThursday = 4,
    WeekDayFriday = 5,
    WeekDaySaturday = 6,
    WeekDaySunday = 7
} WeekDay;

//typedef enum {
//    NearByBusStopType = 11,
//    NearByTramStopType = 12,
//    NearByTrainStopType = 13,
//    NearByMetroStopType = 14,
//    NearByFerryStopType = 15,
//    NearByAirportType = 16,
//    SearchedStopType = 2,
//    GeoCodeType = 3,
//    DroppedPinType = 4,
//    LiveVehicleType = 5,
//    BikeStationType = 6,
//    FavouriteType = 7,
//    OtherType = 8
//} AnnotationType;

typedef enum {
    DefaultAddressLocation = 0,
    StartLocation = 1,
    SearchedStopType = 2,
    GeoCodeType = 3,
    DroppedPinType = 4,
    OtherStopLocation = 5,
    BikeStationLocation = 6,
    FavouriteType = 7,
    SalesPointAnnotationType = 8,
    LiveVehicleAnnotationType = 9,
    AllNearByStopType = 10,
    NearByBusStopType = 11,
    NearByTramStopType = 12,
    NearByTrainStopType = 13,
    NearByMetroStopType = 14,
    NearByFerryStopType = 15,
    NearByAirportType = 16,
    DestinationLocation = 17,
    StopLocation = 18,
    TransferStopLocation = 19,
    ServicePointAnnotationType = 20,
} ReittiAnnotationType;

typedef enum {
    LocationTypeUnknown = 0,
    LocationTypePOI = 1,
    LocationTypeAddress = 2,
    LocationTypeStop = 3,
    LocationTypeDroppedPin = 10,
    LocationTypeContact = 550
} LocationType;

@interface EnumManager : NSObject

+(StopType)stopTypeForGDTypeString:(NSString *)type;
+(StopType)stopTypeForPubTransStopType:(NSString *)type;
+(StopType)stopTypeFromLegType:(LegTransportType)type;
+(StopType)stopTypeFromLineType:(LineType)lineType;

+(VehicleType)vehicleTypeForTypeName:(NSString *)type;
+(VehicleType)vehicleTypeForLineType:(LineType)lineType;

+(LineType)lineTypeForHSLLineTypeId:(NSString *)type;
+(LineType)lineTypeForVehicleType:(VehicleType)vehicleType;
+(LineType)lineTypeForStopType:(StopType)stopType;

+(LegTransportType)legTrasportTypeForLineType:(LineType)lineType;
+(NSString *)lineDisplayName:(LegTransportType)legType forLineCode:(NSString *)lineCode;

+(NSString *)dayNameForWeekDay:(WeekDay)weekDay;
+(NSString *)shortDayNameForWeekDay:(WeekDay)weekDay;
+(WeekDay)weekDayForDayName:(NSString *)dayName;

+(LineType)lineTypeForDigiLineType:(NSString *)trasportType;
+(LegTransportType)legTypeForDigiTrasportType:(NSString *)trasportType;

//Annot type methods
+(BOOL)isNearbyStopAnnotationType:(ReittiAnnotationType)annotType;
+(ReittiAnnotationType)annotTypeForNearbyStopType:(StopType)stopType;
+(BOOL)isAnnotationType:(ReittiAnnotationType)firstType sameAsAnnotaionType:(ReittiAnnotationType)secondType;

@end
