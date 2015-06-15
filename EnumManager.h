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

@interface EnumManager : NSObject

+(StopType)stopTypeForGDTypeString:(NSString *)type;
+(StopType)stopTypeForPubTransStopType:(NSString *)type;

@end
