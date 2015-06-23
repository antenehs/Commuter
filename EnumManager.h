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
    StopTypeOther = 5
} StopType;

typedef enum
{
    VehicleTypeTram = 0,
    VehicleTypeTrain = 1,
    VehicleTypeMetro = 2,
    VehicleTypeBus = 3,
    VehicleTypeLongDistanceTrain = 4,
    VehicleTypeFerry = 5,
    VehicleTypeOther = 6
} VehicleType;

typedef enum{
    LineTypeBus = 0,
    LineTypeTram = 1,
    LineTypeTrain = 2,
    LineTypeMetro = 3,
    LineTypeFerry = 4,
    LineTypeOther = 5
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
    LegTypeOther = 8
} LegTransportType;

@interface EnumManager : NSObject

+(StopType)stopTypeForGDTypeString:(NSString *)type;
+(StopType)stopTypeForPubTransStopType:(NSString *)type;
+(StopType)stopTypeFromLegType:(LegTransportType)type;

+(VehicleType)vehicleTypeForTypeName:(NSString *)type;
+(VehicleType)vehicleTypeForLineType:(LineType)lineType;

+(LineType)lineTypeForHSLLineTypeId:(NSString *)type;
+(LineType)lineTypeForVehicleType:(VehicleType)vehicleType;

+(LegTransportType)legTrasportTypeForLineType:(LineType)lineType;

@end
